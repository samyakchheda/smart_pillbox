import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../routes/routes.dart';
import '../../../../services/auth_service/auth_service.dart';
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

  void signUpUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String res = await AuthService().signUpUser(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (res == "success") {
      Navigator.pushReplacementNamed(context, Routes.userinfo);
    } else {
      mySnackBar(context, res, isError: true);
    }
  }

  Future<void> signInWithGoogle() async {
    setState(() => _isLoading = true);

    User? user = await AuthService().signInWithGoogle();

    setState(() => _isLoading = false);

    if (user != null) {
      Navigator.pushReplacementNamed(context, Routes.home);
    } else {
      mySnackBar(context, 'Google Sign-In failed', isError: true);
    }
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
                autofillHints: const [
                  AutofillHints.newPassword
                ], // Correct hint for new passwords
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
                autofillHints: const [
                  AutofillHints.newPassword
                ], // Corrected autofill hint
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Checkbox(
                    value: _isChecked,
                    onChanged: (value) {
                      setState(() => _isChecked = value!);
                    },
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
            fontWeight: FontWeight.w400,
          ),
          children: [
            TextSpan(
              text: "Login",
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
