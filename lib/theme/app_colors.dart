import 'package:flutter/material.dart';
import 'package:home/theme/theme_provider.dart'; // Import ThemeProvider from main.dart

class AppColors {
  // Light Mode Colors
  static const Color lightBackground = Color(0xFFE0E0E0);
  static const Color lightTextPrimary = Color(0xFF222222);
  static const Color lightTextSecondary = Color(0xFF555555);
  static const Color lightTextPlaceholder = Color(0xFF888888);
  static const Color lightCardBackground = Colors.white;
  static const Color lightButtonColor = Color(0xFF4276FD);
  static const Color lightBorderColor = Color(0xFFCCCCCC);
  static const Color lightErrorColor =
      Color(0xFFFF4444); // Added for light mode

  // Dark Mode Colors
  static const Color darkBackground = Color.fromARGB(255, 26, 23, 23);
  static const Color darkTextPrimary = Colors.white;
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkTextPlaceholder = Color(0xFF666666);
  static const Color darkCardBackground = Color(0xFF1E1E1E);
  static const Color darkButtonColor = Color(0xFF4276FD);
  static const Color darkBorderColor = Color(0xFF444444);
  static const Color darkErrorColor = Color(0xFFCC0000); // Added for dark mode

  // New Section-Specific Colors
  static const Color lightSectionHeaderBackground = Color(0xFFF0F0F0);
  static const Color lightSectionHeaderText = Color(0xFF333333);
  static const Color lightListItemBackground = Colors.white;
  static const Color lightListItemText = Color(0xFF444444);

  static const Color darkSectionHeaderBackground = Color(0xFF2A2727);
  static const Color darkSectionHeaderText = Colors.white;
  static const Color darkListItemBackground = Color(0xFF2E2E2E);
  static const Color darkListItemText = Color(0xFFD0D0D0);

  // New Colors for Pill Animation
  static const Color lightPillLeft =
      Color(0xFF333333); // Dark gray for left half
  static const Color lightPillRight = Colors.white; // White for right half
  static const Color lightPillBubble = Color(0xFF42C2FF); // Light blue bubbles

  static const Color darkPillLeft =
      Color(0xFF2E2E2E); // Darker gray for left half
  static const Color darkPillRight =
      Color(0xFFD0D0D0); // Light gray for right half
  static const Color darkPillBubble = Color(0xFF85F4FF); // Cyan bubbles

  // Common Colors
  static const Color textOnPrimary = Colors.white;
  static const Color kGreyColor = Colors.grey;
  static const Color kWhiteColor = Colors.white;
  static const Color kBlackColor = Colors.black;

  // Theme-Aware Getters
  static Color get background => _isDark ? darkBackground : lightBackground;
  static Color get textPrimary => _isDark ? darkTextPrimary : lightTextPrimary;
  static Color get textSecondary =>
      _isDark ? darkTextSecondary : lightTextSecondary;
  static Color get textPlaceholder =>
      _isDark ? darkTextPlaceholder : lightTextPlaceholder;
  static Color get cardBackground =>
      _isDark ? darkCardBackground : lightCardBackground;
  static Color get buttonColor => _isDark ? darkButtonColor : lightButtonColor;
  static Color get borderColor => _isDark ? darkBorderColor : lightBorderColor;
  static Color get errorColor => _isDark ? darkErrorColor : lightErrorColor;

  // New Section-Specific Theme-Aware Getters
  static Color get sectionHeaderBackground =>
      _isDark ? darkSectionHeaderBackground : lightSectionHeaderBackground;
  static Color get sectionHeaderText =>
      _isDark ? darkSectionHeaderText : lightSectionHeaderText;
  static Color get listItemBackground =>
      _isDark ? darkListItemBackground : lightListItemBackground;
  static Color get listItemText =>
      _isDark ? darkListItemText : lightListItemText;

  // New Pill Animation Theme-Aware Getters
  static Color get pillLeft => _isDark ? darkPillLeft : lightPillLeft;
  static Color get pillRight => _isDark ? darkPillRight : lightPillRight;
  static Color get pillBubble => _isDark ? darkPillBubble : lightPillBubble;

  // UI Element Text Matching
  static Color get buttonText => textOnPrimary;
  static Color get cardText => textPrimary;
  static Color get lightBgText => textPrimary;
  static Color get darkBgText => textSecondary;

  // Helper to determine current theme from ThemeProvider
  static bool get _isDark {
    final themeMode = ThemeProvider.themeNotifier.value;
    if (themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.window.platformBrightness ==
          Brightness.dark;
    }
    return themeMode == ThemeMode.dark;
  }
}
