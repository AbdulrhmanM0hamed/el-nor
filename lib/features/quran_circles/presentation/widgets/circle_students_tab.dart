import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/memorization_circle_model.dart';
import 'student_evaluation_card.dart';

class CircleStudentsTab extends StatelessWidget {
  final List<MemorizationStudent> students;
  final bool isAdmin;
  final Function(int, int)? onEvaluationChanged;
  final Function(int, bool)? onAttendanceChanged;
  final VoidCallback? onAddStudent;

  const CircleStudentsTab({
    Key? key,
    required this.students,
    this.isAdmin = false,
    this.onEvaluationChanged,
    this.onAttendanceChanged,
    this.onAddStudent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: students.length,
      itemBuilder: (context, index) {
        return StudentEvaluationCard(
          student: students[index],
          isAdmin: isAdmin,
          onEvaluationChanged: onEvaluationChanged,
          onAttendanceChanged: onAttendanceChanged,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people,
            size: 64.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            'لا يوجد طلاب',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'لم يتم تسجيل طلاب في هذه الحلقة بعد',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          if (isAdmin && onAddStudent != null)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('إضافة طالب'),
                onPressed: onAddStudent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C595E), // AppColors.logoTeal
                ),
              ),
            ),
        ],
      ),
    );
  }
}
