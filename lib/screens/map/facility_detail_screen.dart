import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:westigov2/models/facility.dart';
import 'package:westigov2/providers/facility_provider.dart';
import 'package:westigov2/utils/constants.dart';

class FacilityDetailScreen extends ConsumerWidget {
  final Facility facility;

  const FacilityDetailScreen({super.key, required this.facility});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Fetch spaces for this facility
    final spacesAsync = ref.watch(facilitySpacesProvider(facility.id));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // 1. App Bar with Image
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                facility.name,
                style: const TextStyle(
                  color: Colors.white,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
              ),
              background: facility.photoUrl != null
                  ? Image.network(
                      facility.photoUrl!,
                      fit: BoxFit.cover,
                      color: Colors.black.withOpacity(0.3),
                      colorBlendMode: BlendMode.darken,
                    )
                  : Container(color: AppColors.primary),
            ),
          ),

          // 2. Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Description
                  if (facility.description != null) ...[
                    Text(
                      'About',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      facility.description!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Spaces Header
                  Text(
                    'Rooms & Spaces',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          // 3. Spaces List
          spacesAsync.when(
            data: (spaces) {
              if (spaces.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
                    child: Text('No spaces listed for this facility.'),
                  ),
                );
              }
              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final space = spaces[index];
                    return ListTile(
                      leading: const Icon(Icons.meeting_room, color: Colors.grey),
                      title: Text(space.name),
                      subtitle: space.floorLevel != null 
                          ? Text(space.floorLevel!) 
                          : null,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        // TODO: Go to Space Detail
                        print('Space tapped: ${space.name}');
                      },
                    );
                  },
                  childCount: spaces.length,
                ),
              );
            },
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, stack) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSizes.paddingL),
                child: Text('Error loading spaces: $err', style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),
          
          // Bottom Padding
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}