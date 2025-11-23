import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:westigo/models/user_profile.dart';
import 'dart:io';

class UserService {
  final SupabaseClient _supabase;

  UserService(this._supabase);

  /// Get current user profile
  Future<UserProfile?> getCurrentUserProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final response =
          await _supabase.from('users').select().eq('id', userId).single();

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

  Future<String?> uploadProfilePicture(String userId, File imageFile) async {
    try {
      final fileExt = imageFile.path.split('.').last;
      final fileName =
          '$userId/profile.${DateTime.now().millisecondsSinceEpoch}.$fileExt';

      // Upload to 'profiles' bucket
      await _supabase.storage.from('profiles').upload(
            fileName,
            imageFile,
            fileOptions: const FileOptions(upsert: true),
          );

      // Get Public URL
      final imageUrl =
          _supabase.storage.from('profiles').getPublicUrl(fileName);
      return imageUrl;
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  /// Remove profile picture
  Future<void> deleteProfilePicture(String userId) async {
    // Note: We ideally should delete the file from Storage bucket too to save space,
    // but finding the exact filename from the URL requires parsing.
    // For MVP, we can just nullify the URL in the database.
    
    // Step 1: Update DB
    await _supabase.from('users').update({
      'profile_picture_url': null,
    }).eq('id', userId);
    
    final list = await _supabase.storage.from('profiles').list(path: userId);
    if (list.isNotEmpty) {
      await _supabase.storage.from('profiles').remove(list.map((f) => '$userId/${f.name}').toList());
    }
  }
}
