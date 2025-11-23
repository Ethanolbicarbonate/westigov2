import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:westigo/providers/auth_provider.dart';
import 'package:westigo/providers/user_provider.dart';
import 'package:westigo/screens/auth/login_screen.dart';
import 'package:westigo/screens/profile/change_email_screen.dart';
import 'package:westigo/screens/profile/change_password_screen.dart';
import 'package:westigo/screens/profile/edit_profile_screen.dart';
import 'package:westigo/utils/constants.dart';
import 'package:westigo/utils/helpers.dart';
import 'package:westigo/screens/profile/account_info_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _isUploading = false;

  Future<void> _handleProfilePictureEdit(
      String userId, String? currentUrl) async {
    // Show Bottom Sheet Options
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUpload(userId, ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickAndUpload(userId, ImageSource.camera);
              },
            ),
            if (currentUrl != null)
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Photo',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDeletePhoto(userId); // Call confirmation
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDeletePhoto(String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remove Photo?'),
        content:
            const Text('Are you sure you want to remove your profile picture?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Remove', style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isUploading = true);
      try {
        final service = ref.read(userServiceProvider);
        await service.deleteProfilePicture(userId);

        await ref
            .read(userProfileProvider.notifier)
            .refresh(); // Full refresh is safer here

        if (mounted) {
          AppHelpers.showSuccessSnackbar(context, 'Profile picture removed');
        }
      } catch (e) {
        if (mounted) {
          AppHelpers.showErrorSnackbar(context, 'Failed to remove photo: $e');
        }
      } finally {
        if (mounted) setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _pickAndUpload(String userId, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 512, // Resize for performance
        maxHeight: 512,
        imageQuality: 70, // Compress
      );

      if (pickedFile == null) return;

      setState(() => _isUploading = true);

      // Upload via service
      final service = ref.read(userServiceProvider);
      final url =
          await service.uploadProfilePicture(userId, File(pickedFile.path));

      if (url != null) {
        // Update User Record in DB
        // We need to get current profile first to update just the photo
        final currentProfile = ref.read(userProfileProvider).value!;
        final updatedProfile = currentProfile.copyWith(profilePictureUrl: url);

        await service.updateUserProfile(updatedProfile);

        // Refresh Local State
        ref.read(userProfileProvider.notifier).updateLocal(updatedProfile);

        if (mounted) {
          AppHelpers.showSuccessSnackbar(context, 'Profile picture updated');
        }
      }
    } catch (e) {
      if (mounted) {
        AppHelpers.showErrorSnackbar(context, 'Failed to upload image: $e');
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textDark,
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User not found'));
          }

          final initials = user.firstName.isNotEmpty && user.lastName.isNotEmpty
              ? '${user.firstName[0]}${user.lastName[0]}'
              : '??';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Column(
              children: [
                // Profile Picture with Upload Logic
                Center(
                  child: GestureDetector(
                    onTap: () => _handleProfilePictureEdit(
                        user.id, user.profilePictureUrl),
                    child: Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 8)
                            ],
                            image: user.profilePictureUrl != null &&
                                    !_isUploading
                                ? DecorationImage(
                                    image:
                                        NetworkImage(user.profilePictureUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _isUploading
                              ? const Padding(
                                  padding: EdgeInsets.all(24.0),
                                  child:
                                      CircularProgressIndicator(strokeWidth: 2),
                                )
                              : (user.profilePictureUrl == null
                                  ? Center(
                                      child: Text(
                                        initials,
                                        style: const TextStyle(
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    )
                                  : null),
                        ),
                        // Camera Icon Overlay
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt,
                                size: 16, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // User Details
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${user.course} • ${user.yearLevel}',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  user.email,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),

                const SizedBox(height: 24),

                // Edit Profile Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfileScreen(user: user),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                    ),
                    child: const Text('Edit Profile'),
                  ),
                ),

                const SizedBox(height: 32),

                // Account Settings
                _buildSectionHeader('Account Settings'),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppSizes.radiusM),
                  ),
                  child: Column(
                    children: [
                      _buildSettingsItem(Icons.info_outline, 'Account Info',
                          () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const AccountInfoScreen()));
                      }),
                      const Divider(height: 1),
                      _buildSettingsItem(Icons.email_outlined, 'Change Email',
                          () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ChangeEmailScreen()));
                      }),
                      const Divider(height: 1),
                      _buildSettingsItem(Icons.lock_outline, 'Change Password',
                          () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ChangePasswordScreen()));
                      }),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Logout Button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Log Out'),
                          content:
                              const Text('Are you sure you want to log out?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(ctx);
                                ref.read(authServiceProvider).signOut();
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                      builder: (_) => const LoginScreen()),
                                  (route) => false,
                                );
                              },
                              child: const Text(
                                'Log Out',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Log Out',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
    );
  }
}
