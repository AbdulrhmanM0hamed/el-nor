import 'package:flutter/material.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/utils/theme/app_theme.dart';
import '../../models/tafsir_model.dart';

class TafsirSurahDetailsScreen extends StatelessWidget {
  final SurahModel surah;

  const TafsirSurahDetailsScreen({
    Key? key,
    required this.surah,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>();
    
    return Scaffold(
      backgroundColor: customColors?.cardContentBg ?? Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              alignment: Alignment.center,
              child: Text(
                '${surah.id}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              surah.nameAr,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary.withOpacity(0.9),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: AppColors.primary.withOpacity(0.05),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'سورة ${surah.nameAr}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: customColors?.textPrimary ?? Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  surah.nameEn,
                  style: TextStyle(
                    fontSize: 16,
                    color: customColors?.textSecondary ?? Colors.grey.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.primary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    '${surah.type == 'meccan' ? 'مكية' : 'مدنية'} • ${surah.totalVerses} آية',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(0),
              itemCount: surah.verses.length,
              itemBuilder: (context, index) {
                final verse = surah.verses[index];
                return _buildVerseCard(context, verse, customColors);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerseCard(
    BuildContext context,
    VerseModel verse,
    CustomColors? customColors,
  ) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: customColors?.cardContentBg ?? Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Verse Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: customColors?.cardHeaderBg ?? AppColors.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  topLeft: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${verse.ayaNo}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'الآية',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'الجزء ${verse.jozz} - صفحة ${verse.page}',
                    style: TextStyle(
                      fontSize: 14,
                      color: customColors?.textSecondary ?? Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
            
            // Verse Text
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                verse.text,
                style: TextStyle(
                  fontSize: 20,
                  height: 1.8,
                  fontWeight: FontWeight.w500,
                  color: customColors?.textPrimary ?? Colors.black,
                ),
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
              ),
            ),
            
            // Tafsir
            if (verse.tafsir != null && verse.tafsir!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: customColors?.timeContainerBg ?? Colors.grey.shade50,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: customColors?.timeContainerBorder ?? Colors.grey.shade200,
                    ),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.menu_book_outlined,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'التفسير الميسر',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: customColors?.textPrimary ?? Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      verse.tafsir!,
                      style: TextStyle(
                        fontSize: 16,
                        height: 1.6,
                        color: customColors?.textPrimary ?? Colors.black87,
                      ),
                      textAlign: TextAlign.justify,
                      textDirection: TextDirection.rtl,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
} 