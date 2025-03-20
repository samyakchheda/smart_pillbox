import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_fonts.dart';

class IntroScreen2 extends StatelessWidget {
  const IntroScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: _buildUI(),
    );
  }

  Widget _buildUI() {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 50),
          Center(
            child: Lottie.asset("assets/animations/progress_tracker.json"),
          ),
          const SizedBox(height: 15),
          Text(
            "Stay on Track",
            style: AppFonts.headline.copyWith(color: AppColors.textPrimary),
          ),
          const Padding(
            padding: EdgeInsets.all(25),
            child: Text(
              "Keep your health goals in check by managing your medication schedule. "
              "Stay organized and never miss a step in your wellness journey.",
              textAlign: TextAlign.center,
              style: AppFonts.bodyText,
            ),
          ),
        ],
      ),
    );
  }
}
