import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:westigo/models/space.dart';
import 'package:westigo/providers/favorite_provider.dart';
import 'package:westigo/utils/constants.dart';
import 'package:westigo/widgets/app_network_image.dart'; // Import

class FavoriteSpaceCard extends ConsumerWidget {
  final Space space;
  final VoidCallback onTap;

  const FavoriteSpaceCard({
    super.key,
    required this.space,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppSizes.radiusM)),
              child: AppNetworkImage(
                imageUrl: space.photoUrl,
                width: 100,
                height: 100,
                fallbackIcon: Icons.meeting_room,
              ),
            ),
            
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      space.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      space.floorLevel ?? 'Unknown Floor',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    if (space.description != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        space.description!,
                        style: const TextStyle(color: AppColors.textLight, fontSize: 12),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Remove Button
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Remove Favorite?'),
                    content: Text('Remove "${space.name}" from your favorites?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ref.read(userFavoritesProvider.notifier).toggleFavorite('space', space.id);
                        },
                        child: const Text('Remove', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}