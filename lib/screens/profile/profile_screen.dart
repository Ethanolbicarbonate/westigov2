import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:westigo/providers/auth_provider.dart';
import 'package:westigo/providers/favorite_provider.dart'; // Added for stats
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
                  _confirmDeletePhoto(userId);
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
        await ref.read(userProfileProvider.notifier).refresh();
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
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 70,
      );

      if (pickedFile == null) return;

      setState(() => _isUploading = true);

      final service = ref.read(userServiceProvider);
      final url =
          await service.uploadProfilePicture(userId, File(pickedFile.path));

      if (url != null) {
        final currentProfile = ref.read(userProfileProvider).value!;
        final updatedProfile = currentProfile.copyWith(profilePictureUrl: url);
        await service.updateUserProfile(updatedProfile);
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
    // Fetch auth user to get 'createdAt'
    final authUser = ref.watch(authServiceProvider).currentUser;
    // Fetch favorites count
    final favoritesAsync = ref.watch(userFavoritesProvider);
    final favoritesCount = favoritesAsync.asData?.value.length ?? 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBodyBehindAppBar: true, // Allow header to go behind status bar
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profile',
            onPressed: userAsync.hasValue && userAsync.value != null
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditProfileScreen(user: userAsync.value!),
                      ),
                    );
                  }
                : null,
          ),
        ],
      ),
      body: userAsync.when(
        data: (user) {
          if (user == null) {
            return const Center(child: Text('User not found'));
          }

          final initials = user.firstName.isNotEmpty && user.lastName.isNotEmpty
              ? '${user.firstName[0]}${user.lastName[0]}'
              : '??';

          final userSince = authUser?.createdAt != null
              ? DateTime.parse(authUser!.createdAt).year.toString()
              : DateTime.now().year.toString();

          return SingleChildScrollView(
            // No padding here, handled inside
            child: Column(
              children: [
                // 1. Curved Header & Profile Pic Stack
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    // Background Curve
                    ClipPath(
                      clipper: _HeaderClipper(),
                      child: Container(
                        height: 220,
                        width: double.infinity,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Color(0xFF0D47A1), // AppColors.primary
                              Color(0xFF1976D2), // Lighter blue
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Profile Picture
                    Positioned(
                      bottom: -50,
                      child: GestureDetector(
                        onTap: () => _handleProfilePictureEdit(
                            user.id, user.profilePictureUrl),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: user.profilePictureUrl != null &&
                                    !_isUploading
                                ? NetworkImage(user.profilePictureUrl!)
                                : null,
                            child: _isUploading
                                ? const CircularProgressIndicator()
                                : (user.profilePictureUrl == null
                                    ? Text(
                                        initials,
                                        style: const TextStyle(
                                          fontSize: 40,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : null),
                          ),
                        ),
                      ),
                    ),
                    // Camera Icon Badge
                    Positioned(
                      bottom: -45,
                      right: MediaQuery.of(context).size.width / 2 - 55,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 60), // Space for the overlapping avatar

                // 2. Name & Course
                Text(
                  '${user.firstName} ${user.lastName}',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${user.course} • ${user.yearLevel}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // 3. Stats Row
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatItem(
                          favoritesCount.toString(), 'Favorites', Icons.favorite),
                      Container(
                          height: 30, width: 1, color: Colors.grey.shade300),
                      _buildStatItem(userSince, 'User Since',
                          Icons.calendar_today_outlined),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 4. Settings List
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSizes.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionHeader('ACCOUNT'),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(AppSizes.radiusM),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildSettingsItem(
                                Icons.person_outline, 'Account Info', () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const AccountInfoScreen()));
                            }),
                            const Divider(height: 1, indent: 56),
                            _buildSettingsItem(
                                Icons.email_outlined, 'Change Email', () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const ChangeEmailScreen()));
                            }),
                            const Divider(height: 1, indent: 56),
                            _buildSettingsItem(
                                Icons.lock_outline, 'Change Password', () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const ChangePasswordScreen()));
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Logout
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Log Out'),
                                content: const Text(
                                    'Are you sure you want to log out?'),
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
                                            builder: (_) =>
                                                const LoginScreen()),
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
                          icon: const Icon(Icons.logout, color: Colors.red),
                          label: const Text(
                            'Log Out',
                            style: TextStyle(
                                color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.red.withValues(alpha: 0.05),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSizes.radiusM),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textDark,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: AppColors.primary),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

// Custom Clipper for the Curved Header
class _HeaderClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 50); // Start line down
    // Create a quadratic bezier curve for the bottom edge
    path.quadraticBezierTo(
      size.width / 2, // Control point x (center)
      size.height, // Control point y (bottom)
      size.width, // End point x (right)
      size.height - 50, // End point y
    );
    path.lineTo(size.width, 0); // Line up to top right
    path.close(); // Close path
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}