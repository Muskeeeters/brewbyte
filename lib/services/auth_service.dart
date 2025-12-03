import 'package:supabase_flutter/supabase_flutter.dart';
class AuthServices{
  final SupabaseClient supabase = Supabase.instance.client;

  Future<String?> signUp({
    required String email,
    required String fullName,
    required String password,
    required String phone,
    required String regNumber,
    required String role,
  }) async {
    final response = await supabase.auth.signUp(email:email,password: password,);
    if (response.user != null) {
      final userId = response.user!.id;
      final insertResponse = await supabase.from('profiles').insert({
        'id'
      })
    }
  }
}