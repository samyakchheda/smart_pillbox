import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      setState(() {});
    });
    _passwordController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String res = await EmailAuthService().login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (res == "success") {
      mySnackBar(context, "Login successful!", isError: false);

      // Get the current user from FirebaseAuth.
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        final normalizedEmail = user.email!.trim().toLowerCase();

        // Query the 'caretakers' collection using the normalized email.
        final querySnapshot = await FirebaseFirestore.instance
            .collection('caretakers')
            .where('email', isEqualTo: normalizedEmail)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          Navigator.pushReplacementNamed(context, Routes.caretakerHome);
        } else {
          Navigator.pushReplacementNamed(context, Routes.home);
        }
      } else {
        Navigator.pushReplacementNamed(context, Routes.home);
      }
    } else {
      mySnackBar(context, res, isError: true);
    }
    setupFCM();
  }

  Future<void> signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    // Call loginWithGoogle() and get an error string (or null on success)
    String? result = await GoogleAuthService().loginWithGoogle();

    setState(() {
      _isLoading = false;
    });

    if (result == null) {
      // Success: get the current user from FirebaseAuth
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        mySnackBar(context, "Google Sign-In successful!", isError: false);

        final normalizedEmail = user.email!.trim().toLowerCase();
        final querySnapshot = await FirebaseFirestore.instance
            .collection('caretakers')
            .where('email', isEqualTo: normalizedEmail)
            .get();

        if (querySnapshot.docs.isNotEmpty) {
          Navigator.pushReplacementNamed(context, Routes.caretakerHome);
        } else {
          Navigator.pushReplacementNamed(context, Routes.home);
        }
      } else {
        mySnackBar(context, 'Google Sign-In failed: No user found',
            isError: true);
      }
    } else {
      // There was an error during login
      mySnackBar(context, result, isError: true);
    }
    setupFCM();
  }

  /// New: Integrated caretaker feature for Facebook login.
  Future<void> signInWithFacebook() async {
    setState(() {
      _isLoading = true;
    });

    User? user = (await FacebookAuthService().signInWithFacebook()) as User?;

    setState(() {
      _isLoading = false;
    });

    if (user != null && user.email != null) {
      mySnackBar(context, "Facebook Sign-In successful!", isError: false);

      final normalizedEmail = user.email!.trim().toLowerCase();
      final querySnapshot = await FirebaseFirestore.instance
          .collection('caretakers')
          .where('email', isEqualTo: normalizedEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Navigator.pushReplacementNamed(context, Routes.caretakerHome);
      } else {
        Navigator.pushReplacementNamed(context, Routes.home);
      }
    } else {
      mySnackBar(context, 'Facebook Sign-In failed', isError: true);
    }
    setupFCM();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Text(
                    "Welcome Back!",
                    style: AppFonts.headline.copyWith(
                      fontSize: 25,
                      color: AppColors.textPrimary,
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
                  autofillHints: const [AutofillHints.email],
                ),
                const SizedBox(height: 20),
                MyTextField(
                  controller: _passwordController,
                  hintText: 'Enter Your Password',
                  icon: Icons.lock,
                  isPassword: true,
                  validator: Validators.validatePassword,
                  fillColor: AppColors.cardBackground,
                  autofillHints: const [AutofillHints.password],
                ),
                _forgotPasswordText(context),
                const SizedBox(height: 25),
                _isLoading
                    ? const CircularProgressIndicator(
                        color: AppColors.buttonColor)
                    : MyElevatedButton(
                        text: "Login",
                        onPressed: loginUser,
                        backgroundColor: AppColors.buttonColor,
                        textColor: AppColors.buttonText,
                        height: 60,
                        width: 380,
                        borderRadius: 50,
                      ),
                const SizedBox(height: 20),
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
                _navigateToSignupScreen(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _forgotPasswordText(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, Routes.forgotPassword);
        },
        child: const Text(
          "Forgot Password?",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color.fromARGB(255, 28, 48, 160),
          ),
        ),
      ),
    );
  }

  Widget _navigateToSignupScreen() {
    return InkWell(
      onTap: () {
        Navigator.pushReplacementNamed(context, Routes.signup);
      },
      child: RichText(
        text: const TextSpan(
          text: "Don't have an account? ",
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          children: [
            TextSpan(
              text: "Sign Up",
              style: TextStyle(
                color: AppColors.buttonColor,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
