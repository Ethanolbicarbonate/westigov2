import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:westigo/config/supabase_config.dart';
import 'package:westigo/utils/constants.dart';
import 'package:westigo/screens/auth_gate.dart';
import 'package:westigo/config/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase
  await SupabaseConfig.initialize();

  runApp(const ProviderScope(child: WestigoApp()));
}

class WestigoApp extends StatelessWidget {
  const WestigoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Westigo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthGate(),
    );
  }
}