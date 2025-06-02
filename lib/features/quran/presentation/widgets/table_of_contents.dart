import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/surah_model.dart';
import '../../data/models/bookmark_model.dart';
import '../cubit/quran_cubit.dart';
import '../cubit/quran_state.dart';
import 'surah_list_item.dart';
import '../../../../core/utils/constant/font_manger.dart';
import '../../../../core/utils/constant/styles_manger.dart';
import '../../../../core/utils/theme/app_colors.dart';

class TableOfContents extends StatefulWidget {
  const TableOfContents({Key? key}) : super(key: key);

  @override
  State<TableOfContents> createState() => _TableOfContentsState();
}

class _TableOfContentsState extends State<TableOfContents> {
  late TextEditingController _searchController;
  String _searchQuery = '';
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadSurahData();
  }
  
  Future<void> _loadSurahData() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Try the direct loading approach first - simplest and most reliable
      final surahs = await SurahList.loadAllSurahsDirectly();
      
      if (surahs.isEmpty) {
        // If direct approach failed, try the alternative methods
        await SurahList.loadSurahs();
        
        // If all else fails, try paginated loading
        if (SurahList.surahs.isEmpty) {
          await SurahList.loadSurahsPaginated(page: 1, pageSize: 114);
        }
      }
      
      // Debug log the results
      debugPrint('TableOfContents: Loaded ${SurahList.surahs.length} surahs');
    } catch (e) {
      debugPrint('TableOfContents: Error loading surahs: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  
  List<Surah> _getFilteredSurahs() {
    // If no surahs are loaded and we're still loading, return empty list
    // This prevents showing "No results" during loading
    if (_isLoading) {
      return [];
    }
    
    // If loading is done but surahs list is empty, force reload
    if (SurahList.surahs.isEmpty && !_isLoading) {
      // Trigger reload and return empty list for now
      Future.microtask(() => _loadSurahData());
      return [];
    }
    
    if (_searchQuery.isEmpty) {
      return SurahList.surahs;
    }
    
    return SurahList.surahs.where((surah) {
      final nameMatch = surah.name.contains(_searchQuery);
      final transliterationMatch = surah.transliteration.toLowerCase().contains(_searchQuery.toLowerCase());
      final translationMatch = surah.translation.toLowerCase().contains(_searchQuery.toLowerCase());
      final idMatch = surah.id.toString() == _searchQuery;
      
      return nameMatch || transliterationMatch || translationMatch || idMatch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // إضافة استماع صريح للتغييرات
    print('Building TableOfContents widget');
    
    return BlocConsumer<QuranCubit, QuranState>(
      listener: (context, state) {
        // استمع للتغييرات في الصفحة الحالية
        print('TableOfContents - State change detected: page=${state.currentPage}');
        
        // تحديث القائمة عند تغيير الصفحة
        if (!_isLoading && SurahList.surahs.isNotEmpty) {
          setState(() {
            // تحديث القائمة فقط
            print('TableOfContents - Refreshing list due to page change');
          });
        }
      },
      builder: (context, state) {
        if (!state.isTableOfContentsVisible) {
          return const SizedBox.shrink();
        }
        
        final filteredSurahs = _getFilteredSurahs();
        
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  color: AppColors.logoTeal,
                  child: Column(
                    children: [
                      Text(
                        'القرآن الكريم',
                        style: getBoldStyle(
                          fontFamily: FontConstant.cairo,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Tabs for Surah list and Bookmarks
                          _buildTab(
                            title: 'فهرس السور',
                            isActive: !state.isBookmarksVisible,
                            onTap: () {
                              if (state.isBookmarksVisible) {
                                context.read<QuranCubit>().toggleBookmarks();
                              }
                            },
                          ),
                          const SizedBox(width: 16),
                          _buildTab(
                            title: 'الإشارات المرجعية',
                            isActive: state.isBookmarksVisible,
                            onTap: () {
                              if (!state.isBookmarksVisible) {
                                context.read<QuranCubit>().toggleBookmarks();
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Search box - only show for surah list, not for bookmarks
                if (!state.isBookmarksVisible)
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'بحث عن سورة',
                        hintStyle: getRegularStyle(
                          fontFamily: FontConstant.cairo,
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        prefixIcon: const Icon(Icons.search, color: AppColors.logoTeal),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: Colors.grey.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.logoTeal,
                            width: 1.5,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                      textAlign: TextAlign.right,
                      style: getMediumStyle(
                        fontFamily: FontConstant.cairo,
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                
                // Search results info - only show for surah list, not for bookmarks
                if (!state.isBookmarksVisible && _searchQuery.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      '${filteredSurahs.length} نتيجة بحث',
                      style: getMediumStyle(
                        fontFamily: FontConstant.cairo,
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                
                // Main content area - either Surah list or Bookmarks
                if (state.isBookmarksVisible)
                  // Bookmarks list
                  Expanded(
                    child: state.bookmarks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.bookmark_border,
                                size: 70,
                                color: AppColors.primary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'لا توجد إشارات مرجعية محفوظة',
                                style: getMediumStyle(
                                  fontFamily: FontConstant.cairo,
                                  fontSize: 16,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'يمكنك حفظ إشارة مرجعية بالضغط على زر الإشارة المرجعية في شريط الأدوات السفلي',
                                style: getRegularStyle(
                                  fontFamily: FontConstant.cairo,
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: state.bookmarks.length,
                          itemBuilder: (context, index) {
                            final bookmark = state.bookmarks[index];
                            return _buildBookmarkItem(context, bookmark);
                          },
                        ),
                  )
                else
                  // Surah list
                  _isLoading 
                  ? Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(
                              'جاري تحميل السور...',
                              style: getMediumStyle(
                                fontFamily: FontConstant.cairo,
                                fontSize: 16,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SurahList.surahs.isEmpty
                      ? Expanded(
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'حدث خطأ في تحميل السور',
                                  style: getMediumStyle(
                                    fontFamily: FontConstant.cairo,
                                    fontSize: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadSurahData,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.logoTeal,
                                  ),
                                  child: Text(
                                    'إعادة المحاولة',
                                    style: getMediumStyle(
                                      fontFamily: FontConstant.cairo,
                                      fontSize: 14,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Expanded(
                          child: filteredSurahs.isEmpty
                            ? Center(
                                child: Text(
                                  'لا توجد نتائج',
                                  style: getMediumStyle(
                                    fontFamily: FontConstant.cairo,
                                    fontSize: 16,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                itemCount: filteredSurahs.length,
                                itemBuilder: (context, index) {
                                  final surah = filteredSurahs[index];
                                  return SurahListItem(
                                    surah: surah,
                                    onTap: () {
                                      // استخدام الرقم الأصلي للصفحة مباشرة
                                      // QuranCubit الآن يتوقع رقم صفحة أصلي
                                      debugPrint('Navigating to surah ${surah.name} (${surah.id})');
                                      debugPrint('Original page number: ${surah.originalPageNumber}');
                                      
                                      // استخدام الصفحة الأصلية للانتقال
                                      context.read<QuranCubit>().navigateToPage(surah.originalPageNumber);
                                    },
                                    isCurrentlyReading: _isCurrentlyReading(surah, state.currentPage),
                                  );
                                },
                              ),
                        ),
                
                // Continue reading button
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: () {
                      // Use the new resumeReading method which handles all the logic internally
                      context.read<QuranCubit>().resumeReading();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.logoTeal,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'متابعة القراءة',
                      style: getBoldStyle(
                        fontFamily: FontConstant.cairo,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  
  // Helper method to build a tab button
  Widget _buildTab({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.logoYellow.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.logoYellow.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Text(
          title,
          style: getMediumStyle(
            fontFamily: FontConstant.cairo,
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
  
  // Helper method to build a bookmark item
  Widget _buildBookmarkItem(BuildContext context, QuranBookmark bookmark) {
    final formattedDate = _formatTimestamp(bookmark.timestamp);
    
    return ListTile(
      leading: const Icon(Icons.bookmark, color: AppColors.primary),
      title: Text(
        bookmark.title,
        style: getMediumStyle(
          fontFamily: FontConstant.cairo,
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        'صفحة ${bookmark.pageNumber} - $formattedDate',
        style: getRegularStyle(
          fontFamily: FontConstant.cairo,
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        onPressed: () {
          context.read<QuranCubit>().removeBookmark(bookmark.pageNumber);
        },
      ),
      onTap: () {
        context.read<QuranCubit>().navigateToPage(bookmark.pageNumber);
      },
    );
  }
  
  // Helper method to format timestamp
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'منذ ${difference.inMinutes} دقيقة';
      } else {
        return 'منذ ${difference.inHours} ساعة';
      }
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
  
  bool _isCurrentlyReading(Surah surah, int currentPage) {
    // الآن currentPage هو رقم صفحة أصلي من Cubit
    // لا نحتاج إلى تحويله
    
    // إضافة تسجيل للتصحيح
    if (surah.id < 5) { // تسجيل أول بضع سور فقط لتجنب كثرة السجلات
      print('Checking if surah ${surah.name} (${surah.id}) is current: currentPage=$currentPage (original)');
    }
    
    // Get all surahs in order by their original page numbers (lowest to highest)
    final List<Surah> orderedSurahs = List.from(SurahList.surahs)
      ..sort((a, b) => a.originalPageNumber.compareTo(b.originalPageNumber));
    
    // Find the current surah's index
    final int surahIndex = orderedSurahs.indexWhere((s) => s.id == surah.id);
    if (surahIndex == -1) return false;
    
    // استخدم الصفحة الحالية مباشرة لأنها أصلية الآن
    final int originalCurrentPage = currentPage;
    
    // Get the current surah's page range using original page numbers
    final int startPage = surah.originalPageNumber;
    
    // If this is the last surah in the ordered list (Surah Al-Nas), 
    // its range extends to the end of the Quran
    if (surahIndex == orderedSurahs.length - 1) {
      final bool isReading = originalCurrentPage >= startPage;
      
      if (isReading && surah.id < 5) {
        print('Surah ${surah.name} IS current (last surah case)');
        print('  originalCurrentPage=$originalCurrentPage, startPage=$startPage');
      }
      
      return isReading;
    }
    
    // Get the next surah's starting page (which is the end of the current surah's range)
    final int endPage = orderedSurahs[surahIndex + 1].originalPageNumber - 1;
    
    // Check if the current page falls within this surah's range
    final bool isReading = originalCurrentPage >= startPage && originalCurrentPage <= endPage;
    
    if (isReading && surah.id < 5) {
      print('Surah ${surah.name} IS current');
      print('  originalCurrentPage=$originalCurrentPage, startPage=$startPage, endPage=$endPage');
    }
    
    return isReading;
  }
} 