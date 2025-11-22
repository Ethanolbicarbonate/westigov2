import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:westigov2/config/supabase_config.dart';
import 'package:westigov2/screens/home_screen.dart';
import 'package:westigov2/screens/auth/login_screen.dart';
import 'package:westigov2/screens/map/map_screen.dart';
import 'package:westigov2/utils/constants.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.accent,
          surface: AppColors.background,
        ),
        useMaterial3: true,
        // Define default text styles if needed
        scaffoldBackgroundColor: AppColors.background,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const MapScreen(),
    );
  }
}