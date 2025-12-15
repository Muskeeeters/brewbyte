import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  static final supabase = Supabase.instance.client;

  // ... (Existing getCurrentProfile function) ...
  static Future<UserModel?> getCurrentProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;
      final data = await supabase.from('profiles').select().eq('id', user.id).single();
      return UserModel.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  // ... (Existing signIn function) ...
  static Future<UserModel> signIn(String email, String password) async {
    try {
      await supabase.auth.signInWithPassword(email: email.trim(), password: password.trim());
      final user = await getCurrentProfile();
      if (user == null) throw Exception("Profile not found");
      return user;
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw AuthFailure('Login failed: ${e.toString()}');
    }
  }

  // ... (Existing signUp function) ...
  static Future<void> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String regNumber,
    required String role,
    required String password,
  }) async {
    try {
      final AuthResponse response = await supabase.auth.signUp(
        email: email.trim(),
        password: password.trim(),
      );
      final user = response.user;
      if (user == null) throw AuthFailure("Signup successful but user is null.");

      final newProfile = UserModel(
        id: user.id,
        fullName: fullName.trim(),
        email: email.trim(),
        phoneNumber: phone.trim(),
        regNumber: regNumber.trim(),
        role: role,
        imageUrl: null, 
      );
      await supabase.from('profiles').insert(newProfile.toJson());
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw AuthFailure('Signup failed: ${e.toString()}');
    }
  }

  // ... (Existing signOut function) ...
  static Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      throw AuthFailure('Logout failed');
    }
  }

  // ⭐ NEW FUNCTION: Send Password Reset Email ⭐
  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email.trim());
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw AuthFailure('Failed to send reset email');
    }
  }
  // ... baaki functions ...

  // ⭐ 5. Update Password (Logged In User ke liye)
  static Future<void> updatePassword(String newPassword) async {
    try {
      await supabase.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw AuthFailure('Password update failed');
    }
  }
}


class AuthFailure implements Exception {
  final String message;
  const AuthFailure(this.message);
  @override
  String toString() => message;
}