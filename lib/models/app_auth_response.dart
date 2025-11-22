class AppAuthResponse {
  final bool success;
  final String? error;
  final String? userId;

  AppAuthResponse({
    required this.success,
    this.error,
    this.userId,
  });
}