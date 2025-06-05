import 'package:beat_elslam/core/utils/theme/app_colors.dart';
import 'package:beat_elslam/core/utils/user_role.dart';
import 'package:beat_elslam/features/quran_circles/data/models/memorization_circle_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'dart:developer' as developer;


class MemorizationCircleCard extends StatelessWidget {
  final MemorizationCircle circle;
  final UserRole userRole;
  final String userId;
  final VoidCallback onTap;

  MemorizationCircleCard({
    Key? key,
    required this.circle,
    required this.userRole,
    required this.userId,
    required this.onTap,
  }) : super(key: key) {
    // Add debug logs in constructor
    developer.log('MemorizationCircleCard Data:', name: 'CircleCard');
    developer.log('Circle Name: ${circle.name}', name: 'CircleCard');
    developer.log('Teacher ID: ${circle.teacherId}', name: 'CircleCard');
    developer.log('Teacher Name: ${circle.teacherName}', name: 'CircleCard');
    developer.log('User Role: $userRole', name: 'CircleCard');
    developer.log('User ID: $userId', name: 'CircleCard');
  }

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
            // شريط الحالة مع نوع الحلقة
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: _getStatusColor(),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getStatusIcon(),
                    color: Colors.white,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    _getStatusText(),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('yyyy/MM/dd').format(circle.endDate ?? DateTime.now()),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
            ),
            
            // محتوى الحلقة
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // اسم الحلقة
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
                  
                  // معلومات المعلم
                  Row(
                    children: [
                      Icon(
                        Icons.person,
                        size: 16.sp,
                        color: AppColors.logoOrange,
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: Builder(
                          builder: (context) {
                            final hasTeacherName = circle.teacherName != null && circle.teacherName!.isNotEmpty;
                            developer.log('Has Teacher Name: $hasTeacherName', name: 'CircleCard');
                            developer.log('Teacher Name Value: ${circle.teacherName}', name: 'CircleCard');
                            
                            return Text(
                              hasTeacherName
                                  ? 'المعلم: ${circle.teacherName}'
                                  : 'المعلم',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[700],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            );
                          }
                        ),
                      ),
                      if (circle.teacherId == userId) ...[
                        SizedBox(width: 8.w),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color: AppColors.logoTeal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Text(
                            'أنت المعلم',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.logoTeal,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 8.h),
                  
                  // الوصف
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
                  
                  // معلومات السور والطلاب
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
            
            // عرض الطلاب
            if (circle.students.isNotEmpty && (userRole == UserRole.admin || userRole == UserRole.teacher || circle.teacherId == userId))
              Padding(
                padding: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'الطلاب المشاركين',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                        const Spacer(),
                        if (userRole == UserRole.admin || circle.teacherId == userId)
                          TextButton(
                            onPressed: () {
                              // عرض تفاصيل الطلاب
                            },
                            child: Text(
                              'إدارة الطلاب',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.logoTeal,
                              ),
                            ),
                          ),
                      ],
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
                              image: circle.students[index].profileImageUrl != null
                                  ? DecorationImage(
                                      image: NetworkImage(circle.students[index].profileImageUrl!),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: circle.students[index].profileImageUrl == null
                                ? Center(
                                    child: Text(
                                      _getInitial(circle.students[index].name),
                                      style: TextStyle(
                                        color: AppColors.logoTeal,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                  )
                                : null,
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

  Color _getStatusColor() {
    if (circle.isExam) {
      return AppColors.logoOrange;
    }
    return circle.teacherId == userId ? AppColors.secondary : AppColors.logoTeal;
  }

  IconData _getStatusIcon() {
    if (circle.isExam) {
      return Icons.assignment;
    }
    return circle.teacherId == userId ? Icons.star : Icons.menu_book;
  }

  String _getStatusText() {
    if (circle.isExam) {
      return 'امتحان حفظ';
    }
    return circle.teacherId == userId ? 'حلقتي' : 'حلقة حفظ';
  }

  String _getInitial(String name) {
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
