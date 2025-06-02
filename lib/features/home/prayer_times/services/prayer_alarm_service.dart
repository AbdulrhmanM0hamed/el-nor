import 'dart:async';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../data/models/prayer_times_model.dart';

// الدوال المستدعاة بواسطة AlarmManager خارج السياق الرئيسي
@pragma('vm:entry-point')
void playPrayerAdhan(int id, Map<String, dynamic> data) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prayerName = data['prayer_name'];
  final isTest = data['is_test'] == true;
  
  debugPrint('📢 تم استدعاء playPrayerAdhan: $prayerName, اختبار: $isTest');
  
  // تسجيل SendPort للتواصل مع عزلة الخلفية
  final SendPort? sendPort = IsolateNameServer.lookupPortByName('prayer_adhan_port');
  if (sendPort != null) {
    sendPort.send('start_prayer_adhan:$prayerName');
  }
  
  // بدء خدمة الواجهة الأمامية
  initForegroundTask();
  
  // إضافة نص مختلف للاختبار
  final notificationTitle = isTest ? 'اختبار وقت الصلاة' : 'وقت الصلاة';
  final notificationText = isTest 
    ? 'هذا اختبار لتشغيل أذان صلاة ${_getArabicPrayerName(prayerName)}'
    : 'حان الآن وقت صلاة ${_getArabicPrayerName(prayerName)}';
  
  await FlutterForegroundTask.startService(
    notificationTitle: notificationTitle,
    notificationText: notificationText,
    callback: startForegroundCallback,
  );
}

// الدالة التي تعمل داخل خدمة الواجهة الأمامية
@pragma('vm:entry-point')
void startForegroundCallback() {
  FlutterForegroundTask.setTaskHandler(PrayerAdhanTaskHandler());
}

// معالج المهام للخدمة الأمامية
class PrayerAdhanTaskHandler extends TaskHandler {
  AudioPlayer? _audioPlayer;
  Timer? _playerTimer;
  
  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    _audioPlayer = AudioPlayer();
    
    // تحقق من وجود رسالة من الإنذار
    final ReceivePort receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(
      receivePort.sendPort,
      'prayer_adhan_foreground_port',
    );
    
    // تشغيل الأذان
    await _playAdhan();
    
    // إنهاء الخدمة بعد انتهاء تشغيل الصوت (حوالي 2-3 دقائق)
    _playerTimer = Timer(const Duration(minutes: 3), () {
      FlutterForegroundTask.stopService();
    });
  }
  
  @override
  Future<void> onRepeatEvent(DateTime timestamp, SendPort? sendPort) async {
    // This method is required by TaskHandler but not used in our case
  }
  
  Future<void> _playAdhan() async {
    try {
      String soundFile = 'assets/audio/azan.m4a';
      
      await _audioPlayer?.setAsset(soundFile);
      await _audioPlayer?.play();
    } catch (e) {
      debugPrint('خطأ في تشغيل الأذان: $e');
    }
  }
  
  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {}
  
  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    await _audioPlayer?.stop();
    await _audioPlayer?.dispose();
    _playerTimer?.cancel();
    
    IsolateNameServer.removePortNameMapping('prayer_adhan_foreground_port');
  }
  
  @override
  void onButtonPressed(String id) {}
}

// تهيئة خدمة الواجهة الأمامية
Future<void> initForegroundTask() async {
  FlutterForegroundTask.init(
    androidNotificationOptions: AndroidNotificationOptions(
      channelId: 'prayer_adhan_channel',
      channelName: 'الأذان والصلاة',
      channelDescription: 'إشعارات أوقات الصلاة',
      channelImportance: NotificationChannelImportance.HIGH,
      priority: NotificationPriority.HIGH,
    ),
    iosNotificationOptions: const IOSNotificationOptions(
      showNotification: true,
      playSound: true,
    ),
    foregroundTaskOptions: const ForegroundTaskOptions(
      interval: 1000,
      isOnceEvent: false,
      autoRunOnBoot: true,
      allowWakeLock: true,
      allowWifiLock: true,
    ),
  );
}

// الفئة الرئيسية لخدمة التنبيه بالصلاة
class PrayerAlarmService {
  static final PrayerAlarmService _instance = PrayerAlarmService._internal();
  
  factory PrayerAlarmService() => _instance;
  
  PrayerAlarmService._internal();
  
  // تهيئة الخدمة
  Future<void> initialize() async {
    await AndroidAlarmManager.initialize();
    final receivePort = ReceivePort();
    IsolateNameServer.registerPortWithName(
      receivePort.sendPort,
      'prayer_adhan_port',
    );
    
    // الاستماع للرسائل من الإنذارات
    receivePort.listen((message) {
      if (message is String && message.startsWith('start_prayer_adhan:')) {
        final prayerName = message.split(':')[1];
        debugPrint('تلقي طلب تشغيل أذان: $prayerName');
      }
    });
  }
  
