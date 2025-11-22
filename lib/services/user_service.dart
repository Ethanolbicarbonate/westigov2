import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:westigov2/models/user_profile.dart';

class UserService {
  final SupabaseClient _supabase;

  UserService(this._supabase);

  /// Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('id', userId)
          .single();
      
      return UserProfile.fromJson(response);
    } catch (e) {
      print('Error fetching user profile: $e');
      return null;
    }
  }

  /// Update user profile
  Future<void> updateUserProfile(UserProfile profile) async {
    await _supabase.from('users').update({
      'first_name': profile.firstName,
      'last_name': profile.lastName,
      'course': profile.course,
      'year_level': profile.yearLevel,
      'profile_picture_url': profile.profilePictureUrl,
    }).eq('id', profile.id);
  }
}