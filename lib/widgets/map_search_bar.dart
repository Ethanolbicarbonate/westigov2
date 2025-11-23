import 'package:flutter/material.dart';
import 'package:westigo/config/theme.dart';
import 'package:westigo/utils/constants.dart';
import 'dart:ui';

class MapSearchBar extends StatelessWidget {
  final VoidCallback onTap;

  const MapSearchBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(AppSizes.paddingM, 0, AppSizes.paddingM, AppSizes.paddingL),
        // Remove padding here, move inside glass container
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingM, vertical: 14),
              color: Colors.white.withValues(alpha: 0.60), // Semi-transparent white
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.primary), // Changed to Primary color
                  const SizedBox(width: 12),
                  Text(
                    'Search facilities and spaces...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textMedium,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }}