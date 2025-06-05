import 'package:flutter/material.dart';
import '../../../../../../../core/utils/theme/app_colors.dart';
import '../../../../../data/models/student_record.dart';

class CircleStudentsTab extends StatelessWidget {
  final List<StudentRecord> students;
  final String teacherId;
  final String currentUserId;
  final Function(String, int)? onEvaluationChanged;
  final Function(String, bool)? onAttendanceChanged;
  final VoidCallback? onAddStudent;

  const CircleStudentsTab({
    Key? key,
    required this.students,
    required this.teacherId,
    required this.currentUserId,
    this.onEvaluationChanged,
    this.onAttendanceChanged,
    this.onAddStudent,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا يوجد طلاب مسجلين',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
                fontWeight: FontWeight.bold,
              ),
            ),
            if (onAddStudent != null) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onAddStudent,
                icon: const Icon(Icons.person_add),
                label: const Text('إضافة طالب'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.logoTeal,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final lastEvaluation = student.evaluations.isNotEmpty 
          ? student.evaluations.last.rating 
          : null;
        final lastAttendance = student.attendance.isNotEmpty 
          ? student.attendance.last.isPresent 
          : null;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(
                  backgroundImage: student.profileImageUrl != null 
                    ? NetworkImage(student.profileImageUrl!) 
                    : null,
                  child: student.profileImageUrl == null 
                    ? Text(
                        student.name[0],
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
                ),
                title: Text(
                  student.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  'آخر تقييم: ${_getEvaluationText(lastEvaluation)}',
                ),
                trailing: _buildAttendanceIndicator(lastAttendance),
              ),
              if (onEvaluationChanged != null || onAttendanceChanged != null)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (onEvaluationChanged != null)
                        _buildEvaluationButtons(student.studentId),
                      if (onAttendanceChanged != null)
                        _buildAttendanceButtons(student.studentId),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAttendanceIndicator(bool? isPresent) {
    if (isPresent == null) return const SizedBox();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isPresent ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        isPresent ? 'حاضر' : 'غائب',
        style: TextStyle(
          color: isPresent ? Colors.green : Colors.red,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEvaluationButtons(String studentId) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.thumb_down, color: Colors.red),
          onPressed: () => onEvaluationChanged?.call(studentId, 1),
        ),
        IconButton(
          icon: const Icon(Icons.thumbs_up_down, color: Colors.orange),
          onPressed: () => onEvaluationChanged?.call(studentId, 2),
        ),
        IconButton(
          icon: const Icon(Icons.thumb_up, color: Colors.green),
          onPressed: () => onEvaluationChanged?.call(studentId, 3),
        ),
      ],
    );
  }

  Widget _buildAttendanceButtons(String studentId) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.check_circle, color: Colors.green),
          onPressed: () => onAttendanceChanged?.call(studentId, true),
        ),
        IconButton(
          icon: const Icon(Icons.cancel, color: Colors.red),
          onPressed: () => onAttendanceChanged?.call(studentId, false),
        ),
      ],
    );
  }

  String _getEvaluationText(int? evaluation) {
    if (evaluation == null) return 'لا يوجد';
    switch (evaluation) {
      case 1:
        return 'ضعيف';
      case 2:
        return 'جيد';
      case 3:
        return 'ممتاز';
      default:
        return 'غير معروف';
    }
  }
} 