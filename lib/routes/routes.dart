import 'package:flutter/material.dart';
import 'package:home/screens/authentication/login/login_screen.dart';
import 'package:home/screens/authentication/password/forgot_password_screen.dart';
import 'package:home/screens/authentication/signup/signup_screen.dart';
import 'package:home/screens/caretaker/home/home_screen.dart';
import 'package:home/screens/home/home_screen.dart';
import 'package:home/screens/onboarding/onboarding_screen.dart';
import 'package:home/screens/profile/profile_setup/profile_completion_screen.dart';
import 'package:home/screens/profile/profile_setup/user_info_screen.dart';
import 'package:home/screens/profile/user_profile_screen.dart';
import 'package:home/screens/splash/splash_screen.dart';

class Routes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String caretakerHome = '/caretakerHome';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgotpassword';
  static const String userProfile = '/userProfile';
  static const String editProfile = '/editProfile';
  // static const String changePassword = '/changePassword';
  static const String userinfoscreen = '/userinfoscreen';
  static const String profileCompletion = '/profileCompletion';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());

      case onboarding:
        return MaterialPageRoute(builder: (_) => const OnboardingScreen());

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());

      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen());

      case forgotPassword:
        return MaterialPageRoute(builder: (_) => const ForgotPasswordScreen());

      case userinfoscreen:
        return MaterialPageRoute(builder: (_) => const UserInfoScreen());

      case profileCompletion:
        return MaterialPageRoute(
            builder: (_) => const ProfileCompletionScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case caretakerHome:
        return MaterialPageRoute(builder: (_) => const CareTakerHomeScreen());

      case userProfile:
        return MaterialPageRoute(builder: (_) => const UserProfileScreen());

      // case changePassword:
      //   return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
