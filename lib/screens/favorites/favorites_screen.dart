import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:westigov2/utils/constants.dart';
import 'package:westigov2/providers/favorite_provider.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: 'Spaces'),
            Tab(text: 'Events'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Spaces Placeholder
          Consumer(
            builder: (context, ref, _) {
              final spacesAsync = ref.watch(favoriteSpacesListProvider);

              return spacesAsync.when(
                data: (spaces) {
                  if (spaces.isNotEmpty) {
                     print('Loaded ${spaces.length} favorite spaces');
                  }
                  return Center(child: Text('Loaded ${spaces.length} spaces (Check Console)'));
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              );
            },
          ),
          
          // Events Placeholder
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event, size: 48, color: Colors.grey),
                SizedBox(height: 16),
                Text('Favorited Events will appear here'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}