import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home/core/constants/app_theme.dart';
import 'package:home/presentation/home/home_screen.dart';
import 'package:home/presentation/onboarding/onboarding_screen.dart';
import 'package:home/firebase_options.dart';
import 'package:home/services/permissions_helper.dart';
import 'package:home/services/alarm_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  _showAlarmScreen(message.data['payload'] ?? '');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize notifications
  await _initNotifications();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MyApp());
}

Future<void> _initNotifications() async {
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse details) {
      if (details.payload != null && details.payload!.startsWith('alarm_')) {
        _showAlarmScreen(details.payload!);
      }
    },
  );

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    _showAlarmScreen(message.data['payload'] ?? '');
  });

  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    _showAlarmScreen(message.data['payload'] ?? '');
  });
}

void _showAlarmScreen(String payload) {
  navigatorKey.currentState?.pushNamed('/alarm_screen', arguments: payload);
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _setupNotifications();
  }

  void _setupNotifications() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showAlarmScreen(message.data['payload'] ?? '');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _showAlarmScreen(message.data['payload'] ?? '');
    });

    flutterLocalNotificationsPlugin.initialize(
      InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: (NotificationResponse details) {
        if (details.payload != null && details.payload!.startsWith('alarm_')) {
          _showAlarmScreen(details.payload!);
        }
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Smart Pillbox',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/alarm_screen': (context) => AlarmScreen(
            payload:
                ModalRoute.of(context)?.settings.arguments as String? ?? ''),
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
