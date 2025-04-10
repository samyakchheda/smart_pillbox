import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../theme/app_colors.dart';
import '../../../theme/app_fonts.dart';

class IntroScreen1 extends StatelessWidget {
  const IntroScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Theme-aware background
      body: _buildUI(context),
    );
  }

  Widget _buildUI(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 50),
          Center(
            child: Container(
              child: Lottie.asset("assets/animations/Doctor.json"),
            ),
          ),
          const SizedBox(height: 15),
          Text(
            "Wellness Path",
            style: AppFonts.headline.copyWith(color: AppColors.textPrimary),
          ),
          Padding(
            padding: const EdgeInsets.all(25),
            child: Text(
              "Begin your path to better health by managing your medications effortlessly. "
              "Stay organized, and embrace a healthier lifestyle from day one.",
              textAlign: TextAlign.center,
              style: AppFonts.bodyText,
            ),
          ),
        ],
      ),
    );
  }
}
