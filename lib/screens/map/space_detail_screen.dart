import 'package:flutter/material.dart';
import 'package:westigov2/models/space.dart';
import 'package:westigov2/utils/constants.dart';
import 'package:westigov2/widgets/favorite_button.dart';

class SpaceDetailScreen extends StatelessWidget {
  final Space space;
  // Optional: pass parent name if available to show context
  final String? parentFacilityName;

  const SpaceDetailScreen({
    super.key,
    required this.space,
    this.parentFacilityName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(space.name),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          FavoriteButton(type: 'space', id: space.id),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo
            if (space.photoUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                child: Image.network(
                  space.photoUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Container(height: 200, color: Colors.grey[200]),
                ),
              ),

            const SizedBox(height: 24),

            // Info Card
            Container(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppSizes.radiusM),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2))
                ],
              ),
              child: Column(
                children: [
                  _buildInfoRow(Icons.apartment, 'Location',
                      parentFacilityName ?? 'Campus Facility'),
                  const Divider(),
                  _buildInfoRow(
                      Icons.layers, 'Floor', space.floorLevel ?? 'Unknown'),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Description
            if (space.description != null) ...[
              Text(
                'About',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                space.description!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }
}
