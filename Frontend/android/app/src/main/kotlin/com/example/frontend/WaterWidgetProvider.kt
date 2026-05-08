package com.example.frontend

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetProvider

class WaterWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(context: Context, appWidgetManager: AppWidgetManager, appWidgetIds: IntArray, widgetData: SharedPreferences) {
        appWidgetIds.forEach { widgetId ->
            // حرف الـ R هنا سيتعرف على ملفات الـ XML بنجاح الآن
            val views = RemoteViews(context.packageName, R.layout.water_widget).apply {
                val backgroundIntent = HomeWidgetBackgroundIntent.getBroadcast(
                    context, 
                    Uri.parse("homeWidgetExample://addwater")
                )
                setOnClickPendingIntent(R.id.btn_add_water, backgroundIntent)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}