import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:home/theme/app_colors.dart';
import 'package:home/theme/app_fonts.dart';

class AboutUsScreen extends StatelessWidget {
  final VoidCallback onBack;

  const AboutUsScreen({required this.onBack, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background, // Theme-aware background
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: AppColors.buttonColor),
                    onPressed: onBack,
                  ),
                  Expanded(
                    child: Text(
                      "About Us".tr(),
                      textAlign: TextAlign.center,
                      style: AppFonts.headline.copyWith(
                        fontSize: 26,
                        color: AppColors.textPrimary,
                        shadows: [
                          Shadow(
                            color: AppColors.textSecondary.withOpacity(0.4),
                            offset: const Offset(2, 2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 30),
              Card(
                color: AppColors.cardBackground.withOpacity(0.95),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 12,
                shadowColor: AppColors.textSecondary.withOpacity(0.5),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Text(
                        "At Smart PillBox".tr(),
                        style: AppFonts.subHeadline.copyWith(
                          fontSize: 20,
                          color: AppColors.buttonColor, // Accent color
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        ("We are dedicated to revolutionizing medication management through cutting-edge technology. " +
                                "Our mission is to enhance medication adherence and elevate the quality of life for individuals, " +
                                "especially the elderly and those managing chronic conditions.")
                            .tr(),
                        textAlign: TextAlign.center,
                        style: AppFonts.bodyText.copyWith(
                          fontSize: 16,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 12,
                shadowColor: AppColors.textSecondary.withOpacity(0.5),
                color: AppColors.cardBackground.withOpacity(0.95),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppColors.buttonColor,
                              AppColors.buttonColor.withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(Icons.lightbulb,
                            color: AppColors.kWhiteColor, size: 34),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          ("Our vision is to create a world where medication non-adherence is a thing of the past. " +
                                  "We empower individuals and caregivers with an intelligent, sleek solution for managing daily medications.")
                              .tr(),
                          style: AppFonts.bodyText.copyWith(
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Text(
                "Why Choose Smart PillBox?".tr(),
                style: AppFonts.headline.copyWith(
                  fontSize: 22,
                  color: AppColors.textPrimary,
                  shadows: [
                    Shadow(
                      color: AppColors.textSecondary.withOpacity(0.4),
                      offset: const Offset(2, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              _featureCard(
                  Icons.alarm,
                  "Automated Reminders".tr(),
                  "Never miss a dose with stylish, timely alerts.".tr(),
                  AppColors.buttonColor),
              _featureCard(
                  Icons.touch_app,
                  "User-Friendly Design".tr(),
                  "Sleek, intuitive, and perfect for all ages.".tr(),
                  AppColors.buttonColor),
              _featureCard(
                  Icons.notifications,
                  "Caregiver Notifications".tr(),
                  "Stay connected with elegant updates.".tr(),
                  AppColors.buttonColor),
              _featureCard(
                  Icons.security,
                  "Secure & Portable".tr(),
                  "Compact luxury built for your lifestyle.".tr(),
                  AppColors.buttonColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureCard(
      IconData icon, String title, String description, Color accentColor) {
    return Card(
      color: AppColors.cardBackground.withOpacity(0.9),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 8,
      shadowColor: accentColor.withOpacity(0.6),
      margin: const EdgeInsets.only(bottom: 12), // Fixed typo: 'bottom'
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    accentColor,
                    accentColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(icon, color: AppColors.kWhiteColor, size: 32),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppFonts.subHeadline.copyWith(
                      fontSize: 16,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    description,
                    style: AppFonts.bodyText.copyWith(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
