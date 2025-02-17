import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../models/user_model.dart';
import '../database_service/user_service.dart';

class GoogleAuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// 🔹 **Google Sign-In**
  Future<User?> signInWithGoogle() async {
    try {
      await _googleSignIn.signOut(); // Ensure fresh session
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // User canceled sign-in

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential =
          await _firebaseAuth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user == null) return null;

      // 🔹 Check if user exists in Firestore
      final DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        // 🔹 Store new user details
        final newUser = UserModel(
          uid: user.uid,
          email: user.email ?? '',
          name: user.displayName ?? '',
          // profilePicture: user.photoURL ?? '',
          gender: '',
          birthDate: '',
          phoneNumber: '',
        );

        await UserService().saveUserDetails(newUser);
      }

      return user;
    } catch (e) {
      print("❌ Google Sign-In Error: $e");
      return null;
    }
  }
}
