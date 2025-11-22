import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:westigov2/models/event.dart';

class EventService {
  final SupabaseClient _supabase;

  EventService(this._supabase);

  /// Fetch upcoming events
  Future<List<Event>> getUpcomingEvents() async {
    final response = await _supabase
        .from('events')
        .select()
        .gte('end_date', DateTime.now().toIso8601String()) // Only future events
        .order('start_date', ascending: true);

    return (response as List).map((json) => Event.fromJson(json)).toList();
  }

  // TODO: Implement advanced filtering by Scope (Year/Course) in Phase 5
}