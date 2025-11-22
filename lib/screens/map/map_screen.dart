import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:westigov2/utils/constants.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Center of West Visayas State University
  static final LatLng _wvsuCenter = LatLng(10.712805, 122.562543);
  final MapController _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: _wvsuCenter,
          initialZoom: 17.0, // Close enough to see buildings
          minZoom: 15.0,     // Don't let them zoom out to the whole world
          maxZoom: 19.0,
          cameraConstraint: CameraConstraint.contain(
            bounds: LatLngBounds(
              LatLng(10.7050, 122.5520), // Southwest bound (approx)
              LatLng(10.7205, 122.5730), // Northeast bound (approx)
            ),
          ),
          interactionOptions: const InteractionOptions(
            flags: InteractiveFlag.all,
          ),
        ),
        children: [
          // 1. OpenStreetMap Tiles
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.wvsu.westigo', // Required by OSM
            subdomains: const ['a', 'b', 'c'],
          ),

          // 2. Attribution (Required by OSM)
          const RichAttributionWidget(
            attributions: [
              TextSourceAttribution(
                'OpenStreetMap contributors',
                onTap: null, // Can add link logic later if needed
              ),
            ],
          ),
        ],
      ),
    );
  }
}