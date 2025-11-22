import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:westigov2/providers/auth_provider.dart';
import 'package:westigov2/utils/constants.dart';
import 'package:westigov2/utils/helpers.dart';
import 'package:westigov2/utils/validators.dart';

class ChangeEmailScreen extends ConsumerStatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  ConsumerState<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends ConsumerState<ChangeEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  Future<void> _updateEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final service = ref.read(authServiceProvider);
      final response = await service.updateEmail(_emailController.text.trim());

      if (!mounted) return;

      if (response.success) {
        AppHelpers.showSuccessSnackbar(
          context, 
          'Confirmation link sent to ${_emailController.text}. Please verify.',
        );
        Navigator.pop(context);
      } else {
        AppHelpers.showErrorSnackbar(context, response.error ?? 'Failed to update email');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentEmail = ref.read(authServiceProvider).currentUser?.email ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Email'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textDark,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Current Email', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 4),
              Text(currentEmail, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'New Email Address',
                  border: OutlineInputBorder(),
                ),
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _updateEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('Send Confirmation Link'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}