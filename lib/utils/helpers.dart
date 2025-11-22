import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppHelpers {
  /// Format: "Oct 24, 2:00 PM"
  static String formatDateTime(DateTime dt) {
    return DateFormat('MMM d, h:mm a').format(dt);
  }

  /// Show a simple error snackbar
  static void showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show a success snackbar
  static void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}