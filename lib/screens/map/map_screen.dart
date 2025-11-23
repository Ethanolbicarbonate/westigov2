import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:westigo/providers/facility_provider.dart';
import 'package:westigo/screens/map/facility_detail_screen.dart';
import 'package:westigo/utils/constants.dart';
import 'package:westigo/utils/page_transitions.dart'; // Import this!
import 'package:westigo/widgets/facility_marker.dart';
import 'package:westigo/widgets/facility_bottom_sheet.dart';
import 'package:westigo/widgets/map_search_bar.dart';
import 'package:westigo/providers/search_provider.dart';
import 'package:westigo/screens/map/search_screen.dart';
import 'package:westigo/widgets/map_recenter_button.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  static const LatLng _wvsuCenter = LatLng(10.712805, 122.562543);
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
                  const LatLng(10.7050, 122.5520),
                  const LatLng(10.7205, 122.5730),
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
                                // USE SLIDE UP ROUTE HERE
                                Navigator.push(
                                  context,
                                  SlideUpRoute(
                                    page: FacilityDetailScreen(facility: facility),
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
                  return const MarkerLayer(markers: []);
                },
              ),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors', onTap: null),
                ],
              ),
            ],
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: MapRecenterButton(
              onPressed: () {
                _mapController.move(_wvsuCenter, 17.0);
              },
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: MediaQuery.of(context).padding.bottom + 16,
            child: MapSearchBar(
              onTap: () {
                ref.read(allSpacesProvider);
                // USE FADE ROUTE HERE
                Navigator.of(context).push(
                  FadeRoute(page: const SearchScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}