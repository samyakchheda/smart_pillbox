import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home/services/notifications_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:typed_data';

Future<void> checkMedicineTimes(
  String userId,
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
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

    // Process each medicine
    for (var medicine in medicines) {
      String medicineName = medicine['medicineName'] ?? 'Unnamed medicine';
      List<dynamic> times = medicine['medicineTimes'] ?? [];
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
            await scheduleAlarm(
                flutterLocalNotificationsPlugin, tzMedicineTime, medicineName);
            print(
                "[DEBUG] Alarm scheduled successfully for $medicineName at $medicineTime.");
          } catch (e) {
            print("[ERROR] Error scheduling alarm: $e");
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

Future<void> scheduleAlarm(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
    tz.TZDateTime scheduledTime,
    String medicineName) async {
  AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'alarm_channel_id',
    'Alarm Channel',
    channelDescription: 'Channel for alarm notifications',
    importance: Importance.max,
    priority: Priority.high,
    sound: RawResourceAndroidNotificationSound('alarm'),
    vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
    enableVibration: true,
    playSound: true,
    fullScreenIntent: true,
    timeoutAfter: 60000,
    actions: <AndroidNotificationAction>[
      AndroidNotificationAction(
        'snooze',
        'Snooze',
      ),
      AndroidNotificationAction(
        'stop',
        'Stop',
        cancelNotification: true,
      ),
    ],
  );

  NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  // Schedule the alarm using the TZDateTime
  await flutterLocalNotificationsPlugin.zonedSchedule(
    0,
    'Medicine Reminder',
    'It\'s time to take your medicine: $medicineName!',
    scheduledTime,
    platformChannelSpecifics,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time,
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    payload: medicineName,
  );
}
