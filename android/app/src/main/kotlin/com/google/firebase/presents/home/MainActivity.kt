package com.example.smart_pillbox

import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.smart_pillbox/alarm"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "scheduleAlarm") {
                val alarmTime = call.argument<Long>("alarmTime")
                val payload = call.argument<String>("payload")
                if (alarmTime != null && payload != null) {
                    scheduleAlarm(alarmTime, payload)
                    result.success(null)
                } else {
                    result.error("INVALID_ARGUMENT", "Alarm time or payload is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun scheduleAlarm(alarmTime: Long, payload: String) {
        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val intent = Intent(this, AlarmReceiver::class.java).apply {
            putExtra("payload", payload)
        }
        
        val uniqueRequestCode = alarmTime.hashCode() // Generate a unique request code
        
        val pendingIntent = PendingIntent.getBroadcast(
            this,
            uniqueRequestCode, // Use unique request code
            intent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, alarmTime, pendingIntent)
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, alarmTime, pendingIntent)
        }
    }
}