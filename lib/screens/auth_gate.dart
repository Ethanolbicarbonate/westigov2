import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:westigo/screens/auth/login_screen.dart';
import 'package:westigo/screens/home_screen.dart';
import 'package:westigo/screens/splash_screen.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  bool _isLoading = true;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

// Update _checkSession
  Future<void> _checkSession() async {
    // Start minimum timer
    final minSplashTime = Future.delayed(const Duration(seconds: 3));

    // Check session
    final session = Supabase.instance.client.auth.currentSession;

    // Wait for timer
    await minSplashTime;

    if (mounted) {
      setState(() {
        _isAuthenticated = session != null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const SplashScreen(); // Show custom splash instead of CircularProgressIndicator
    }

    return _isAuthenticated ? const HomeScreen() : const LoginScreen();
  }
}
