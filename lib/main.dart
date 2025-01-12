import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home/presentation/onboarding/onboarding_screen.dart';
import 'package:home/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_page.dart';
import 'services/notifications_service.dart';
import 'services/permissions_helper.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Background handler for receiving FCM messages when the app is killed
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase in the background handler (necessary for Firebase to work)
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Call the notification handler to schedule a local notification
  await NotificationHelper.scheduleMedicineReminder(
    DateTime.now(),
    message.notification?.title ?? 'Medicine Reminder',
    message.notification?.body ?? 'Time to take your medicine',
    notificationId: message.messageId ?? 'default',
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize the Notification helper
  await NotificationHelper.init();

  // Set background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Smart Pillbox',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF6F6F6),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF6F6F6),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    requestPermissions(context);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return HomePage();
          } else {
            return const OnboardingScreen();
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void requestPermissions(BuildContext context) async {
    await requestNotificationPermission();
    await requestAlarmPermission(context);
    setupFCM();
  }
}

Future<void> setupFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  try {
    // Retrieve the FCM token
    String? token = await messaging.getToken();
    if (token != null) {
      await saveTokenToFirestore(token);
    }

    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await saveTokenToFirestore(newToken);
    });

    // Request permissions for notifications
    await messaging.requestPermission();
  } catch (e) {
    print("Error setting up FCM: $e");
  }
}

Future<void> saveTokenToFirestore(String token) async {
  try {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final prefs = await SharedPreferences.getInstance();

    if (userId.isNotEmpty) {
      // Save token to Firestore for the logged-in user
      await FirebaseFirestore.instance.collection('users').doc(userId).set(
        {'deviceToken': token},
        SetOptions(merge: true),
      );
      print('Token saved to Firestore for user $userId');
    } else {
      // Save token locally if no user is logged in
      await prefs.setString('fcm_token', token);
      print('Token saved locally: $token');
    }
  } catch (e) {
    print('Error saving token: $e');
  }
}
