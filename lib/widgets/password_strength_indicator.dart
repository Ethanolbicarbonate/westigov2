import 'package:flutter/material.dart';
import 'package:westigov2/utils/constants.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;

  const PasswordStrengthIndicator({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    // Calculate strength
    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.contains(RegExp(r'[A-Z]'))) strength++;
    if (password.contains(RegExp(r'[a-z]'))) strength++;
    if (password.contains(RegExp(r'[0-9]'))) strength++;

    // Determine color and label
    Color color = Colors.grey.shade300;
    String label = 'Weak';

    if (password.isEmpty) {
      strength = 0;
    } else if (strength <= 2) {
      color = Colors.red;
      label = 'Weak';
    } else if (strength == 3) {
      color = Colors.orange;
      label = 'Medium';
    } else if (strength == 4) {
      color = Colors.green;
      label = 'Strong';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _buildBar(strength >= 1 ? color : Colors.grey.shade300)),
            const SizedBox(width: 4),
            Expanded(child: _buildBar(strength >= 2 ? color : Colors.grey.shade300)),
            const SizedBox(width: 4),
            Expanded(child: _buildBar(strength >= 3 ? color : Colors.grey.shade300)),
            const SizedBox(width: 4),
            Expanded(child: _buildBar(strength >= 4 ? color : Colors.grey.shade300)),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          password.isEmpty ? '' : label,
          style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildBar(Color color) {
    return Container(
      height: 4,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}