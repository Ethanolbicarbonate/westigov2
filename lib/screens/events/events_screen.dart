import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:westigov2/providers/event_provider.dart';
import 'package:westigov2/utils/constants.dart';
import 'package:westigov2/widgets/event_card.dart';
import 'package:westigov2/screens/events/event_detail_screen.dart';
import 'package:westigov2/widgets/event_filter_sheet.dart';
import 'package:westigov2/providers/event_filter_provider.dart';
import 'package:westigov2/widgets/event_card_skeleton.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(filteredEventsProvider);

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
            icon: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.filter_list),
                Consumer(builder: (context, ref, _) {
                  final state = ref.watch(eventFilterProvider);
                  final count = state.selectedYears.length +
                      state.selectedColleges.length;

                  if (count == 0) return const SizedBox.shrink();

                  return Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$count',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }),
              ],
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const EventFilterSheet(),
              );
            },
          ),
        ],
      ),
      body: eventsAsync.when(
        data: (events) {
          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.event_busy,
                        size: 64, color: AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'No upcoming events',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Check back later for campus updates',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () => ref.refresh(eventsProvider),
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(eventsProvider.future),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              itemCount: events.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final event = events[index];
                return EventCard(
                  event: event,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EventDetailScreen(event: event),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => ListView.separated(
          padding: const EdgeInsets.all(AppSizes.paddingM),
          itemCount: 3, // Show 3 skeletons
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (_, __) => const EventCardSkeleton(),
        ),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Something went wrong',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                err.toString().contains('SocketException')
                    ? 'Check your internet connection'
                    : 'Failed to load events',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => ref.refresh(eventsProvider),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
