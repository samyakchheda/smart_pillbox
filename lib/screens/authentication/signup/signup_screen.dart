import 'package:flutter/material.dart';
import 'package:home/screens/authentication/signup/components/signup_form.dart';
import '../../../theme/app_colors.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Theme-aware background
      resizeToAvoidBottomInset: true,
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: SignupForm(),
          ),
        ],
      ),
    );
  }
}
