import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/utils/constant/font_manger.dart';
import '../../../../core/utils/constant/styles_manger.dart';
import '../../data/models/prayer_times_model.dart';

class PrayerTimesHeader extends StatefulWidget {
  final DateInfo dateInfo;
  final String location;
  final PrayerTimes prayerTimes;

  const PrayerTimesHeader({
    Key? key,
    required this.dateInfo,
    required this.location,
    required this.prayerTimes,
  }) : super(key: key);

  @override
  State<PrayerTimesHeader> createState() => _PrayerTimesHeaderState();
}

class _PrayerTimesHeaderState extends State<PrayerTimesHeader> {
  Timer? _timer;
  String _remainingTime = '';
  String _nextPrayerName = '';
  
  @override
  void initState() {
    super.initState();
    _calculateNextPrayer();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
  
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _calculateNextPrayer();
    });
  }
  
  void _calculateNextPrayer() {
    final now = DateTime.now();
    final prayers = {
      'الفجر': _convertToDateTime(widget.prayerTimes.fajr),
      'الشروق': _convertToDateTime(widget.prayerTimes.sunrise),
      'الظهر': _convertToDateTime(widget.prayerTimes.dhuhr),
      'العصر': _convertToDateTime(widget.prayerTimes.asr),
      'المغرب': _convertToDateTime(widget.prayerTimes.maghrib),
      'العشاء': _convertToDateTime(widget.prayerTimes.isha),
    };
    
    DateTime? nextPrayerTime;
    String nextPrayer = '';
    
    // Find the next prayer
    for (var entry in prayers.entries) {
      if (entry.value.isAfter(now)) {
        if (nextPrayerTime == null || entry.value.isBefore(nextPrayerTime)) {
          nextPrayerTime = entry.value;
          nextPrayer = entry.key;
        }
      }
    }
    
    // If no prayer found for today, use first prayer of tomorrow
    if (nextPrayerTime == null) {
      nextPrayerTime = _convertToDateTime(widget.prayerTimes.fajr)
          .add(const Duration(days: 1));
      nextPrayer = 'الفجر';
    }
    
    // Calculate remaining time
    final remaining = nextPrayerTime.difference(now);
    final hours = remaining.inHours;
    final minutes = remaining.inMinutes % 60;
    final seconds = remaining.inSeconds % 60;
    
    setState(() {
      _remainingTime = '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
      _nextPrayerName = nextPrayer;
    });
  }
  
  DateTime _convertToDateTime(String timeString) {
    final now = DateTime.now();
    final parts = timeString.split(':');
    if (parts.length < 2) return now;
    
    int hour = int.tryParse(parts[0]) ?? 0;
    int minute = int.tryParse(parts[1]) ?? 0;
    
    return DateTime(now.year, now.month, now.day, hour, minute);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.logoTeal,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.logoTeal.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Location
          const SizedBox(height: 24),

          // Title
          Align(
            alignment: Alignment.center,
            child: Text(
              '  مواقيت الصلاة  ',
              style: getBoldStyle(
                fontFamily: FontConstant.cairo,
                fontSize: FontSize.size24,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          // Countdown Timer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.logoOrange.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.logoYellow.withOpacity(0.3), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'الوقت المتبقي لصلاة $_nextPrayerName',
                  style: getMediumStyle(
                    fontFamily: FontConstant.cairo,
                    fontSize: FontSize.size14,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.logoTeal.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.logoYellow.withOpacity(0.3), width: 1),
                  ),
                  child: Text(
                    _remainingTime,
                    style: getBoldStyle(
                      fontFamily: FontConstant.cairo,
                      fontSize: FontSize.size18,
                      color: AppColors.logoYellow,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Dates container
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Gregorian date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'التاريخ الميلادي',
                      style: getMediumStyle(
                        fontFamily: FontConstant.cairo,
                        fontSize: FontSize.size12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.dateInfo.dateEn,
                      style: getBoldStyle(
                        fontFamily: FontConstant.cairo,
                        fontSize: FontSize.size16,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                // Divider
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.white.withOpacity(0.3),
                ),

                // Hijri date
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'التاريخ الهجري',
                      style: getMediumStyle(
                        fontFamily: FontConstant.cairo,
                        fontSize: FontSize.size12,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          widget.dateInfo.dateHijri.date,
                          style: getBoldStyle(
                            fontFamily: FontConstant.cairo,
                            fontSize: FontSize.size16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.dateInfo.dateHijri.weekday.ar,
                          style: getMediumStyle(
                            fontFamily: FontConstant.cairo,
                            fontSize: FontSize.size14,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
