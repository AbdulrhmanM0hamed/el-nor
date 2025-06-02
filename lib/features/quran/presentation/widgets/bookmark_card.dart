import 'package:flutter/material.dart';
import '../../data/models/bookmark_model.dart';
import '../../../../core/utils/constant/font_manger.dart';
import '../../../../core/utils/constant/styles_manger.dart';
import '../../../../core/utils/theme/app_colors.dart';

/// A card widget that displays a single bookmark
class BookmarkCard extends StatelessWidget {
  /// The bookmark to display
  final QuranBookmark bookmark;
  
  /// Callback when the card is tapped
  final VoidCallback onTap;
  
  const BookmarkCard({
    Key? key,
    required this.bookmark,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedDate = _formatBookmarkDate(bookmark.timestamp);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: AppColors.white,
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Page indicator
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.logoTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    '${bookmark.pageNumber}',
                    style: getBoldStyle(
                      fontFamily: FontConstant.cairo,
                      fontSize: 18,
                      color: AppColors.logoTeal,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Bookmark details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookmark.title,
                      style: getBoldStyle(
                        fontFamily: FontConstant.cairo,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formattedDate,
                      style: getRegularStyle(
                        fontFamily: FontConstant.cairo,
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Navigate icon
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.logoOrange,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Format the bookmark date in a human-readable format
  String _formatBookmarkDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'منذ ${difference.inMinutes} دقيقة';
      }
      return 'منذ ${difference.inHours} ساعة';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} يوم';
    } else {
      return '${date.year}/${date.month}/${date.day}';
    }
  }
}
