import 'package:flutter/services.dart';

class AlarmScheduler {
  static const platform = MethodChannel('com.example.smart_pillbox/alarm');

  static Future<void> scheduleAlarm(
    String medicineId,
    DateTime alarmTime,
    String payload,
    List<String> selectedDays,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      // Calculate the next valid alarm time based on the provided criteria.
      DateTime? nextAlarmTime =
          getNextAlarmTime(alarmTime, selectedDays, startDate, endDate);
      if (nextAlarmTime != null) {
        await platform.invokeMethod('scheduleAlarm', {
          'medicineId': medicineId,
          'alarmTime': nextAlarmTime.millisecondsSinceEpoch,
          'payload': payload,
          'selectedDays': selectedDays,
          'startDate': startDate.millisecondsSinceEpoch,
          'endDate': endDate.millisecondsSinceEpoch,
        });
      } else {
        print(
            "[DEBUG] No valid next alarm time found for medicine ID: $medicineId.");
      }
    } on PlatformException catch (e) {
      print("Failed to schedule alarm: '${e.message}'.");
    }
  }

  /// Calculates the next valid alarm time based on:
  /// 1. The stored time-of-day from [baseTime],
  /// 2. The days of the week specified in [selectedDays],
  /// 3. The allowed date range between [startDate] and [endDate],
  /// 4. And ensuring the computed time is in the future relative to now.
  ///
  /// Returns a DateTime representing the next alarm time, or null if none is found.
  static DateTime? getNextAlarmTime(DateTime baseTime,
      List<String> selectedDays, DateTime startDate, DateTime endDate) {
    // Get the current time.
    DateTime currentTime = DateTime.now();
    // Start with the provided base time.
    DateTime checkTime = baseTime;

    // If the base time is before the startDate, adjust it to the startDate
    // but keep the original time-of-day (hour, minute, second).
    if (checkTime.isBefore(startDate)) {
      checkTime = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        baseTime.hour,
        baseTime.minute,
        baseTime.second,
      );
    }

    // Loop until we reach the end date, checking each day if it matches the criteria.
    while (checkTime.isBefore(endDate)) {
      // Get the abbreviated day name (e.g., "Mon", "Tue") for checkTime.
      String dayName = _getDayName(checkTime.weekday);
      // If the current checkTime falls on one of the selected days and is in the future, return it.
      if (selectedDays.contains(dayName) && checkTime.isAfter(currentTime)) {
        return checkTime;
      }
      // Move to the next day.
      checkTime = checkTime.add(const Duration(days: 1));
    }

    // Return null if no valid alarm time was found within the date range.
    return null;
  }

  /// Converts a weekday integer (1-7) into its abbreviated string representation.
  ///
  /// For example, 1 (Sunday) returns 'Sun', 2 (Monday) returns 'Mon', etc.
  static String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.sunday:
        return 'Sun';
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      default:
        return '';
    }
  }

  static Future<void> cancelAlarm(String medicineId) async {
    try {
      await platform.invokeMethod('cancelAlarm', {
        'medicineId': medicineId,
      });
      print("[DEBUG] Alarm for medicine ID $medicineId canceled successfully.");
    } on PlatformException catch (e) {
      print(
          "[ERROR] Failed to cancel alarm for medicine ID $medicineId: '${e.message}'.");
    }
  }
}
