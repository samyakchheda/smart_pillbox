import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  Future<String> signUpUser({
    required String email,
    required String password,
  }) async {
    String res = 'Some error occurred';
    try {
      if (email.isNotEmpty && password.isNotEmpty) {
        UserCredential credential =
            await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );

        if (credential.user != null) {
          await _firestore.collection('users').doc(credential.user!.uid).set({
            'email': email,
            'uid': credential.user!.uid,
          });

          res = await storeOtherDetails(
            email: email,
            name: '',
            birthDate: '',
            gender: '',
            phoneNumber: '',
          );

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

  Future<String> storeOtherDetails({
    required String email,
    required String name,
    required String birthDate,
    required String gender,
    required String phoneNumber,
    String? profilePicture,
  }) async {
    String res = "Some error occurred";
    try {
      String uid = await FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection("users").doc(uid).get();

      if (userDoc.exists) {
        await FirebaseFirestore.instance.collection("users").doc(uid).update({
          "name": name,
          "gender": gender,
          "birthdate": birthDate,
          "phoneNumber": phoneNumber,
          if (profilePicture != null) "profilePicture": profilePicture,
        });
        res = "User details updated successfully!";
        print("User Details Updated!!!");
      } else {
        await FirebaseFirestore.instance.collection("users").doc(uid).set({
          "email": email,
          "name": name,
          "gender": gender,
          "birthdate": birthDate,
          "phoneNumber": phoneNumber,
          if (profilePicture != null) "profilePicture": profilePicture,
        });
        res = "User details stored successfully!";
        print("User Details Stored!!!");
      }
    } catch (e) {
      print("Error: $e");
      res = e.toString();
    }
    return res;
  }

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

  Future<void> updateUserProfile({
    required String name,
    required String gender,
    required String birthdate,
    required String phoneNumber,
  }) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'name': name,
          'gender': gender,
          'birthdate': birthdate,
          'phoneNumber': phoneNumber,
        });
      }
    } catch (e) {
      throw Exception('Error updating user profile: $e');
    }
  }

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

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  static Future<String?> changePassword(
      {required String currentPassword,
      required String newPassword,
      required BuildContext context}) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: currentPassword,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
        return null;
      }
      return "User not found";
    } catch (e) {
      return "Error : $e";
    }
  }

  Future<UserCredential?> signInWithGoogle(BuildContext context) async {
    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      if (gUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Google Sign-In was canceled.")),
        );
        return null;
      }
      final GoogleSignInAuthentication gAuth = await gUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);

      final User? user = userCredential.user;
      if (user != null) {
        DocumentReference userRef =
            _firestore.collection('users').doc(user.uid);
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

        return userCredential;
      } else {
        throw FirebaseAuthException(
            code: 'USER_NULL', message: "User returned as null after sign-in.");
      }
    } catch (e) {
      print('Error during Google Sign-In: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
      return null;
    }
  }
}
