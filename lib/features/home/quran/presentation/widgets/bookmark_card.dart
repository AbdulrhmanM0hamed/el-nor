import 'package:flutter/material.dart';
import '../../data/models/bookmark_model.dart';
import '../../../../../core/utils/constant/font_manger.dart';
import '../../../../../core/utils/constant/styles_manger.dart';
import '../../../../../core/utils/theme/app_colors.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final formattedDate = _formatBookmarkDate(bookmark.timestamp);

    return Card(
      margin: EdgeInsets.only(bottom: screenWidth * 0.03),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(screenWidth * 0.03)),
      color: AppColors.white,
      elevation: 4,
      child: InkWell(
        borderRadius: BorderRadius.circular(screenWidth * 0.03),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.04),
          child: Row(
            children: [
              // Page indicator
              Container(
                width: screenWidth * 0.13,
                height: screenWidth * 0.13,
                decoration: BoxDecoration(
                  color: AppColors.logoTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(screenWidth * 0.02),
                ),
                child: Center(
                  child: Text(
                    '${bookmark.pageNumber}',
                    style: getBoldStyle(
                      fontFamily: FontConstant.cairo,
                      fontSize: screenWidth * 0.048,
                      color: AppColors.logoTeal,
                    ),
                  ),
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              // Bookmark details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookmark.title,
                      style: getBoldStyle(
                        fontFamily: FontConstant.cairo,
                        fontSize: screenWidth * 0.042,
                        color: AppColors.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: screenWidth * 0.01),
                    Text(
                      formattedDate,
                      style: getRegularStyle(
                        fontFamily: FontConstant.cairo,
                        fontSize: screenWidth * 0.037,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Navigate icon
              Icon(
                Icons.arrow_forward_ios,
                size: screenWidth * 0.04,
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
