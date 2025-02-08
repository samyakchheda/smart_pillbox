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

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.smart_pillbox/alarm"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "scheduleAlarm" -> {
                    val alarmTime = call.argument<Long>("alarmTime")
                    val payload = call.argument<String>("payload")
                    val medicineId = call.argument<String>("medicineId")
                    if (alarmTime != null && payload != null && medicineId != null) {
                        scheduleAlarm(alarmTime, payload, medicineId)
                        result.success(null)
                    } else {
                        result.error("INVALID_ARGUMENT", "Alarm time, payload, or medicine ID is null", null)
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

    private fun scheduleAlarm(alarmTime: Long, payload: String, medicineId: String) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, AlarmReceiver::class.java).apply {
            putExtra("payload", payload)
        }
        
        val uniqueRequestCode = medicineId.hashCode() // Use medicineId as unique ID
        
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            uniqueRequestCode,
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, alarmTime, pendingIntent)
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, alarmTime, pendingIntent)
        }
        
        Log.d("AlarmScheduler", "Alarm scheduled for medicine ID: $medicineId at $alarmTime")
    }

    private fun cancelAlarm(medicineId: String) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, AlarmReceiver::class.java)
        val pendingIntent = PendingIntent.getBroadcast(
            this, 
            medicineId.hashCode(),  // Use medicine ID to retrieve the correct alarm
            intent, 
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        
        alarmManager.cancel(pendingIntent)
        pendingIntent.cancel()
        Log.d("AlarmScheduler", "Alarm canceled for medicine ID: $medicineId")
    }
}
