package com.example.smart_pillbox

import android.app.AlarmManager
import android.app.PendingIntent
import android.app.KeyguardManager
import android.content.Context
import android.content.Intent
import android.media.MediaPlayer
import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import android.widget.Button
import android.widget.TextView
import android.os.VibrationEffect
import android.os.Vibrator
import java.util.Calendar
import io.flutter.embedding.android.FlutterActivity

class AlarmActivity : FlutterActivity() {
    private var mediaPlayer: MediaPlayer? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O_MR1) {
            setShowWhenLocked(true)
            setTurnScreenOn(true)
        } else {
            window.addFlags(
                WindowManager.LayoutParams.FLAG_SHOW_WHEN_LOCKED
                        or WindowManager.LayoutParams.FLAG_DISMISS_KEYGUARD
                        or WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON
                        or WindowManager.LayoutParams.FLAG_TURN_SCREEN_ON
                        or WindowManager.LayoutParams.FLAG_ALLOW_LOCK_WHILE_SCREEN_ON
            )
        }

        // Disable keyguard
        val keyguardManager = getSystemService(Context.KEYGUARD_SERVICE) as KeyguardManager
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            keyguardManager.requestDismissKeyguard(this, null)
        }

        setContentView(R.layout.activity_alarm)

        val alarmTextView: TextView = findViewById(R.id.alarmTextView)
        val dismissButton: Button = findViewById(R.id.dismissButton)
        val snoozeButton: Button = findViewById(R.id.snoozeButton)

        val message = intent.getStringExtra("payload") ?: "Time to take your medicine!"
        alarmTextView.text = message

        // Play alarm sound
        mediaPlayer = MediaPlayer.create(this, R.raw.alarm)
        mediaPlayer?.isLooping = true
        mediaPlayer?.start()

        val vibrator = context.getSystemService(Context.VIBRATOR_SERVICE) as Vibrator
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            // Vibration effect for Android 8.0+ (API 26+)
            val vibrationEffect = VibrationEffect.createWaveform(
                longArrayOf(0, 500, 1000, 500, 1000), // Pattern: wait, vibrate, pause, vibrate
                0 // Repeat indefinitely (use -1 to stop after one cycle)
            )
            vibrator.vibrate(vibrationEffect)
        } else {
            // For older devices
            vibrator.vibrate(longArrayOf(0, 500, 1000, 500, 1000), 0)
        }

        // Dismiss button stops alarm
        dismissButton.setOnClickListener {
            mediaPlayer?.stop()
            mediaPlayer?.release()
            mediaPlayer = null
            vibrator.cancel()
            finish()
        }

        // Handle Snooze Button
        snoozeButton.setOnClickListener {
            val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
            val snoozeIntent = Intent(this, AlarmReceiver::class.java)
            val pendingIntent = PendingIntent.getBroadcast(
                this,
                System.currentTimeMillis().toInt(), // Unique request code
                snoozeIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )

            val snoozeTime = Calendar.getInstance().apply {
                add(Calendar.MINUTE, 5) // Add snooze minutes
            }.timeInMillis

            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.M) {
                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, snoozeTime, pendingIntent)
            } else {
                alarmManager.setExact(AlarmManager.RTC_WAKEUP, snoozeTime, pendingIntent)
            }

            mediaPlayer?.stop()
            mediaPlayer?.release()
            mediaPlayer = null
            vibrator.cancel()
            finish()
            finish() // Close the alarm screen
        }
    }



    override fun onDestroy() {
        super.onDestroy()
        mediaPlayer?.release()
    }
}