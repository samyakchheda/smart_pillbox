import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:home/services/notifications_service.dart';
import 'home_page.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Background message: ${message.data}");

  if (message.data.isNotEmpty) {
    NotificationsService.showCustomNotification(
      message.data['title'] ?? "No Title",
      message.data['body'] ?? "No Body",
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  NotificationsService.initialize();
  NotificationsService.requestPermission();

  runApp(SmartPillboxApp());
}

class SmartPillboxApp extends StatelessWidget {
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
      home: HomePage(),
    );
  }
}
