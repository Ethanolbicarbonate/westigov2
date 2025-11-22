import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // Import Riverpod
import 'package:latlong2/latlong.dart';
import 'package:westigov2/providers/facility_provider.dart'; // Import Provider
import 'package:westigov2/utils/constants.dart';

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
    // Watch the facilities provider
    final facilitiesAsyncValue = ref.watch(facilitiesProvider);

    // Debug Listener: Print to console when data arrives
    ref.listen(facilitiesProvider, (previous, next) {
      next.when(
        data: (facilities) {
          print('✅ SUCCESS: Fetched ${facilities.length} facilities from Supabase!');
          for (var f in facilities) {
            print(' - ${f.name} at [${f.latitude}, ${f.longitude}]');
          }
        },
        error: (err, stack) => print('❌ ERROR: $err'),
        loading: () => print('⏳ Loading facilities...'),
      );
    });

    return Scaffold(
      body: FlutterMap(
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
          const RichAttributionWidget(
            attributions: [
              TextSourceAttribution('OpenStreetMap contributors', onTap: null),
            ],
          ),
          // Note: We haven't added the MarkerLayer yet (Next Sub-Phase)
        ],
      ),
    );
  }
}