import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../cubit/quran_cubit.dart';
import '../../../../../core/utils/constant/font_manger.dart';
import '../../../../../core/utils/constant/styles_manger.dart';
import '../../../../../core/utils/theme/app_colors.dart';

/// A class containing dialog widgets for the Quran screen
class QuranDialogs {
  /// Shows a dialog to add or update a bookmark
  static Future<void> showAddBookmarkDialog(
    BuildContext context,
    TextEditingController bookmarkTitleController,
  ) async {
    final cubit = context.read<QuranCubit>();
    final isBookmarked = cubit.isCurrentPageBookmarked();
    
    // Set the initial text in the controller
    bookmarkTitleController.text = isBookmarked 
        ? cubit.state.bookmarks.firstWhere(
            (b) => b.pageNumber == cubit.state.currentPage).title
        : 'صفحة ${cubit.state.currentPage}';
    
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(20),
        title: Text(
          isBookmarked ? 'تعديل الإشارة المرجعية' : 'إضافة إشارة مرجعية',
          textAlign: TextAlign.center,
          style: getBoldStyle(
            fontFamily: FontConstant.cairo,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            const Icon(
              Icons.bookmark,
              size: 50,
              color: AppColors.logoOrange,
            ),
            const SizedBox(height: 16),
            // Current page info
            Text(
              'الصفحة الحالية: ${cubit.state.currentPage}',
              style: getMediumStyle(
                fontFamily: FontConstant.cairo,
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            // Title field
            TextField(
              controller: bookmarkTitleController,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                hintText: 'عنوان الإشارة المرجعية',
                hintStyle: getRegularStyle(
                  fontFamily: FontConstant.cairo,
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.logoTeal,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (isBookmarked)
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      cubit.removeBookmark(cubit.state.currentPage);
                    },
                    child: Text(
                      'حذف',
                      style: getMediumStyle(
                        fontFamily: FontConstant.cairo,
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                  ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'إلغاء',
                    style: getMediumStyle(
                      fontFamily: FontConstant.cairo,
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    cubit.addBookmark(bookmarkTitleController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isBookmarked ? 'تحديث' : 'حفظ',
                    style: getBoldStyle(
                      fontFamily: FontConstant.cairo,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Show dialog to jump to a specific page
  static void showJumpToPageDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'انتقل إلى صفحة',
          textAlign: TextAlign.center,
          style: getBoldStyle(
            fontFamily: FontConstant.cairo,
            fontSize: 18,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: 'أدخل رقم الصفحة (1-604)',
                hintStyle: getRegularStyle(
                  fontFamily: FontConstant.cairo,
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'إلغاء',
                    style: getMediumStyle(
                      fontFamily: FontConstant.cairo,
                      fontSize: 16,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final pageText = controller.text.trim();
                    if (pageText.isNotEmpty) {
                      final page = int.tryParse(pageText);
                      if (page != null && page >= 1 && page <= 604) {
                        Navigator.of(context).pop();
                        context.read<QuranCubit>().navigateToPage(page);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'انتقال',
                    style: getBoldStyle(
                      fontFamily: FontConstant.cairo,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  /// Show zoom hint dialog only once using shared_preferences
  static Future<void> showZoomHintDialogIfNeeded(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool('zoom_hint_shown') ?? false;
    if (!shown) {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!context.mounted) return;
      await showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/zoom.png',
                width: 90,
                height: 90,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 18),
              Text(
                'يمكنك تكبير أو تصغير صفحة المصحف بسهولة!\n\nاستخدم إصبعيك للتكبير (Zoom In) أو التصغير (Zoom Out) بحرية لقراءة أوضح وأكثر راحة.',
                textAlign: TextAlign.center,
                style: getMediumStyle(
                  fontFamily: FontConstant.cairo,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'فهمت',
                  style: getBoldStyle(
                    fontFamily: FontConstant.cairo,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
      await prefs.setBool('zoom_hint_shown', true);
    }
  }
}
