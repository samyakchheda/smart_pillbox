import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:home/theme/app_colors.dart'; // Adjust path to match your project structure
import 'package:home/theme/app_fonts.dart'; // Adjust path to include AppFonts

class DividerWithOr extends StatelessWidget {
  const DividerWithOr({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: AppColors.textPlaceholder, // Theme-aware color for divider
            thickness: 2,
            indent: 10,
            endIndent: 5,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            "Or Continue with".tr(),
            style: AppFonts.caption.copyWith(
              color: AppColors.textSecondary, // Theme-aware color
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: AppColors.textPlaceholder, // Theme-aware color for divider
            thickness: 2,
            indent: 5,
            endIndent: 10,
          ),
        ),
      ],
    );
  }
}
