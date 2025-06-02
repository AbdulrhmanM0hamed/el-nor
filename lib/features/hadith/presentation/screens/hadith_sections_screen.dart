import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/hadith_cubit.dart';
import '../cubit/hadith_state.dart';
import '../../models/hadith_model.dart';
import 'hadith_list_screen.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/utils/theme/app_theme.dart';

class HadithSectionsScreen extends StatelessWidget {
  static const routeName = '/hadith';

  const HadithSectionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الأحاديث النبوية الصحيحة',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.primary.withValues(alpha: 0.9),
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
        child: BlocBuilder<HadithCubit, HadithState>(
          builder: (context, state) {
            if (state is HadithInitial) {
              context.read<HadithCubit>().loadHadithCollections();
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (state is HadithLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              );
            }

            if (state is HadithError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 70, color: AppColors.error),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
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
                              context
                                  .read<HadithCubit>()
                                  .loadHadithCollections();
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('إعادة المحاولة'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
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

            if (state is HadithLoaded) {
              if (state.collections.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.info_outline,
                          size: 64, color: AppColors.primary),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد أحاديث متاحة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: customColors?.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return _buildCollectionsList(
                  context, state.collections, customColors);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildCollectionsList(
    BuildContext context,
    List<HadithCollection> collections,
    CustomColors? customColors,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: collections.length,
      itemBuilder: (context, index) {
        final collection = collections[index];
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            margin: const EdgeInsets.only(bottom: 20),
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
                      builder: (context) =>
                          HadithListScreen(collection: collection),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header with colored background
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: customColors?.cardHeaderBg ??
                            AppColors.primary.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(16),
                          topLeft: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              collection.sectionName,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color:
                                    customColors?.textPrimary ?? Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Text(
                              '${_countSahihHadiths(collection)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Content
                    const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.menu_book_outlined,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'عرض الأحاديث',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Spacer(),
                              Icon(
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

  // حساب عدد الأحاديث الصحيحة في المجموعة
  int _countSahihHadiths(HadithCollection collection) {
    return collection.hadiths.where((hadith) {
      if (hadith.grades.isEmpty) return false;
      final grade = hadith.grades.first.grade.toLowerCase();
      return grade.contains('صحيح') || grade.contains('sahih') || grade.contains('maqtu sahih');
    }).length;
  }
}
