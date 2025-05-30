import 'package:flutter/material.dart';
import 'package:home/theme/app_colors.dart';

class AppFonts {
  static const String raleway = 'Poppins';

  // Headline - Large Titles & Section Headers
  static TextStyle get headline => TextStyle(
        fontFamily: raleway,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary, // Theme-aware
        height: 1.3,
      );

  // Subheadline - Subtitles & Section Headings
  static TextStyle get subHeadline => TextStyle(
        fontFamily: raleway,
        fontSize: 20,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary, // Theme-aware
        height: 1.3,
      );

  // BodyText - General Content & Descriptions (e.g., ListTile titles)
  static TextStyle get bodyText => TextStyle(
        fontFamily: raleway,
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: AppColors.listItemText, // Updated to use new listItemText
        height: 1.5,
      );

  // ButtonText - Buttons & Call-to-Action
  static TextStyle get buttonText => TextStyle(
        fontFamily: raleway,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.buttonText, // Always white
      );

  // Caption - Hints, Timestamps, and Helper Texts
  static TextStyle get caption => TextStyle(
        fontFamily: raleway,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPlaceholder, // Theme-aware
        height: 1.2,
      );

  // Optional: New style for section headers
  static TextStyle get sectionHeaderText => TextStyle(
        fontFamily: raleway,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.sectionHeaderText, // Theme-aware
        height: 1.3,
      );
}
