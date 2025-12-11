import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  static final supabase = Supabase.instance.client;

  // Login
  static Future<UserModel> signIn(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      final user = response.user;
      if (user == null) {
        throw Exception("Login succeeded but user data is missing.");
      }

      // Fetch Profile
      // Using 'maybeSingle' to handle potential missing profile gracefully or 'single' to enforce it.
      // Given we want to fail if no profile, 'single' is better, but 'maybeSingle' allows checking null.
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();
      
      return UserModel.fromJson(data);
    } on AuthException catch (e) {
      print("AuthService: AuthException: ${e.message}");
      throw AuthFailure(e.message);
    } on PostgrestException catch (e) {
      print("AuthService: PostgrestException: ${e.message}");
      throw AuthFailure("Profile fetch failed: ${e.message}");
    } catch (e) {
      print("AuthService: Generic Exception: $e");
      throw AuthFailure('Login failed: ${e.toString()}');
    }
  }

  // Sign up + Create Profile
  static Future<void> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String regNumber,
    required String role,
    required String password,
  }) async {
    print('Attempting signUp with Email: $email and Password Length: ${password.length}');
    try {
      final AuthResponse response = await supabase.auth.signUp(
        email: email.trim(),
        password: password.trim(),
      );
      
      final user = response.user;
      if (user == null) {
        throw AuthFailure("Signup successful but user not returned.");
      }

      final newProfile = UserModel(
        id: user.id, // Explicitly linking the ID
        fullName: fullName.trim(),
        email: email.trim(),
        phoneNumber: phone.trim(),
        regNumber: regNumber.trim(),
        role: role,
      );

      await supabase.from('profiles').insert(newProfile.toJson());
      
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw AuthFailure('Signup failed: ${e.toString()}');
    }
  }

  // Logout
  static Future<void> signOut() async {
    try {
      await supabase.auth.signOut();
    } catch (e) {
      throw AuthFailure('Logout failed: ${e.toString()}');
    }
  }
}

class AuthFailure implements Exception {
  final String message;
  const AuthFailure(this.message);

  @override
  String toString() => message;
}
