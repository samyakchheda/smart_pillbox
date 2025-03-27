import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class FacebookAuthService {
  Future<Map<String, dynamic>?> signInWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login(
      permissions: ['email', 'public_profile'],
    );

    if (result.status == LoginStatus.success) {
      // Get Facebook access token
      final OAuthCredential credential =
          FacebookAuthProvider.credential(result.accessToken!.tokenString);

      // Sign in with Firebase
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Fetch user details
      final userData = await FacebookAuth.instance.getUserData(
        fields: "name,email,picture.width(200).height(200)",
      );

      return userData; // Return user data
    }

    return null;
  }

  Future<void> signOut() async {
    await FacebookAuth.instance.logOut();
    await FirebaseAuth.instance.signOut();
  }
}
