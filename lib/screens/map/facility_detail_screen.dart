import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:westigo/models/facility.dart';
import 'package:westigo/providers/facility_provider.dart';
import 'package:westigo/utils/constants.dart';
import 'package:westigo/utils/page_transitions.dart';
import 'package:westigo/screens/map/space_detail_screen.dart';
import 'package:westigo/widgets/favorite_button.dart';
import 'package:westigo/utils/debouncer.dart';
import 'package:westigo/widgets/app_network_image.dart';

class FacilityDetailScreen extends ConsumerStatefulWidget {
  final Facility facility;

  const FacilityDetailScreen({super.key, required this.facility});

  @override
  ConsumerState<FacilityDetailScreen> createState() =>
      _FacilityDetailScreenState();
}

class _FacilityDetailScreenState extends ConsumerState<FacilityDetailScreen> {
  final TextEditingController _searchController = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 300);
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.dispose();
    super.dispose();
  }

  void _shareFacility() {
    // Use exact latitude and longitude to drop a pin
    final lat = widget.facility.latitude;
    final long = widget.facility.longitude;
    final mapLink =
        'https://www.google.com/maps/search/?api=1&query=$lat,$long';

    final text = 'Meet me at ${widget.facility.name}! 🏢\n\n'
        'Here\'s the location:\nSent via Westigo.\n\n'
        '$mapLink';

    SharePlus.instance.share(ShareParams(text: text));
  }

  @override
  Widget build(BuildContext context) {
    final spacesAsync = ref.watch(facilitySpacesProvider(widget.facility.id));

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            actions: [
              // Add this IconButton
              IconButton(
                icon: const Icon(Icons.share),
                tooltip: 'Share Location',
                onPressed: _shareFacility,
              ),
              FavoriteButton(type: 'facility', id: widget.facility.id),
            ],
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsets.only(left: 16, bottom: 16, right: 16),
              centerTitle: false,
              title: Text(
                widget.facility.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3.0,
                        color: Colors.black54),
                  ],
                ),
              ),
              background: Hero(
                tag: 'facility-img-${widget.facility.id}',
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppNetworkImage(
                      imageUrl: widget.facility.photoUrl,
                      fallbackIcon: Icons.business,
                    ),
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
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.facility.description != null) ...[
                    Text(
                      'About',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.facility.description!,
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
                  const SizedBox(height: 12),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search rooms...',
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onChanged: (value) {
                      _debouncer.run(() {
                        setState(() {
                          _searchQuery = value.toLowerCase();
                        });
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          spacesAsync.when(
            data: (spaces) {
              final filteredSpaces = spaces.where((space) {
                return space.name.toLowerCase().contains(_searchQuery);
              }).toList();

              if (filteredSpaces.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: AppSizes.paddingL, vertical: 20),
                    child: Center(
                        child: Text('No spaces found matching your search.')),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final space = filteredSpaces[index];
                    return ListTile(
                      leading:
                          const Icon(Icons.meeting_room, color: Colors.grey),
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
                              parentFacilityName: widget.facility.name,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  childCount: filteredSpaces.length,
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
