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
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        centerTitle: true,
        title: const Text('Forgot Password', style: AppFonts.headline),
        iconTheme: const IconThemeData(color: AppColors.kBlackColor),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Enter your registered email, and we will send a password reset link:',
                  style:
                      AppFonts.bodyText.copyWith(color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                MyTextField(
                  controller: _emailController,
                  hintText: 'Enter your email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.validateEmail,
                  fillColor: AppColors.cardBackground,
                ),
                const SizedBox(height: 40),
                _isLoading
                    ? const CircularProgressIndicator()
                    : MyElevatedButton(
                        text: 'Send Reset Email',
                        onPressed: _resetPassword,
                        backgroundColor: AppColors.buttonColor,
                        textColor: AppColors.buttonText,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        borderRadius: 50,
                      ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Sign In',
                    style: AppFonts.buttonText
                        .copyWith(color: AppColors.buttonColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
