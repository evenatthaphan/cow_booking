package com.example.cow_booking

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onStart() {
        super.onStart()
        
        // สร้าง Notification Channel สำหรับ Android 8 ขึ้นไป
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelId = "cow_booking_channel"
            val channelName = "Cow Booking Notifications"
            val importance = NotificationManager.IMPORTANCE_HIGH
            val channel = NotificationChannel(channelId, channelName, importance).apply {
                description = "Notifications for Cow Booking"
                enableVibration(true)
                enableLights(true)
            }
            
            val notificationManager = getSystemService(NOTIFICATION_SERVICE) as NotificationManager
            notificationManager.createNotificationChannel(channel)
        }
    }
}
