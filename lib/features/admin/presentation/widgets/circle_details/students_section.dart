import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../../../core/utils/theme/app_colors.dart';
import '../../../data/models/memorization_circle_model.dart';
import '../shared/profile_image.dart';

class StudentsSection extends StatelessWidget {
  final MemorizationCircleModel circle;
  final bool isLoading;

  const StudentsSection({
    Key? key,
    required this.circle,
    required this.isLoading,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الطلاب',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.logoTeal,
                  ),
                ),
                Text(
                  '${circle.studentIds.length} طالب',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            Divider(height: 16.h),
            _buildStudentsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsList() {
    if (circle.studentIds.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Center(
          child: Text(
            'لا يوجد طلاب مسجلين في هذه الحلقة',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    } else if (isLoading || (circle.students.isEmpty && circle.studentIds.isNotEmpty)) {
      return Container(
        height: 120.h,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.logoOrange),
            SizedBox(height: 12.h),
            Text(
              'جاري تحميل بيانات ${circle.studentIds.length} طالب...',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    } else {
      return ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: circle.students.length,
        separatorBuilder: (context, index) => SizedBox(height: 8.h),
        itemBuilder: (context, index) {
          final student = circle.students[index];
          return _buildStudentCard(student);
        },
      );
    }
  }

  Widget _buildStudentCard(CircleStudent student) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8.r),
          onTap: () {
            // يمكن إضافة عملية عند الضغط على الطالب
          },
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              children: [
                ProfileImage(
                  imageUrl: student.profileImageUrl,
                  name: student.name,
                  color: AppColors.logoOrange,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14.sp,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            student.evaluations.isNotEmpty
                                ? _formatDate(student.evaluations.last.date)
                                : 'لا يوجد تقييم سابق',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'غير محدد';
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
