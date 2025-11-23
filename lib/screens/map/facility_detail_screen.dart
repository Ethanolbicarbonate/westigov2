import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:westigo/models/facility.dart';
import 'package:westigo/providers/facility_provider.dart';
import 'package:westigo/utils/constants.dart';
import 'package:westigo/utils/page_transitions.dart';
import 'package:westigo/screens/map/space_detail_screen.dart';
import 'package:westigo/widgets/favorite_button.dart';

class FacilityDetailScreen extends ConsumerWidget {
  final Facility facility;

  const FacilityDetailScreen({super.key, required this.facility});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacesAsync = ref.watch(facilitySpacesProvider(facility.id));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            actions: [
              FavoriteButton(type: 'facility', id: facility.id),
            ],
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16, right: 16), // Better placement
              centerTitle: false, // Left align looks more modern/readable with large text
              title: Text(
                facility.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Colors.black54,
                    ),
                  ],
                ),
              ),
              background: Hero(
                tag: 'facility-img-${facility.id}',
                child: facility.photoUrl != null
                    ? Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(
                            facility.photoUrl!,
                            fit: BoxFit.cover,
                          ),
                          // Gradient overlay for better text readability
                          const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black54],
                                stops: [0.6, 1.0],
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(color: AppColors.primary),
              ),
            ),
          ),
          
          // ... Rest of existing content ...
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SpaceDetailScreen(
                              space: space,
                              parentFacilityName: facility.name,
                            ),
                          ),
                        );
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
                child: Text('Error loading spaces: $err',
                    style: const TextStyle(color: Colors.red)),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}