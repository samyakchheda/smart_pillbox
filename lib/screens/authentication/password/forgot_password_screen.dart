import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:home/widgets/common/my_elevated_button.dart';
import 'package:home/widgets/common/my_snack_bar.dart';
import 'package:home/widgets/common/my_text_field.dart';
import '../../../helpers/validators.dart';
import '../../../services/auth_service/password_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_fonts.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final PasswordService _passwordService = PasswordService();
  final TextEditingController _emailController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    String message = await _passwordService.sendPasswordResetEmail(email);

    mySnackBar(
      context,
      message,
      isError: !message.contains("sent"),
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: AppColors.background, // Adaptive background
      appBar: AppBar(
        backgroundColor: AppColors.background, // Matches scaffold
        elevation: 0, // Flat design for modern look
        centerTitle: true,
        title: Text(
          'Forgot Password'.tr(),
          style: AppFonts.headline.copyWith(
            color: AppColors.textPrimary,
            fontSize: 24,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.buttonColor, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Enter your registered email, and we will send a password reset link:'
                        .tr(),
                    style: AppFonts.bodyText.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  MyTextField(
                    controller: _emailController,
                    hintText: 'Enter your email',
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: Validators.validateEmail,
                    fillColor: AppColors.cardBackground,
                    hintStyle: AppFonts.bodyText.copyWith(
                      color: AppColors.textSecondary.withOpacity(0.6),
                    ),
                    textStyle: AppFonts.bodyText.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    iconColor: AppColors.buttonColor,
                    borderRadius: 12,
                  ),
                  const SizedBox(height: 48),
                  _isLoading
                      ? CircularProgressIndicator(
                          color: AppColors.buttonColor,
                        )
                      : MyElevatedButton(
                          text: 'Send Reset Email',
                          onPressed: _resetPassword,
                          backgroundColor: AppColors.buttonColor,
                          textColor: AppColors.buttonText,
                          padding: const EdgeInsets.symmetric(
                              vertical: 18, horizontal: 24),
                          borderRadius: 50,
                          textStyle: AppFonts.buttonText.copyWith(fontSize: 16),
                          height: 60,
                          icon: const Icon(Icons.mail, size: 20),
                          iconSpacing: 12.0,
                        ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Sign In'.tr(),
                      style: AppFonts.buttonText.copyWith(
                        color: AppColors.buttonColor,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
