import 'package:firebase_core/firebase_core.dart';
import 'package:floating_draggable_widget/floating_draggable_widget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as firestore;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:home/screens/ai/chat_screen.dart';
import 'package:home/helpers/functions/permissions_manager.dart';
import 'package:home/screens/language/lang_selection_screen.dart';
import 'package:home/services/pharmacy_service/location_service.dart';
import 'package:home/services/pharmacy_service/pharmacy_service.dart';
import 'package:home/screens/caretaker/home/home_screen.dart';
import 'package:home/screens/home/home_screen.dart';
import 'package:home/firebase_options.dart';
import 'package:home/routes/routes.dart';
import 'package:home/services/medicine_service/medicine_service.dart';
import 'package:home/theme/app_colors.dart';
import 'package:home/theme/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:cron/cron.dart';
import 'package:feedback/feedback.dart'; // Feedback package
import 'package:shake_gesture/shake_gesture.dart'; // Shake gesture package
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:easy_localization/easy_localization.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Position? userLocation; // Global user location
List<dynamic>? pharmacyData; // Global pharmacy data
MapController mapController = MapController(
  initPosition: GeoPoint(latitude: 0, longitude: 0),
);

void callMedicineCheck() async {
  // Get the current user
  User? user = FirebaseAuth.instance.currentUser;

  if (user != null) {
    String userId = user.uid; // Get UID dynamically
    bool isNotification = false; //urgentttttttttttttttttttttttttttt
    debugPrint(userId);

    checkMedicineTimes(userId, isNotification);
  } else {
    print("No user is signed in.");
  }
}

/// Requests location permission and fetches user location & nearby pharmacies.
/// This function is called at app startup before runApp.
Future<void> _initializeLocationAndPharmacies() async {
  // Check and request location permission.
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print("Location permission denied.");
      return;
    }
  } else if (permission == LocationPermission.deniedForever) {
    print(
        "Location permission permanently denied. Please enable it in settings.");
    return;
  }

  // Once permission is granted, fetch the location.
  try {
    userLocation = await LocationService.getCurrentLocation();
    if (userLocation != null) {
      mapController = MapController(
        initPosition: GeoPoint(
          latitude: userLocation!.latitude,
          longitude: userLocation!.longitude,
        ),
      );
      pharmacyData = await PharmacyService().getNearbyPharmacies(userLocation!);
      print(
          "Location fetched: ${userLocation!.latitude}, ${userLocation!.longitude}");
    }
  } catch (e) {
    print("Error fetching location or pharmacies: $e");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ThemeProvider.init();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize Gemini with your API key.
  const apiKey = 'AIzaSyD3psw8M8hiX2mnwGoXxc-0-ZvBxPa0IYY';
  Gemini.init(apiKey: apiKey);

  // Create a Cron instance and schedule a job (e.g., at midnight).
  final cron = Cron();
  cron.schedule(Schedule.parse('0 0 * * *'), () {
    callMedicineCheck();
  });

  await dotenv.load(fileName: "assets/.env");

  // Wrap the app with BetterFeedback and our custom ShakeFeedbackWrapper.
  runApp(
    EasyLocalization(
      supportedLocales: [
        Locale('en', 'US'),
        Locale('hi', 'IN'),
        Locale('gu', 'IN'), // Gujarati - India
        Locale('mr', 'IN'), // Marathi - India
      ],
      path: 'assets/translations', // <-- path to your translation files
      fallbackLocale: Locale('en', 'US'),
      child: const BetterFeedback(
        child: ShakeFeedbackWrapper(
          child: MyApp(),
        ),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeProvider.themeNotifier,
      builder: (context, mode, child) {
        return MaterialApp(
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          navigatorKey: navigatorKey,
          title: 'Smart Pillbox',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            primaryColor: AppColors.buttonColor,
            scaffoldBackgroundColor: AppColors.lightBackground,
            cardColor: AppColors.lightCardBackground,
            textTheme: ThemeData.light().textTheme.apply(
                  bodyColor: AppColors.textPrimary,
                  displayColor: AppColors.textPrimary,
                ),
            iconTheme: IconThemeData(color: AppColors.buttonColor),
            dividerColor: AppColors.textPlaceholder,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                foregroundColor: AppColors.buttonText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: AppColors.buttonColor,
            scaffoldBackgroundColor: AppColors.darkBackground,
            cardColor: AppColors.darkCardBackground,
            textTheme: ThemeData.dark().textTheme.apply(
                  bodyColor: AppColors.textPrimary,
                  displayColor: AppColors.textPrimary,
                ),
            iconTheme: IconThemeData(color: AppColors.buttonColor),
            dividerColor: AppColors.textPlaceholder,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
                foregroundColor: AppColors.buttonText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          themeMode: mode, // This should reflect ThemeProvider's value
          initialRoute: '/',
          onGenerateRoute: Routes.generateRoute,
          routes: {
            '/': (context) => const AuthWrapper(),
          },
        );
      },
    );
  }
}

/// AuthWrapper decides which screen to display based on authentication.
/// It still requests notification and alarm permissions.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<bool> isCaretaker(String email) async {
    final querySnapshot = await firestore.FirebaseFirestore.instance
        .collection('caretakers')
        .where('email', isEqualTo: email)
        .get();
    return querySnapshot.docs.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    // Request other necessary permissions.
    requestPermissions(context);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            final user = snapshot.data!;
            return FutureBuilder<bool>(
              future: isCaretaker(user.email!),
              builder: (context, caretakerSnapshot) {
                // Show caretaker or normal home screen based on user type.
                Widget homeScreen = caretakerSnapshot.data == true
                    ? const CareTakerHomeScreen()
                    : const HomeScreen();
                // Wrap the home screen with the floating draggable widget.
                return FloatingDraggableWidget(
                  dx: MediaQuery.of(context).size.width -
                      55, // Stick to the right edge
                  dy: MediaQuery.of(context).size.height *
                      0.65, // Position slightly below the top
                  mainScreenWidget: homeScreen,
                  floatingWidget: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChatScreen()),
                      );
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.buttonColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 5),
                        ],
                      ),
                      child: const Icon(FontAwesomeIcons.robot,
                          color: Colors.white, size: 28),
                    ),
                  ),
                  autoAlign:
                      false, // Disable auto-align to keep it where we place it
                  floatingWidgetWidth: 55,
                  floatingWidgetHeight: 55,
                  speed: 0.5,
                );
              },
            );
          } else {
            // If the user is not logged in, show the onboarding screen.
            return LanguageSelectionScreen();
          }
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  /// Requests notification and alarm permissions.
  void requestPermissions(BuildContext context) async {
    await requestNotificationPermission();
    await requestAlarmPermission(context);
    await _initializeLocationAndPharmacies();
  }
}

