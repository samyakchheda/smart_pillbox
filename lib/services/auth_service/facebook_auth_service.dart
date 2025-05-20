import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FacebookAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FacebookAuth _facebookAuth = FacebookAuth.instance;

  /// Facebook Sign-Up with caretaker integration
  Future<String?> signUpWithFacebook() async {
    try {
      // Force a sign-out to ensure a fresh session
      await _facebookAuth.logOut();

      // Initiate Facebook login
      final LoginResult result = await _facebookAuth.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status != LoginStatus.success) {
        return "Facebook sign-in was cancelled or failed";
      }

      final AccessToken? accessToken = result.accessToken;
      if (accessToken == null) {
        return "Failed to retrieve Facebook access token";
      }

      // Create Firebase credential
      final OAuthCredential credential =
          FacebookAuthProvider.credential(accessToken.tokenString);

      // Check if an account with this email already exists
      final userData = await _facebookAuth.getUserData(fields: "email");
      final String? email = userData['email'];

      if (email != null) {
        final List<String> signInMethods =
            await _firebaseAuth.fetchSignInMethodsForEmail(email);
        if (signInMethods.isNotEmpty) {
          await _facebookAuth.logOut();
          return "An account with this email already exists. Please login instead.";
        }
      }

      // Sign in with Firebase
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        return "Authentication failed";
      }

      // Normalize the email
      final normalizedEmail = user.email?.trim().toLowerCase() ?? '';

      // Query the "caretakers" collection
      if (normalizedEmail.isNotEmpty) {
        final QuerySnapshot caretakerQuery = await _firestore
            .collection('caretakers')
            .where('email', isEqualTo: normalizedEmail)
            .get();

        if (caretakerQuery.docs.isNotEmpty) {
          print("User is a caretaker: $normalizedEmail");
          // Optionally, implement additional caretaker-specific logic here
        }
      }

      return null; // Sign-up successful
    } catch (e) {
      return "Error during Facebook sign-up: ${e.toString()}";
    }
  }

  /// Facebook Login with caretaker integration
  Future<String?> loginWithFacebook() async {
    try {
      // Force a sign-out to ensure a fresh session
      await _facebookAuth.logOut();

      // Initiate Facebook login
      final LoginResult result = await _facebookAuth.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status != LoginStatus.success) {
        return "Facebook sign-in was cancelled or failed";
      }

      final AccessToken? accessToken = result.accessToken;
      if (accessToken == null) {
        return "Failed to retrieve Facebook access token";
      }

      // Create Firebase credential
      final OAuthCredential credential =
          FacebookAuthProvider.credential(accessToken.tokenString);

      // Sign in with Firebase
      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        return "Authentication failed";
      }

      // Check if the user has an existing record
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final bool accountExists = userDoc.exists;

      if (!accountExists ||
          (userCredential.additionalUserInfo?.isNewUser ?? false)) {
        // Delete the auto-created account if no record is found
        await user.delete();
        await _firebaseAuth.signOut();
        return "No account found with this email. Please sign up first.";
      }

      // Caretaker-specific checks
      final normalizedEmail = user.email?.trim().toLowerCase() ?? '';
      if (normalizedEmail.isNotEmpty) {
        final caretakerQuery = await _firestore
            .collection('caretakers')
            .where('email', isEqualTo: normalizedEmail)
            .get();

        if (caretakerQuery.docs.isNotEmpty) {
          print("User is a caretaker: $normalizedEmail");
          // Implement caretaker-specific logic if needed
        }
      }

      return null; // Login successful
    } catch (e) {
      return "Error during Facebook login: ${e.toString()}";
    }
  }

  /// Logout from Facebook
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _facebookAuth.logOut();
  }
}
