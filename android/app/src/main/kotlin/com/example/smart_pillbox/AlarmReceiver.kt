package com.example.smart_pillbox

import android.app.*
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.media.AudioAttributes
import android.media.MediaPlayer
import android.os.Build
import androidx.core.app.NotificationCompat
import java.util.Calendar

class AlarmReceiver : BroadcastReceiver() {

    companion object {
        private var mediaPlayer: MediaPlayer? = null
    }

    override fun onReceive(context: Context, intent: Intent) {
        val notificationManager = context.getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager

        // Handle stop and snooze actions
        when (intent.action) {
            "STOP_ALARM" -> {
                stopAlarm(context, notificationManager)
                return
            }
            "SNOOZE_ALARM" -> {
                snoozeAlarm(context, notificationManager)
                return
            }
        }

        // Create the notification channel (for Android O and above)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            createNotificationChannel(notificationManager)
        }

        // Launch the AlarmActivity
        val alarmIntent = Intent(context, AlarmActivity::class.java).apply {
            putExtra("payload", intent.getStringExtra("payload"))
            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        }
        context.startActivity(alarmIntent)

        // Build stop and snooze PendingIntents for the notification actions
        val stopIntent = Intent(context, AlarmReceiver::class.java).apply {
            action = "STOP_ALARM"
        }
        val snoozeIntent = Intent(context, AlarmReceiver::class.java).apply {
            action = "SNOOZE_ALARM"
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
            .setContentText("It's time to take your medicine!")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setCategory(NotificationCompat.CATEGORY_ALARM)
            .setFullScreenIntent(fullScreenPendingIntent, true)
            .setAutoCancel(true)
            .setVibrate(longArrayOf(0, 500, 1000, 500))
            .addAction(R.drawable.ic_stop, "Stop", stopPendingIntent)
            .addAction(R.drawable.ic_snooze, "Snooze (5 min)", snoozePendingIntent)

        notificationManager.notify(1, builder.build())

        // --- Reschedule the next recurring alarm (if recurring info is provided) ---
        // Reschedule the next alarm if recurring info is provided
        val selectedDays = intent.getStringArrayListExtra("selectedDays")
        val endDate = intent.getLongExtra("endDate", -1L)
        val medicineId = intent.getStringExtra("medicineId")
        val startDate = intent.getLongExtra("startDate", -1L)

        if (selectedDays != null && endDate != -1L && medicineId != null && startDate != -1L) {
            val currentTime = System.currentTimeMillis()
            val nextAlarmTime = calculateNextAlarmTime(currentTime, selectedDays, startDate)
            if (nextAlarmTime != null && nextAlarmTime < endDate) {
                scheduleNextRecurringAlarm(context, nextAlarmTime, intent)
            }
        }
    }

    /**
     * Creates the notification channel for the alarm.
     */
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
        }
    }

    /**
     * Stops the alarm sound and cancels the notification.
     */
    private fun stopAlarm(context: Context, notificationManager: NotificationManager) {
        mediaPlayer?.apply {
            stop()
            release()
        }
        mediaPlayer = null
        notificationManager.cancel(1)
    }

    /**
     * Snoozes the alarm for 5 minutes.
     */
    private fun snoozeAlarm(context: Context, notificationManager: NotificationManager) {
        stopAlarm(context, notificationManager)
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val snoozeIntent = Intent(context, AlarmReceiver::class.java)
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
    }

    /**
     * Schedules the next recurring alarm.
     */
    private fun scheduleNextRecurringAlarm(context: Context, nextAlarmTime: Long, originalIntent: Intent) {
        val alarmManager = context.getSystemService(Context.ALARM_SERVICE) as AlarmManager
        val newIntent = Intent(context, AlarmReceiver::class.java).apply {
            putExtra("payload", originalIntent.getStringExtra("payload"))
            putExtra("medicineId", originalIntent.getStringExtra("medicineId"))
            putExtra("selectedDays", originalIntent.getStringArrayListExtra("selectedDays"))
            putExtra("startDate", originalIntent.getLongExtra("startDate", -1L))
            putExtra("endDate", originalIntent.getLongExtra("endDate", -1L))
        }
        val medicineId = originalIntent.getStringExtra("medicineId") ?: ""
        val uniqueRequestCode = medicineId.hashCode()
        val pendingIntent = PendingIntent.getBroadcast(
            context,
            uniqueRequestCode,
            newIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, nextAlarmTime, pendingIntent)
        } else {
            alarmManager.setExact(AlarmManager.RTC_WAKEUP, nextAlarmTime, pendingIntent)
        }
    }

    /**
     * Calculates the next alarm time based on the current time, selected days, and the original startDate (intended time-of-day).
     */
    private fun calculateNextAlarmTime(currentTime: Long, selectedDays: List<String>, startDate: Long): Long? {
        val calendar = Calendar.getInstance()
        // Start from the later of currentTime or startDate.
        calendar.timeInMillis = if (currentTime < startDate) startDate else currentTime

        // Retrieve the intended hour and minute from startDate.
        val startCalendar = Calendar.getInstance().apply { timeInMillis = startDate }
        val intendedHour = startCalendar.get(Calendar.HOUR_OF_DAY)
        val intendedMinute = startCalendar.get(Calendar.MINUTE)

        // Day map with abbreviated names matching Flutter.
        val dayMap = mapOf(
            "Sun" to Calendar.SUNDAY,
            "Mon" to Calendar.MONDAY,
            "Tue" to Calendar.TUESDAY,
            "Wed" to Calendar.WEDNESDAY,
            "Thu" to Calendar.THURSDAY,
            "Fri" to Calendar.FRIDAY,
            "Sat" to Calendar.SATURDAY
        )

        val currentDay = calendar.get(Calendar.DAY_OF_WEEK)
        var daysUntilNext: Int? = null

        // Loop through the next 7 days (including today) to find a matching day.
        for (i in 0..7) {
            val checkDay = (currentDay - 1 + i) % 7 + 1
            val dayName = dayMap.entries.find { it.value == checkDay }?.key
            if (dayName != null && selectedDays.any { it.equals(dayName, ignoreCase = true) }) {
                calendar.add(Calendar.DAY_OF_YEAR, i)
                calendar.set(Calendar.HOUR_OF_DAY, intendedHour)
                calendar.set(Calendar.MINUTE, intendedMinute)
                calendar.set(Calendar.SECOND, 0)
                calendar.set(Calendar.MILLISECOND, 0)
                if (calendar.timeInMillis > currentTime) {
                    daysUntilNext = i
                    break
                } else {
                    calendar.timeInMillis = currentTime
                }
            }
        }
        return daysUntilNext?.let { calendar.timeInMillis }
    }
}
