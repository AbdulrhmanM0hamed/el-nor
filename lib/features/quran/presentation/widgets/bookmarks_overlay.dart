import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/bookmark_model.dart';
import '../cubit/quran_cubit.dart';
import '../../../../core/utils/constant/font_manger.dart';
import '../../../../core/utils/constant/styles_manger.dart';
import '../../../../core/utils/theme/app_colors.dart';
import 'bookmark_card.dart';

/// A widget that displays the bookmarks overlay
class BookmarksOverlay extends StatelessWidget {
  /// List of bookmarks to display
  final List<QuranBookmark> bookmarks;
  
  /// Callback when the overlay should be closed
  final VoidCallback onClose;
  
  const BookmarksOverlay({
    Key? key,
    required this.bookmarks,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.85),
      child: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Bookmarks list
            Expanded(
              child: bookmarks.isEmpty
                  ? _buildEmptyBookmarksMessage()
                  : _buildBookmarksList(context),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build the header with title and close button
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      color: AppColors.logoTeal,
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.logoYellow),
            onPressed: onClose,
          ),
          Expanded(
            child: Text(
              'الإشارات المرجعية',
              textAlign: TextAlign.center,
              style: getBoldStyle(
                fontFamily: FontConstant.cairo,
                fontSize: 18,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: 48), // Balance the close button
        ],
      ),
    );
  }
  
  /// Build a message when there are no bookmarks
  Widget _buildEmptyBookmarksMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.bookmark_border,
            size: 80,
            color: AppColors.logoOrange,
          ),
          const SizedBox(height: 24),
          Text(
            'لا توجد إشارات مرجعية حتى الآن',
            textAlign: TextAlign.center,
            style: getMediumStyle(
              fontFamily: FontConstant.cairo,
              fontSize: 18,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'اضغط على زر الإشارة المرجعية في الشريط العلوي لحفظ موقع القراءة الحالي',
            textAlign: TextAlign.center,
            style: getRegularStyle(
              fontFamily: FontConstant.cairo,
              fontSize: 16,
              color: AppColors.logoYellow.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build the list of bookmark cards
  Widget _buildBookmarksList(BuildContext context) {
    return ListView.builder(
      itemCount: bookmarks.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final bookmark = bookmarks[index];
        return BookmarkCard(
          bookmark: bookmark,
          onTap: () {
            // Navigate to the bookmarked page
            context.read<QuranCubit>().navigateToPage(bookmark.pageNumber);
            
            // Close the bookmarks overlay
            onClose();
          },
        );
      },
    );
  }
}
