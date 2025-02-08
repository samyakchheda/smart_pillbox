import 'package:flutter/services.dart';

class AlarmScheduler {
  static const platform = MethodChannel('com.example.smart_pillbox/alarm');

  static Future<void> scheduleAlarm(
      String medicineId, DateTime alarmTime, String payload) async {
    try {
      await platform.invokeMethod('scheduleAlarm', {
        'medicineId': medicineId,
        'alarmTime': alarmTime.millisecondsSinceEpoch,
        'payload': payload,
      });
    } on PlatformException catch (e) {
      print("Failed to schedule alarm: '${e.message}'.");
    }
  }

  static Future<void> cancelAlarm(String medicineId) async {
    try {
      await platform.invokeMethod('cancelAlarm', {
        'medicineId': medicineId, // Pass the medicine ID
      });
      print("[DEBUG] Alarm for medicine ID $medicineId canceled successfully.");
    } on PlatformException catch (e) {
      print(
          "[ERROR] Failed to cancel alarm for medicine ID $medicineId: '${e.message}'.");
    }
  }
}
