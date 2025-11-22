import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:westigov2/utils/constants.dart';
import 'package:westigov2/providers/favorite_provider.dart';
import 'package:westigov2/widgets/favorite_space_card.dart';
import 'package:westigov2/screens/map/space_detail_screen.dart';
import 'package:westigov2/widgets/favorite_event_card.dart';
import 'package:westigov2/screens/events/event_detail_screen.dart'; // To navigate

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 64, color: Colors.grey[400]),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary),
              ),
              child: Text(buttonText),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Two tabs: Spaces and Events
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Favorites',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Consumer(
            builder: (context, ref, _) {
              final spacesCount =
                  ref.watch(favoriteSpacesListProvider).asData?.value.length ??
                      0;
              final eventsCount =
                  ref.watch(favoriteEventsListProvider).asData?.value.length ??
                      0;

              return TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primary,
                tabs: [
                  Tab(text: 'Spaces ($spacesCount)'),
                  Tab(text: 'Events ($eventsCount)'),
                ],
              );
            },
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          Consumer(
            builder: (context, ref, _) {
              final spacesAsync = ref.watch(favoriteSpacesListProvider);

              return spacesAsync.when(
                data: (spaces) {
                  if (spaces.isEmpty) {
                    return _buildEmptyState(
                      icon: Icons.star_border,
                      title: 'No favorite spaces',
                      subtitle:
                          'Save rooms, labs, or buildings you visit often for quick access.',
                      buttonText: 'Explore Map',
                      onPressed: () {
                        // Ideally switch tabs, but for now show snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Go to the Map tab to explore!')),
                        );
                      },
                    );
                  }

                  // List of favorite spaces
                  return ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    itemCount: spaces.length,
                    itemBuilder: (context, index) {
                      final space = spaces[index];
                      return FavoriteSpaceCard(
                        space: space,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SpaceDetailScreen(space: space),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              );
            },
          ),
          // Events
          Consumer(
            builder: (context, ref, _) {
              final eventsAsync = ref.watch(favoriteEventsListProvider);

              return eventsAsync.when(
                data: (events) {
                  if (events.isEmpty) {
                    return _buildEmptyState(
                      icon: Icons.event_available,
                      title: 'No favorite events',
                      subtitle:
                          'Don\'t miss out! Star events you are interested in attending.',
                      buttonText: 'Browse Events',
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Go to the Events tab to browse!')),
                        );
                      },
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(AppSizes.paddingM),
                    itemCount: events.length,
                    itemBuilder: (context, index) {
                      final event = events[index];
                      return FavoriteEventCard(
                        event: event,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EventDetailScreen(event: event),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              );
            },
          ),
        ],
      ),
    );
  }
}
