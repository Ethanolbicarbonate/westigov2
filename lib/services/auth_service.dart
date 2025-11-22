import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:westigov2/models/app_auth_response.dart';

class AuthService {
  final SupabaseClient _supabase;

  AuthService(this._supabase);

  // Real Auth State Check
  bool get isAuthenticated => _supabase.auth.currentUser != null;
  String? get currentUserId => _supabase.auth.currentUser?.id;

  /// Real Login
  Future<AppAuthResponse> signIn(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        return AppAuthResponse(success: true, userId: response.user!.id);
      }
      return AppAuthResponse(success: false, error: 'Login failed: No user returned');
      
    } on AuthException catch (e) {
      return AppAuthResponse(success: false, error: e.message);
    } catch (e) {
      return AppAuthResponse(success: false, error: 'An unexpected error occurred');
    }
  }

  /// Real Signup
  Future<AppAuthResponse> signUp(String email, String password, Map<String, dynamic> data) async {
    try {
      // 1. Create Auth User
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return AppAuthResponse(success: false, error: 'Signup failed: No user created');
      }

      final userId = response.user!.id;

      // 2. Insert Profile Data into public.users table
      await _supabase.from('users').insert({
        'id': userId,
        'email': email,
        'first_name': data['first_name'],
        'last_name': data['last_name'],
        'course': data['course'],
        'year_level': data['year_level'],
        // created_at is handled by default in DB
      });

      return AppAuthResponse(success: true, userId: userId);

    } on AuthException catch (e) {
      return AppAuthResponse(success: false, error: e.message);
    } catch (e) {
      // If insert fails, we should technically cleanup the auth user, 
      // but for this phase we will just report the error.
      return AppAuthResponse(success: false, error: 'Error creating profile: $e');
    }
  }

  /// Real Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  /// Real Password Reset
  Future<AppAuthResponse> sendPasswordResetEmail(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return AppAuthResponse(success: true);
    } on AuthException catch (e) {
      return AppAuthResponse(success: false, error: e.message);
    } catch (e) {
      return AppAuthResponse(success: false, error: 'An unexpected error occurred');
    }
  }
}