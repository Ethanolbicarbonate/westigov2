import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:westigov2/models/event.dart';
import 'package:westigov2/providers/auth_provider.dart';
import 'package:westigov2/services/event_service.dart';

final eventServiceProvider = Provider<EventService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return EventService(supabase);
});

final eventsProvider = FutureProvider<List<Event>>((ref) async {
  final service = ref.read(eventServiceProvider);
  return await service.getEvents();
});