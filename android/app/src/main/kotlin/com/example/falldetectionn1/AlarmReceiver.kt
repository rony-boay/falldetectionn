package com.example.falldetectionn1

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat

class AlarmReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        val prediction = intent.getStringExtra("prediction")
        val timestamp = intent.getStringExtra("timestamp")

        val builder = NotificationCompat.Builder(context, "channelId")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle("Fall Detected: $prediction")
            .setContentText("Timestamp: $timestamp")
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)

        val notificationManager = NotificationManagerCompat.from(context)
        notificationManager.notify(1001, builder.build())
    }
}
