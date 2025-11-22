import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:westigov2/models/space.dart';

class SpaceService {
  final SupabaseClient _supabase;

  SpaceService(this._supabase);

  /// Fetch spaces belonging to a specific facility
  Future<List<Space>> getSpacesByFacility(int facilityId) async {
    final response = await _supabase
        .from('spaces')
        .select()
        .eq('parent_facility_id', facilityId)
        .order('name', ascending: true);

    return (response as List).map((json) => Space.fromJson(json)).toList();
  }

  /// Search spaces globally (for the search tab)
  Future<List<Space>> searchSpaces(String query) async {
    final response = await _supabase
        .from('spaces')
        .select()
        .ilike('name', '%$query%');

    return (response as List).map((json) => Space.fromJson(json)).toList();
  }
}