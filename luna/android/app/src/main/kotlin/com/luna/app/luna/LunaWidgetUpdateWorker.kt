package com.luna.app.luna

import android.content.Context
import androidx.glance.appwidget.updateAll
import androidx.work.CoroutineWorker
import androidx.work.WorkerParameters
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId
import java.time.temporal.ChronoUnit

class LunaWidgetUpdateWorker(
    context: Context,
    params: WorkerParameters,
) : CoroutineWorker(context, params) {

    override suspend fun doWork(): Result {
        val prefs = applicationContext
            .getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)

        val startMsStr  = prefs.getString("luna_cycle_start_ms", null)
        val cycleLength = prefs.getInt("luna_cycle_length", 28)

        if (startMsStr != null) {
            val startMs = startMsStr.toLongOrNull()
            if (startMs != null) {
                val zone      = ZoneId.systemDefault()
                val startDate = Instant.ofEpochMilli(startMs).atZone(zone).toLocalDate()
                val today     = LocalDate.now(zone)

                val cycleDay  = (ChronoUnit.DAYS.between(startDate, today) + 1)
                    .toInt().coerceAtLeast(1)
                val nextStart = startDate.plusDays(cycleLength.toLong())
                val daysUntil = ChronoUnit.DAYS.between(today, nextStart)
                    .toInt().coerceAtLeast(0)

                prefs.edit()
                    .putInt("luna_cycle_day", cycleDay)
                    .putInt("luna_days_until_period", daysUntil)
                    .apply()
            }
        }

        LunaWidget().updateAll(applicationContext)
        return Result.success()
    }
}
