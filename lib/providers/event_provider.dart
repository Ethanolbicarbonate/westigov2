import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:westigo/models/event.dart';
import 'package:westigo/providers/auth_provider.dart';
import 'package:westigo/services/event_service.dart';
import 'package:westigo/providers/event_filter_provider.dart';

final eventServiceProvider = Provider<EventService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return EventService(supabase);
});

final eventsProvider = FutureProvider<List<Event>>((ref) async {
  final service = ref.read(eventServiceProvider);
  return await service.getEvents();
});

final filteredEventsProvider = Provider<AsyncValue<List<Event>>>((ref) {
  // 1. Get raw events
  final eventsAsync = ref.watch(eventsProvider);
  
  // 2. Get active filters
  final filters = ref.watch(eventFilterProvider);

  // 3. If loading or error, pass it through
  return eventsAsync.whenData((events) {
    // If no filters, return all
    if (!filters.hasFilters) return events;

    // Filter Logic
    return events.where((event) {
      // "All Students" always shows
      if (event.scopes.contains('All Students')) return true;

      bool matchesYear = false;
      bool matchesCollege = false;

      // Check Year Filters
      if (filters.selectedYears.isNotEmpty) {
        for (var year in filters.selectedYears) {
          if (event.scopes.contains(year)) {
            matchesYear = true;
            break;
          }
        }
      } else {
        // If no year filters selected, we treat it as "match any year" 
        // UNLESS college filters are set. This depends on desired logic.
        // Usually: (YearMatch OR NoYearFilters) AND (CollegeMatch OR NoCollegeFilters)
        matchesYear = true; 
      }

      // Check College Filters
      if (filters.selectedColleges.isNotEmpty) {
        for (var college in filters.selectedColleges) {
          if (event.scopes.contains(college)) {
            matchesCollege = true;
            break;
          }
        }
      } else {
        matchesCollege = true;
      }
      
      // However, if we follow the simple "OR" logic across all tags:
      // If I select "1st Year", I want 1st year events.
      // If I select "CICT", I want CICT events.
      // If I select BOTH, do I want "1st Year CICT students only" (AND) or "Anyone who is 1st Year OR anyone in CICT" (OR)?
      
      // Let's implement strict inclusive logic (Has ANY of the selected tags)
      // BUT keep "All Students" visibility.
      
      bool hasSelectedYear = false;
      for (var y in filters.selectedYears) {
        if (event.scopes.contains(y)) hasSelectedYear = true;
      }
      
      bool hasSelectedCollege = false;
      for (var c in filters.selectedColleges) {
        if (event.scopes.contains(c)) hasSelectedCollege = true;
      }

      // If user selected ONLY years, check years.
      if (filters.selectedYears.isNotEmpty && filters.selectedColleges.isEmpty) {
        return hasSelectedYear;
      }
      // If user selected ONLY colleges, check colleges.
      if (filters.selectedColleges.isNotEmpty && filters.selectedYears.isEmpty) {
        return hasSelectedCollege;
      }
      // If user selected BOTH, it usually implies intersection for audience targeting 
      // e.g. "1st Year CICT" event should show if I filter "1st Year" + "CICT".
      // But a "1st Year Nursing" event should NOT show if I filter "1st Year" + "CICT" (maybe?).
      
      // Simpler approach for Phase 5: Show if it matches ANY selected filter.
      return hasSelectedYear || hasSelectedCollege;
    }).toList();
  });
});