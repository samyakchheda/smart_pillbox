import 'package:flutter/material.dart';
import 'package:home/presentation/authentication/login/login_screen.dart';
import 'package:home/presentation/authentication/password/change_password_screen.dart';
import 'package:home/presentation/authentication/password/forgot_password_screen.dart';
import 'package:home/presentation/authentication/signup/signup_screen.dart';
import 'package:home/presentation/home/home_screen.dart';
import 'package:home/presentation/onboarding/onboarding_screen.dart';
import 'package:home/presentation/profile/profile_setup/profile_completion_screen.dart';
import 'package:home/presentation/profile/profile_setup/profile_picture_screen.dart';
import 'package:home/presentation/profile/profile_setup/user_info_screen.dart';
import 'package:home/presentation/profile/user_profile_screen.dart';
import 'package:home/presentation/splash/splash_screen.dart';

class Routes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgotpassword';
  static const String userinfo = '/userinfo';
  static const String profilePicture = '/profilePicture';
  static const String profileCompletion = '/profileCompletion';
  static const String userProfile = '/userProfile';
  static const String editProfile = '/editProfile';
  static const String changePassword = '/changePassword';

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

      case userinfo:
        return MaterialPageRoute(builder: (_) => const UserInfoScreen());

      case profilePicture:
        return MaterialPageRoute(builder: (_) => const ProfilePictureScreen());

      case profileCompletion:
        return MaterialPageRoute(
            builder: (_) => const ProfileCompletionScreen());

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());

      case userProfile:
        return MaterialPageRoute(builder: (_) => const UserProfileScreen());

      case changePassword:
        return MaterialPageRoute(builder: (_) => const ChangePasswordScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
