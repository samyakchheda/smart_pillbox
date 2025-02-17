import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FCMService {
  static Future<void> setupFCM() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;

    try {
      // Get token for the device
      String? token = await messaging.getToken();
      if (token != null) {
        await saveTokenToFirestore(token);
      }

      // Listen for token refresh
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        await saveTokenToFirestore(newToken);
      });

      // Request notification permission
      await messaging.requestPermission();
    } catch (e) {
      print("Error setting up FCM: $e");
    }
  }

  static Future<void> saveTokenToFirestore(String token) async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      final prefs = await SharedPreferences.getInstance();
      if (userId.isNotEmpty) {
        // Store token in Firestore
        await FirebaseFirestore.instance.collection('users').doc(userId).set(
          {'deviceToken': token},
          SetOptions(merge: true),
        );
      } else {
        // Store token locally if user is not authenticated
        await prefs.setString('fcm_token', token);
      }
    } catch (e) {
      print('Error saving token: $e');
    }
  }
}
