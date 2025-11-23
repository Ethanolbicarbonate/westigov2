import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:westigo/providers/favorite_provider.dart';
import 'package:westigo/utils/constants.dart';

class FavoriteButton extends ConsumerStatefulWidget {
  final String type;
  final int id;

  const FavoriteButton({super.key, required this.type, required this.id});

  @override
  ConsumerState<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends ConsumerState<FavoriteButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 1.0), weight: 50),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tuple for params
    final isFav = ref.watch(isFavoriteProvider(Tuple2(widget.type, widget.id)));

    return ScaleTransition(
      scale: _scaleAnimation,
      child: IconButton(
        icon: Icon(
          isFav ? Icons.favorite : Icons.favorite_border,
          color: isFav ? Colors.red : Colors.white,
        ),
        onPressed: () {
          // Haptics
          HapticFeedback.mediumImpact();
          
          // Play Animation
          _controller.reset();
          _controller.forward();

          // Logic
          ref.read(userFavoritesProvider.notifier).toggleFavorite(widget.type, widget.id);
        },
      ),
    );
  }
}