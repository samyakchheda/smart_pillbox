package com.example.smart_pillbox

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.smart_pillbox/alarm"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleAlarm" -> {
                    val alarmTime = call.argument<Long>("alarmTime")
                    val payload = call.argument<String>("payload")
                    val medicineId = call.argument<String>("medicineId")
                    val selectedDays = call.argument<List<String>>("selectedDays")
                    val endDate = call.argument<Long>("endDate")
                    val startDate = call.argument<Long>("startDate")

                    if (alarmTime != null && payload != null && medicineId != null &&
                        selectedDays != null && endDate != null && startDate != null) {
                        scheduleRecurringAlarm(alarmTime, payload, medicineId, selectedDays, startDate, endDate)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Missing required parameters", null)
                    }
                }
                "cancelAlarm" -> {
                    val medicineId = call.argument<String>("medicineId")
                    if (medicineId != null) {
                        cancelAlarm(medicineId)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Medicine ID is null", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun scheduleRecurringAlarm(
        initialAlarmTime: Long,
        payload: String,
        medicineId: String,
        selectedDays: List<String>,
        startDate: Long,
        endDate: Long
    ) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, AlarmReceiver::class.java).apply {
            putExtra("payload", payload)
            putExtra("medicineId", medicineId)
            putExtra("selectedDays", ArrayList(selectedDays))
            putExtra("startDate", startDate)
            putExtra("endDate", endDate)
            putExtra("alarmTime", initialAlarmTime) // Pass original alarm time for reference
        }

        // Use a unique requestCode combining medicineId and alarmTime
        val requestCode = (medicineId + initialAlarmTime.toString()).hashCode()

        val pendingIntent = PendingIntent.getBroadcast(
            this,
            requestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        Log.d("AlarmScheduler", "Scheduling alarm for medicine ID: $medicineId at time: $initialAlarmTime (requestCode: $requestCode)")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, initialAlarmTime, pendingIntent)
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, initialAlarmTime, pendingIntent)
        }

        Log.d("AlarmScheduler", "Alarm scheduled successfully for medicine ID: $medicineId at time: $initialAlarmTime")
    }

    private fun cancelAlarm(medicineId: String) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, AlarmReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            medicineId.hashCode(),
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        alarmManager.cancel(pendingIntent)
        pendingIntent.cancel()
        Log.d("AlarmScheduler", "Alarm canceled for medicine ID: $medicineId")
    }
}