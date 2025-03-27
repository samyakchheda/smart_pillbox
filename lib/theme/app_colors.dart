import 'package:flutter/material.dart';

class AppColors {
  // Primary & Accent Colors
  static const buttonColor =
      Color(0xFF4276FD); // Vibrant Blue (Primary Action Color)
  static const lightBackground =
      Color(0xFFF6F6F6); // Light Cyan (Main Background)
  static const darkBackground =
      Color(0xFFE0E0E0); // Equivalent to Colors.grey.shade300
  static const cardBackground = Colors.white; // Soft Aqua (Cards, Popups)

  // Text Colors
  static const textPrimary =
      Color(0xFF222222); // Dark Gray (Primary Text - Headings, Important Text)
  static const textSecondary = Color(
      0xFF555555); // Medium Gray (Secondary Text - Descriptions, Subheadings)
  static const textPlaceholder =
      Color(0xFF888888); // Light Gray (Placeholders, Disabled Text)
  static const textOnPrimary =
      Colors.white; // White (Text on Primary Backgrounds)

  // Icon Colors
  static const iconPrimary = Color(0xFF42C2FF); // Vibrant Blue (Active Icons)
  static const iconSecondary =
      Color(0xFF85F4FF); // Bright Cyan (Less Prominent Icons)
  static const iconDisabled = Color(0xFFBBBBBB); // Muted Gray (Disabled Icons)
  static const iconOnPrimary =
      Colors.white; // White (Icons on Primary Backgrounds)

  // UI Element Text & Icon Matching
  static const buttonText = textOnPrimary; // Button Text (White)
  static const buttonIcon = iconOnPrimary; // Button Icon (White)

  static const cardText = textPrimary; // Card Text (Dark Gray)
  static const cardIcon = iconPrimary; // Card Icon (Blue)

  static const lightBgText = textPrimary; // Light Background Text (Dark Gray)
  static const lightBgIcon = iconPrimary; // Light Background Icon (Blue)

  static const darkBgText = textSecondary; // Dark Background Text (Medium Gray)
  static const darkBgIcon = iconSecondary; // Dark Background Icon (Cyan)

  // Neutral Colors
  static const kGreyColor = Colors.grey; // Neutral Gray (Generic Purpose)
  static const kWhiteColor = Colors.white; // White (General Use)
  static const kBlackColor = Colors.black; // Black (General Use)
}
