import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:home/main.dart';
import 'package:home/services/auth_service/email_auth_service.dart';
import 'package:home/services/auth_service/facebook_auth_service.dart';
import 'package:home/services/auth_service/google_auth_service.dart';
import '../../../../routes/routes.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_fonts.dart';
import '../../../../helpers/validators.dart';
import '../../../../widgets/divider_with_or.dart';
import '../../../../widgets/my_elevated_button.dart';
import '../../../../widgets/my_snack_bar.dart';
import '../../../../widgets/my_text_field.dart';

class SignupForm extends StatefulWidget {
  const SignupForm({super.key});

  @override
  State<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<SignupForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isChecked = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Sign up using email and password with caretaker integration.
  Future<void> signUpUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String res = await EmailAuthService().signUp(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (res == "success") {
      // After successful sign-up, fetch the current user.
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        final normalizedEmail = user.email!.trim().toLowerCase();
        // Check if the email exists in the caretakers collection.
        final querySnapshot = await FirebaseFirestore.instance
            .collection('caretakers')
            .where('email', isEqualTo: normalizedEmail)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          Navigator.pushReplacementNamed(context, Routes.caretakerHome);
        } else {
          Navigator.pushReplacementNamed(context, Routes.userinfoscreen);
        }
      } else {
        Navigator.pushReplacementNamed(context, Routes.userinfoscreen);
      }
    } else {
      mySnackBar(context, res, isError: true);
    }
    setupFCM();
  }

  /// Google Sign-Up with caretaker integration.
  /// Google Sign-Up with caretaker integration.
  Future<void> signInWithGoogle() async {
    setState(() => _isLoading = true);

    // Call GoogleAuthService().loginWithGoogle() which returns a String error or null on success.
    String? result = await GoogleAuthService().signUpWithGoogle();

    setState(() => _isLoading = false);

    if (result == null) {
      // Login was successful. Retrieve the current user.
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        final normalizedEmail = user.email!.trim().toLowerCase();
        final querySnapshot = await FirebaseFirestore.instance
            .collection('caretakers')
            .where('email', isEqualTo: normalizedEmail)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          Navigator.pushReplacementNamed(context, Routes.caretakerHome);
        } else {
          Navigator.pushReplacementNamed(context, Routes.userinfoscreen);
        }
      } else {
        mySnackBar(context, 'Google Sign-In failed: No user found',
            isError: true);
      }
    } else {
      // There was an error during Google login.
      mySnackBar(context, result, isError: true);
    }
    setupFCM();
  }

  /// Facebook Sign-Up with caretaker integration.
  Future<void> signInWithFacebook() async {
    setState(() => _isLoading = true);

    try {
      final fbAuthService = FacebookAuthService();
      // The Facebook service should return user data or credentials.
      final userData = await fbAuthService.signInWithFacebook();

      if (userData == null) {
        setState(() => _isLoading = false);
        mySnackBar(context, "Facebook sign-in failed. Try again.",
            isError: true);
        return;
      }

      // Authenticate with Firebase using the Facebook access token.
      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(
        FacebookAuthProvider.credential(userData['accessToken']),
      );

      User? user = userCredential.user;
      if (user != null && user.email != null) {
        final normalizedEmail = user.email!.trim().toLowerCase();
        // Check if the user's email exists in the caretakers collection.
        final querySnapshot = await FirebaseFirestore.instance
            .collection('caretakers')
            .where('email', isEqualTo: normalizedEmail)
            .get();
        if (querySnapshot.docs.isNotEmpty) {
          Navigator.pushReplacementNamed(context, Routes.caretakerHome);
        } else {
          Navigator.pushReplacementNamed(context, Routes.userinfoscreen);
        }
      } else {
        mySnackBar(context, "Failed to sign in with Firebase.", isError: true);
      }
    } catch (e) {
      mySnackBar(context, "Facebook sign-in error: ${e.toString()}",
          isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
    setupFCM();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Text(
                  "Become a SmartDose Member!",
                  style: AppFonts.headline.copyWith(
                    color: AppColors.textPrimary,
                    fontSize: 30,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              MyTextField(
                controller: _emailController,
                hintText: 'Enter Your Email',
                icon: Icons.email,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.validateEmail,
                fillColor: AppColors.cardBackground,
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.email
                ],
              ),
              const SizedBox(height: 20),
              MyTextField(
                controller: _passwordController,
                hintText: 'Enter Your Password',
                icon: Icons.lock,
                isPassword: true,
                validator: Validators.validatePassword,
                fillColor: AppColors.cardBackground,
                keyboardType: TextInputType.visiblePassword,
                autofillHints: const [AutofillHints.newPassword],
              ),
              const SizedBox(height: 20),
              MyTextField(
                controller: _confirmPasswordController,
                hintText: 'Confirm Your Password',
                icon: Icons.lock,
                isPassword: true,
                validator: (value) => value == _passwordController.text
                    ? null
                    : "Passwords do not match!",
                fillColor: AppColors.cardBackground,
                keyboardType: TextInputType.visiblePassword,
                autofillHints: const [AutofillHints.newPassword],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _isChecked,
                    onChanged: (value) => setState(() => _isChecked = value!),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {},
                      child: const Text(
                        "I agree to the Privacy Policy and Terms of Use",
                        style: TextStyle(
                            fontSize: 14, color: AppColors.textSecondary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ConstrainedBox(
                      constraints:
                          const BoxConstraints(maxWidth: double.infinity),
                      child: MyElevatedButton(
                        text: "Register",
                        onPressed: () {
                          if (!_isChecked) {
                            mySnackBar(
                              context,
                              "Please agree to the Terms of Use and Privacy Policy to continue.",
                              isError: true,
                            );
                            return;
                          }
                          signUpUser();
                        },
                        backgroundColor: AppColors.buttonColor,
                        height: 60,
                        borderRadius: 50,
                      ),
                    ),
              const SizedBox(height: 15),
              const DividerWithOr(),
              const SizedBox(height: 20),
              MyElevatedButton(
                text: "Continue With Google",
                onPressed: signInWithGoogle,
                backgroundColor: Colors.white,
                textColor: AppColors.kBlackColor,
                borderRadius: 50,
                icon: Image.asset("assets/icons/ic_google.png"),
                height: 60,
                borderColor: AppColors.kBlackColor,
              ),
              const SizedBox(height: 15),
              MyElevatedButton(
                text: "Continue With Facebook",
                onPressed: signInWithFacebook,
                backgroundColor: Colors.white,
                textColor: AppColors.kBlackColor,
                borderRadius: 50,
                icon: Image.asset("assets/icons/ic_fb.png"),
                height: 60,
                borderColor: AppColors.kBlackColor,
              ),
              const SizedBox(height: 15),
              _navigateToLoginScreen(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navigateToLoginScreen() {
    return InkWell(
      onTap: () {
        Navigator.pushReplacementNamed(context, Routes.login);
      },
      child: RichText(
        text: const TextSpan(
          text: "Already have an account? ",
          style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w400),
          children: [
            TextSpan(
              text: "Login",
              style: TextStyle(
                  color: AppColors.buttonColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
