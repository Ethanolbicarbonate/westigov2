import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:westigo/models/event.dart';
import 'package:westigo/providers/search_provider.dart';
import 'package:westigo/screens/map/space_detail_screen.dart';
import 'package:westigo/utils/constants.dart';
import 'package:westigo/utils/helpers.dart';
import 'package:westigo/widgets/favorite_button.dart';

class EventDetailScreen extends ConsumerWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  Future<void> _handleLocationTap(BuildContext context, WidgetRef ref) async {
    if (event.locationId == null) return;

    try {
      final spaceService = ref.read(spaceServiceProvider);
      final space = await spaceService.getSpaceById(event.locationId!);

      if (context.mounted) {
        if (space != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SpaceDetailScreen(space: space),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location details not found')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading location: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            actions: [
              FavoriteButton(type: 'event', id: event.id),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'event-img-${event.id}',
                child: event.imageUrl != null
                    ? Image.network(
                        event.imageUrl!,
                        fit: BoxFit.cover,
                        color: Colors.black.withValues(alpha: 0.2),
                        colorBlendMode: BlendMode.darken,
                      )
                    : Container(color: AppColors.primary),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSizes.paddingL),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                  ),
                  const SizedBox(height: 16),

                  _buildInfoRow(Icons.calendar_today,
                      AppHelpers.formatDateTime(event.startDate)),
                  const SizedBox(height: 12),

                  // UPDATED LOCATION ROW
                  if (event.locationId != null)
                    _buildInfoRow(
                      Icons.location_on,
                      event.locationName ?? 'View Location Details', // Use Name
                      isLink: true,
                      onTap: () => _handleLocationTap(context, ref),
                    ),

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  if (event.description != null) ...[
                    Text(
                      'About this Event',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      event.description!,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            height: 1.5,
                            color: Colors.grey[800],
                          ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  Text(
                    'Who should attend?',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: event.scopes
                        .map((s) => Chip(
                              label: Text(s),
                              backgroundColor: AppColors.background,
                              labelStyle: const TextStyle(fontSize: 12),
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text,
      {bool isLink = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600, // Bold
                color: isLink ? AppColors.primary : AppColors.textDark, // Blue if link
                // Removed textDecoration: underline
              ),
            ),
          ),
          if (isLink)
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primary),
        ],
      ),
    );
  }
}