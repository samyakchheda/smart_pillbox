import 'package:firebase_auth/firebase_auth.dart';
import 'package:home/services/auth_service/facebook_auth_service.dart';
import 'password_service.dart';
import 'email_auth_service.dart';
import 'google_auth_service.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final EmailAuthService _emailAuthService = EmailAuthService();
  final GoogleAuthService _googleAuthService = GoogleAuthService();
  final FacebookAuthService _facebookAuthService = FacebookAuthService();
  final PasswordService _passwordService = PasswordService();

  /// 🔹 **Google Sign-In**
  Future<User?> signInWithGoogle() => _googleAuthService.signInWithGoogle();

  Future<UserCredential?> signInWithFacebook() =>
      _facebookAuthService.signInWithFacebook();

  /// 🔹 **Email & Password Authentication**
  Future<String> signUpUser(
          {required String email, required String password}) =>
      _emailAuthService.signUpUser(email: email, password: password);

  Future<String> loginUser({required String email, required String password}) =>
      _emailAuthService.loginUser(email: email, password: password);

  /// 🔹 **Password Management**
  Future<String> sendPasswordResetEmail(String email) =>
      _passwordService.sendPasswordResetEmail(email);

  Future<String> changePassword(
          {required String currentPassword, required String newPassword}) =>
      _passwordService.changePassword(
          currentPassword: currentPassword, newPassword: newPassword);

  /// 🔹 **Sign Out**
  Future<void> signOut() async => _emailAuthService.signOut();
}
