import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:home/services/alarm_screen.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:http/http.dart' as http;
import 'dart:convert';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notification =
      FlutterLocalNotificationsPlugin();

  static const String backendUrl =
      'https://notification-api-yham.onrender.com/send_notification'; // Replace with your actual server URL

  static Future<void> init() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await _notification.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        navigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (_) => AlarmScreen(
              medicineName: response.payload ?? 'Your Medicine',
            ),
          ),
          (route) => false, // Remove all other routes
        );
      },
    );

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

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

  Future<void> sendNotificationToBackend(
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
}
