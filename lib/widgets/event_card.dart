import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:westigo/models/event.dart';
import 'package:westigo/utils/constants.dart';
import 'package:westigo/utils/helpers.dart';
import 'package:westigo/widgets/favorite_button.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Parse date parts
    final month = DateFormat('MMM').format(event.startDate).toUpperCase();
    final day = DateFormat('d').format(event.startDate);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 4), // Tiny margin for shadow separation
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. Image Area
            Stack(
              children: [
                // Hero Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusM)),
                  child: Hero(
                    tag: 'event-img-${event.id}',
                    child: SizedBox(
                      height: 160,
                      width: double.infinity,
                      child: event.imageUrl != null
                          ? Image.network(
                              event.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _buildPlaceholder(),
                            )
                          : _buildPlaceholder(),
                    ),
                  ),
                ),
                
                // Gradient Overlay (Bottom of image)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.5),
                        ],
                      ),
                    ),
                  ),
                ),

                // Date Badge (Top Left)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                    ),
                    child: Column(
                      children: [
                        Text(
                          month,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          day,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            height: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Favorite Button (Top Right) - Reused
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    child: FavoriteButton(type: 'event', id: event.id),
                  ),
                ),
              ],
            ),

            // 2. Details Area
            Padding(
              padding: const EdgeInsets.all(AppSizes.paddingM),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    event.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Location & Time Row
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('h:mm a').format(event.startDate),
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(width: 16),
                      // Optional Location if available
                      const Icon(Icons.location_on, size: 14, color: Colors.grey),
                      // ...
                    ],
                  ),
                  
                  const SizedBox(height: 12),

                  // Audience Tags
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: event.scopes.map((scope) => _buildTag(scope)).toList(),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.event, color: Colors.grey, size: 40),
      ),
    );
  }

  Widget _buildTag(String text) {
    Color bg = Colors.grey.shade200;
    Color fg = Colors.grey.shade800;

    if (text == 'All Students') {
      bg = Colors.blueGrey.shade100;
      fg = Colors.blueGrey.shade800;
    } else if (text.contains('year')) {
      bg = Colors.blue.shade100;
      fg = Colors.blue.shade800;
    } else {
      // Colleges (CICT, etc.)
      bg = Colors.green.shade100;
      fg = Colors.green.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
