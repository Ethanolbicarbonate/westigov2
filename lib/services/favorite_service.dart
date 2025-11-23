import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:westigo/models/favorite.dart';
import 'package:westigo/models/space.dart';
import 'package:westigo/models/event.dart';

class FavoriteService {
  final SupabaseClient _supabase;

  FavoriteService(this._supabase);

  /// Get all favorites for the current user
  Future<List<Favorite>> getUserFavorites(String userId) async {
    final response =
        await _supabase.from('favorites').select().eq('user_id', userId);

    return (response as List).map((json) => Favorite.fromJson(json)).toList();
  }

  /// Add a favorite
  Future<void> addFavorite(String userId, String type, int id) async {
    await _supabase.from('favorites').insert({
      'user_id': userId,
      'favoritable_type': type,
      'favoritable_id': id,
    });
  }

  /// Remove a favorite
  Future<void> removeFavorite(String userId, String type, int id) async {
    await _supabase.from('favorites').delete().match({
      'user_id': userId,
      'favoritable_type': type,
      'favoritable_id': id,
    });
  }

  Future<List<Space>> getFavoriteSpaces(String userId) async {
    final favResponse = await _supabase
        .from('favorites')
        .select('favoritable_id')
        .eq('user_id', userId)
        .eq('favoritable_type', 'space');

    final ids =
        (favResponse as List).map((r) => r['favoritable_id'] as int).toList();

    if (ids.isEmpty) return [];

    final spacesResponse =
        await _supabase.from('spaces').select().inFilter('id', ids);

    return (spacesResponse as List)
        .map((json) => Space.fromJson(json))
        .toList();
  }

  Future<List<Event>> getFavoriteEvents(String userId) async {
    // 1. Get IDs
    final favResponse = await _supabase
        .from('favorites')
        .select('favoritable_id')
        .eq('user_id', userId)
        .eq('favoritable_type', 'event');

    final ids =
        (favResponse as List).map((r) => r['favoritable_id'] as int).toList();

    if (ids.isEmpty) return [];

    // 2. Fetch events matching IDs
    // Note: We might want location names too, but let's stick to basic fetch for consistency with list
    final eventsResponse =
        await _supabase.from('events').select().inFilter('id', ids);

    return (eventsResponse as List)
        .map((json) => Event.fromJson(json))
        .toList();
  }
}
