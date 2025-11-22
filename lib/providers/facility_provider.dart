import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:westigov2/models/facility.dart';
import 'package:westigov2/providers/auth_provider.dart';
import 'package:westigov2/services/facility_service.dart';
import 'package:westigov2/models/space.dart';
import 'package:westigov2/providers/search_provider.dart'; // for spaceServiceProvider

// 1. Provider for the FacilityService
final facilityServiceProvider = Provider<FacilityService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return FacilityService(supabase);
});

// 2. FutureProvider to fetch the list of facilities
// This automatically handles loading/error/data states
final facilitiesProvider = FutureProvider<List<Facility>>((ref) async {
  final service = ref.read(facilityServiceProvider);
  return await service.getFacilities();
});

final facilitySpacesProvider = FutureProvider.family<List<Space>, int>((ref, facilityId) async {
  final service = ref.read(spaceServiceProvider);
  return await service.getSpacesByFacility(facilityId);
});