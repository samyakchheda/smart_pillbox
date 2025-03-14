import 'package:firebase_core/firebase_core.dart';
import 'package:floating_draggable_widget/floating_draggable_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:home/ai/chat_screen.dart';
import 'package:home/helpers/functions/permissions_manager.dart';
import 'package:home/pharmacy/services/location_service.dart';
import 'package:home/pharmacy/services/pharmacy_service.dart';
import 'package:home/presentation/home/home_screen.dart';
import 'package:home/presentation/onboarding/onboarding_screen.dart';
import 'package:home/firebase_options.dart';
import 'package:home/routes/routes.dart';
import 'package:home/services/medicine_service/medicine_service.dart';
import 'package:home/theme/app_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:cron/cron.dart';
import 'package:feedback/feedback.dart'; // Feedback package
import 'package:shake_gesture/shake_gesture.dart'; // Shake gesture package
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Position? userLocation; // Store user location globally
List<dynamic>? pharmacyData; // Store pharmacy data globally
MapController mapController =
    MapController(initPosition: GeoPoint(latitude: 0, longitude: 0));

// Example function to be called periodically.
void callMedicineCheck() {
  const String userId = "WZK4k6u2SrYzBIKprwzFd3yaULh2";
  const bool isNotification = false;
  checkMedicineTimes(userId, isNotification);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Gemini with your API key.
  const apiKey = 'AIzaSyD3psw8M8hiX2mnwGoXxc-0-ZvBxPa0IYY';
  Gemini.init(apiKey: apiKey);

  // Create a Cron instance and schedule a job.
  final cron = Cron();
  // Example: schedule a job at midnight (adjust your cron expression as needed).
  cron.schedule(Schedule.parse('0 0 * * *'), () {
    callMedicineCheck();
  });

  _fetchUserLocationAndPharmacies();

  // Wrap the app with BetterFeedback and our custom ShakeFeedbackWrapper.
  runApp(
    const BetterFeedback(
      child: ShakeFeedbackWrapper(
        child: MyApp(),
      ),
    ),
  );
}

Future<void> _fetchUserLocationAndPharmacies() async {
  try {
    userLocation = await LocationService.getCurrentLocation();
    if (userLocation != null) {
      mapController = MapController(
        initPosition: GeoPoint(
          latitude: userLocation!.latitude, // Null check (!)
          longitude: userLocation!.longitude,
        ),
      );

      pharmacyData = await PharmacyService().getNearbyPharmacies(userLocation!);
    }
  } catch (e) {
    print("Error fetching location or pharmacies: $e");
  }
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
        '/': (context) => const MainWrapper(),
      },
    );
  }
}

class MainWrapper extends StatelessWidget {
  const MainWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingDraggableWidget(
      // The main screen content behind the floating button.
      mainScreenWidget: const AuthWrapper(),
      // Floating button widget.
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
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
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
      await firestore.FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .set(
        {'deviceToken': token},
        firestore.SetOptions(merge: true),
      );
    } else {
      await prefs.setString('fcm_token', token);
    }
  } catch (e) {
    print('Error saving token: $e');
  }
}

/// Writes screenshot bytes to a temporary file and returns the file path.
Future<String> writeScreenshotToFile(Uint8List screenshotBytes) async {
  final directory = await getTemporaryDirectory();
  final filePath = '${directory.path}/feedback_screenshot.png';
  final file = File(filePath);
  await file.writeAsBytes(screenshotBytes);
  return filePath;
}

/// ShakeFeedbackWrapper uses the shake_gesture package to detect shakes
/// and triggers the BetterFeedback dialog when a shake is detected.
/// Once feedback is submitted, an email is pre-composed with the screenshot attached.
class ShakeFeedbackWrapper extends StatelessWidget {
  final Widget child;
  const ShakeFeedbackWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ShakeGesture(
      onShake: () {
        BetterFeedback.of(context).show((UserFeedback feedback) async {
          String? screenshotPath;
          // If a screenshot is available, write it to a temporary file.
          if (feedback.screenshot != null && feedback.screenshot!.isNotEmpty) {
            screenshotPath = await writeScreenshotToFile(feedback.screenshot!);
          }

          // Since textual feedback isn't supported, we use a default message.
          final email = Email(
            body: "User submitted feedback with a screenshot attached.",
            subject: 'User Feedback',
            recipients: [
              'smartdose.care@gmail.com'
            ], // Change to your support email.
            attachmentPaths: screenshotPath != null ? [screenshotPath] : null,
            isHTML: false,
          );

          try {
            await FlutterEmailSender.send(email);
          } catch (error) {
            print('Error sending email: $error');
          }
        });
      },
      child: child,
    );
  }
}
