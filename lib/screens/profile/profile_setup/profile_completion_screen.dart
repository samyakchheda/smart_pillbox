import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:home/theme/app_colors.dart'; // Adjust import path
import 'package:home/theme/app_fonts.dart'; // Adjust import path
import '../../../routes/routes.dart';

class ProfileCompletionScreen extends StatefulWidget {
  const ProfileCompletionScreen({super.key});

  @override
  _ProfileCompletionScreenState createState() =>
      _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 9, milliseconds: 500), () {
      Navigator.pushReplacementNamed(context, Routes.home); // Adjust route name
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Theme-aware background
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Lottie.asset(
              'assets/animations/loading.json', // Replace with your downloaded Lottie file path
              width: 200,
              height: 200,
              fit: BoxFit.cover,
            ),
            const SizedBox(height: 20),
            Text(
              "Crafting Your Profile...",
              style: AppFonts.headline.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary, // Theme-aware text color
              ),
            ),
          ],
        ),
      ),
    );
  }
}
