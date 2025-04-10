import 'package:flutter/material.dart';
import '../../../theme/app_colors.dart';
import 'components/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background, // Theme-aware background
      resizeToAvoidBottomInset: true,
      body: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: LoginForm(),
          ),
        ],
      ),
    );
  }
}
