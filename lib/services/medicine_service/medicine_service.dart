import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:home/services/notifications_service/alarm_scheduler.dart';
import 'package:home/services/notifications_service/notifications_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

Future<void> checkMedicineTimes(
  String userId,
  bool isNotification,
) async {
  try {
    print("[DEBUG] Fetching user document for userId: $userId");

    // Initialize timezone data (ideally do this once at app startup)
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
      // Ensure 'medicineNames', 'medicineTimes', and 'selectedDays' are valid lists
      String? medicineId = medicine['id'];
      List<dynamic> medicineNames = medicine['medicineNames'] ?? [];
      List<dynamic> medicineTimes = medicine['medicineTimes'] ?? [];
      List<dynamic> selectedDays = medicine['selectedDays'] ?? [];

      // Convert Timestamps to DateTime for start and end dates
      DateTime startDate = (medicine['startDate'] as Timestamp).toDate();
      DateTime endDate = (medicine['endDate'] as Timestamp).toDate();

      if (medicineId == null ||
          medicineNames.isEmpty ||
          medicineTimes.isEmpty ||
          selectedDays.isEmpty) {
        print(
            "[DEBUG] Skipping medicine with missing ID, names, times, or selectedDays.");
        continue;
      }

      // Combine medicine names into a single string
      String medicineNamesCombined = medicineNames.join(', ');
      print(
          "[DEBUG] Processing medicine: $medicineNamesCombined (ID: $medicineId)");

      for (var timeStamp in medicineTimes) {
        if (timeStamp is Timestamp) {
          // The stored time might be using a default date (like 1970-01-01)
          // so we extract the time-of-day and combine it with the start date.
          DateTime medicineTime = timeStamp.toDate();
          DateTime candidateTime = DateTime(
            startDate.year,
            startDate.month,
            startDate.day,
            medicineTime.hour,
            medicineTime.minute,
            medicineTime.second,
            medicineTime.millisecond,
            medicineTime.microsecond,
          );

          // For notifications, skip if the candidate time is in the past.
          // You might also want to calculate the next valid occurrence if needed.
          if (isNotification && candidateTime.isBefore(DateTime.now())) {
            print(
                "[DEBUG] Skipping notification for $medicineNamesCombined as the candidate time $candidateTime is in the past.");
            continue;
          }

          // Convert to TZDateTime using the local timezone
          final tz.TZDateTime tzCandidateTime =
              tz.TZDateTime.from(candidateTime, tz.local);

          String notificationId =
              '$medicineId-${candidateTime.toIso8601String()}';
          print(
              "[DEBUG] Scheduling ${isNotification ? 'notification' : 'alarm'} for $medicineNamesCombined (ID: $medicineId) at $candidateTime");

          if (isNotification) {
            try {
              await NotificationHelper.scheduleMedicineReminder(
                tzCandidateTime,
                "Medicine Reminder",
                "It's time to take your medicine: $medicineNamesCombined",
                notificationId: notificationId,
              );
              print(
                  "[DEBUG] Notification scheduled successfully for $medicineNamesCombined (ID: $medicineId).");
            } catch (e) {
              print("[ERROR] Error sending push notification: $e");
            }
          } else {
            try {
              // Schedule local alarm using the candidate time
              String payload =
                  'Time to take your medicine:\n $medicineNamesCombined';
              await AlarmScheduler.scheduleAlarm(
                medicineId,
                tzCandidateTime,
                payload,
                List<String>.from(selectedDays),
                startDate,
                endDate,
              );
              print(
                  "[DEBUG] Alarm scheduled successfully for $medicineNamesCombined (ID: $medicineId) with base time $candidateTime. Start Date: $startDate. End Date: $endDate");
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
