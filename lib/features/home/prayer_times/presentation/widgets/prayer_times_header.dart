import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../../core/utils/theme/app_colors.dart';
import '../../../../../core/utils/constant/font_manger.dart';
import '../../../../../core/utils/constant/styles_manger.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    return Container(
      padding: EdgeInsets.fromLTRB(screenWidth * 0.05, screenWidth * 0.2, screenWidth * 0.05, screenWidth * 0.05),
      decoration: BoxDecoration(
        color: AppColors.logoTeal,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(screenWidth * 0.08),
          bottomRight: Radius.circular(screenWidth * 0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.logoTeal.withOpacity(0.3),
            blurRadius: screenWidth * 0.025,
            offset: Offset(0, screenWidth * 0.01),
          ),
        ],
      ),
      child: Column(
        children: [
          // Location
          SizedBox(height: screenWidth * 0.06),

          // Title
          Align(
            alignment: Alignment.center,
            child: Text(
              '  مواقيت الصلاة  ',
              style: getBoldStyle(
                fontFamily: FontConstant.cairo,
                fontSize: screenWidth * 0.06, // Replaces FontSize.size24
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: screenWidth * 0.04),
          
          // Countdown Timer
          Container(
            padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03, horizontal: screenWidth * 0.04),
            decoration: BoxDecoration(
              color: AppColors.logoOrange.withOpacity(0.3),
              borderRadius: BorderRadius.circular(screenWidth * 0.03),
              border: Border.all(color: AppColors.logoYellow.withOpacity(0.3), width: 1),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'الوقت المتبقي لصلاة $_nextPrayerName',
                  style: getMediumStyle(
                    fontFamily: FontConstant.cairo,
                    fontSize: screenWidth * 0.035, // Replaces FontSize.size14
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: screenWidth * 0.02),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04, vertical: screenWidth * 0.02),
                  decoration: BoxDecoration(
                    color: AppColors.logoTeal.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    border: Border.all(color: AppColors.logoYellow.withOpacity(0.3), width: 1),
                  ),
                  child: Text(
                    _remainingTime,
                    style: getBoldStyle(
                      fontFamily: FontConstant.cairo,
                      fontSize: screenWidth * 0.045, // Replaces FontSize.size18
                      color: AppColors.logoYellow,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: screenWidth * 0.04),

          // Dates container
          Container(
            padding: EdgeInsets.all(screenWidth * 0.04),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(screenWidth * 0.04),
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
                        fontSize: screenWidth * 0.03, // Replaces FontSize.size12
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.01),
                    Text(
                      widget.dateInfo.dateEn,
                      style: getBoldStyle(
                        fontFamily: FontConstant.cairo,
                        fontSize: screenWidth * 0.04, // Replaces FontSize.size16
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),

                // Divider
                Container(
                  height: screenWidth * 0.1,
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
                        fontSize: screenWidth * 0.03, // Replaces FontSize.size12
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: screenWidth * 0.01),
                    Row(
                      children: [
                        Text(
                          widget.dateInfo.dateHijri.date,
                          style: getBoldStyle(
                            fontFamily: FontConstant.cairo,
                            fontSize: screenWidth * 0.04, // Replaces FontSize.size16
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          widget.dateInfo.dateHijri.weekday.ar,
                          style: getMediumStyle(
                            fontFamily: FontConstant.cairo,
                            fontSize: screenWidth * 0.035, // Replaces FontSize.size14
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
