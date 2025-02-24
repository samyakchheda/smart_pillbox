import 'package:firebase_core/firebase_core.dart';
import 'package:floating_draggable_widget/floating_draggable_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:home/ai/chat_screen.dart';
import 'package:home/helpers/functions/permissions_manager.dart';
import 'package:home/presentation/home/home_screen.dart';
import 'package:home/presentation/onboarding/onboarding_screen.dart';
import 'package:home/firebase_options.dart';
import 'package:home/routes/routes.dart';
import 'package:home/services/medicine_service/medicine_service.dart';
import 'package:home/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:cron/cron.dart'; // Import the cron package

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Example function to be called periodically.
void callMedicineCheck() {
  const String userId = "FGnDI9a6A8bfHRlzE6i2uKYwx3j1";
  const bool isNotification = false;
  // Call your medicine check function.
  checkMedicineTimes(userId, isNotification);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  const apiKey =
      'AIzaSyD3psw8M8hiX2mnwGoXxc-0-ZvBxPa0IYY'; // Replace with your actual API key
  Gemini.init(apiKey: apiKey);

  // Create a Cron instance.
  final cron = Cron();

  // Schedule a job that runs every 5 minutes using a cron expression.
  // The expression "*/5 * * * *" means every 5 minutes.
  cron.schedule(Schedule.parse('0 0 * * *'), () {
    callMedicineCheck();
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.darkBackground,
      ),
      title: 'Smart Pillbox',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: Routes.generateRoute,
      routes: {
        '/': (context) =>
            const MainWrapper(), // Wrap everything with MainWrapper
      },
    );
  }
}

class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});
  @override
  Widget build(BuildContext context) {
    return FloatingDraggableWidget(
      // The main screen content that appears behind the floating button.
      mainScreenWidget: const AuthWrapper(),
      // The floating button widget.
      floatingWidget: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChatScreen()),
          );
        },
        child: Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: AppColors.buttonColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 5),
            ],
          ),
          child:
              const Icon(FontAwesomeIcons.robot, color: Colors.white, size: 28),
        ),
      ),
      autoAlign: true,
      floatingWidgetWidth: 55,
      floatingWidgetHeight: 55,
      speed: 0.5,
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
