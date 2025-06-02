import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/theme/app_colors.dart';
import '../../../../../core/utils/constant/font_manger.dart';
import '../../../../../core/utils/constant/styles_manger.dart';
import '../../services/prayer_reminder_service.dart';
import '../cubit/prayer_times_cubit.dart';
import '../cubit/prayer_times_state.dart';
import '../widgets/prayer_time_card.dart';
import '../widgets/prayer_times_header.dart';

class PrayerTimesScreen extends StatefulWidget {
  static const String routeName = '/prayer-times';

  const PrayerTimesScreen({Key? key}) : super(key: key);

  @override
  State<PrayerTimesScreen> createState() => _PrayerTimesScreenState();
}

class _PrayerTimesScreenState extends State<PrayerTimesScreen> {
  final PrayerReminderService _reminderService = PrayerReminderService();

  @override
  void initState() {
    super.initState();
    // تحميل مواقيت الصلاة عند بدء الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // تهيئة خدمة التذكير بالصلاة
      await _reminderService.initialize();

      // ثم تحميل مواقيت الصلاة
      _loadPrayerTimes();
    });
  }

  void _loadPrayerTimes() {
    context.read<PrayerTimesCubit>().getPrayerTimes();
  }

  // Convert 24-hour format to 12-hour format with AM/PM
  String _formatTime(String time24) {
    // إذا كان الوقت فارغاً
    if (time24.isEmpty) {
      return 'غير متاح';
    }

    final parts = time24.split(':');
    if (parts.length != 2) return time24;

    int hour = int.tryParse(parts[0].trim()) ?? 0;
    final minute = parts[1].trim();
    final period = hour >= 12 ? 'م' : 'ص';

    hour = hour > 12 ? hour - 12 : hour;
    hour = hour == 0 ? 12 : hour; // 0 hour should be 12 AM

    return '$hour:$minute $period';
  }

  // Determine which prayer is next
  String _getNextPrayer(DateTime now, Map<String, DateTime> prayerTimes) {
    String nextPrayer = '';
    DateTime? nextTime;

    prayerTimes.forEach((prayer, time) {
      if (time.isAfter(now) && (nextTime == null || time.isBefore(nextTime!))) {
        nextPrayer = prayer;
        nextTime = time;
      }
    });

    // If no prayer is after current time, first prayer of tomorrow is next
    if (nextPrayer.isEmpty) {
      nextPrayer = 'Fajr';
    }

    return nextPrayer;
  }

  DateTime _parseTime(String timeStr) {
    final now = DateTime.now();
    try {
      final parts = timeStr.split(':');
      if (parts.length != 2) {
        // إذا كان التنسيق غير صالح، إرجاع الوقت الحالي
        return now;
      }

      final hour = int.tryParse(parts[0].trim()) ?? 0;
      final minute = int.tryParse(parts[1].trim()) ?? 0;

      return DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute
      );
    } catch (e) {
      debugPrint('Error parsing time: $e');
      // في حالة حدوث أي خطأ، إرجاع الوقت الحالي
      return now;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: BlocBuilder<PrayerTimesCubit, PrayerTimesState>(
        builder: (context, state) {
          debugPrint('🔍 PrayerTimesScreen: Current state: ${state.runtimeType}');

          if (state is PrayerTimesLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (state is PrayerTimesError) {
            debugPrint('❌ PrayerTimesScreen: Error state - ${state.message}');
            final isNoInternet = state.message.contains('SocketException') || state.message.contains('Failed host lookup');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isNoInternet) ...[
                    Image.asset(
                      'assets/images/internet_disconnect.png',
                      width: 90,
                      height: 90,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'الاتصال بالإنترنت مطلوب لعرض مواقيت الصلاة',
                      style: getBoldStyle(
                        fontFamily: FontConstant.cairo,
                        fontSize: FontSize.size16,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ] else ...[
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'حدث خطأ أثناء تحميل مواقيت الصلاة',
                      style: getBoldStyle(
                        fontFamily: FontConstant.cairo,
                        fontSize: FontSize.size16,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.message,
                      style: getRegularStyle(
                        fontFamily: FontConstant.cairo,
                        fontSize: FontSize.size14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadPrayerTimes,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      'إعادة المحاولة',
                      style: getBoldStyle(
                        fontFamily: FontConstant.cairo,
                        fontSize: FontSize.size14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else if (state is PrayerTimesLoaded) {
            final prayerTimes = state.prayerTimes;
            final location = '${prayerTimes.region}, ${prayerTimes.country}';

            debugPrint('✅ PrayerTimesScreen: Loaded state');
            debugPrint('⏰ Screen data - Fajr: ${prayerTimes.prayerTimes.fajr}, Dhuhr: ${prayerTimes.prayerTimes.dhuhr}');

            // Determine next prayer time
            final now = DateTime.now();
            final prayerTimeMap = {
              'Fajr': _parseTime(prayerTimes.prayerTimes.fajr),
              'Dhuhr': _parseTime(prayerTimes.prayerTimes.dhuhr),
              'Asr': _parseTime(prayerTimes.prayerTimes.asr),
              'Maghrib': _parseTime(prayerTimes.prayerTimes.maghrib),
              'Isha': _parseTime(prayerTimes.prayerTimes.isha),
            };
            final nextPrayer = _getNextPrayer(now, prayerTimeMap);

            return CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  expandedHeight: 330,
                  floating: false,
                  pinned: true,
                  backgroundColor: AppColors.logoTeal,
                  elevation: 0,
                  flexibleSpace: FlexibleSpaceBar(
                    background: PrayerTimesHeader(
                      dateInfo: prayerTimes.date,
                      location: location,
                      prayerTimes: prayerTimes.prayerTimes,
                    ),
                  ),
                  centerTitle: true,
                ),

                // Prayer Times List
                SliverPadding(
                  padding: const EdgeInsets.only(top: 16, bottom: 80),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Today's prayer times title
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        child: Text(
                          'مواقيت اليوم',
                          style: getBoldStyle(
                            fontFamily: FontConstant.cairo,
                            fontSize: FontSize.size18,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),

                      // Prayer time cards
                      PrayerTimeCard(
                        title: 'الفجر',
                        time: _formatTime(prayerTimes.prayerTimes.fajr),
                        icon: Icons.nightlight_round,
                        color: Colors.indigo,
                        isNext: nextPrayer == 'Fajr',
                      ),
                      PrayerTimeCard(
                        title: 'الشروق',
                        time: _formatTime(prayerTimes.prayerTimes.sunrise),
                        icon: Icons.wb_sunny_outlined,
                        color: Colors.orange,
                      ),
                      PrayerTimeCard(
                        title: 'الظهر',
                        time: _formatTime(prayerTimes.prayerTimes.dhuhr),
                        icon: Icons.wb_sunny,
                        color: Colors.amber,
                        isNext: nextPrayer == 'Dhuhr',
                      ),
                      PrayerTimeCard(
                        title: 'العصر',
                        time: _formatTime(prayerTimes.prayerTimes.asr),
                        icon: Icons.sunny_snowing,
                        color: Colors.deepOrange,
                        isNext: nextPrayer == 'Asr',
                      ),
                      PrayerTimeCard(
                        title: 'المغرب',
                        time: _formatTime(prayerTimes.prayerTimes.maghrib),
                        icon: Icons.nights_stay_outlined,
                        color: Colors.purple,
                        isNext: nextPrayer == 'Maghrib',
                      ),
                      PrayerTimeCard(
                        title: 'العشاء',
                        time: _formatTime(prayerTimes.prayerTimes.isha),
                        icon: Icons.nights_stay,
                        color: Colors.deepPurple,
                        isNext: nextPrayer == 'Isha',
                      ),
                    ]),
                  ),
                ),
              ],
            );
          }

          // Initial state
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.access_time,
                  size: 70,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'مواقيت الصلاة',
                  style: getBoldStyle(
                    fontFamily: FontConstant.cairo,
                    fontSize: FontSize.size20,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'جاري تحميل المواقيت...',
                  style: getRegularStyle(
                    fontFamily: FontConstant.cairo,
                    fontSize: FontSize.size16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadPrayerTimes,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'تحميل المواقيت',
                    style: getBoldStyle(
                      fontFamily: FontConstant.cairo,
                      fontSize: FontSize.size14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}