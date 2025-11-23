import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:westigo/utils/constants.dart';
import 'package:westigo/providers/favorite_provider.dart';
import 'package:westigo/widgets/favorite_space_card.dart';
import 'package:westigo/screens/map/space_detail_screen.dart';
import 'package:westigo/widgets/favorite_event_card.dart';
import 'package:westigo/screens/events/event_detail_screen.dart';
import 'package:westigo/providers/home_provider.dart';
import 'package:westigo/widgets/empty_state_widget.dart'; // Import

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
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
          // Spaces Tab
          Consumer(
            builder: (context, ref, _) {
              final spacesAsync = ref.watch(favoriteSpacesListProvider);

              return spacesAsync.when(
                data: (spaces) {
                  if (spaces.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.bookmark_border,
                      title: 'No favorite spaces',
                      subtitle: 'Save rooms, labs, or buildings you visit often for quick access.',
                      actionLabel: 'Explore Map',
                      onAction: () {
                        ref.read(homeTabProvider.notifier).state = 0;
                      },
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.refresh(favoriteSpacesListProvider.future),
                    child: ListView.builder(
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
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              );
            },
          ),
          // Events Tab
          Consumer(
            builder: (context, ref, _) {
              final eventsAsync = ref.watch(favoriteEventsListProvider);

              return eventsAsync.when(
                data: (events) {
                  if (events.isEmpty) {
                    return EmptyStateWidget(
                      icon: Icons.event_busy,
                      title: 'No favorite events',
                      subtitle: 'Don\'t miss out! Star events you are interested in attending.',
                      actionLabel: 'Browse Events',
                      onAction: () {
                        ref.read(homeTabProvider.notifier).state = 1;
                      },
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () =>
                        ref.refresh(favoriteEventsListProvider.future),
                    child: ListView.builder(
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
                    ),
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