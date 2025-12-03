import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class AuthService{
  static final supabase = Supabase.instance.client;

  //login
  static Future<void> signIn(String email,String password) async {
    await supabase.auth.signInWithPassword(
      email:email.trim(),
      password: password.trim(),
    );
  }

  //signup +create profile
  static Future<void> signUp({
    required String fullName,
    required String email,
    required String phone,
    required String regNumber,
    required String role,
    required String password,
  }) async {
    final AuthResponse response = await supabase.auth.signUp(
      email: email.trim(),
      password: password.trim(),
    );
    final user = response.user;
    if (user == null) throw Exception("Signup failed - user null");
    final newProfile = UserModel(
      id:user.id,
      fullName:fullName.trim(),
      email:email.trim(),
      phoneNumber: phone.trim(),
      regNumber: regNumber.trim(),
      role:role,
    );

    await supabase.from('profiles').insert({
      'id':user.id,
      ...newProfile.toSupabaseMap(),
    });
  }
  //Logout
  static Future<void> signOut() async{
    await supabase.auth.signOut();
  }
}