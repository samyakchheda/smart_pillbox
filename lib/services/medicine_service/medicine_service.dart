import 'package:cloud_firestore/cloud_firestore.dart';
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

    // --- New Logic: Fetch FCM token from caretaker's document ---
    // We assume that the user's document has a "caretakers" array field containing caretaker emails.
    List<dynamic> caretakerEmails = userData['caretakers'] ?? [];
    String? fcmToken;
    if (caretakerEmails.isNotEmpty) {
      // Take the first caretaker email (adjust if you want to handle multiple)
      String caretakerEmail =
          caretakerEmails.first.toString().trim().toLowerCase();
      QuerySnapshot caretakerQuery = await FirebaseFirestore.instance
          .collection('caretakers')
          .where('email', isEqualTo: caretakerEmail)
          .get();
      if (caretakerQuery.docs.isNotEmpty) {
        // Fetch the caretaker's device token
        fcmToken = caretakerQuery.docs.first.get('deviceToken');
        print("[DEBUG] FCM token from caretaker: $fcmToken");
      }
    }
    if (fcmToken == null) {
      print("[DEBUG] No caretaker FCM token found for userId: $userId");
      return;
    }
    // --- End of New Logic ---

    // Process all medicines
    for (var medicine in medicines) {
      // Ensure 'medicineNames', 'medicineTimes', and 'selectedDays' are valid lists
      String? medicineId = medicine['id'];
      List<dynamic> medicineNames = medicine['medicineNames'] ?? [];
      List<dynamic> medicineTimes = medicine['medicineTimes'] ?? [];
      List<dynamic> selectedDays = medicine['selectedDays'] ?? [];

      // Assume each medicine has a 'taken' flag; default to false if not provided.
      bool taken = true;

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

      // First loop: Schedule notifications or alarms as per your original logic.
      for (var timeStamp in medicineTimes) {
        if (timeStamp is Timestamp) {
          // Extract the time-of-day from the stored time and combine with the start date.
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
          if (isNotification && candidateTime.isBefore(DateTime.now())) {
            print(
                "[DEBUG] Skipping notification for $medicineNamesCombined as the candidate time $candidateTime is in the past.");
            continue;
          }

          // Convert to TZDateTime using the local timezone.
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
              // Schedule local alarm using the candidate time.
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

      // Second loop: For each scheduled time, wait 1 hour after the scheduled time,
      // then check if the medicine was taken, and send a notification accordingly.
      for (var timeStamp in medicineTimes) {
        DateTime scheduledTime;
        if (timeStamp is Timestamp) {
          DateTime medicineTime = timeStamp.toDate();
          scheduledTime = DateTime(
            startDate.year,
            startDate.month,
            startDate.day,
            medicineTime.hour,
            medicineTime.minute,
            medicineTime.second,
            medicineTime.millisecond,
            medicineTime.microsecond,
          );
        } else if (timeStamp is int) {
          scheduledTime = DateTime.fromMillisecondsSinceEpoch(timeStamp);
        } else {
          print(
              "[DEBUG] Invalid time format for $medicineNamesCombined (ID: $medicineId): $timeStamp");
          continue;
        }

        DateTime checkTime = scheduledTime.add(Duration(minutes: 2));
        Duration waitTime = checkTime.difference(DateTime.now());

        if (waitTime.isNegative) {
          // If we're already past the check time, perform the check immediately.
          await checkMedicineStatus(
            medicineId,
            fcmToken,
            medicineNamesCombined,
            taken,
            scheduledTime,
          );
        } else {
          // Schedule the check to run exactly 1 hour after the scheduled time.
          Future.delayed(waitTime, () async {
            await checkMedicineStatus(
              medicineId,
              fcmToken!,
              medicineNamesCombined,
              taken,
              scheduledTime,
            );
          });
        }
      }
    }
  } catch (error) {
    print("[ERROR] Error checking medicine times: $error");
  }
}

/// Helper function that checks whether the medicine was taken and sends a notification.
Future<void> checkMedicineStatus(
  String medicineId,
  String fcmToken,
  String medicineNamesCombined,
  bool taken,
  DateTime scheduledTime,
) async {
  if (taken) {
    try {
      await NotificationHelper.sendNotificationToBackend(
        fcmToken,
        "Medicine Reminder",
        "$medicineNamesCombined taken at ${scheduledTime.toLocal()}",
      );
      print(
          "[DEBUG] Notification sent for $medicineNamesCombined (ID: $medicineId) as taken.");
    } catch (e) {
      print("[ERROR] Error sending push notification: $e");
    }
  } else {
    try {
      await NotificationHelper.sendNotificationToBackend(
        fcmToken,
        "Medicine Reminder",
        "$medicineNamesCombined not taken at ${scheduledTime.toLocal()}",
      );
      print(
          "[DEBUG] Notification sent for $medicineNamesCombined (ID: $medicineId) as not taken.");
    } catch (e) {
      print("[ERROR] Error sending push notification: $e");
    }
  }
}
