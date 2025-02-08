import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home/services/alarm_scheduler.dart';
import 'package:home/services/notifications_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> checkMedicineTimes(
  String userId,
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  bool isNotification,
) async {
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

    // Process all medicines
    for (var medicine in medicines) {
      // Ensure 'medicineNames' and 'medicineTimes' are valid lists
      String? medicineId = medicine['id']; // Retrieve medicineId
      List<dynamic> medicineNames = medicine['medicineNames'] ?? [];
      List<dynamic> medicineTimes = medicine['medicineTimes'] ?? [];

      if (medicineId == null ||
          medicineNames.isEmpty ||
          medicineTimes.isEmpty) {
        print("[DEBUG] Skipping medicine with missing ID, names, or times.");
        continue;
      }

      // Combine medicine names into a single string
      String medicineNamesCombined = medicineNames.join(', ');
      print(
          "[DEBUG] Processing medicine: $medicineNamesCombined (ID: $medicineId)");

      for (var timeStamp in medicineTimes) {
        if (timeStamp is Timestamp) {
          DateTime medicineTime = timeStamp.toDate();

          // Skip scheduling if the time is in the past
          if (medicineTime.isBefore(DateTime.now())) {
            print(
                "[DEBUG] Skipping notification for $medicineNamesCombined as the time $medicineTime is in the past.");
            continue;
          }

          // Convert to TZDateTime
          final tz.TZDateTime tzMedicineTime = tz.TZDateTime.from(
            medicineTime,
            tz.local,
          );

          String notificationId =
              '$medicineId-${medicineTime.toIso8601String()}';
          print(
              "[DEBUG] Scheduling notification for $medicineNamesCombined (ID: $medicineId) at $medicineTime");

          if (isNotification) {
            try {
              await NotificationHelper.scheduleMedicineReminder(
                tzMedicineTime,
                "Medicine Reminder",
                "It's time to take your medicine: $medicineNamesCombined",
                notificationId: notificationId,
              );
              print(
                  "[DEBUG] Notification sent successfully for $medicineNamesCombined (ID: $medicineId).");
            } catch (e) {
              print("[ERROR] Error sending push notification: $e");
            }
          } else {
            try {
              // Schedule local alarm
              String payload =
                  'Time to take your medicine:\n $medicineNamesCombined';
              await AlarmScheduler.scheduleAlarm(
                  medicineId, tzMedicineTime, payload);
              print(
                  "[DEBUG] Alarm scheduled successfully for $medicineNamesCombined (ID: $medicineId) at $medicineTime.");
            } catch (e) {
              print("[ERROR] Error scheduling alarm: $e");
            }
          }
        } else {
          print(
              "[DEBUG] Invalid timestamp for $medicineNamesCombined (ID: $medicineId): $timeStamp");
        }
      }
    }
  } catch (error) {
    print("[ERROR] Error checking medicine times: $error");
  }
}
