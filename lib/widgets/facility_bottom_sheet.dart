import 'package:flutter/material.dart';
import 'package:westigo/models/facility.dart';
import 'package:westigo/utils/constants.dart';
import 'package:westigo/widgets/app_network_image.dart'; // Import

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
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Handle bar
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
          
          Text(
            facility.name,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
          ),
          const SizedBox(height: 8),
          
          // Photo with Hero and AppNetworkImage
          Hero(
            tag: 'facility-img-${facility.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppSizes.radiusM),
              child: SizedBox(
                height: 150,
                width: double.infinity,
                child: AppNetworkImage(
                  imageUrl: facility.photoUrl,
                  fallbackIcon: Icons.business,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
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
          
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}