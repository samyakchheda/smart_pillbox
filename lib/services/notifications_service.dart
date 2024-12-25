import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:http/http.dart' as http;
import 'dart:convert';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notification =
      FlutterLocalNotificationsPlugin();

  // Backend URL for sending notifications via Flask server
  static const String backendUrl =
      'https://notification-api-git-main-rishivejani15s-projects.vercel.app/send_notification'; // Replace with your actual server URL

  // Initialize local notifications
  static Future<void> init() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: androidInitializationSettings);

    await _notification.initialize(initializationSettings);

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
  }

  // Schedule local notification for medicine reminder
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
      // Adjust time if it's in the past
      tz.TZDateTime scheduledTime = tz.TZDateTime.from(medicineTime, tz.local);
      if (scheduledTime
          .isBefore(tz.TZDateTime.now(tz.local).add(Duration(minutes: 5)))) {
        scheduledTime = scheduledTime.add(Duration(days: 1));
      }

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
      // Optionally, log to a service like Firebase Crashlytics
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
          'device_token':
              "dcxeyWktSlGFIwetDW0io5:APA91bFFhD4PlijUGTUdeKUf31wAMP0kUQGKvCZQ3S7C3pGSLfzsRvX9siYoy94y4E_bVSzefzKqRlvDqofubJzxQMFQLr-VAHf9d8OQFbUJvJfZGAcDNQY",
          'title': title,
          'body': body,
        }),
      );

      if (response.statusCode == 200) {
        print('Notification sent successfully');
      } else {
        // Print response body for debugging
        print('Failed to send notification');
        print('Response code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Check if a notification is already scheduled
  static Future<bool> isNotificationScheduled(String notificationId) async {
    try {
      final pendingNotifications =
          await _notification.pendingNotificationRequests();
      return pendingNotifications
          .any((notification) => notification.id == notificationId.hashCode);
    } catch (e) {
      // Optionally, log to a service like Firebase Crashlytics
      return false;
    }
  }
}
