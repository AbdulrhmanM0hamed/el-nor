import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer_times_model.dart';

class PrayerTimesLocalRepository {
  static const String _prayerTimesKey = 'prayer_times_data';
  static const String _lastUpdateKey = 'prayer_times_last_update';

  // Save prayer times data to local storage
  Future<bool> savePrayerTimes(PrayerTimesResponse prayerTimes) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Convert the model to JSON string
      final jsonData = json.encode({
        'region': prayerTimes.region,
        'country': prayerTimes.country,
        'prayer_times': {
          'Fajr': prayerTimes.prayerTimes.fajr,
          'Sunrise': prayerTimes.prayerTimes.sunrise,
          'Dhuhr': prayerTimes.prayerTimes.dhuhr,
          'Asr': prayerTimes.prayerTimes.asr,
          'Maghrib': prayerTimes.prayerTimes.maghrib,
          'Isha': prayerTimes.prayerTimes.isha,
        },
        'date': {
          'date_en': prayerTimes.date.dateEn,
          'date_hijri': {
            'date': prayerTimes.date.dateHijri.date,
            'format': prayerTimes.date.dateHijri.format,
            'day': prayerTimes.date.dateHijri.day,
            'weekday': {
              'en': prayerTimes.date.dateHijri.weekday.en,
              'ar': prayerTimes.date.dateHijri.weekday.ar,
            },
            'month': {
              'number': prayerTimes.date.dateHijri.month.number,
              'en': prayerTimes.date.dateHijri.month.en,
              'ar': prayerTimes.date.dateHijri.month.ar,
              'days': prayerTimes.date.dateHijri.month.days,
            },
            'year': prayerTimes.date.dateHijri.year,
          },
        },
        'meta': {
          'timezone': prayerTimes.meta.timezone,
        },
      });
      
      // Save the last update timestamp
      await prefs.setString(_lastUpdateKey, DateTime.now().toIso8601String());
      
      // Save the prayer times data
      return await prefs.setString(_prayerTimesKey, jsonData);
    } catch (e) {
      print('Error saving prayer times: $e');
      return false;
    }
  }

  // Get cached prayer times from local storage
  Future<PrayerTimesResponse?> getCachedPrayerTimes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString(_prayerTimesKey);
      
      if (jsonData == null) {
        return null;
      }
      
      final Map<String, dynamic> data = json.decode(jsonData);
      return PrayerTimesResponse.fromJson(data);
    } catch (e) {
      print('Error retrieving cached prayer times: $e');
      return null;
    }
  }

  // Get the last update timestamp
  Future<DateTime?> getLastUpdateTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getString(_lastUpdateKey);
      
      if (timestamp == null) {
        return null;
      }
      
      return DateTime.parse(timestamp);
    } catch (e) {
      print('Error retrieving last update time: $e');
      return null;
    }
  }

  // Check if we need to update the cached data (e.g., if it's a different day)
  Future<bool> shouldUpdateCache() async {
    // دائما نعود بـ true للإجبار على التحديث من الخادم
    return true;

    // تم تعطيل الكود التالي مؤقتًا حتى تحل مشكلة الأوقات
    /*
    final lastUpdate = await getLastUpdateTime();
    
    if (lastUpdate == null) {
      return true;
    }
    
    final now = DateTime.now();
    
    // Update if date has changed
    return lastUpdate.day != now.day || 
           lastUpdate.month != now.month ||
           lastUpdate.year != now.year;
    */
  }
} 