import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_fonts.dart';

class IntroScreen3 extends StatelessWidget {
  const IntroScreen3({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Theme-aware background
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 50),
          Center(
            child: Container(
              child: Lottie.asset("assets/animations/Reminders.json"),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "Gentle Reminders".tr(),
            style: AppFonts.headline.copyWith(color: AppColors.textPrimary),
          ),
          Padding(
            padding: const EdgeInsets.all(25),
            child: Text(
              "Receive gentle reminders when it's time to take your medicine. "
                      "Let us help you stay consistent, ensuring you never forget a dose."
                  .tr(),
              textAlign: TextAlign.center,
              style: AppFonts.bodyText,
            ),
          ),
        ],
      ),
    );
  }
}
