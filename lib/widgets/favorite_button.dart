import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:westigov2/providers/favorite_provider.dart';
import 'package:westigov2/utils/constants.dart';

class FavoriteButton extends ConsumerWidget {
  final String type; // 'facility' or 'space'
  final int id;

  const FavoriteButton({super.key, required this.type, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use Record for params (Dart 3)
    final isFav = ref.watch(isFavoriteProvider(Tuple2(type, id)));

    return IconButton(
      icon: Icon(
        isFav ? Icons.favorite : Icons.favorite_border,
        color: isFav ? Colors.red : Colors.white,
      ),
      onPressed: () {
        ref.read(userFavoritesProvider.notifier).toggleFavorite(type, id);
      },
    );
  }
}