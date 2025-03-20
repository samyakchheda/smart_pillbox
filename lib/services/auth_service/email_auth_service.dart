import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';

class EmailAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> signUpUser({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) return "Please fill all fields";

      UserCredential credential =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) return "Failed to create user.";

      // 🔹 Create UserModel instance
      final newUser = UserModel(
        uid: credential.user!.uid,
        email: email,
        name: '',
        birthDate: '',
        gender: '',
        phoneNumber: '',
      );

      // 🔹 Save user data in Firestore (under "users" collection)
      await _firestore
          .collection("users")
          .doc(credential.user!.uid)
          .set(newUser.toJson());

      return "success";
    } on FirebaseAuthException catch (e) {
      // Handle Firebase authentication errors
      if (e.code == 'email-already-in-use') {
        return "This email is already in use.";
      } else if (e.code == 'weak-password') {
        return "Password is too weak. Try a stronger password.";
      } else if (e.code == 'invalid-email') {
        return "Invalid email format.";
      } else {
        return "FirebaseAuth Error: ${e.message}";
      }
    } catch (e) {
      return "Error: ${e.toString()}"; // ✅ Returns the actual error message
    }
  }

  /// 🔹 **Login with Email & Password**
  Future<String> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) return "Please fill all fields";

      UserCredential credential =
          await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) return "Login failed. Try again.";

      return "success";
    } catch (e) {
      return e.toString();
    }
  }

  /// 🔹 **Logout**
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
