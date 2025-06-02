import 'package:flutter/material.dart';
import '../../../../../core/utils/theme/app_colors.dart';
import '../../../../../core/utils/constant/font_manger.dart';
import '../../../../../core/utils/constant/styles_manger.dart';
import '../../models/azkar_model.dart';

class AzkarCategoryItem extends StatelessWidget {
  final AzkarCategory category;
  final VoidCallback onTap;

  const AzkarCategoryItem({
    Key? key,
    required this.category,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withOpacity(0.8),
              AppColors.primary.withOpacity(0.6),
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            splashColor: Colors.white.withOpacity(0.2),
            highlightColor: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      Icons.book,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          category.name,
                          style: getBoldStyle(
                            fontFamily: FontConstant.cairo,
                            fontSize: FontSize.size16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "${category.items.length} ذكر",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: FontConstant.cairo,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                "عدد التكرار: ${category.totalCount}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: FontConstant.cairo,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 