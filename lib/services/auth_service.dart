import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService {
  static final supabase = Supabase.instance.client;

  // 1. Get Current Profile (Centralized Logic)
  static Future<UserModel?> getCurrentProfile() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) return null;

      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', user.id)
          .single();

      return UserModel.fromJson(data);
    } catch (e) {
      print("Error fetching profile: $e");
      return null;
    }
  }

  // 2. Login
  static Future<UserModel> signIn(String email, String password) async {
    try {
      await supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password.trim(),
      );
      
      // Login ke baad profile fetch karo
      final user = await getCurrentProfile();
      if (user == null) throw Exception("User profile not found in database.");
      
      return user;
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } catch (e) {
      throw AuthFailure('Login failed: ${e.toString()}');
    }
  }

  // 3. Sign Up
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

      // Naya Profile banao (including image_url as null initially)
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

  // 4. Logout
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