import 'package:flutter/material.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_fonts.dart';

void mySnackBar(BuildContext context, String message,
    {bool isError = false, IconData? icon}) {
  final snackBar = SnackBar(
    content: Row(
      children: [
        Icon(
          icon ?? (isError ? Icons.error_outline : Icons.check_circle_outline),
          color: isError ? AppColors.iconSecondary : AppColors.iconPrimary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: AppFonts.bodyText.copyWith(color: AppColors.textOnPrimary),
          ),
        ),
      ],
    ),
    backgroundColor: isError ? AppColors.buttonColor : AppColors.darkBackground,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30), // Pill-shaped design
    ),
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    duration: const Duration(seconds: 3),
    elevation: 4,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
