package com.example.beat_elslam

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import androidx.annotation.NonNull
import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

class MainActivity : FlutterActivity() {
    private val BATTERY_SETTINGS_CHANNEL = "com.beatelslam.app/battery_settings"
    private val APP_SETTINGS_CHANNEL = "com.beatelslam.app/app_settings"
    private val PERMISSIONS_REQUEST_CODE = 123

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        requestRequiredPermissions()
    }

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // إضافة قناة لفتح إعدادات البطارية
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BATTERY_SETTINGS_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "openBatterySettings") {
                try {
                    val success = openBatteryOptimizationSettings()
                    result.success(success)
                } catch (e: Exception) {
                    result.error("UNAVAILABLE", "Battery optimization settings not available.", null)
                }
            } else {
                result.notImplemented()
            }
        }

        // إضافة قناة لفتح إعدادات التطبيق
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, APP_SETTINGS_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "openAppSettings") {
                try {
                    val success = openAppSettings()
                    result.success(success)
                } catch (e: Exception) {
                    result.error("UNAVAILABLE", "App settings not available.", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    // طلب الأذونات المطلوبة
    private fun requestRequiredPermissions() {
        val permissionsToRequest = mutableListOf<String>()

        // أذونات الإشعارات لـ Android 13+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
                permissionsToRequest.add(Manifest.permission.POST_NOTIFICATIONS)
            }
        }

        // طلب أذونات الموقع إذا كان ذلك مطلوباً
        if (ContextCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {
            permissionsToRequest.add(Manifest.permission.ACCESS_FINE_LOCATION)
        }

        // أذونات الإنذار الدقيق
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            if (ContextCompat.checkSelfPermission(this, Manifest.permission.SCHEDULE_EXACT_ALARM) != PackageManager.PERMISSION_GRANTED) {
                permissionsToRequest.add(Manifest.permission.SCHEDULE_EXACT_ALARM)
            }
        }

        // طلب الأذونات إذا كان هناك أي أذونات مطلوبة
        if (permissionsToRequest.isNotEmpty()) {
            ActivityCompat.requestPermissions(this, permissionsToRequest.toTypedArray(), PERMISSIONS_REQUEST_CODE)
        }
    }

    // طريقة لفتح إعدادات تحسين البطارية
    private fun openBatteryOptimizationSettings(): Boolean {
        return try {
            val helper = BatteryOptimizationHelper(context)
            val intent = helper.getRequestIgnoreBatteryOptimizationIntent()
            startActivity(intent)
            true
        } catch (e: Exception) {
            // في حالة حدوث خطأ، نحاول استخدام إعدادات البطارية العامة
            try {
                val helper = BatteryOptimizationHelper(context)
                val intent = helper.getBatterySettingsIntent()
                startActivity(intent)
                true
            } catch (e2: Exception) {
                false
            }
        }
    }

    // طريقة لفتح إعدادات التطبيق العامة
    private fun openAppSettings(): Boolean {
        return try {
            val helper = BatteryOptimizationHelper(context)
            val intent = helper.getAppSettingsIntent()
            startActivity(intent)
            true
        } catch (e: Exception) {
            false
        }
    }
}
