import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:home/helpers/functions/permissions_manager.dart';
import 'package:home/presentation/home/home_screen.dart';
import 'package:home/presentation/onboarding/onboarding_screen.dart';
import 'package:home/firebase_options.dart';
import 'package:home/routes/routes.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Smart Pillbox',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: Routes.generateRoute,
      routes: {
        '/': (context) => const AuthWrapper(),
      },
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
            return const HomeScreen();
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
    String? token = await messaging.getToken();
    if (token != null) {
      await saveTokenToFirestore(token);
    }
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      await saveTokenToFirestore(newToken);
    });
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
      await FirebaseFirestore.instance.collection('users').doc(userId).set(
        {'deviceToken': token},
        SetOptions(merge: true),
      );
    } else {
      await prefs.setString('fcm_token', token);
    }
  } catch (e) {
    print('Error saving token: $e');
  }
}
