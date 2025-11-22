import 'package:flutter/material.dart';
import 'package:westigov2/utils/constants.dart';

class FacilityMarker extends StatelessWidget {
  final VoidCallback onTap;

  const FacilityMarker({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                )
              ],
            ),
            child: const Icon(
              Icons.location_on,
              color: Colors.white,
              size: 18,
            ),
          ),
          // Small triangle at bottom to make it look like a pin
          // (Optional polish, can keep simple circle for now)
        ],
      ),
    );
  }
}