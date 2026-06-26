package com.luna.app.luna

import android.os.Bundle
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import io.flutter.embedding.android.FlutterActivity
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        scheduleWidgetUpdate()
    }

    private fun scheduleWidgetUpdate() {
        val request = PeriodicWorkRequestBuilder<LunaWidgetUpdateWorker>(1, TimeUnit.DAYS)
            .build()
        WorkManager.getInstance(this).enqueueUniquePeriodicWork(
            "luna_widget_update",
            ExistingPeriodicWorkPolicy.KEEP,
            request,
        )
    }
}
