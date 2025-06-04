import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../data/models/memorization_circle_model.dart';
import '../../../data/models/surah_assignment.dart';

class SurahAssignmentsSection extends StatelessWidget {
  final MemorizationCircleModel circle;

  const SurahAssignmentsSection({
    Key? key,
    required this.circle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (circle.surahAssignments.isEmpty) {
      return Card(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: const Center(
            child: Text(
              'لا توجد سور مخصصة لهذه الحلقة',
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      );
    }

    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.menu_book, size: 24.r),
                SizedBox(width: 8.w),
                Text(
                  'السور المخصصة',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: circle.surahAssignments.length,
              separatorBuilder: (context, index) => Divider(height: 16.h),
              itemBuilder: (context, index) {
                final assignment = circle.surahAssignments[index];
                return _buildSurahAssignmentCard(assignment);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahAssignmentCard(SurahAssignment assignment) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'سورة ${assignment.surahName}',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  'من الآية: ${assignment.startVerse}',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
              Expanded(
                child: Text(
                  'إلى الآية: ${assignment.endVerse}',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ],
          ),
          if (assignment.notes != null && assignment.notes!.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              'ملاحظات: ${assignment.notes}',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          SizedBox(height: 8.h),
          Text(
            'تاريخ التكليف: ${_formatDate(assignment.assignedDate)}',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
} 