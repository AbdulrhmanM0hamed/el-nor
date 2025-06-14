import 'package:noor_quran/core/utils/constant/font_manger.dart';
import 'package:noor_quran/core/utils/constant/styles_manger.dart';
import 'package:noor_quran/core/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../quran/data/models/surah_model.dart';
import 'package:intl/intl.dart';
import '../quran/presentation/cubit/quran_cubit.dart';

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
      
      // التحقق مما إذا كان الويدجيت لا يزال موجودًا في الشجرة
      if (!mounted) {
        debugPrint('Widget is no longer mounted, cancelling setState');
        return;
      }
      
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
      
      // التحقق مرة أخرى قبل استدعاء setState
      if (mounted) {
        setState(() {
          _pageNumber = lastPage;
          _surahName = surah.transliteration;
          _surahNameArabic = surah.name;
          _hijriDate = '${hijriMonths[hijriMonth - 1]} - $hijriDay-$hijriYear';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading last read data: $e');
      // التحقق مما إذا كان الويدجيت لا يزال موجودًا في الشجرة قبل استدعاء setState
      if (mounted) {
        setState(() {
          _surahName = 'Al-Fatiha';
          _surahNameArabic = 'الفاتحة';
          _hijriDate = 'رمضان - ${DateFormat('dd-yyyy').format(DateTime.now())}';
          _isLoading = false;
        });
      }
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
    final screenWidth = MediaQuery.of(context).size.width;
    final cardHeight = screenWidth * 0.3;

    return GestureDetector(
      onTap: () => _navigateToLastReadPage(context),
      child: Container(
        height: cardHeight,
        margin: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenWidth * 0.03,
        ),
        decoration: BoxDecoration(
          color: AppColors.logoTeal,
          borderRadius: BorderRadius.circular(screenWidth * 0.04),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: screenWidth * 0.02,
              offset: Offset(0, screenWidth * 0.01),
            ),
          ],
        ),
        child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : Stack(
                children: [
                  // Date on top right
                  Positioned(
                    top: -cardHeight * 0.05,
                    right: screenWidth * 0.025,
                    child: Container(
                      height: cardHeight * 0.3,
                      width: screenWidth * 0.4,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.04,
                        vertical: cardHeight * 0.07,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD336),
                        borderRadius: BorderRadius.circular(screenWidth * 0.03),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _hijriDate,
                            style: getBoldStyle(
                              fontFamily: FontConstant.cairo,
                              fontSize: screenWidth * 0.03,
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
                    top: cardHeight * 0.18,
                    left: screenWidth * 0.04,
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
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'آخر قراءة - صفحة $_pageNumber',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: screenWidth * 0.035,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: cardHeight * 0.03),

                        // Surah name
                        Text(
                          '$_surahName - $_surahNameArabic',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: cardHeight * 0.03),

                        // Go to button
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.04,
                            vertical: cardHeight * 0.02,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(screenWidth * 0.02),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.arrow_back, color: Colors.white, size: screenWidth * 0.04),
                              SizedBox(width: screenWidth * 0.02),
                              Text(
                                'Go to',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.035,
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
                    bottom: cardHeight * 0.05,
                    right: screenWidth * 0.05,
                    child: Image.asset(
                      'assets/images/lantern.png',
                      height: cardHeight * 0.7,
                      width: screenWidth * 0.2,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
