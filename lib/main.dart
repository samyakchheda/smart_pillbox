import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home/presentation/onboarding_screen.dart';
import 'package:home/firebase_options.dart';
import 'home_page.dart';
import 'services/notifications_service.dart';
import 'services/permissions_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationHelper.init(); // Initialize local notifications

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Smart Pillbox',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: const Color(0xFFF6F6F6),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFF6F6F6),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
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
    // Call permission requests when building the widget tree
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

  // Add a method to request permissions within the widget tree
  void requestPermissions(BuildContext context) async {
    await requestNotificationPermission();
    await requestAlarmPermission(context); // Pass context here
    await setupFCM();
  }
}

Future<void> setupFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  try {
    // Retrieve and save the FCM token
    String? token = await messaging.getToken();
    if (token != null) {
      print('FCM Token: $token');
      await saveTokenToFirestore(token);
    }

    // Listen for token refresh
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print('New FCM Token: $newToken');
      await saveTokenToFirestore(newToken);
    });

    // Set up background message handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  } catch (e) {
    print("Error setting up FCM: $e");
  }
}

Future<void> saveTokenToFirestore(String token) async {
  String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  if (userId.isNotEmpty) {
    await FirebaseFirestore.instance.collection('users').doc(userId).set(
      {'deviceToken': token},
      SetOptions(merge: true),
    );
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling background message: ${message.messageId}");
  await NotificationHelper.scheduleMedicineReminder(
    DateTime.now(),
    message.notification?.title ?? 'Medicine Reminder',
    message.notification?.body ?? 'Time to take your medicine',
    notificationId: message.messageId ?? 'default',
  );
}
