import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:westigo/models/facility.dart';

class FacilityService {
  final SupabaseClient _supabase;

  FacilityService(this._supabase);

  /// Fetches all facilities from Supabase
  Future<List<Facility>> getFacilities() async {
    try {
      final response = await _supabase
          .from('facilities')
          .select()
          .order('name', ascending: true);

      // Map the list of JSON objects to a list of Facility objects
      final facilities = (response as List)
          .map((json) => Facility.fromJson(json))
          .toList();
      
      return facilities;
    } catch (e) {
      // Log error
      print('Error fetching facilities: $e');
      // Return empty list or rethrow depending on how you want to handle it
      // For now, rethrow so the UI knows something went wrong
      rethrow;
    }
  }

  /// Search facilities by name
  Future<List<Facility>> searchFacilities(String query) async {
    try {
      final response = await _supabase
          .from('facilities')
          .select()
          .ilike('name', '%$query%'); 

      return (response as List)
          .map((json) => Facility.fromJson(json))
          .toList();
    } catch (e) {
      print('Error searching facilities: $e');
      rethrow;
    }
  }

  /// Fetch single facility by ID
  Future<Facility?> getFacilityById(int id) async {
    try {
      final response = await _supabase
          .from('facilities')
          .select()
          .eq('id', id)
          .single();
      return Facility.fromJson(response);
    } catch (e) {
      return null;
    }
  }
}