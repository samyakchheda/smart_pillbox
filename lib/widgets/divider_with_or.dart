import 'package:flutter/material.dart';
import '../theme/app_colors.dart'; // Ensure this path matches your project structure

class DividerWithOr extends StatelessWidget {
  const DividerWithOr({super.key});

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Expanded(
          child: Divider(
              color: Color(0xFF777777), thickness: 2, indent: 10, endIndent: 5),
        ),
        Text(
          "Or Continue with",
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        Expanded(
          child: Divider(
              color: Color(0xFF777777), thickness: 2, indent: 5, endIndent: 10),
        ),
      ],
    );
  }
}
