package com.example.smart_pillbox

import android.app.*
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.os.Build
import android.util.Log
import androidx.core.app.NotificationCompat

class AlarmReceiver : BroadcastReceiver() {

    companion object {
        private var mediaPlayer: MediaPlayer? = null
    }

    override fun onReceive(context: Context, intent: Intent) {
        Log.d("AlarmReceiver", "Alarm triggered with intent: ${intent.action}, extras: ${intent.extras?.keySet()}")

        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        val medicineId = intent.getStringExtra("medicineId") ?: "unknown"
        val payload = intent.getStringExtra("payload") ?: "Medicine Reminder"
        val alarmTime = intent.getLongExtra("alarmTime", -1L)

        when (intent.action) {
            "STOP_ALARM" -> {
                stopAlarm(context, notificationManager, medicineId, intent.getLongExtra("alarmTime", -1L))
                Log.d("AlarmReceiver", "Alarm stopped for medicine ID: $medicineId")
                return
            }
            "SNOOZE_ALARM" -> {
                snoozeAlarm(context, notificationManager, medicineId, intent.getLongExtra("alarmTime", -1L))
                Log.d("AlarmReceiver", "Alarm snoozed for medicine ID: $medicineId")
                return
            }
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            createNotificationChannel(notificationManager)
        }

        val alarmIntent = Intent(context, AlarmActivity::class.java).apply {
            putExtra("payload", payload)
            putExtra("medicineId", medicineId)
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        try {
            context.startActivity(alarmIntent)
            Log.d("AlarmReceiver", "Started AlarmActivity for medicine ID: $medicineId")
        } catch (e: Exception) {
            Log.e("AlarmReceiver", "Failed to start AlarmActivity: ${e.message}")
        }

        val stopIntent = Intent(context, AlarmReceiver::class.java).apply {
            action = "STOP_ALARM"
            putExtra("medicineId", medicineId)
            putExtra("alarmTime", alarmTime) // Add alarmTime to stopIntent
        }
        val snoozeIntent = Intent(context, AlarmReceiver::class.java).apply {
            action = "SNOOZE_ALARM"
            putExtra("medicineId", medicineId)
            putExtra("alarmTime", alarmTime) // Add alarmTime to snoozeIntent
        }

        val stopPendingIntent = PendingIntent.getBroadcast(
            context,
            0,
            stopIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val snoozePendingIntent = PendingIntent.getBroadcast(
            context,
            1,
            snoozeIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val fullScreenPendingIntent = PendingIntent.getActivity(
            context,
            0,
            alarmIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val builder = NotificationCompat.Builder(context, "medicine_reminder")
            .setSmallIcon(R.drawable.ic_notification)
            .setContentTitle("Medicine Reminder")
            .setContentText("It's time to take your medicine: $payload")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setFullScreenIntent(fullScreenPendingIntent, true)
            .setAutoCancel(true)
            .setVibrate(longArrayOf(0, 500, 1000, 500))
            .addAction(R.drawable.ic_stop, "Stop", stopPendingIntent)
            .addAction(R.drawable.ic_snooze, "Snooze (5 min)", snoozePendingIntent)

        val notificationId = (medicineId + alarmTime.toString()).hashCode()
        notificationManager.notify(notificationId, builder.build())
        Log.d("AlarmReceiver", "Notification posted for medicine ID: $medicineId at time: $alarmTime (notificationId: $notificationId)")
    }

    private fun createNotificationChannel(notificationManager: NotificationManager) {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val attributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_ALARM)
                .build()

            val channel = NotificationChannel(
                "medicine_reminder",
                "Medicine Reminders",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "This channel is for medicine reminders"
                enableVibration(true)
                enableLights(true)
            }
            notificationManager.createNotificationChannel(channel)
            Log.d("AlarmReceiver", "Notification channel created")
        }
    }

    private fun stopAlarm(context: Context, notificationManager: NotificationManager, medicineId: String, alarmTime: Long) {
        mediaPlayer?.apply {
            stop()
            release()
        }
        mediaPlayer = null
        val notificationId = (medicineId + alarmTime.toString()).hashCode() // Use same ID as notify
        notificationManager.cancel(notificationId)
        Log.d("AlarmReceiver", "Notification canceled for medicine ID: $medicineId (notificationId: $notificationId)")
    }

    private fun snoozeAlarm(context: Context, notificationManager: NotificationManager, medicineId: String, alarmTime: Long) {
        stopAlarm(context, notificationManager, medicineId, alarmTime) // Pass alarmTime to stopAlarm
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val snoozeIntent = Intent(context, AlarmReceiver::class.java).apply {
            putExtra("medicineId", medicineId)
        }
        val pendingSnoozeIntent = PendingIntent.getBroadcast(
            context,
            2,
            snoozeIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        val snoozeTime = System.currentTimeMillis() + (5 * 60 * 1000)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, snoozeTime, pendingSnoozeIntent)
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, snoozeTime, pendingSnoozeIntent)
        }
        Log.d("AlarmReceiver", "Snooze alarm scheduled for medicine ID: $medicineId at: $snoozeTime")
    }
}