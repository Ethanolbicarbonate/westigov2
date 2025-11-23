import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:latlong2/latlong.dart';
import 'package:westigo/providers/facility_provider.dart'; // Import Provider
import 'package:westigo/screens/map/facility_detail_screen.dart';
import 'package:westigo/utils/constants.dart';
import 'package:westigo/widgets/facility_marker.dart';
import 'package:westigo/widgets/facility_bottom_sheet.dart';
import 'package:westigo/widgets/map_search_bar.dart';
import 'package:westigo/providers/search_provider.dart';
import 'package:westigo/screens/map/search_screen.dart';

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
                                Navigator.pop(context); // Close sheet
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FacilityDetailScreen(
                                        facility: facility),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
                loading: () => const MarkerLayer(markers: []),
                error: (err, stack) {
                  // Only show snackbar once
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to load map pins: $err')),
                    );
                  });
                  return const MarkerLayer(markers: []);
                },
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
              onTap: () {
                // Ensure spaces are loaded
                ref.read(allSpacesProvider);

                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        const SearchScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      // Fade transition
                      return FadeTransition(opacity: animation, child: child);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
