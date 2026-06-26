package com.luna.app.luna

import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.action.actionStartActivity
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider

class LunaWidget : GlanceAppWidget() {

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val prefs = context.getSharedPreferences("HomeWidgetPreferences", Context.MODE_PRIVATE)
        val phase      = prefs.getString("luna_phase", "menstrual") ?: "menstrual"
        val phaseName  = prefs.getString("luna_phase_name", "Menstrual Phase") ?: "Menstrual Phase"
        val cycleDay   = prefs.getInt("luna_cycle_day", 0)
        val daysUntil  = prefs.getInt("luna_days_until_period", 0)
        val hasCycle   = prefs.getBoolean("luna_has_cycle", false)

        provideContent {
            WidgetContent(
                phase     = phase,
                phaseName = phaseName,
                cycleDay  = cycleDay,
                daysUntil = daysUntil,
                hasCycle  = hasCycle,
            )
        }
    }
}

@Composable
private fun WidgetContent(
    phase: String,
    phaseName: String,
    cycleDay: Int,
    daysUntil: Int,
    hasCycle: Boolean,
) {
    val phaseColor = when (phase) {
        "follicular" -> Color(0xFFF97316)
        "ovulation"  -> Color(0xFF10B981)
        "luteal"     -> Color(0xFF8B5CF6)
        else         -> Color(0xFFE53E6A)
    }
    val bgColor = when (phase) {
        "follicular" -> Color(0xFF2D1F08)
        "ovulation"  -> Color(0xFF0D2B22)
        "luteal"     -> Color(0xFF1E1433)
        else         -> Color(0xFF2D1220)
    }

    Box(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(bgColor)
            .padding(14.dp)
            .clickable(actionStartActivity<MainActivity>()),
        contentAlignment = Alignment.TopStart,
    ) {
        Column {
            Text(
                text = "● $phaseName",
                style = TextStyle(
                    color = ColorProvider(phaseColor),
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Medium,
                ),
            )
            Spacer(modifier = GlanceModifier.height(10.dp))
            if (hasCycle) {
                Text(
                    text = "Day $cycleDay",
                    style = TextStyle(
                        color = ColorProvider(Color.White),
                        fontSize = 26.sp,
                        fontWeight = FontWeight.Bold,
                    ),
                )
                Spacer(modifier = GlanceModifier.height(3.dp))
                Text(
                    text = if (daysUntil == 0) "Period due" else "$daysUntil days until period",
                    style = TextStyle(
                        color = ColorProvider(Color(0xCCFFFFFF)),
                        fontSize = 12.sp,
                    ),
                )
            } else {
                Text(
                    text = "No active cycle",
                    style = TextStyle(
                        color = ColorProvider(Color.White),
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Medium,
                    ),
                )
                Spacer(modifier = GlanceModifier.height(3.dp))
                Text(
                    text = "Tap to start tracking",
                    style = TextStyle(
                        color = ColorProvider(Color(0xCCFFFFFF)),
                        fontSize = 12.sp,
                    ),
                )
            }
        }
    }
}
