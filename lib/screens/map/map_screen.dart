import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:latlong2/latlong.dart';
import 'package:westigov2/providers/facility_provider.dart'; // Import Provider
import 'package:westigov2/utils/constants.dart';
import 'package:westigov2/widgets/facility_marker.dart';
import 'package:westigov2/widgets/facility_bottom_sheet.dart';
import 'package:westigov2/widgets/map_search_bar.dart';
import 'package:westigov2/providers/search_provider.dart';

// Change to ConsumerStatefulWidget
class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  // Use your custom coordinates here
  static final LatLng _wvsuCenter = LatLng(10.712805, 122.562543);
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final facilitiesAsyncValue = ref.watch(facilitiesProvider);

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _wvsuCenter,
              initialZoom: 17.0,
              minZoom: 15.0,
              maxZoom: 19.0,
              cameraConstraint: CameraConstraint.contain(
                bounds: LatLngBounds(
                  LatLng(10.7050, 122.5520),
                  LatLng(10.7205, 122.5730),
                ),
              ),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.wvsu.westigo',
                subdomains: const ['a', 'b', 'c'],
              ),

              /// Marker Layer (Based on AsyncValue)
              facilitiesAsyncValue.when(
                data: (facilities) => MarkerLayer(
                  markers: facilities.map((facility) {
                    return Marker(
                      point: LatLng(facility.latitude, facility.longitude),
                      width: 30,
                      height: 30,
                      child: FacilityMarker(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (context) => FacilityBottomSheet(
                              facility: facility,
                              onViewSpaces: () {
                                Navigator.pop(context);
                                print(
                                    'View Spaces clicked for ${facility.name}');
                              },
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
                loading: () => const MarkerLayer(markers: []),
                error: (err, stack) => const MarkerLayer(markers: []),
              ),

              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: null,
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + 16,
            child: MapSearchBar(
              onTap: () async {
                // Trigger data fetch for spaces (lazy load)
                ref.read(allSpacesProvider);

                // Set a query manually to test
                ref.read(searchQueryProvider.notifier).state = "CICT";

                // Give it a moment to calculate
                await Future.delayed(const Duration(milliseconds: 500));

                // Read results
                final results = ref.read(searchResultsProvider);
                print('--- Search Results for "CICT" ---');
                for (var r in results) {
                  print('[${r.type}] ${r.name}');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
