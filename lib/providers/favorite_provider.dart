import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:westigov2/models/favorite.dart';
import 'package:westigov2/providers/auth_provider.dart';
import 'package:westigov2/services/favorite_service.dart';
import 'package:westigov2/models/space.dart';
import 'package:westigov2/models/event.dart';

// Service Provider
final favoriteServiceProvider = Provider<FavoriteService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return FavoriteService(supabase);
});

final favoriteSpacesListProvider = FutureProvider<List<Space>>((ref) async {
  final service = ref.read(favoriteServiceProvider);
  final authState = ref.read(authServiceProvider);
  final userId = authState.currentUserId;

  if (userId == null) return [];

  // We depend on the main favorites list changing to re-fetch this details list
  // So we watch userFavoritesProvider to trigger a refresh when IDs change
  ref.watch(userFavoritesProvider);

  return await service.getFavoriteSpaces(userId);
});

// User Favorites List Provider
// We use StateNotifier to optimistically update the UI (add/remove instantly)
class FavoriteNotifier extends StateNotifier<AsyncValue<List<Favorite>>> {
  final FavoriteService _service;
  final String? _userId;

  FavoriteNotifier(this._service, this._userId)
      : super(const AsyncValue.loading()) {
    if (_userId != null) {
      _fetchFavorites();
    } else {
      state = const AsyncValue.data([]);
    }
  }

  Future<void> _fetchFavorites() async {
    try {
      final favorites = await _service.getUserFavorites(_userId!);
      state = AsyncValue.data(favorites);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleFavorite(String type, int id) async {
    if (_userId == null) return;

    final currentList = state.value ?? [];
    final exists = currentList
        .any((f) => f.favoritableType == type && f.favoritableId == id);

    // Optimistic Update
    if (exists) {
      // Remove immediately from UI
      state = AsyncValue.data(currentList
          .where((f) => !(f.favoritableType == type && f.favoritableId == id))
          .toList());
      try {
        await _service.removeFavorite(_userId, type, id);
      } catch (e) {
        // Revert if failed
        _fetchFavorites();
      }
    } else {
      // Add immediately to UI (with temp ID)
      final newFav = Favorite(
          id: -1, userId: _userId, favoritableType: type, favoritableId: id);
      state = AsyncValue.data([...currentList, newFav]);
      try {
        await _service.addFavorite(_userId, type, id);
        // Fetch again to get real ID
        _fetchFavorites();
      } catch (e) {
        // Revert
        _fetchFavorites();
      }
    }
  }
}

final userFavoritesProvider =
    StateNotifierProvider<FavoriteNotifier, AsyncValue<List<Favorite>>>((ref) {
  final service = ref.read(favoriteServiceProvider);
  final authState = ref.watch(authServiceProvider);
  // Note: This depends on the AuthService having a currentUserId getter working
  return FavoriteNotifier(service, authState.currentUserId);
});

// Helper to check specific status
final isFavoriteProvider =
    Provider.family<bool, Tuple2<String, int>>((ref, params) {
  final favorites = ref.watch(userFavoritesProvider).asData?.value ?? [];
  return favorites.any((f) =>
      f.favoritableType == params.item1 && f.favoritableId == params.item2);
});

// Simple Tuple class if you don't have one (or use a Record in Dart 3)
class Tuple2<T1, T2> {
  final T1 item1;
  final T2 item2;
  Tuple2(this.item1, this.item2);
}

final favoriteEventsListProvider = FutureProvider<List<Event>>((ref) async {
  final service = ref.read(favoriteServiceProvider);
  final authState = ref.read(authServiceProvider);
  final userId = authState.currentUserId;

  if (userId == null) return [];

  // Watch main list for changes
  ref.watch(userFavoritesProvider);

  return await service.getFavoriteEvents(userId);
});
