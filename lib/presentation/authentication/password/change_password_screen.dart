import 'package:flutter/material.dart';
import '../../../services/auth_service/auth_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_fonts.dart';
import '../../../widgets/my_elevated_button.dart';
import '../../../widgets/my_snack_bar.dart';
import '../../../widgets/my_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Future<void> _changePassword() async {
    if (_newPasswordController.text != _confirmPasswordController.text) {
      mySnackBar(context, 'New passwords do not match!',
          isError: true, icon: Icons.error_outline);
      return;
    }

    final authService = AuthService();
    final errorMessage = await authService.changePassword(
      currentPassword: _currentPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    if (errorMessage == "Password changed successfully.") {
      mySnackBar(context, 'Password updated successfully!',
          isError: false, icon: Icons.check_circle_outline);
      Navigator.pop(context);
    } else {
      mySnackBar(context, errorMessage, isError: true, icon: Icons.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Change Password', style: AppFonts.headline),
        backgroundColor: AppColors.buttonColor,
        foregroundColor: AppColors.kWhiteColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            MyTextField(
              controller: _currentPasswordController,
              hintText: 'Current Password',
              icon: Icons.lock,
              isPassword: true,
              borderRadius: 50,
              fillColor: AppColors.cardBackground,
            ),
            const SizedBox(height: 20),
            MyTextField(
              controller: _newPasswordController,
              hintText: 'New Password',
              icon: Icons.lock_outline,
              isPassword: true,
              borderRadius: 50,
              fillColor: AppColors.cardBackground,
              keyboardType: TextInputType.visiblePassword,
              autofillHints: const [
                AutofillHints.newPassword
              ], // Enables Google password suggestion
            ),
            const SizedBox(height: 20),
            MyTextField(
              controller: _confirmPasswordController,
              hintText: 'Confirm New Password',
              icon: Icons.lock_reset,
              isPassword: true,
              borderRadius: 12.0,
              keyboardType: TextInputType.visiblePassword,
              autofillHints: const [
                AutofillHints.password
              ], // Suggests saved new password
            ),
            const SizedBox(height: 30),
            MyElevatedButton(
              text: 'Save',
              onPressed: _changePassword,
              backgroundColor: AppColors.buttonColor,
              textColor: Colors.white,
              borderRadius: 50,
            ),
          ],
        ),
      ),
    );
  }
}
