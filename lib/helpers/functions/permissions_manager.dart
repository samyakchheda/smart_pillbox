import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestNotificationPermission() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  try {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: true,
      badge: true,
      carPlay: true,
      criticalAlert: true,
      provisional: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Notification permissions granted.');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('Notification permissions granted provisionally.');
    } else {
      print('Notification permissions denied.');
    }
  } catch (e) {
    print("Error requesting notification permission: $e");
  }
}

Future<void> requestAlarmPermission(BuildContext context) async {
  if (Platform.isAndroid) {
    try {
      var status = await Permission.scheduleExactAlarm.status;

      if (status.isDenied || status.isPermanentlyDenied) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Dialog(
            backgroundColor: Colors.grey[900],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.notifications,
                    color: Colors.blue,
                    size: 40,
                  ),
                  const SizedBox(height: 20),
                  RichText(
                    textAlign: TextAlign.center,
                    text: const TextSpan(
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                      children: [
                        TextSpan(text: 'Allow '),
                        TextSpan(
                          text: 'home',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(text: ' to send you notifications?'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Column(
                    children: [
                      TextButton(
                        onPressed: () async {
                          Navigator.of(context).pop();
                          var result =
                              await Permission.scheduleExactAlarm.request();

                          if (result.isGranted) {
                            print("Alarm permission granted.");
                          } else {
                            print("Alarm permission denied.");
                          }
                        },
                        child: const Text(
                          "Allow",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          print("Permission denied by user.");
                        },
                        child: const Text(
                          "Don't allow",
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      } else if (status.isGranted) {
        print("Alarm permission already granted.");
      } else {
        print("Permission not required for this version.");
      }
    } catch (e) {
      print("Error checking alarm permission: $e");
    }
  } else {
    print("Alarm permission is not applicable to this platform.");
  }
}
