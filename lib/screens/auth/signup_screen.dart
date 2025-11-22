import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:westigov2/providers/auth_provider.dart';
import 'package:westigov2/screens/home_screen.dart';
import 'package:westigov2/utils/constants.dart';
import 'package:westigov2/utils/helpers.dart';
import 'package:westigov2/utils/validators.dart';
import 'package:westigov2/widgets/password_strength_indicator.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  String? _selectedCourse;
  String? _selectedYearLevel;
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  final List<String> _courses = [
    'CICT', 'COE', 'CBM', 'CAS', 'CON', 'PESCAR', 'COM', 'COD', 'COL', 'COC'
  ];
  
  final List<String> _yearLevels = [
    '1st Year', '2nd Year', '3rd Year', '4th Year'
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    // Set loading
    ref.read(authLoadingProvider.notifier).state = true;

    try {
      final authService = ref.read(authServiceProvider);
      
      // Prepare extra data for the 'users' table
      final userData = {
        'first_name': _firstNameController.text.trim(),
        'last_name': _lastNameController.text.trim(),
        'course': _selectedCourse,
        'year_level': _selectedYearLevel,
      };

      final response = await authService.signUp(
        _emailController.text.trim(),
        _passwordController.text,
        userData,
      );

      if (!mounted) return;

      if (response.success) {
        // Success -> Navigate to Home
        // (In real app, maybe go to "Check your email" screen if email confirmation is on)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (route) => false, // Remove all previous routes
        );
        AppHelpers.showSuccessSnackbar(context, 'Account created successfully!');
      } else {
        AppHelpers.showErrorSnackbar(context, response.error ?? 'Signup failed');
      }
    } catch (e) {
      if (mounted) AppHelpers.showErrorSnackbar(context, 'An unexpected error occurred');
    } finally {
      if (mounted) ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(authLoadingProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textDark),
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSizes.paddingL),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create Account',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Join the Westigo community',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textLight,
                        ),
                  ),
                  const SizedBox(height: 32),

                  // Name Fields
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _firstNameController,
                          enabled: !isLoading,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'First Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => Validators.validateRequired(v, 'First Name'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _lastNameController,
                          enabled: !isLoading,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Last Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => Validators.validateRequired(v, 'Last Name'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Course
                  DropdownButtonFormField<String>(
                    value: _selectedCourse,
                    decoration: const InputDecoration(
                      labelText: 'Course/College',
                      border: OutlineInputBorder(),
                    ),
                    items: _courses.map((course) {
                      return DropdownMenuItem(value: course, child: Text(course));
                    }).toList(),
                    onChanged: isLoading ? null : (val) => setState(() => _selectedCourse = val),
                    validator: (val) => val == null ? 'Please select a course' : null,
                  ),
                  const SizedBox(height: 16),

                  // Year Level
                  DropdownButtonFormField<String>(
                    value: _selectedYearLevel,
                    decoration: const InputDecoration(
                      labelText: 'Year Level',
                      border: OutlineInputBorder(),
                    ),
                    items: _yearLevels.map((year) {
                      return DropdownMenuItem(value: year, child: Text(year));
                    }).toList(),
                    onChanged: isLoading ? null : (val) => setState(() => _selectedYearLevel = val),
                    validator: (val) => val == null ? 'Please select a year level' : null,
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: _emailController,
                    enabled: !isLoading,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 16),

                  // Password
                  TextFormField(
                    controller: _passwordController,
                    enabled: !isLoading,
                    obscureText: _obscurePassword,
                    onChanged: (val) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: Validators.validatePassword,
                  ),
                  PasswordStrengthIndicator(password: _passwordController.text),
                  const SizedBox(height: 16),

                  // Confirm Password
                  TextFormField(
                    controller: _confirmPasswordController,
                    enabled: !isLoading,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Retype Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (val) => Validators.validateConfirmPassword(
                      val, 
                      _passwordController.text
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Sign Up Button
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppSizes.radiusM),
                      ),
                    ),
                    child: isLoading
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : const Text(
                          'Create Account',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}