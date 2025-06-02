import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../data/models/memorization_circle_model.dart';

class SurahAssignmentCard extends StatelessWidget {
  final SurahAssignment assignment;
  final bool isAdmin;
  final VoidCallback? onEdit;

  const SurahAssignmentCard({
    Key? key,
    required this.assignment,
    this.isAdmin = false,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              // Acción al tocar la tarjeta
            },
            child: Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                children: [
                  // Icono de la Surah
                  Container(
                    width: 50.w,
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: AppColors.logoTeal.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        Icons.menu_book,
                        color: AppColors.logoTeal,
                        size: 24.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  
                  // Información de la Surah
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'سورة ${assignment.surahName}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.logoTeal,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'من الآية ${assignment.startVerse} إلى الآية ${assignment.endVerse}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Botón de edición (solo para administradores)
                  if (isAdmin && onEdit != null)
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: AppColors.logoOrange,
                        size: 20.sp,
                      ),
                      onPressed: onEdit,
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
