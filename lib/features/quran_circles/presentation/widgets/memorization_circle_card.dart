import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../data/models/memorization_circle_model.dart';

class MemorizationCircleCard extends StatelessWidget {
  final MemorizationCircle circle;
  final VoidCallback onTap;

  const MemorizationCircleCard({
    Key? key,
    required this.circle,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado con tipo de círculo (memorización o examen)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: circle.isExam ? AppColors.logoOrange : AppColors.logoTeal,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    circle.isExam ? Icons.assignment : Icons.menu_book,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    circle.isExam ? 'امتحان حفظ' : 'حلقة حفظ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('yyyy/MM/dd').format(circle.date),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenido principal
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del círculo
                  Text(
                    circle.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.logoTeal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  
                  // Nombre del maestro
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 16.sp,
                        color: AppColors.logoOrange,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        circle.teacherName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  
                  // Descripción
                  Text(
                    circle.description,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 16.h),
                  
                  // Información de asignaciones y estudiantes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoItem(
                        Icons.book,
                        'السور المقررة',
                        '${circle.assignments.length}',
                      ),
                      _buildInfoItem(
                        Icons.people,
                        'الطلاب',
                        '${circle.students.length}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Mostrar avatares de estudiantes
            if (circle.students.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'الطلاب المشاركين',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    SizedBox(
                      height: 40.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: circle.students.length > 5 ? 5 : circle.students.length,
                        itemBuilder: (context, index) {
                          final showMore = circle.students.length > 5 && index == 4;
                          
                          if (showMore) {
                            return Container(
                              width: 40.w,
                              height: 40.h,
                              margin: EdgeInsets.only(right: 8.w),
                              decoration: BoxDecoration(
                                color: AppColors.logoTeal.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  '+${circle.students.length - 4}',
                                  style: TextStyle(
                                    color: AppColors.logoTeal,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.sp,
                                  ),
                                ),
                              ),
                            );
                          }
                          
                          return Container(
                            width: 40.w,
                            height: 40.h,
                            margin: EdgeInsets.only(right: 8.w),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage(circle.students[index].imageUrl),
                                fit: BoxFit.cover,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: AppColors.logoOrange,
        ),
        SizedBox(width: 4.w),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.logoTeal,
          ),
        ),
      ],
    );
  }
}
