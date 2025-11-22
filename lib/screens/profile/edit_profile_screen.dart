import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:westigov2/models/user_profile.dart';
import 'package:westigov2/providers/user_provider.dart';
import 'package:westigov2/utils/constants.dart';
import 'package:westigov2/utils/helpers.dart';
import 'package:westigov2/utils/validators.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  final UserProfile user;

  const EditProfileScreen({super.key, required this.user});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  String? _selectedCourse;
  String? _selectedYearLevel;
  bool _isLoading = false;

  final List<String> _courses = [
    'CICT',
    'COE',
    'CBM',
    'CAS',
    'CON',
    'PESCAR',
    'COM',
    'COD',
    'COL',
    'COC'
  ];

  final List<String> _yearLevels = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year'
  ];

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(text: widget.user.firstName);
    _lastNameController = TextEditingController(text: widget.user.lastName);

    // Handle case where saved course might not be in our current list (legacy data safety)
    _selectedCourse =
        _courses.contains(widget.user.course) ? widget.user.course : null;
    _selectedYearLevel = _yearLevels.contains(widget.user.yearLevel)
        ? widget.user.yearLevel
        : null;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Create updated object
      final updatedUser = widget.user.copyWith(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        course: _selectedCourse,
        yearLevel: _selectedYearLevel,
      );

      // Call service
      final service = ref.read(userServiceProvider);
      await service.updateUserProfile(updatedUser);

      // Update local state
      ref.read(userProfileProvider.notifier).updateLocal(updatedUser);

      if (!mounted) return;
      AppHelpers.showSuccessSnackbar(context, 'Profile updated successfully');
      Navigator.pop(context);
    } catch (e) {
      AppHelpers.showErrorSnackbar(context, 'Failed to update profile: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        behavior: HitTestBehavior.translucent,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSizes.paddingL),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                      labelText: 'First Name', border: OutlineInputBorder()),
                  validator: (v) =>
                      Validators.validateRequired(v, 'First Name'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                      labelText: 'Last Name', border: OutlineInputBorder()),
                  validator: (v) => Validators.validateRequired(v, 'Last Name'),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCourse,
                  decoration: const InputDecoration(
                      labelText: 'Course', border: OutlineInputBorder()),
                  items: _courses
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCourse = val),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _selectedYearLevel,
                  decoration: const InputDecoration(
                      labelText: 'Year Level', border: OutlineInputBorder()),
                  items: _yearLevels
                      .map((y) => DropdownMenuItem(value: y, child: Text(y)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedYearLevel = val),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child:
                                CircularProgressIndicator(color: Colors.white))
                        : const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
