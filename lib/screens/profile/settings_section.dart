import 'package:flutter/material.dart';
import 'package:home/theme/app_colors.dart';
import 'package:home/theme/app_fonts.dart';

class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> items;
  final Color? sectionBackground; // Optional theme-aware background
  final Color? sectionText; // Optional theme-aware text color
  final Color? itemBackground; // Optional theme-aware item background
  final Color? itemText; // Optional theme-aware item text color
  final Color? itemIcon; // Optional theme-aware item icon color

  const SettingsSection({
    required this.title,
    required this.items,
    this.sectionBackground,
    this.sectionText,
    this.itemBackground,
    this.itemText,
    this.itemIcon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        color: sectionBackground ??
            AppColors.cardBackground, // Use theme-aware color
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Text(
                title,
                style: AppFonts.sectionHeaderText.copyWith(
                  color: sectionText ?? AppColors.sectionHeaderText,
                ),
              ),
            ),
            ...items.map((item) {
              // Wrap each item with a Container to apply itemBackground if provided
              return Container(
                color: itemBackground ?? AppColors.listItemBackground,
                child: item,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
