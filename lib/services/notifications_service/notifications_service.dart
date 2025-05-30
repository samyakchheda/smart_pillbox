import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'dart:convert';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notification =
      FlutterLocalNotificationsPlugin();

  static const String backendUrl =
      'https://notification-api-yham.onrender.com/send_notification';

  /// Initializes the notification settings and timezone.
  static Future<void> init() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await _notification.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Automatically navigate to AlarmScreen when notification is received
        if (response.payload != null) {
          // Ensure payload is non-null before passing
          // navigateToAlarmScreen(response.payload!);
        }
      },
    );

    // Initialize timezone data
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    // Create notification channel for Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'medicine_reminder',
      'Medicine Reminders',
      description: 'This channel is for medicine reminders',
      importance: Importance.high,
    );

    await _notification
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Schedules a medicine reminder notification.
  static Future<void> scheduleMedicineReminder(
    DateTime medicineTime,
    String title,
    String body, {
    required String notificationId,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'medicine_reminder',
      'Medicine Reminders',
      channelDescription: 'This channel is for medicine reminders',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails notificationDetails =
        NotificationDetails(android: androidDetails);

    try {
      tz.TZDateTime scheduledTime = tz.TZDateTime.from(medicineTime, tz.local);

      await _notification.zonedSchedule(
        notificationId.hashCode,
        title,
        body,
        scheduledTime,
        notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      print("Error scheduling notification: $e");
    }
  }

  static Future<void> scheduleAlarm(
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
      'It\'s time to take your medicines: $medicineName!',
      scheduledTime,
      platformChannelSpecifics,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: medicineName,
    );
  }

  /// Sends a notification to the backend server.
  static Future<void> sendNotificationToBackend(
      String deviceToken, String title, String body) async {
    try {
      final response = await http.post(
        Uri.parse(backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'device_token': deviceToken,
          'title': title,
          'body': body,
        }),
      );

      if (response.statusCode == 200) {
        print('[DEBUG] Notification sent successfully');
      } else {
        print('[DEBUG] Failed to send notification');
      }
    } catch (e) {
      print('[ERROR] Error sending notification: $e');
    }
  }

  /// Navigates to the AlarmScreen with the provided payload.
  // static void navigateToAlarmScreen(String payload) {
  //   // Use the navigator key to push the AlarmScreen
  //   navigatorKey.currentState?.pushAndRemoveUntil(
  //     MaterialPageRoute(
  //       builder: (_) => AlarmScreen(
  //         medicineName: payload, // Pass the payload as needed
  //       ),
  //     ),
  //     (route) => false, // Remove all other routes
  //   );
  // }
}
