import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:westigov2/models/event.dart';

class EventService {
  final SupabaseClient _supabase;

  EventService(this._supabase);

  /// Fetch upcoming events
  /// Note: We join with 'spaces' and 'facilities' to get location names if possible,
  /// but for this phase we focus on getting the raw event data first.
  /// 
  /// To get the Space Name:
  /// We can use Supabase's select syntax: select('*, spaces(name)')
  Future<List<Event>> getEvents() async {
    try {
      final response = await _supabase
          .from('events')
          .select('*, spaces(name)') // Join to get space name if location_id exists
          .gte('end_date', DateTime.now().toIso8601String()) // Only future events
          .order('start_date', ascending: true);

      // Note: Our Event model doesn't currently store "locationName" from the join.
      // We will parse the standard fields now.
      // If you want to show the location name in the card without fetching it separately,
      // we might need to extend the Event model or handle it in the UI via SpaceService.
      // For now, let's just get the basic event list working.

      return (response as List).map((json) => Event.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching events: $e');
      rethrow;
    }
  }

  /// Get events filtered by scope (Client-side filtering for simplicity first)
  Future<List<Event>> getEventsByScope(List<String> userScopes) async {
    // 1. Fetch all upcoming
    final allEvents = await getEvents();

    // 2. Filter in Dart
    // Logic: Keep event IF it has "All Students" OR matches any userScope
    return allEvents.where((event) {
      if (event.scopes.contains('All Students')) return true;
      for (var scope in userScopes) {
        if (event.scopes.contains(scope)) return true;
      }
      return false;
    }).toList();
  }
}