  // جدولة الإنذارات لجميع أوقات الصلاة
  Future<void> scheduleAllPrayerAlarms(Map<String, DateTime> prayerTimes) async {
    // إلغاء كل الإنذارات المجدولة مسبقًا
    await cancelAllAlarms();
    
    // جدولة إنذار لكل وقت صلاة
    for (final entry in prayerTimes.entries) {
      final prayerName = entry.key;
      final prayerTime = entry.value;
      
      // تجاهل أوقات الصلاة التي مرت بالفعل
      if (prayerTime.isAfter(DateTime.now())) {
        await schedulePrayerAlarm(prayerName, prayerTime);
        debugPrint('تمت جدولة التنبيه لصلاة ${_getArabicPrayerName(prayerName)} في ${prayerTime.toString()}');
      }
    }
    
    // حفظ بيانات الجدولة
    await _saveScheduledTimes(prayerTimes);
    debugPrint('✅ تمت جدولة جميع التنبيهات بنجاح');
  }
  
  // جدولة إنذار لوقت صلاة محدد
  Future<void> schedulePrayerAlarm(String prayerName, DateTime prayerTime) async {
    final int uniqueId = _getUniqueIdForPrayer(prayerName);
    
    await AndroidAlarmManager.oneShotAt(
      prayerTime,
      uniqueId,
      playPrayerAdhan,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: false,
      params: {'prayer_name': prayerName},
      allowWhileIdle: true,
    );
  }
  
  // إلغاء جميع الإنذارات
  Future<void> cancelAllAlarms() async {
    for (int i = 0; i < 10; i++) {
      await AndroidAlarmManager.cancel(i);
    }
  }
  
  // إعادة جدولة الإنذارات استنادًا إلى الأوقات المخزنة
  Future<void> rescheduleFromStoredTimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final prayerTimesJson = prefs.getString('prayer_times_data');
      
      if (prayerTimesJson != null) {
        final prayerTimesData = json.decode(prayerTimesJson);
        if (prayerTimesData is Map<String, dynamic>) {
          final prayerTimes = PrayerTimesResponse.fromJson(prayerTimesData);
          
          final prayerTimesMap = {
            'fajr': _parseTimeString(prayerTimes.prayerTimes.fajr),
            'dhuhr': _parseTimeString(prayerTimes.prayerTimes.dhuhr),
            'asr': _parseTimeString(prayerTimes.prayerTimes.asr),
            'maghrib': _parseTimeString(prayerTimes.prayerTimes.maghrib),
            'isha': _parseTimeString(prayerTimes.prayerTimes.isha),
          };
          
          await scheduleAllPrayerAlarms(prayerTimesMap);
        }
      }
    } catch (e) {
      debugPrint('❌ خطأ في إعادة جدولة التنبيهات: $e');
    }
  }
  
  // حفظ الأوقات المجدولة
  Future<void> _saveScheduledTimes(Map<String, DateTime> prayerTimes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('prayer_alarms_enabled', true);
  }
  
  // الحصول على معرف فريد لكل صلاة
  int _getUniqueIdForPrayer(String prayerName) {
    switch (prayerName.toLowerCase()) {
      case 'fajr': return 1;
      case 'sunrise': return 2;
      case 'dhuhr': return 3;
      case 'asr': return 4;
      case 'maghrib': return 5;
      case 'isha': return 6;
      default: return 0;
    }
  }
  
  // طريقة لاختبار تشغيل الأذان بعد فترة محددة
  Future<void> scheduleTestAdhan(String prayerName, DateTime scheduledTime) async {
    final int uniqueId = 888; // رقم مخصص للاختبار
    
    debugPrint('⏰ جدولة اختبار الأذان في ${scheduledTime.toString()} لصلاة ${_getArabicPrayerName(prayerName)}');
    
    await AndroidAlarmManager.oneShotAt(
      scheduledTime,
      uniqueId,
      playPrayerAdhan,
      exact: true,
      wakeup: true,
      rescheduleOnReboot: false,
      params: {'prayer_name': prayerName, 'is_test': true},
      allowWhileIdle: true,
    );
    
    debugPrint('✅ تم جدولة اختبار الأذان بنجاح');
  }
}

// توابع مساعدة
DateTime _parseTimeString(String timeStr) {
  final parts = timeStr.split(':');
  final now = DateTime.now();
  return DateTime(
    now.year, 
    now.month, 
    now.day, 
    int.parse(parts[0]), 
    int.parse(parts[1])
  );
}

String _getArabicPrayerName(String prayerName) {
  final prayerNames = {
    'fajr': 'الفجر',
    'sunrise': 'الشروق',
    'dhuhr': 'الظهر',
    'asr': 'العصر',
    'maghrib': 'المغرب',
    'isha': 'العشاء',
  };
  
  return prayerNames[prayerName.toLowerCase()] ?? prayerName;
} 