import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:westigov2/models/user_profile.dart';
import 'package:westigov2/providers/auth_provider.dart';
import 'package:westigov2/services/user_service.dart';

final userServiceProvider = Provider<UserService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return UserService(supabase);
});

// We use a FutureProvider for initial fetch, but a StateNotifier might be better
// if we want to update it locally immediately after editing. 
// Let's use a simpler StateNotifier that fetches on init.

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
      state = AsyncValue.error(e, st);
    }
  }
  
  // Optimistic update
  void updateLocal(UserProfile profile) {
    state = AsyncValue.data(profile);
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  final service = ref.watch(userServiceProvider);
  // Also depend on auth state so we refresh if user changes
  ref.watch(authServiceProvider); 
  return UserProfileNotifier(service);
});