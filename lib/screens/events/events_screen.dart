import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:westigov2/providers/event_provider.dart';
import 'package:westigov2/utils/constants.dart';
import 'package:westigov2/widgets/event_card.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Campus Events',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        actions: [
          // Filter Button
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Open Filter Sheet
              print('Filter tapped');
            },
          ),
        ],
      ),
      body: eventsAsync.when(
        data: (events) {
          // Debug Print
          if (events.isNotEmpty) {
            print('✅ Loaded ${events.length} events');
            for (var e in events) {
              print(' - ${e.name} (${e.scopes})');
            }
          }

          if (events.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.event_busy, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No upcoming events'),
                ],
              ),
            );
          }

          // Placeholder List
          return RefreshIndicator(
            onRefresh: () => ref.refresh(eventsProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final event = events[index];
                // Temporary Placeholder Card
                return EventCard(
                  event: event,
                  onTap: () {
                    // TODO: Navigate to Detail
                    print('Tapped ${event.name}');
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Error loading events: $err'),
        ),
      ),
    );
  }
}
