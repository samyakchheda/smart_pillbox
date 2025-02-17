import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../routes/routes.dart';
import '../../../../services/auth_service/auth_service.dart';
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

    String res = await AuthService().loginUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() {
      _isLoading = false;
    });

    if (res == "success") {
      mySnackBar(context, "Login successful!", isError: false);
      Navigator.pushReplacementNamed(context, Routes.home);
    } else {
      mySnackBar(context, res, isError: true);
    }
  }

  Future<void> signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    User? user = await AuthService().signInWithGoogle();

    setState(() {
      _isLoading = false;
    });

    if (user != null) {
      mySnackBar(context, "Google Sign-In successful!", isError: false);
      Navigator.pushReplacementNamed(context, Routes.home);
    } else {
      mySnackBar(context, 'Google Sign-In failed', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: AutofillGroup(
          // Improves autofill behavior
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
                  autofillHints: const [
                    AutofillHints.email
                  ], // Enable email autofill
                ),
                const SizedBox(height: 20),
                MyTextField(
                  controller: _passwordController,
                  hintText: 'Enter Your Password',
                  icon: Icons.lock,
                  isPassword: true,
                  validator: Validators.validatePassword,
                  fillColor: AppColors.cardBackground,
                  autofillHints: const [
                    AutofillHints.password
                  ], // Enable password autofill
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
                  onPressed: () async {
                    AuthService().signInWithFacebook();
                  },
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
