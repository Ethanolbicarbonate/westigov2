import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:westigov2/models/app_auth_response.dart'; // Import renamed model

class AuthService {
  final SupabaseClient _supabase;

  bool _isMockLoggedIn = false;
  String? _mockUserId;

  AuthService(this._supabase);

  bool get isAuthenticated => _isMockLoggedIn;
  String? get currentUserId => _mockUserId;

  Future<AppAuthResponse> signIn(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email.isEmpty || password.isEmpty) {
      return AppAuthResponse(success: false, error: 'Email and password are required');
    }

    _isMockLoggedIn = true;
    _mockUserId = 'mock-user-123';
    
    return AppAuthResponse(success: true, userId: _mockUserId);
  }

  Future<AppAuthResponse> signUp(String email, String password, Map<String, dynamic> data) async {
    await Future.delayed(const Duration(seconds: 1));

    if (email.isEmpty || password.isEmpty) {
      return AppAuthResponse(success: false, error: 'All fields are required');
    }

    _isMockLoggedIn = true;
    _mockUserId = 'mock-user-123';
    
    print('Mock Signup Data: $data');

    return AppAuthResponse(success: true, userId: _mockUserId);
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isMockLoggedIn = false;
    _mockUserId = null;
  }

  Future<AppAuthResponse> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email.isEmpty) {
      return AppAuthResponse(success: false, error: 'Email is required');
    }
    return AppAuthResponse(success: true);
  }
}