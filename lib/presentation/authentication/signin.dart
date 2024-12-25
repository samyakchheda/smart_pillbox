import 'package:flutter/material.dart';
import 'package:home/home_page.dart';
import 'package:home/presentation/authentication/signup.dart';
import '../../common/widgets/snackbar/basic_snack_bar.dart';
import '../../common/theme/app_color.dart';
import '../../services/providers/auth_service.dart';
import '../home/home_screen.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSecurePassword = true;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // void loginUser() async {
  //   if (_formKey.currentState?.validate() ?? false) {
  //     String res = await AuthService().loginUser(
  //       email: _emailController.text.trim(),
  //       password: _passwordController.text.trim(),
  //     );
  //
  //     if (res == "success") {
  //       Navigator.of(context).pushReplacement(
  //         MaterialPageRoute(
  //           builder: (BuildContext context) => const HomeScreen(),
  //         ),
  //       );
  //     } else {
  //       showSnackBar(context, res);
  //     }
  //   }
  // }
  void loginUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      String res = await AuthService().loginUser(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (res == "success") {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false, // Remove all previous routes
        );
      } else {
        showSnackBar(context, res);
      }
    }
  }

  void showForgotPasswordDialog(BuildContext context) {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Forgot Password?"),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                children: [
                  const Text(
                    "Enter your registered email to receive a password reset link.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.email),
                      hintText: "Enter Your Email",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your email";
                      }
                      if (!RegExp(
                              r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
                          .hasMatch(value)) {
                        return "Please enter a valid email address";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        String res = await AuthService().sendPasswordResetEmail(
                          email: emailController.text.trim(),
                        );
                        if (res == "success") {
                          showSnackBar(context, "Password reset email sent.");
                          Navigator.pop(context); // Close the dialog
                        } else {
                          showSnackBar(context, res);
                        }
                      }
                    },
                    child: const Text("Send Reset Link"),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close the dialog
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                _emailAddressTextField(),
                const SizedBox(height: 18),
                _passwordTextField(),
                _forgotPasswordText(),
                const SizedBox(height: 70),
                ElevatedButton(
                  onPressed: loginUser,
                  child: const Text('Login'),
                ),
                const SizedBox(height: 10),
                _dividerWithOr(),
                const SizedBox(height: 10),
                _googleSignInButton(),
                const SizedBox(height: 10),
                _navigateToSignupScreen(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _emailAddressTextField() {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.email),
        hintText: "Enter Your Email",
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        return null;
      },
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _isSecurePassword,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: _togglePassword(),
        hintText: "Enter Your Password",
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        return null;
      },
    );
  }

  Widget _togglePassword() {
    return Padding(
      padding: const EdgeInsets.all(5.0),
      child: IconButton(
        onPressed: () {
          setState(() {
            _isSecurePassword = !_isSecurePassword;
          });
        },
        icon: _isSecurePassword
            ? const Icon(Icons.visibility)
            : const Icon(Icons.visibility_off),
        color: AppColors.kGreyColor,
      ),
    );
  }

  Widget _dividerWithOr() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Divider(
            thickness: 1,
            color: Colors.grey.shade400,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: Text(
            'or',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        Expanded(
          child: Divider(
            thickness: 1,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }

  Widget _googleSignInButton() {
    return ElevatedButton.icon(
      onPressed: () {
        AuthService().signInWithGoogle(context);
      },
      icon: Image.asset(
        'assets/icons/ic_google.png', // Ensure you have the Google logo in your assets folder
        height: 24,
      ),
      label: const Text(
        'Continue with Google',
        style: TextStyle(fontSize: 16),
      ),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _forgotPasswordText() {
    return Padding(
      padding: const EdgeInsets.only(top: 5, right: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              showForgotPasswordDialog(context);
            },
            child: const Text(
              "Forgot Password?",
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _navigateToSignupScreen() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Don\'t have an account? '),
          GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const SignupScreen(),
                ),
                (route) => false, // Remove all previous routes
              );
            },
            child: const Text(
              'Create Now',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
