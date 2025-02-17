import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user_model.dart';

class EmailAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🔹 **Sign Up with Email & Password**
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
    } catch (e) {
      return "Error: \${e.toString()}";
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
