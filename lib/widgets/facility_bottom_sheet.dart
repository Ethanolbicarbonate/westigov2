import 'package:flutter/material.dart';
import 'package:westigov2/models/facility.dart';
import 'package:westigov2/utils/constants.dart';

class FacilityBottomSheet extends StatelessWidget {
  final Facility facility;
  final VoidCallback onViewSpaces;

  const FacilityBottomSheet({
    super.key,
    required this.facility,
    required this.onViewSpaces,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingL),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Shrink to fit content
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar (visual cue for dragging)
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Facility Name
          Text(
            facility.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
          ),
          const SizedBox(height: 8),
          
          // Photo
          if (facility.photoUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              child: Image.network(
                facility.photoUrl!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 150,
                    color: Colors.grey[200],
                    child: const Center(child: Icon(Icons.image_not_supported)),
                  );
                },
              ),
            ),
          
          const SizedBox(height: 12),
          
          // Description
          if (facility.description != null)
            Text(
              facility.description!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textLight,
                  ),
            ),
            
          const SizedBox(height: 24),
          
          // Action Button
          ElevatedButton(
            onPressed: onViewSpaces,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
              ),
            ),
            child: const Text('View Spaces & Details'),
          ),
          
          // Extra padding for bottom safe area (iPhone home bar)
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}