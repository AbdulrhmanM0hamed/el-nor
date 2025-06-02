import 'package:beat_elslam/core/utils/constant/font_manger.dart';
import 'package:beat_elslam/core/utils/constant/styles_manger.dart';
import 'package:beat_elslam/core/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../quran/data/models/surah_model.dart';
import 'package:intl/intl.dart';
import '../../quran/presentation/cubit/quran_cubit.dart';

class LastReadCard extends StatefulWidget {
  final VoidCallback? onTap;

  const LastReadCard({super.key, this.onTap});

  @override
  State<LastReadCard> createState() => _LastReadCardState();
}

class _LastReadCardState extends State<LastReadCard> {
  bool _isLoading = true;
  String _surahName = '';
  String _surahNameArabic = '';
  int _pageNumber = 1; // رقم الصفحة الأصلي (غير معكوس)
  String _hijriDate = '';
  
  @override
  void initState() {
    super.initState();
    _loadLastReadData();
  }
  
  // Find the surah that contains the given original page number
  Surah _findSurahByPageNumber(int originalPageNumber) {
    // نستخدم رقم الصفحة الأصلي لإيجاد السورة المناسبة
    debugPrint('Finding surah for original page number: $originalPageNumber');
    
    // تحميل جميع السور وترتيبها حسب رقم الصفحة الأصلي
    final List<Surah> orderedSurahs = List.from(SurahList.surahs)
      ..sort((a, b) => a.originalPageNumber.compareTo(b.originalPageNumber));
    
    // البحث عن آخر سورة برقم صفحة بداية أقل من أو يساوي رقم الصفحة المعطى
    for (int i = 0; i < orderedSurahs.length; i++) {
      final Surah currentSurah = orderedSurahs[i];
      debugPrint('Checking surah ${currentSurah.name} - Original page: ${currentSurah.originalPageNumber}');
      
      // إذا كانت هذه آخر سورة
      if (i == orderedSurahs.length - 1) {
        if (currentSurah.originalPageNumber <= originalPageNumber) {
          debugPrint('Found last surah: ${currentSurah.name}');
          return currentSurah;
        }
      } 
      // التحقق مما إذا كانت الصفحة قبل بداية السورة التالية
      else {
        final Surah nextSurah = orderedSurahs[i + 1];
        if (currentSurah.originalPageNumber <= originalPageNumber && 
            originalPageNumber < nextSurah.originalPageNumber) {
          debugPrint('Found surah: ${currentSurah.name}');
          return currentSurah;
        }
      }
    }
    
    // الافتراضي هو السورة الأولى إذا لم يتم العثور على تطابق
    debugPrint('No match found, returning first surah');
    return orderedSurahs.first;
  }
  
  Future<void> _loadLastReadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // استخدام المفتاح المتسق من QuranCubit للصفحة الأخيرة المقروءة
      final lastPage = prefs.getInt(QuranCubit.kLastReadPageKey) ?? 1;
      
      debugPrint('Last read page from SharedPreferences: $lastPage (original page)');
      
      // تحميل جميع السور
      await SurahList.loadSurahsPaginated(page: 1, pageSize: 114);
      
      // العثور على السورة بناءً على رقم الصفحة
      final surah = _findSurahByPageNumber(lastPage);
      
      // الحصول على التاريخ الهجري الحالي
      final hijri = HijriCalendar.now();
      final hijriMonth = hijri.hMonth;
      final hijriDay = hijri.hDay;
      final hijriYear = hijri.hYear;
      
      // اسم الشهر بالعربية
      final List<String> hijriMonths = [
        'محرم', 'صفر', 'ربيع الأول', 'ربيع الثاني', 'جمادى الأولى', 'جمادى الآخرة',
        'رجب', 'شعبان', 'رمضان', 'شوال', 'ذو القعدة', 'ذو الحجة'
      ];
      
      setState(() {
        _pageNumber = lastPage;
        _surahName = surah.transliteration;
        _surahNameArabic = surah.name;
        _hijriDate = '${hijriMonths[hijriMonth - 1]} - $hijriDay-$hijriYear';
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading last read data: $e');
      setState(() {
        _surahName = 'Al-Fatiha';
        _surahNameArabic = 'الفاتحة';
        _hijriDate = 'رمضان - ${DateFormat('dd-yyyy').format(DateTime.now())}';
        _isLoading = false;
      });
    }
  }
  
  // Method to navigate to the last read page
  void _navigateToLastReadPage(BuildContext context) {
    debugPrint('Navigating to last read page: $_pageNumber (original page)');
    
    if (widget.onTap != null) {
      widget.onTap!();
    } else {
      // Navigate to Quran screen with the page number
      // رقم الصفحة هنا هو رقم أصلي، لا حاجة للتحويل
      Navigator.of(context).pushNamed('/quran', arguments: _pageNumber);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToLastReadPage(context),
      child: Container(
        height: 120.h,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: AppColors.logoTeal,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8.r,
              offset: Offset(0, 3.h),
            ),
          ],
        ),
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Stack(
                children: [
                  // Date on top right
                  Positioned(
                    top: -5.h,
                    right: 10.w,
                    child: Container(
                      height: 36.h,
                      width: 150.w,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD336),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _hijriDate,
                            style: getBoldStyle(
                              fontFamily: FontConstant.cairo,
                              fontSize: FontSize.size12.sp,
                              color: AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Left side content
                  Positioned(
                    top: 22.h,
                    left: 16.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Last read text
                        Row(
                          children: [
                            Text(
                              'Last Read ',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'آخر قراءة - صفحة $_pageNumber',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        // Surah name
                        Text(
                          '$_surahName - $_surahNameArabic',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.h),
                        // Go to button
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row( 
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_back, color: Colors.white, size: 16.sp),
                              SizedBox(width: 4.w),
                              Text(
                                'Go to',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Lantern icon below date
                  Positioned(
                    bottom: 5.h,
                    right: 20.w,
                    child: Image.asset(
                      'assets/images/lantern.png',
                      height: 80.h,
                      width: 80.w,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
