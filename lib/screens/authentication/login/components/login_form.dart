import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:home/main.dart';
import 'package:home/services/auth_service/email_auth_service.dart';
import 'package:home/services/auth_service/facebook_auth_service.dart';
import 'package:home/services/auth_service/google_auth_service.dart';
import '../../../../helpers/otp_auth_service.dart';
import '../../../../routes/routes.dart';
import '../../../../theme/app_colors.dart';
import '../../../../theme/app_fonts.dart';
import '../../../../helpers/validators.dart';
import '../../../../widgets/common/divider_with_or.dart';
import '../../../../widgets/common/my_snack_bar.dart';
import '../../../../widgets/common/my_text_field.dart';
import '../../../../widgets/common/my_elevated_button.dart';

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
  Timer? _timer;
  int _secondsRemaining = 60;
  bool _showOtpScreen = false;
  final OtpAuthService _otpService = OtpAuthService();

  // OTP Controllers
  final List<TextEditingController> _otpControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _otpFocusNodes = List.generate(6, (_) => FocusNode());

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() => setState(() {}));
    _passwordController.addListener(() => setState(() {}));
    _checkClipboardForOtp();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var focusNode in _otpFocusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _startTimer() {
    _secondsRemaining = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  Future<void> _checkClipboardForOtp() async {
    ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null && data.text != null) {
      String text = data.text!.trim();
      if (text.length == 6 && RegExp(r'^\d{6}$').hasMatch(text)) {
        for (int i = 0; i < 6; i++) {
          _otpControllers[i].text = text[i];
        }
        _verifyOtp();
      }
    }
  }

  Future<void> loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String res = await EmailAuthService().login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (res == "success") {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        try {
          bool isOtpEnabled = await _otpService.checkOtpEnabled(user.uid);
          if (isOtpEnabled) {
            await _otpService.generateAndSendOtp(user.email!, user.uid);
            _startTimer();
            setState(() => _showOtpScreen = true);
            mySnackBar(context, "OTP sent to your email", isError: false);
          } else {
            _navigateAfterLogin(user);
          }
        } catch (e) {
          mySnackBar(context, "Error: $e", isError: true);
          setState(() => _isLoading = false);
        }
      } else {
        mySnackBar(context, "No user found after login", isError: true);
        setState(() => _isLoading = false);
      }
    } else {
      mySnackBar(context, res, isError: true);
      setState(() => _isLoading = false);
    }
  }

  void _navigateAfterLogin(User user) async {
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
    setupFCM();
    setState(() => _isLoading = false);
  }

  Future<void> signInWithGoogle() async {
    setState(() => _isLoading = true);
    String? result = await GoogleAuthService().loginWithGoogle();

    if (result == null) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        try {
          bool isOtpEnabled = await _otpService.checkOtpEnabled(user.uid);
          if (isOtpEnabled) {
            await _otpService.generateAndSendOtp(user.email!, user.uid);
            _startTimer();
            setState(() {
              _isLoading = false;
              _showOtpScreen = true;
            });
            mySnackBar(context, "OTP sent to your email", isError: false);
          } else {
            mySnackBar(context, "Google Sign-In successful!", isError: false);
            _navigateAfterLogin(user);
          }
        } catch (e) {
          mySnackBar(context, "Error: $e", isError: true);
          setState(() => _isLoading = false);
        }
      } else {
        mySnackBar(context, 'Google Sign-In failed: No user found',
            isError: true);
        setState(() => _isLoading = false);
      }
    } else {
      mySnackBar(context, result, isError: true);
      setState(() => _isLoading = false);
    }
  }

  Future<void> signInWithFacebook() async {
    setState(() => _isLoading = true);
    final fbAuthService = FacebookAuthService();

    String? result = await fbAuthService.loginWithFacebook();

    if (result == null) {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null && user.email != null) {
        try {
          bool isOtpEnabled = await _otpService.checkOtpEnabled(user.uid);
          if (isOtpEnabled) {
            await _otpService.generateAndSendOtp(user.email!, user.uid);
            _startTimer();
            setState(() {
              _isLoading = false;
              _showOtpScreen = true;
            });
            mySnackBar(context, "OTP sent to your email", isError: false);
          } else {
            mySnackBar(context, "Facebook Sign-In successful!", isError: false);
            _navigateAfterLogin(user);
          }
        } catch (e) {
          mySnackBar(context, "Error: $e", isError: true);
          setState(() => _isLoading = false);
        }
      } else {
        mySnackBar(context, 'Facebook Sign-In failed: No user found',
            isError: true);
        setState(() => _isLoading = false);
      }
    } else {
      mySnackBar(context, result, isError: true);
      setState(() => _isLoading = false);
    }
  }

  void _verifyOtp() async {
    String otp = _otpControllers.map((c) => c.text).join();
    if (otp.length == 6) {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          bool verified = await _otpService.verifyOtp(otp, user.uid);
          if (verified) {
            _timer?.cancel();
            _navigateAfterLogin(user);
          } else {
            mySnackBar(context, "Invalid OTP", isError: true);
          }
        }
      } catch (e) {
        mySnackBar(context, e.toString(), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            child: _showOtpScreen ? _buildOtpScreen() : _buildLoginForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Text(
            "Welcome Back!".tr(),
            style: AppFonts.headline.copyWith(
              fontSize: 25,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 20),
        MyTextField(
          controller: _emailController,
          hintText: 'Enter Your Email'.tr(),
          icon: Icons.email,
          keyboardType: TextInputType.emailAddress,
          validator: Validators.validateEmail,
          fillColor: AppColors.cardBackground,
          autofillHints: const [AutofillHints.email],
        ),
        const SizedBox(height: 20),
        MyTextField(
          controller: _passwordController,
          hintText: 'Enter Your Password'.tr(),
          icon: Icons.lock,
          isPassword: true,
          validator: Validators.validatePassword,
          fillColor: AppColors.cardBackground,
          autofillHints: const [AutofillHints.password],
        ),
        _forgotPasswordText(context),
        const SizedBox(height: 25),
        _isLoading
            ? CircularProgressIndicator(color: AppColors.buttonColor)
            : MyElevatedButton(
                text: "Login".tr(),
                backgroundColor: AppColors.buttonColor,
                onPressed: loginUser,
                height: 60,
                borderRadius: 50,
                width: 380,
              ),
        const SizedBox(height: 20),
        const DividerWithOr(),
        const SizedBox(height: 20),
        MyElevatedButton(
          onPressed: signInWithGoogle,
          backgroundColor: AppColors.cardBackground,
          textColor: AppColors.textPrimary,
          height: 60,
          borderRadius: 50,
          borderSide: BorderSide(color: AppColors.borderColor, width: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/icons/ic_google.png", height: 24),
              const SizedBox(width: 10),
              Text(
                "Continue With Google".tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        MyElevatedButton(
          onPressed: signInWithFacebook,
          backgroundColor: AppColors.cardBackground,
          textColor: AppColors.textPrimary,
          height: 60,
          borderRadius: 50,
          borderSide: BorderSide(color: AppColors.borderColor, width: 2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset("assets/icons/ic_fb.png", height: 24),
              const SizedBox(width: 10),
              Text(
                "Continue With Facebook".tr(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
        _navigateToSignupScreen(),
      ],
    );
  }

  Widget _buildOtpScreen() {
    return Column(
      children: [
        Text(
          "Verify Your OTP".tr(),
          style: AppFonts.headline.copyWith(
            fontSize: 28,
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Enter the 6-digit code sent to your email".tr(),
          style: AppFonts.caption.copyWith(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(6, (index) {
            return Flexible(
              child: Container(
                constraints: const BoxConstraints(
                  minWidth: 45,
                  maxWidth: 60,
                ),
                height: 60,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: TextFormField(
                  controller: _otpControllers[index],
                  focusNode: _otpFocusNodes[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 1,
                  style: AppFonts.bodyText.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    counterText: "",
                    filled: true,
                    fillColor: AppColors.cardBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.buttonColor,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                  onChanged: (value) {
                    if (value.isNotEmpty && index < 5) {
                      _otpFocusNodes[index + 1].requestFocus();
                    }
                    if (value.isEmpty && index > 0) {
                      _otpFocusNodes[index - 1].requestFocus();
                    }
                    if (index == 5 && value.isNotEmpty) {
                      _verifyOtp();
                    }
                  },
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.timer, color: AppColors.textSecondary, size: 20),
            const SizedBox(width: 5),
            Text(
              'Time remaining: $_secondsRemaining sec',
              style: AppFonts.caption.copyWith(
                fontSize: 16,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 30),
        MyElevatedButton(
          onPressedAsync: _secondsRemaining == 0
              ? () async {
                  try {
                    User? user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      await _otpService.resendOtp(user.email!, user.uid);
                      _startTimer();
                      mySnackBar(context, "New OTP sent", isError: false);
                    }
                  } catch (e) {
                    mySnackBar(context, e.toString(), isError: true);
                  }
                }
              : null,
          backgroundColor:
              _secondsRemaining == 0 ? AppColors.buttonColor : Colors.grey,
          text: _secondsRemaining == 0
              ? "Resend OTP"
              : "Resend in $_secondsRemaining s",
          height: 50,
          width: 200,
          borderRadius: 25,
          disabled: _secondsRemaining > 0,
        ),
        const SizedBox(height: 20),
        TextButton(
          onPressed: () {
            setState(() => _showOtpScreen = false);
            for (var controller in _otpControllers) {
              controller.clear();
            }
          },
          child: Text(
            "Back to Login".tr(),
            style: AppFonts.bodyText.copyWith(
              color: AppColors.buttonColor,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _forgotPasswordText(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          Navigator.pushNamed(context, Routes.forgotPassword);
        },
        child: Text(
          "Forgot Password?".tr(),
          style: AppFonts.bodyText.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.buttonColor,
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
        text: TextSpan(
          text: "Don't have an account? ".tr(),
          style: AppFonts.bodyText.copyWith(
            color: AppColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
          children: [
            TextSpan(
              text: "Sign Up".tr(),
              style: AppFonts.bodyText.copyWith(
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

extension WidgetExtension on Widget {
  Widget also(void Function(Widget) callback) {
    callback(this);
    return this;
  }
}
