// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:home/services/notifications_service.dart';
// import 'dart:async'; // For periodic timer
// import 'home_page.dart';

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   print("Background message: ${message.data}");

//   if (message.data.isNotEmpty) {
//     NotificationsService.showCustomNotification(
//       message.data['title'] ?? "No Title",
//       message.data['body'] ?? "No Body",
//     );
//   }
// }

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();

//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//   NotificationsService.initialize();
//   NotificationsService.requestPermission();

//   // Start periodic checks for medicine times
//   Timer.periodic(Duration(seconds: 30), (_) {
//     NotificationsService.checkAndNotifyMedicineTimes();
//   });

//   runApp(SmartPillboxApp());
// }

// class SmartPillboxApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
// debugShowCheckedModeBanner: false,
// title: 'Smart Pillbox',
// theme: ThemeData(
//   primarySwatch: Colors.blue,
//   scaffoldBackgroundColor: const Color(0xFFF6F6F6),
//   appBarTheme: AppBarTheme(
//     backgroundColor: const Color(0xFFF6F6F6),
//     elevation: 0,
//     iconTheme: const IconThemeData(color: Colors.black),
//   ),
// ),
//       home: HomePage(),
//     );
//   }
// }

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:home/presentation/onboarding_screen.dart';
import 'package:home/firebase_options.dart';
import 'package:home/services/medicine_service.dart';
import 'home_page.dart';
import 'services/notifications_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationHelper.init(); // Initialize local notifications

  // Request notification permissions for iOS
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission();

  // Get the FCM token
  String? token = await messaging.getToken();
  print('FCM Token: $token');

  // Set up background message handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle the background message (schedule local notifications)
  print("Handling background message: ${message.messageId}");
  await NotificationHelper.scheduleMedicineReminder(
    DateTime.now(), // Ensure you adjust this to match your logic for the time
    message.notification?.title ?? 'Medicine Reminder',
    message.notification?.body ?? 'Time to take your medicine',
    notificationId: message.messageId ?? 'default',
  );
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
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            checkMedicineTimes(snapshot.data!.uid);
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
}
