package com.example.alive

import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannels()
    }

    private fun createNotificationChannels() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val manager = getSystemService(NotificationManager::class.java)

            // Alerts channel (high priority)
            val alertsChannel = NotificationChannel(
                "alive_alerts",
                "Safety Alerts",
                NotificationManager.IMPORTANCE_HIGH
            ).apply {
                description = "Alerts when your contact hasn't checked in"
                enableVibration(true)
            }

            // Requests channel
            val requestsChannel = NotificationChannel(
                "alive_requests",
                "Connection Requests",
                NotificationManager.IMPORTANCE_DEFAULT
            ).apply {
                description = "Monitoring connection requests"
            }

            manager.createNotificationChannel(alertsChannel)
            manager.createNotificationChannel(requestsChannel)
        }
    }
}