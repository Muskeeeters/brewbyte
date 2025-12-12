import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import 'auth_service.dart'; // For AuthFailure exception re-use if needed, or define new one.

class UserService {
  static final supabase = Supabase.instance.client;

  // 1. Fetch Self Profile
  static Future<UserModel> fetchSelfProfile(String userId) async {
    try {
      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      
      return UserModel.fromJson(data);
    } catch (e) {
      throw Exception('Failed to fetch profile: $e');
    }
  }

  // 2. Fetch All Profiles (Manager Only - logic handled in UI/Router guards, here data access only)
  static Future<List<UserModel>> fetchAllProfiles() async {
    try {
      // Supabase returns a List<Map<String, dynamic>>
      final List<dynamic> data = await supabase
          .from('profiles')
          .select()
          .order('full_name', ascending: true);

      return data.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch all profiles: $e');
    }
  }

  // 3. Update User Role (Manager Only)
  static Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await supabase
          .from('profiles')
          .update({'role': newRole})
          .eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }

  // 4. Update Self Profile (Name, Phone)
  static Future<void> updateSelfProfile({
    required String userId,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      await supabase.from('profiles').update({
        'full_name': fullName,
        'phone_number': phoneNumber,
      }).eq('id', userId);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}
