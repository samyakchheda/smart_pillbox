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
      await _googleSignIn.signOut(); // Ensure a fresh session
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

      // Normalize the email to avoid case or whitespace issues
      final normalizedEmail = user.email?.trim().toLowerCase() ?? '';

      // 🔹 Check if the user is a caretaker by querying the "caretakers" collection
      final QuerySnapshot caretakerQuery = await _firestore
          .collection('caretakers')
          .where('email', isEqualTo: normalizedEmail)
          .get();

      if (caretakerQuery.docs.isNotEmpty) {
        // The email exists in the caretakers collection.
        print("User is a caretaker: $normalizedEmail");
        // Optionally, you can update the caretaker document here if needed.
      } else {
        // The user is not a caretaker.
        // Check if the user exists in the 'users' collection and add if not.
        final DocumentSnapshot userDoc =
            await _firestore.collection('users').doc(user.uid).get();

        if (!userDoc.exists) {
          // 🔹 Store new user details for a normal user
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
      }

      return user;
    } catch (e) {
      print("❌ Google Sign-In Error: $e");
      return null;
    }
  }
}
