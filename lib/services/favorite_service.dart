import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:westigov2/models/favorite.dart';

class FavoriteService {
  final SupabaseClient _supabase;

  FavoriteService(this._supabase);

  /// Get all favorites for the current user
  Future<List<Favorite>> getUserFavorites(String userId) async {
    final response = await _supabase
        .from('favorites')
        .select()
        .eq('user_id', userId);

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
    await _supabase
        .from('favorites')
        .delete()
        .match({
          'user_id': userId,
          'favoritable_type': type,
          'favoritable_id': id,
        });
  }
}