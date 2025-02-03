import 'package:flutter/services.dart';

class AlarmScheduler {
  static const platform = MethodChannel('com.example.smart_pillbox/alarm');

  static Future<void> scheduleAlarm(DateTime alarmTime, String payload) async {
    try {
      await platform.invokeMethod('scheduleAlarm', {
        'alarmTime': alarmTime.millisecondsSinceEpoch,
        'payload': payload,
      });
    } on PlatformException catch (e) {
      print("Failed to schedule alarm: '${e.message}'.");
    }
  }
}
