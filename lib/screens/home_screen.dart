import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:westigov2/providers/auth_provider.dart';
import 'package:westigov2/screens/auth/login_screen.dart';
import 'package:westigov2/screens/map/map_screen.dart'; // Import MapScreen
import 'package:westigov2/utils/constants.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // We remove the AppBar for the map view to maximize screen space
      // (The Search bar in later sub-phases will act as the header)
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Temporary Logout button floating on top left
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black12, blurRadius: 4, spreadRadius: 1)
            ],
          ),
          child: IconButton(
            icon: const Icon(Icons.logout, color: AppColors.primary, size: 20),
            onPressed: () async {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ),
      ),
      body: const MapScreen(),
    );
  }
}