Future<void> setupFCM() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  try {
    String? token = await messaging.getToken();
    print("FCM token retrieved: $token");
    if (token != null) {
      await saveTokenToFirestore(token);
    }
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      print("FCM token refreshed: $newToken");
      await saveTokenToFirestore(newToken);
    });
    await messaging.requestPermission();
  } catch (e) {
    print("Error setting up FCM: $e");
  }
}

Future<void> saveTokenToFirestore(String token) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    final prefs = await SharedPreferences.getInstance();

    if (user != null) {
      final userId = user.uid;
      final normalizedEmail = user.email?.trim().toLowerCase() ?? '';

      // Check if the user's email exists in the "caretakers" collection.
      final caretakerQuery = await firestore.FirebaseFirestore.instance
          .collection('caretakers')
          .where('email', isEqualTo: normalizedEmail)
          .get();

      if (caretakerQuery.docs.isNotEmpty) {
        final caretakerDocId = caretakerQuery.docs.first.id;
        await firestore.FirebaseFirestore.instance
            .collection('caretakers')
            .doc(caretakerDocId)
            .set({
          'deviceToken': token,
          'name': user.displayName ?? '',
          'email': user.email ?? '',
        }, firestore.SetOptions(merge: true));
        print("Caretaker token updated for: $normalizedEmail");
      } else {
        await firestore.FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .set({
          'deviceToken': token,
        }, firestore.SetOptions(merge: true));
        print("User token updated for: ${user.email}");
      }
    } else {
      await prefs.setString('fcm_token', token);
      print("Token stored locally in SharedPreferences");
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
/// and triggers the BetterFeedback dialog. Once feedback is submitted,
/// an email is pre-composed with the screenshot attached.
class ShakeFeedbackWrapper extends StatelessWidget {
  final Widget child;
  const ShakeFeedbackWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ShakeGesture(
      onShake: () {
        BetterFeedback.of(context).show((UserFeedback feedback) async {
          String? screenshotPath;
          if (feedback.screenshot != null && feedback.screenshot!.isNotEmpty) {
            screenshotPath = await writeScreenshotToFile(feedback.screenshot!);
          }
          final email = Email(
            body: "User submitted feedback with a screenshot attached.",
            subject: 'User Feedback',
            recipients: [
              'smartdose.care@gmail.com'
            ], // Update to your support email.
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
