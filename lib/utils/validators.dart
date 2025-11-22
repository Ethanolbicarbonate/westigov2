class Validators {
  // Regex for standard email format
  static final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
  );

  // Regex for password strength: 1 number, 1 upper, 1 lower
  static final RegExp _hasDigit = RegExp(r'[0-9]');
  static final RegExp _hasUpper = RegExp(r'[A-Z]');
  static final RegExp _hasLower = RegExp(r'[a-z]');

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegExp.hasMatch(value)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!_hasDigit.hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    if (!_hasUpper.hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!_hasLower.hasMatch(value)) {
      return 'Password must contain at least one lowercase letter';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String passwordToMatch) {
    if (value == null || value.isEmpty) {
      return 'Please re-type your password';
    }
    if (value != passwordToMatch) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }
}