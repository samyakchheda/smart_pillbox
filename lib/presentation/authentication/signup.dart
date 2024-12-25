import 'package:flutter/material.dart';
import 'package:home/home_page.dart';
import '../../common/theme/app_color.dart';
import '../../common/widgets/snackbar/basic_snack_bar.dart';
import '../../services/providers/auth_service.dart';
import 'signin.dart';
import '../home/home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSecurePassword = true;

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
  }

  void signUpUser() async {
    if (_formKey.currentState!.validate()) {
      String res = await AuthService().signUpUser(
        email: _emailController.text,
        password: _passwordController.text,
        name: _usernameController.text,
      );

      if (res == "success") {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (BuildContext context) => HomePage(),
          ),
        );
      } else {
        showSnackBar(context, res);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const SizedBox(height: 20),
                _usernameTextField(),
                const SizedBox(height: 18),
                _emailTextField(),
                const SizedBox(height: 18),
                _passwordTextField(),
                const SizedBox(height: 70),
                ElevatedButton(
                  onPressed: signUpUser,
                  child: const Text("Create Account"),
                ),
                const SizedBox(height: 10),
                _dividerWithOr(),
                const SizedBox(height: 10),
                _googleSignInButton(),
                const SizedBox(height: 10),
                _navigateToLoginScreen(),
              ],
            ),
          ),
        ),
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

  Widget _usernameTextField() {
    return TextFormField(
      controller: _usernameController,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.person),
        hintText: 'Enter Your Name',
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your name';
        }
        return null;
      },
    );
  }

  Widget _emailTextField() {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(
        prefixIcon: Icon(Icons.email),
        hintText: 'Enter Your Email',
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your email';
        }
        if (!RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$')
            .hasMatch(value)) {
          return 'Please enter a valid email address';
        }
        return null;
      },
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      controller: _passwordController,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.lock),
        hintText: 'Enter Your Password',
        suffixIcon: togglePassword(),
      ).applyDefaults(Theme.of(context).inputDecorationTheme),
      obscureText: _isSecurePassword,
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters long';
        }
        return null;
      },
    );
  }

  Widget togglePassword() {
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

  Widget _navigateToLoginScreen() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Do you have an account? '),
          GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const SigninScreen(),
                ),
                (route) => false, // Remove all previous routes
              );
            },
            child: const Text(
              'Log In',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
