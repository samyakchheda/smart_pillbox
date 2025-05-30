import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// Google Sign-Up with caretaker integration.
  Future<String?> signUpWithGoogle() async {
    try {
      // Force a sign-out to ensure a fresh session.
      await _googleSignIn.signOut();
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return "Google sign-in was cancelled";

      // Normalize the email.
      final normalizedEmail = googleUser.email.trim().toLowerCase();

      // Check if a user with this email already exists in Firestore.
      final QuerySnapshot userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: normalizedEmail)
          .get();

      if (userQuery.docs.isNotEmpty) {
        await _googleSignIn.signOut();
        return "An account with this email already exists. Please login instead.";
      }

      // Check if an account with this email exists in Firebase Authentication.
      final List<String> signInMethods =
          await _firebaseAuth.fetchSignInMethodsForEmail(googleUser.email);
      if (signInMethods.isNotEmpty) {
        await _googleSignIn.signOut();
        return "An account with this email already exists. Please login instead.";
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;
      if (user == null) return "Authentication failed";

      // Check if this is a new user.
      if (!userCredential.additionalUserInfo!.isNewUser) {
        // If the user is not new, they already exist in Firebase Authentication.
        await user.delete(); // Delete the newly created user.
        await _firebaseAuth.signOut();
        await _googleSignIn.signOut();
        return "An account with this Google account already exists. Please login instead.";
      }

      // Store user details in Firestore.
      await _firestore.collection('users').doc(user.uid).set({
        'email': normalizedEmail,
        'uid': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        // Add other fields as needed.
      });

      // Query the "caretakers" collection.
      final QuerySnapshot caretakerQuery = await _firestore
          .collection('caretakers')
          .where('email', isEqualTo: normalizedEmail)
          .get();

      if (caretakerQuery.docs.isNotEmpty) {
        print("User is a caretaker: $normalizedEmail");
        // Optionally, implement additional caretaker-specific logic here.
      }

      return null; // Sign-up successful.
    } catch (e) {
      return "Error during Google sign-up: ${e.toString()}";
    }
  }

  /// Google Login with caretaker integration.
  Future<String?> loginWithGoogle() async {
    try {
      await _googleSignIn.signOut();
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        return "Google sign-in was cancelled";
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) {
        return "Authentication failed";
      }

      // Check if the user has an existing record in your Firestore (or other DB)
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final bool accountExists = userDoc.exists;

      if (!accountExists ||
          (userCredential.additionalUserInfo?.isNewUser ?? false)) {
        // Delete the auto-created account if no record is found
        await user.delete();
        await _firebaseAuth.signOut();
        return "No account found with this email. Please sign up first.";
      }

      // Additional caretaker-specific checks (if needed)
      final normalizedEmail = user.email?.trim().toLowerCase() ?? '';
      final caretakerQuery = await _firestore
          .collection('caretakers')
          .where('email', isEqualTo: normalizedEmail)
          .get();

      if (caretakerQuery.docs.isNotEmpty) {
        print("User is a caretaker: $normalizedEmail");
        // Implement caretaker-specific logic if needed.
      }

      return null; // Login successful.
    } catch (e) {
      return "Error during Google login: ${e.toString()}";
    }
  }

  /// Logout from Google.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    await _googleSignIn.signOut();
  }
}
