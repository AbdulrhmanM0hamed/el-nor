import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/utils/theme/app_theme.dart';
import '../../models/tafsir_model.dart';
import '../cubit/tafsir_cubit.dart';
import '../cubit/tafsir_state.dart';
import 'tafsir_surah_details_screen.dart';

class TafsirSurahListScreen extends StatelessWidget {
  static const String routeName = '/tafsir';

  const TafsirSurahListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تفسير القرآن الكريم',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary.withOpacity(0.9),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary.withOpacity(0.05),
              Colors.transparent,
            ],
          ),
        ),
        child: BlocBuilder<TafsirCubit, TafsirState>(
          builder: (context, state) {
            if (state is TafsirInitial) {
              context.read<TafsirCubit>().loadAllSurahs();
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (state is TafsirLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (state is TafsirError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline, size: 70, color: AppColors.error),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        color: customColors?.cardContentBg ?? Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 4),
                            blurRadius: 12,
                            color: Colors.black.withOpacity(0.1),
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            state.message,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16, 
                              color: customColors?.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () {
                              context.read<TafsirCubit>().loadAllSurahs();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('إعادة المحاولة'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            if (state is TafsirSurahListLoaded) {
              return _buildSurahList(context, state.surahs, customColors);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildSurahList(
    BuildContext context,
    List<SurahModel> surahs,
    CustomColors? customColors,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: surahs.length,
      itemBuilder: (context, index) {
        final surah = surahs[index];
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: customColors?.cardContentBg ?? Colors.white,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TafsirSurahDetailsScreen(surah: surah),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header with colored background
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
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              '${surah.id}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                surah.nameAr,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: customColors?.textPrimary ?? Colors.black,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${surah.nameEn} • ${surah.type == 'meccan' ? 'مكية' : 'مدنية'}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: customColors?.textSecondary ?? Colors.grey.shade700,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              '${surah.totalVerses} آية',
                              style: const TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Preview of first verse
                    if (surah.verses.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              surah.verses.first.text,
                              style: TextStyle(
                                fontSize: 18,
                                height: 1.5,
                                color: customColors?.textPrimary ?? Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  'عرض التفسير',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 