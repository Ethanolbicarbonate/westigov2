import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:westigov2/models/space.dart';
import 'package:westigov2/providers/favorite_provider.dart';
import 'package:westigov2/utils/constants.dart';

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
              child: SizedBox(
                width: 100,
                height: 100,
                child: space.photoUrl != null
                    ? Image.network(
                        space.photoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
                      )
                    : Container(color: Colors.grey[200], child: const Icon(Icons.meeting_room, color: Colors.grey)),
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
                // Show confirmation dialog
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