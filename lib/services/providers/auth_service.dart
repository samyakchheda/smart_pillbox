import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Sign up user with email and password
  Future<String> signUpUser({
    required String email,
    required String password,
    required String name,
  }) async {
    String res = 'Some error occurred';
    try {
      if (email.isNotEmpty && password.isNotEmpty && name.isNotEmpty) {
        UserCredential credential =
            await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (credential.user != null) {
          // Save the user data in Firestore
          await _firestore.collection('users').doc(credential.user!.uid).set({
            'name': name,
            'email': email,
            'uid': credential.user!.uid,
          });
          res = "success";
        } else {
          res = "Failed to create user.";
        }
      } else {
        res = "Please fill all the fields";
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  // Login user with email and password
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    String res = 'Some error occurred';
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        UserCredential credential =
            await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (credential.user != null) {
          res = "success";
        } else {
          res = "Failed to sign in.";
        }
      } else {
        res = "Please fill all the fields";
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  // Send password reset email
  Future<String> sendPasswordResetEmail({required String email}) async {
    String res = 'Some error occurred';
    try {
      if (email.isNotEmpty) {
        await _firebaseAuth.sendPasswordResetEmail(email: email);
        res = "success";
      } else {
        res = "Please provide an email address";
      }
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  // Sign out user
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Future<UserCredential?> signInWithGoogle(BuildContext context) async {
  //   try {
  //     // Start the sign-in process
  //     final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
  //     if (gUser == null) {
  //       // User canceled the Google Sign-In flow
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text("Google Sign-In was canceled.")),
  //       );
  //       return null;
  //     }
  //
  //     // Obtain the auth details from the request
  //     final GoogleSignInAuthentication gAuth = await gUser.authentication;
  //
  //     // Create a credential for Firebase
  //     final OAuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: gAuth.accessToken,
  //       idToken: gAuth.idToken,
  //     );
  //
  //     // Sign in with the credential
  //     final UserCredential userCredential =
  //     await _firebaseAuth.signInWithCredential(credential);
  //
  //     // Verify and log user details
  //     final User? user = userCredential.user;
  //     if (user != null) {
  //       print('Google Sign-In successful. User UID: ${user.uid}');
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Welcome, ${user.displayName}!")),
  //       );
  //       return userCredential;
  //     } else {
  //       throw FirebaseAuthException(
  //           code: 'USER_NULL', message: "User returned as null after sign-in.");
  //     }
  //   } catch (e) {
  //     // Handle and log errors
  //     print('Error during Google Sign-In: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error: ${e.toString()}")),
  //     );
  //     return null;
  //   }
  // }

  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      // Start the sign-in process
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      if (gUser == null) {
        // User canceled the Google Sign-In flow
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Google Sign-In was canceled.")),
        );
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      // Create a credential for Firebase
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      // Sign in with the credential
      final UserCredential userCredential =
      await _firebaseAuth.signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user != null) {
        // If the user is not already in Firestore, save their details
        DocumentReference userRef = _firestore.collection('users').doc(user.uid);
        final docSnapshot = await userRef.get();

        if (!docSnapshot.exists) {
          await userRef.set({
            'name': user.displayName,
            'email': user.email,
            'profilePicture': user.photoURL ?? '',
            'uid': user.uid,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Welcome, ${user.displayName}!")),
          );
        }

        // After signing in and saving user details, navigate to HomeScreen
        return userCredential;
      } else {
        throw FirebaseAuthException(
            code: 'USER_NULL', message: "User returned as null after sign-in.");
      }
    } catch (e) {
      // Handle and log errors
      print('Error during Google Sign-In: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
      return null;
    }
  }
}
