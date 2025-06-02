import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/quran_cubit.dart';
import '../cubit/quran_state.dart';
import '../../../../../core/utils/constant/font_manger.dart';
import '../../../../../core/utils/constant/styles_manger.dart';
import '../../../../../core/utils/theme/app_colors.dart';

/// AppBar widget for the Quran screen
class QuranAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Callback when the bookmark button is pressed
  final VoidCallback onBookmarkPressed;
  
  /// Callback when the bookmarks list button is pressed
  final VoidCallback onBookmarksListPressed;
  
  const QuranAppBar({
    Key? key,
    required this.onBookmarkPressed,
    required this.onBookmarksListPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<QuranCubit, QuranState>(
      builder: (context, state) {
        return AppBar(
          backgroundColor: AppColors.logoTeal,
          elevation: 4,
          title: Text(
            'القرآن الكريم - صفحة ${state.currentPage}',
            style: getBoldStyle(
              fontFamily: FontConstant.cairo,
              fontSize: 18,
              color: AppColors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.menu_book, color: AppColors.logoYellow),
            onPressed: () {
              context.read<QuranCubit>().toggleTableOfContents();
            },
          ),
          actions: [
            // Bookmark button
            _buildBookmarkButton(context),
            
            // Bookmarks list button
            IconButton(
              icon: const Icon(Icons.bookmarks, color: AppColors.logoYellow),
              onPressed: onBookmarksListPressed,
              tooltip: 'الإشارات المرجعية',
            ),
          ],
        );
      },
    );
  }
  
  /// Bookmark button for the app bar
  Widget _buildBookmarkButton(BuildContext context) {
    return BlocBuilder<QuranCubit, QuranState>(
      buildWhen: (previous, current) => 
        previous.bookmarks != current.bookmarks || 
        previous.currentPage != current.currentPage,
      builder: (context, state) {
        final isBookmarked = state.bookmarks.any(
          (bookmark) => bookmark.pageNumber == state.currentPage
        );
        
        return IconButton(
          icon: Icon(
            isBookmarked ? Icons.bookmark : Icons.bookmark_add_outlined,
            color: Colors.white,
          ),
          onPressed: onBookmarkPressed,
          tooltip: isBookmarked ? 'تعديل الإشارة المرجعية' : 'إضافة إشارة مرجعية',
        );
      },
    );
  }
  
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
