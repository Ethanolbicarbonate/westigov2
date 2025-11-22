import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:westigov2/providers/auth_provider.dart';
import 'package:westigov2/utils/constants.dart';
import 'package:westigov2/utils/helpers.dart';

class AccountInfoScreen extends ConsumerWidget {
  const AccountInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(authServiceProvider).currentUser;
    
    if (user == null) return const Scaffold(body: Center(child: Text('No user')));

    final createdAt = DateTime.parse(user.createdAt); // Supabase User createdAt string

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Info'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Column(
          children: [
            _buildInfoTile('Email', user.email ?? 'Unknown'),
            const Divider(),
            _buildInfoTile('User ID', user.id),
            const Divider(),
            _buildInfoTile('Member Since', AppHelpers.formatDateTime(createdAt)),
            const Divider(),
            _buildInfoTile('Last Sign In', AppHelpers.formatDateTime(DateTime.parse(user.lastSignInAt ?? user.createdAt))),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}