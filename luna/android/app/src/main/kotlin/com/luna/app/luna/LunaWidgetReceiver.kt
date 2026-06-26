package com.luna.app.luna

import androidx.glance.appwidget.GlanceAppWidgetReceiver

class LunaWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget = LunaWidget()
}
