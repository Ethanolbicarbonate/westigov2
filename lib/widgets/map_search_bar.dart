import 'package:flutter/material.dart';
import 'package:westigo/utils/constants.dart';

class MapSearchBar extends StatelessWidget {
  final VoidCallback onTap;

  const MapSearchBar({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppSizes.paddingM, 
          0, 
          AppSizes.paddingM, 
          AppSizes.paddingL
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingM, 
          vertical: 12
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppSizes.radiusM),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.textLight),
            const SizedBox(width: 12),
            Text(
              'Search facilities and spaces...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textLight,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}