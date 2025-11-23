import 'package:flutter/material.dart';
import 'package:westigo/config/theme.dart';

class MapRecenterButton extends StatelessWidget {
  final VoidCallback onPressed;
  const MapRecenterButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: Colors.white,
      foregroundColor: AppTheme.primary,
      shape: const CircleBorder(),
      mini: true,
      elevation: 4,
      child: const Icon(Icons.my_location),
    );
  }
}