import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:westigov2/services/auth_service.dart';

// 1. Provider for the Supabase Client
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// 2. Provider for the AuthService (Depend on Supabase Client)
final authServiceProvider = Provider<AuthService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AuthService(supabase);
});

// 3. State Provider for Loading status
final authLoadingProvider = StateProvider<bool>((ref) => false);