import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:latlong2/latlong.dart';
import 'package:westigov2/providers/facility_provider.dart'; // Import Provider
import 'package:westigov2/utils/constants.dart';
import 'package:westigov2/widgets/facility_marker.dart';

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
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          // ... (Keep your existing options) ...
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

          // 3. Marker Layer (Only show when data is loaded)
          facilitiesAsyncValue.when(
            data: (facilities) => MarkerLayer(
              markers: facilities.map((facility) {
                return Marker(
                  point: LatLng(facility.latitude, facility.longitude),
                  width: 30,
                  height: 30,
                  child: FacilityMarker(
                    onTap: () {
                      // We will implement the bottom sheet in the next sub-phase
                      print('Tapped on ${facility.name}');
                    },
                  ),
                );
              }).toList(),
            ),
            // Show nothing or a loading overlay if needed (though AsyncValue handles it gracefully)
            loading: () => const MarkerLayer(markers: []),
            error: (err, stack) => const MarkerLayer(markers: []),
          ),

          const RichAttributionWidget(
            attributions: [
              TextSourceAttribution('OpenStreetMap contributors', onTap: null),
            ],
          ),
        ],
      ),
    );
  }
}
