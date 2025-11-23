import 'package:flutter/material.dart';
import 'package:westigo/utils/constants.dart';

class AppNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final IconData fallbackIcon;
  final Color? backgroundColor;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.fallbackIcon = Icons.image_not_supported,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // If no URL is provided immediately show fallback
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildFallback();
    }

    return Image.network(
      imageUrl!,
      width: width,
      height: height,
      fit: fit,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded) return child;
        if (frame == null) {
          // Loading State
          return Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: const Center(
              child: SizedBox(
                width: 24, 
                height: 24, 
                child: CircularProgressIndicator(strokeWidth: 2)
              ),
            ),
          );
        }
        return child;
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildFallback();
      },
    );
  }

  Widget _buildFallback() {
    return Container(
      width: width,
      height: height,
      color: backgroundColor ?? Colors.grey[200],
      child: Center(
        child: Icon(
          fallbackIcon,
          color: Colors.grey[400],
          size: (width != null && width! < 50) ? 16 : 24,
        ),
      ),
    );
  }
}