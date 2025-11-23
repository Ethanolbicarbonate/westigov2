import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:westigo/models/facility.dart';
import 'package:westigo/models/space.dart';
import 'package:westigo/providers/auth_provider.dart';
import 'package:westigo/providers/facility_provider.dart';
import 'package:westigo/services/space_service.dart';

// Provider for SpaceService
final spaceServiceProvider = Provider<SpaceService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SpaceService(supabase);
});

// Provider to fetch ALL spaces
final allSpacesProvider = FutureProvider<List<Space>>((ref) async {
  final service = ref.read(spaceServiceProvider);
  return await service.getAllSpaces();
});

// Search Query State
final searchQueryProvider = StateProvider<String>((ref) => '');

// The Result Object (Polymorphic)
class SearchResult {
  final String name;
  final String? description;
  final String type; // 'Facility' or 'Space'
  final dynamic originalObject; // The Facility or Space object

  SearchResult({
    required this.name,
    this.description,
    required this.type,
    required this.originalObject,
  });
}

// The Filtered Results Provider
final searchResultsProvider = Provider<List<SearchResult>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase();
  
  // If query is empty, return nothing
  if (query.isEmpty) return [];

  // Get Data
  final facilities = ref.watch(facilitiesProvider).asData?.value ?? [];
  final spaces = ref.watch(allSpacesProvider).asData?.value ?? [];

  List<SearchResult> results = [];

  // 1. Filter Facilities
  for (var f in facilities) {
    // Simple contains + Fuzzy score
    bool nameMatch = f.name.toLowerCase().contains(query);
    // Calculate similarity (0.0 to 1.0)
    double score = f.name.similarityTo(query);
    
    if (nameMatch || score > 0.3) { // 0.3 is a loose threshold
      results.add(SearchResult(
        name: f.name,
        description: f.description,
        type: 'Facility',
        originalObject: f,
      ));
    }
  }

  // 2. Filter Spaces
  for (var s in spaces) {
    bool nameMatch = s.name.toLowerCase().contains(query);
    double score = s.name.similarityTo(query);

    if (nameMatch || score > 0.3) {
      results.add(SearchResult(
        name: s.name,
        description: s.description,
        type: 'Space',
        originalObject: s,
      ));
    }
  }

  return results;
});