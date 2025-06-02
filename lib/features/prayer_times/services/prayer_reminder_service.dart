import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/models/prayer_times_model.dart';
import 'package:flutter/foundation.dart';

@pragma('vm:entry-point')
class PrayerReminderService {
  // Singleton pattern
  static final PrayerReminderService _instance = PrayerReminderService._internal();
  
  @pragma('vm:entry-point')
  factory PrayerReminderService() => _instance;
  
  @pragma('vm:entry-point')
  PrayerReminderService._internal();

  bool _isInitialized = false;

  // Map prayer names to their Arabic names
  final Map<String, Map<String, String>> _prayerInfo = {
    'Fajr': {'name': 'الفجر', 'arabicName': 'الفجر'},
    'Dhuhr': {'name': 'الظهر', 'arabicName': 'الظهر'},
    'Asr': {'name': 'العصر', 'arabicName': 'العصر'},
    'Maghrib': {'name': 'المغرب', 'arabicName': 'المغرب'},
    'Isha': {'name': 'العشاء', 'arabicName': 'العشاء'},
    'fajr': {'name': 'الفجر', 'arabicName': 'الفجر'},
    'dhuhr': {'name': 'الظهر', 'arabicName': 'الظهر'},
    'asr': {'name': 'العصر', 'arabicName': 'العصر'},
    'maghrib': {'name': 'المغرب', 'arabicName': 'المغرب'},
    'isha': {'name': 'العشاء', 'arabicName': 'العشاء'},
  };

  // Initialize the service
  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('ℹ️ PrayerReminderService already initialized.');
      return;
    }
    debugPrint('🔄 Initializing PrayerReminderService...');
    
    _isInitialized = true;
    debugPrint('✅ PrayerReminderService Initialized Successfully');
  }

  // فتح إعدادات تحسينات البطارية (للاستخدام في شاشة الإعدادات)
  Future<bool> openBatteryOptimizationSettings() async {
    const platform = MethodChannel('com.beatelslam.app/battery_settings');
    try {
      return await platform.invokeMethod('openBatterySettings') ?? false;
    } catch (e) {
      debugPrint('❌ Error opening battery settings via channel: $e');
      return false;
    }
  }
}