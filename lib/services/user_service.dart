import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

// Database Layer Class
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

  // 2. Fetch All Profiles
  static Future<List<UserModel>> fetchAllProfiles() async {
    try {
      final List<dynamic> data = await supabase
          .from('profiles')
          .select()
          .order('full_name', ascending: true);

      return data.map((json) => UserModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch all profiles: $e');
    }
  }

  // 3. Update User Role
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

  // 4. Update Self Profile (FIXED: Ab ye Image URL accept karega)
  static Future<void> updateSelfProfile({
    required String userId,
    required String fullName,
    required String phoneNumber,
    String? imageUrl, // <--- YE ADD KIYA HAI
  }) async {
    try {
      // Data prepare karein
      final Map<String, dynamic> updates = {
        'full_name': fullName,
        'phone_number': phoneNumber,
      };

      // Agar Image URL aya hai, to usay bhi list mein daalein
      if (imageUrl != null) {
        updates['image_url'] = imageUrl;
      }

      // Supabase ko bhejein
      await supabase.from('profiles').update(updates).eq('id', userId);
      
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }
}