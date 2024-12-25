import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:home/services/notifications_service.dart';

Future<void> checkMedicineTimes(String userId) async {
  DateTime now = DateTime.now();
  print("[DEBUG] Starting checkMedicineTimes for userId: $userId at $now");

  try {
    // Ensure Firebase is initialized
    if (Firebase.apps.isEmpty) {
      print("[DEBUG] Firebase is not initialized. Initializing now...");
      await Firebase.initializeApp();
      print("[DEBUG] Firebase initialization completed.");
    } else {
      print("[DEBUG] Firebase is already initialized.");
    }

    // Fetch user data from Firestore
    print("[DEBUG] Fetching user document for userId: $userId");
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!documentSnapshot.exists) {
      print("[DEBUG] No document found for userId: $userId. Exiting...");
      return;
    }

    print("[DEBUG] User document found for userId: $userId");
    Map<String, dynamic>? userData =
        documentSnapshot.data() as Map<String, dynamic>?;

    if (userData == null) {
      print("[DEBUG] User data is null for userId: $userId. Exiting...");
      return;
    }

    List<dynamic> medicines = userData['medicines'] ?? [];
    print("[DEBUG] Medicines list retrieved: $medicines");

    if (medicines.isEmpty) {
      print("[DEBUG] Medicines list is empty for userId: $userId. Exiting...");
      return;
    }

    // Retrieve the FCM token from Firestore
    String? fcmToken = userData['deviceToken'];
    if (fcmToken == null) {
      print(
          "[DEBUG] FCM token is null for userId: $userId. Attempting to retrieve a new token...");
      fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null) {
        print("[DEBUG] Unable to retrieve FCM token. Exiting...");
        return;
      }
      print("[DEBUG] New FCM Token retrieved: $fcmToken");
    }

    for (var medicine in medicines) {
      String medicineName = medicine['name'] ?? 'Unnamed medicine';
      print("[DEBUG] Processing medicine: $medicineName");

      List<dynamic> times = medicine['times'] ?? [];
      print("[DEBUG] Times for $medicineName: $times");

      if (times.isEmpty) {
        print("[DEBUG] No times specified for $medicineName. Skipping...");
        continue;
      }

      for (var timeStamp in times) {
        if (timeStamp is Timestamp) {
          DateTime medicineTime = timeStamp.toDate();
          print(
              "[DEBUG] Parsed medicine time for $medicineName: $medicineTime");

          // Check if it's time for the notification
          int timeDifference = now.difference(medicineTime).inMinutes.abs();
          print(
              "[DEBUG] Time difference for $medicineName: $timeDifference minutes");

          if (timeDifference <= 5) {
            print(
                "[DEBUG] Time is within 5 minutes for $medicineName. Sending notifications...");

            String notificationId =
                '$medicineName-${medicineTime.toIso8601String()}';

            // Send FCM notification via backend
            try {
              print("[DEBUG] Sending FCM notification for $medicineName");
              await NotificationHelper().sendNotificationToBackend(
                fcmToken,
                "Medicine Reminder",
                "It's time to take your medicine: $medicineName",
              );
              print("[DEBUG] FCM notification sent for $medicineName");
            } catch (e) {
              print("[ERROR] Error sending FCM notification: $e");
            }

            // Also schedule a local notification
            try {
              print("[DEBUG] Scheduling local notification for $medicineName");
              await NotificationHelper.scheduleMedicineReminder(
                medicineTime,
                "Medicine Reminder",
                "It's time to take your medicine: $medicineName",
                notificationId: notificationId,
              );
              print("[DEBUG] Local notification scheduled for $medicineName");
            } catch (e) {
              print("[ERROR] Error scheduling local notification: $e");
            }
          } else {
            print(
                "[DEBUG] Time is not within 5 minutes for $medicineName. Skipping notification.");
          }
        } else {
          print(
              "[DEBUG] Invalid timestamp format in times for $medicineName. Skipping...");
        }
      }
    }
  } catch (error) {
    print("[ERROR] Error checking medicine times for userId: $userId - $error");
  }
}
