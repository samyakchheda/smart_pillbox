import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:home/services/notifications_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> checkMedicineTimes(String userId) async {
  try {
    print("[DEBUG] Fetching user document for userId: $userId");

    // Initialize timezone data
    tz.initializeTimeZones();

    // Fetch user document from Firestore
    DocumentSnapshot documentSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();

    if (!documentSnapshot.exists) {
      print("[DEBUG] No document found for userId: $userId");
      return;
    }

    Map<String, dynamic>? userData =
        documentSnapshot.data() as Map<String, dynamic>?;

    if (userData == null) {
      print("[DEBUG] User data is null for userId: $userId");
      return;
    }

    print("[DEBUG] User data fetched successfully for userId: $userId");

    // Retrieve medicines list
    List<dynamic> medicines = userData['medicines'] ?? [];
    print("[DEBUG] Medicines list: $medicines");

    // Retrieve or generate the FCM token
    String? fcmToken =
        userData['deviceToken'] ?? await FirebaseMessaging.instance.getToken();
    print("[DEBUG] FCM Token: $fcmToken");

    if (fcmToken == null) {
      print("[DEBUG] No FCM token found for userId: $userId");
      return;
    }

    // Process each medicine
    for (var medicine in medicines) {
      String medicineName = medicine['name'] ?? 'Unnamed medicine';
      List<dynamic> times = medicine['times'] ?? [];
      print("[DEBUG] Processing medicine: $medicineName, times: $times");

      for (var timeStamp in times) {
        if (timeStamp is Timestamp) {
          DateTime medicineTime = timeStamp.toDate();

          // Skip scheduling if the time is in the past
          if (medicineTime.isBefore(DateTime.now())) {
            print(
                "[DEBUG] Skipping notification for $medicineName as the time $medicineTime is in the past.");
            continue;
          }

          // Convert to TZDateTime
          final tz.TZDateTime tzMedicineTime = tz.TZDateTime.from(
            medicineTime,
            tz.local,
          );

          String notificationId =
              '$medicineName-${medicineTime.toIso8601String()}';
          print(
              "[DEBUG] Scheduling notification for $medicineName at $medicineTime with ID: $notificationId");

          try {
            // Schedule local notification
            await NotificationHelper.scheduleMedicineReminder(
              tzMedicineTime,
              "Medicine Reminder",
              "It's time to take your medicine: $medicineName",
              notificationId: notificationId,
            );
            print(
                "[DEBUG] Notification scheduled successfully for $medicineName at $medicineTime.");
          } catch (e) {
            print("[ERROR] Error scheduling notification: $e");
          }

          // Send push notification
          print(
              "[DEBUG] Sending push notification for $medicineName at $medicineTime");
          try {
            await NotificationHelper().sendNotificationToBackend(
              fcmToken,
              "Medicine Reminder",
              "It's time to take your medicine: $medicineName",
            );
            print("[DEBUG] Notification sent successfully for $medicineName.");
          } catch (e) {
            print("[ERROR] Error sending push notification: $e");
          }
        } else {
          print("[DEBUG] Invalid timestamp for $medicineName: $timeStamp");
        }
      }
    }
  } catch (error) {
    print("[ERROR] Error checking medicine times: $error");
  }
}
