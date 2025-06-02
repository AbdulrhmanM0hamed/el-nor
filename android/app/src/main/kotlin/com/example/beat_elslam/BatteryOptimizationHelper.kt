package com.example.beat_elslam; // OK

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings

/**
 * Helper class to handle battery optimization settings
 */
class BatteryOptimizationHelper(private val context: Context) {
    
    /**
     * Check if the app is ignoring battery optimizations
     */
    fun isIgnoringBatteryOptimizations(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            val powerManager = context.getSystemService(Context.POWER_SERVICE) as PowerManager
            return powerManager.isIgnoringBatteryOptimizations(context.packageName)
        }
        return false
    }
    
    /**
     * Open battery optimization settings for this app
     */
    fun getRequestIgnoreBatteryOptimizationIntent(): Intent {
        val intent = Intent()
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            if (isIgnoringBatteryOptimizations()) {
                // If already ignoring, open the full list
                intent.action = Settings.ACTION_IGNORE_BATTERY_OPTIMIZATION_SETTINGS
            } else {
                // If not ignoring, request to be ignored
                intent.action = Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS
                intent.data = Uri.parse("package:${context.packageName}")
            }
        }
        return intent
    }
    
    /**
     * Open battery settings (fallback)
     */
    fun getBatterySettingsIntent(): Intent {
        return Intent(Settings.ACTION_BATTERY_SAVER_SETTINGS)
    }
    
    /**
     * Open app details settings
     */
    fun getAppSettingsIntent(): Intent {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        intent.data = Uri.fromParts("package", context.packageName, null)
        return intent
    }
}
