// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:timezone/data/latest.dart' as tzData;

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   tzData.initializeTimeZones();

//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   const AndroidInitializationSettings initializationSettingsAndroid =
//       AndroidInitializationSettings('@mipmap/ic_launcher');

//   final InitializationSettings initializationSettings =
//       InitializationSettings(android: initializationSettingsAndroid);

//   await flutterLocalNotificationsPlugin.initialize(initializationSettings);

//   runApp(
//       MyApp(flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin));
// }

// class MyApp extends StatelessWidget {
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

//   MyApp({required this.flutterLocalNotificationsPlugin});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: AlarmScheduler(
//         flutterLocalNotificationsPlugin: flutterLocalNotificationsPlugin,
//       ),
//     );
//   }
// }

// class AlarmScheduler extends StatefulWidget {
//   final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

//   AlarmScheduler({required this.flutterLocalNotificationsPlugin});

//   @override
//   _AlarmSchedulerState createState() => _AlarmSchedulerState();
// }

// class _AlarmSchedulerState extends State<AlarmScheduler> {
//   TimeOfDay _selectedTime = TimeOfDay.now();

//   Future<void> _selectTime(BuildContext context) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: _selectedTime,
//     );
//     if (picked != null && picked != _selectedTime) {
//       setState(() {
//         _selectedTime = picked;
//       });
//     }
//   }

//   Future<void> scheduleAlarm() async {
//     final DateTime now = DateTime.now();
//     DateTime alarmTime = DateTime(
//       now.year,
//       now.month,
//       now.day,
//       _selectedTime.hour,
//       _selectedTime.minute,
//     );

//     if (alarmTime.isBefore(now)) {
//       alarmTime = alarmTime.add(Duration(days: 1));
//     }

//     // Convert DateTime to TZDateTime
//     tz.TZDateTime scheduledDate = tz.TZDateTime.from(alarmTime, tz.local);

//     AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'alarm_channel_id',
//       'Alarm Channel',
//       channelDescription: 'Channel for alarm notifications',
//       importance: Importance.max,
//       priority: Priority.high,
//       sound: const RawResourceAndroidNotificationSound('alarm'),
//       vibrationPattern: Int64List.fromList([0, 1000, 500, 1000]),
//       enableVibration: true,
//       playSound: true,
//       timeoutAfter: 60000, // Auto-dismiss after 1 minute
//       actions: const <AndroidNotificationAction>[
//         AndroidNotificationAction(
//           'snooze',
//           'Snooze',
//         ),
//         AndroidNotificationAction(
//           'stop',
//           'Stop',
//         ),
//       ],
//     );

//     NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);

//     // Updated function without androidAllowWhileIdle
//     await widget.flutterLocalNotificationsPlugin.zonedSchedule(
//       0,
//       'Medicine Reminder',
//       'It\'s time to take your medicine!',
//       scheduledDate, // Pass TZDateTime here
//       platformChannelSpecifics,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: DateTimeComponents.time,
//       androidScheduleMode:
//           AndroidScheduleMode.exactAllowWhileIdle, // Added this line
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Schedule Alarm'),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text(
//               'Selected time: ${_selectedTime.format(context)}',
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: () => _selectTime(context),
//               child: Text('Select Time'),
//             ),
//             SizedBox(height: 20),
//             ElevatedButton(
//               onPressed: scheduleAlarm,
//               child: Text('Schedule Alarm'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
