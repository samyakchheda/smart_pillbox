import 'package:firebase_auth/firebase_auth.dart';

class PasswordService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> sendPasswordResetEmail(String email) async {
    try {
      if (email.isEmpty) return "Please enter your email.";
      await _firebaseAuth.sendPasswordResetEmail(email: email);
      return "If an account exists with this email, a reset link has been sent.";
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      print('Unexpected error in sendPasswordResetEmail: $e');
      return "An unexpected error occurred. Please try again.";
    }
  }

  /// 🔹 **Check User's Sign-In Provider**
  Future<bool> isEmailPasswordUser() async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user == null) return false;

      // Fetch the provider data for the current user
      final providerData = user.providerData;

      // Check if any provider is email/password (providerId == 'password')
      return providerData.any((info) => info.providerId == 'password');
    } catch (e) {
      print('Error in isEmailPasswordUser: $e');
      return false;
    }
  }

  /// 🔹 **Change Password (User must be logged in and using email/password)**
  Future<String> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      User? user = _firebaseAuth.currentUser;
      if (user == null) return "User not logged in.";

      // Check if the user signed in with email/password
      bool isEmailPassword = await isEmailPasswordUser();
      if (!isEmailPassword) {
        return "Password changes are only available for email/password accounts. "
            "For Google or Facebook accounts, use their respective password management.";
      }

      if (user.email == null) return "User email is missing.";

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      // 🔥 **Re-authenticate the user**
      await user.reauthenticateWithCredential(credential);

      // 🔹 Update password
      await user.updatePassword(newPassword);
      return "Password changed successfully.";
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      print('Unexpected error in changePassword: $e');
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
        print('FirebaseAuthException: ${e.code} - ${e.message}');
        return "Authentication error: ${e.message}";
    }
  }
}
