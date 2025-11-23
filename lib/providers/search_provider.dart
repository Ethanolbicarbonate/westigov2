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
  final double score; // Relevance score for sorting

  SearchResult({
    required this.name,
    this.description,
    required this.type,
    required this.originalObject,
    this.score = 0.0,
  });
}

// The Filtered Results Provider
final searchResultsProvider = Provider<List<SearchResult>>((ref) {
  final query = ref.watch(searchQueryProvider).trim().toLowerCase();
  
  // If query is empty, return nothing
  if (query.isEmpty) return [];

  // Get Data
  final facilities = ref.watch(facilitiesProvider).asData?.value ?? [];
  final spaces = ref.watch(allSpacesProvider).asData?.value ?? [];

  List<SearchResult> results = [];

  // Helper to calculate relevance score (0.0 to 1.0)
  double getRelevance(String text) {
    final lowerText = text.toLowerCase();
    
    // 1. Exact Match (Highest Priority)
    if (lowerText == query) return 1.0;
    
    // 2. Starts With (High Priority)
    if (lowerText.startsWith(query)) return 0.95;
    
    // 3. Contains word boundary (e.g. "Hall" in "Westigo Hall")
    if (lowerText.contains(' $query')) return 0.9;
    
    // 4. General Contains
    if (lowerText.contains(query)) return 0.85;

    // 5. Fuzzy Matching (Typos & Partial Words)
    // Calculate Dice coefficient
    double score = lowerText.similarityTo(query);
    
    // Boost score if individual words match loosely
    // e.g. "admin bldg" -> "Administration Building"
    final queryWords = query.split(' ');
    if (queryWords.length > 1) {
      int wordMatches = 0;
      final textWords = lowerText.split(' ');
      
      for (var qw in queryWords) {
        if (textWords.any((tw) => tw.startsWith(qw) || tw.similarityTo(qw) > 0.7)) {
          wordMatches++;
        }
      }
      
      // If most words matched, give a good score
      if (wordMatches >= queryWords.length) {
        score = 0.8; 
      } else if (wordMatches > 0) {
        // Boost existing score if at least some words match
        score += (0.1 * wordMatches);
      }
    }

    return score;
  }

  // 1. Filter Facilities
  for (var f in facilities) {
    double score = getRelevance(f.name);
    // Also check description for keywords if name doesn't match well
    if (score < 0.5 && f.description != null) {
        double descScore = getRelevance(f.description!) * 0.5; // Penalty for description match
        if (descScore > score) score = descScore;
    }

    if (score > 0.3) { // Threshold
      results.add(SearchResult(
        name: f.name,
        description: f.description,
        type: 'Facility',
        originalObject: f,
        score: score,
      ));
    }
  }

  // 2. Filter Spaces
  for (var s in spaces) {
    double score = getRelevance(s.name);
    if (score > 0.3) {
      results.add(SearchResult(
        name: s.name,
        description: s.description,
        type: 'Space',
        originalObject: s,
        score: score,
      ));
    }
  }

  // Sort by Score (Descending)
  results.sort((a, b) => b.score.compareTo(a.score));

  return results;
});