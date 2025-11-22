import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:westigov2/models/facility.dart';

class FacilityService {
  final SupabaseClient _supabase;

  // Dependency injection via constructor allows for easier testing
  FacilityService(this._supabase);

  /// Fetches all facilities from Supabase
  Future<List<Facility>> getFacilities() async {
    try {
      final response = await _supabase
          .from('facilities')
          .select()
          .order('name', ascending: true);

      // Map the list of JSON objects to a list of Facility objects
      return (response as List)
          .map((json) => Facility.fromJson(json))
          .toList();
    } catch (e) {
      // In a real app, we might log this error to a monitoring service
      print('Error fetching facilities: $e');
      rethrow;
    }
  }

  /// Search facilities by name (Simple ILIKE search for now)
  Future<List<Facility>> searchFacilities(String query) async {
    try {
      final response = await _supabase
          .from('facilities')
          .select()
          .ilike('name', '%$query%'); // Case-insensitive partial match

      return (response as List)
          .map((json) => Facility.fromJson(json))
          .toList();
    } catch (e) {
      print('Error searching facilities: $e');
      rethrow;
    }
  }
}