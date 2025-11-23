// lib/providers/user_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:westigo/models/user_profile.dart';
import 'package:westigo/providers/auth_provider.dart'; // Import this
import 'package:westigo/services/user_service.dart';

final userServiceProvider = Provider<UserService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return UserService(supabase);
});

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final UserService _service;

  UserProfileNotifier(this._service) : super(const AsyncValue.loading()) {
    refresh();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final profile = await _service.getCurrentUserProfile();
      state = AsyncValue.data(profile);
    } catch (e, st) {
      // If user is logged out, getCurrentUserProfile might fail or return null.
      // We handle that gracefully.
      state = AsyncValue.error(e, st);
    }
  }
  
  void updateLocal(UserProfile profile) {
    state = AsyncValue.data(profile);
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  final service = ref.watch(userServiceProvider);
  
  // FIX: Watch the Auth State Changes Stream
  // This forces the provider to rebuild/refresh whenever the user logs in or out
  ref.watch(authStateChangesProvider);
  
  return UserProfileNotifier(service);
});