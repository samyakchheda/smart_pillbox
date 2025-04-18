import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:home/services/auth_service/password_service.dart';
import 'package:home/theme/app_colors.dart';
import 'package:home/widgets/common/my_snack_bar.dart';
import 'package:home/widgets/common/my_text_field.dart';
import 'package:home/widgets/common/my_elevated_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  final VoidCallback onBack;

  const ChangePasswordScreen({required this.onBack, super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isEmailPasswordUser = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkAuthMethod();

    // Add listener to newPasswordController for strong password auto-copy
    _newPasswordController.addListener(() {
      String newPassword = _newPasswordController.text;
      if (_isStrongPassword(newPassword)) {
        _confirmPasswordController.text = newPassword;
      }
    });
  }

  // Define what makes a password "strong"
  bool _isStrongPassword(String password) {
    return password.length >= 8 &&
        RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]+$')
            .hasMatch(password);
  }

  Future<void> _checkAuthMethod() async {
    final passwordService = PasswordService();
    try {
      final isEmailPassword = await passwordService.isEmailPasswordUser();
      setState(() {
        _isEmailPasswordUser = isEmailPassword;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      mySnackBar(context, 'Error checking authentication method',
          isError: true, icon: Icons.error);
    }
  }

  Future<void> _changePassword() async {
    if (!_isEmailPasswordUser) {
      mySnackBar(
          context,
          'Password change is only available for email/password accounts. '
          'For Google or Facebook accounts, please use their respective password management.',
          isError: true,
          icon: Icons.info);
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      mySnackBar(context, 'New passwords do not match!',
          isError: true, icon: Icons.error_outline);
      return;
    }

    setState(() => _isLoading = true); // Show loading indicator
    final passwordService = PasswordService();
    try {
      final errorMessage = await passwordService.changePassword(
        currentPassword: _currentPasswordController.text,
        newPassword: _newPasswordController.text,
      );

      setState(() => _isLoading = false); // Hide loading indicator

      if (errorMessage == "Password changed successfully.") {
        mySnackBar(context, 'Password updated successfully!',
            isError: false, icon: Icons.check_circle_outline);
        widget.onBack(); // Use onBack for consistency
      } else {
        mySnackBar(context, errorMessage, isError: true, icon: Icons.error);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      mySnackBar(context, 'An unexpected error occurred: $e',
          isError: true, icon: Icons.error);
    }
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Container(
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back, color: AppColors.buttonColor),
                  onPressed: widget.onBack,
                ),
                Text(
                  "Change Password".tr(),
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            MyTextField(
              controller: _currentPasswordController,
              hintText: "Old Password",
              icon: Icons.lock,
              isPassword: true,
              keyboardType: TextInputType.visiblePassword,
              autofillHints: const [AutofillHints.password],
              enabled: _isEmailPasswordUser,
              fillColor: Colors.grey[200]!,
              borderRadius: 50,
            ),
            const SizedBox(height: 15),
            MyTextField(
              controller: _newPasswordController,
              hintText: "New Password",
              icon: Icons.lock,
              isPassword: true,
              keyboardType: TextInputType.visiblePassword,
              autofillHints: const [AutofillHints.newPassword],
              enabled: _isEmailPasswordUser,
              fillColor: Colors.grey[200]!,
              borderRadius: 50,
            ),
            const SizedBox(height: 15),
            MyTextField(
              controller: _confirmPasswordController,
              hintText: "Confirm New Password",
              icon: Icons.lock_reset,
              isPassword: true,
              keyboardType: TextInputType.visiblePassword,
              autofillHints: const [AutofillHints.password],
              enabled: _isEmailPasswordUser,
              fillColor: Colors.grey[200]!,
              borderRadius: 50,
            ),
            const SizedBox(height: 30),
            if (!_isEmailPasswordUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  "Password changes are not available for Google/Facebook accounts"
                      .tr(),
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ),
            Center(
              child: MyElevatedButton(
                text: "Save",
                onPressed: _isEmailPasswordUser ? _changePassword : () {},
                backgroundColor: AppColors.buttonColor,
                textColor: Colors.white,
                borderRadius: 50,
                height: 50.0,
                width: double.infinity,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
