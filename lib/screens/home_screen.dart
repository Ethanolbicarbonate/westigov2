import 'package:flutter/material.dart';
import 'package:westigov2/utils/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Westigo'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, size: 64, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Welcome to WVSU Campus Map',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text(
              'Phase 2 Complete',
              style: TextStyle(color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }
}