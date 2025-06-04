import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/student_record.dart';
import 'student_evaluation_card.dart';

class CircleStudentsTab extends StatelessWidget {
  final List<StudentRecord> students;
  final String teacherId;
  final String? currentUserId;
  final Function(String, int)? onEvaluationChanged;
  final Function(String, bool)? onAttendanceChanged;
  final VoidCallback? onAddStudent;

  const CircleStudentsTab({
    Key? key,
    required this.students,
    required this.teacherId,
    this.currentUserId,
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
          teacherId: teacherId,
          currentUserId: currentUserId,
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
            Icons.people_outline,
            size: 64.sp,
            color: Colors.grey,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا يوجد طلاب في هذه الحلقة',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.grey,
            ),
          ),
          if (onAddStudent != null) ...[
            SizedBox(height: 24.h),
            TextButton.icon(
              onPressed: onAddStudent,
              icon: const Icon(Icons.person_add),
              label: const Text('إضافة طالب'),
            ),
          ],
        ],
      ),
    );
  }
}


