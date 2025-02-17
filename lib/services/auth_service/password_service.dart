import 'package:firebase_auth/firebase_auth.dart';

class PasswordService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// 🔹 **Send Password Reset Email**
  Future<String> sendPasswordResetEmail(String email) async {
    try {
      if (email.isEmpty) return "Please enter your email.";

      final providers = await _firebaseAuth.fetchSignInMethodsForEmail(email);
      if (providers.isEmpty) return "No account found with this email.";

      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return "Password reset email sent. Check your inbox.";
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  /// 🔹 **Change Password (User must be logged in)**
  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user == null) return "User not logged in.";

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      // 🔥 **Fix: Re-authenticate the user correctly**
      await user.reauthenticateWithCredential(credential);

      // 🔹 Update password
      await user.updatePassword(newPassword);
      return "Password changed successfully.";
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return "An unexpected error occurred.";
    }
  }

  /// 🔹 **Handle Firebase Authentication Errors**
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case "user-not-found":
        return "No user found with this email.";
      case "invalid-email":
        return "Invalid email format.";
      case "weak-password":
        return "The new password is too weak. Try a stronger one.";
      case "wrong-password":
        return "Current password is incorrect.";
      case "requires-recent-login":
        return "You need to re-login before changing your password.";
      default:
        return "Authentication error: ${e.message}";
    }
  }
}
