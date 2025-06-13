import 'package:noor_quran/core/utils/constant/styles_manger.dart';
import 'package:flutter/material.dart';
import '../../../../../../../core/utils/theme/app_colors.dart';
import '../../../../../data/models/student_record.dart';
import 'package:intl/intl.dart';

class CircleStudentsTab extends StatelessWidget {
  final List<StudentRecord> students;
  final String teacherId;
  final String currentUserId;
  final Function(String, int)? onEvaluationChanged;
  final Function(String, int)? onEvaluationDelete;
  final Function(String, bool)? onAttendanceChanged;
  final VoidCallback? onAddStudent;

  const CircleStudentsTab({
    Key? key,
    required this.students,
    required this.teacherId,
    required this.currentUserId,
    this.onEvaluationChanged,
    this.onEvaluationDelete,
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
                subtitle:
                    Text('آخر تقييم: ${_getEvaluationText(lastEvaluation)}'),
                trailing: Text(
                  DateFormat('yyyy-MM-dd').format(student.createdAt.toLocal()),
                ),
              ),
              // قائمة التقييمات السابقة
              if (student.evaluations.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: student.evaluations.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final eval = entry.value;
                      final isLast = idx == student.evaluations.length - 1;
                      final dateStr =
                          DateFormat('dd/MM/yyyy').format(eval.date);
                      Widget chip = Chip(
                        label: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getEvaluationText(eval.rating),
                              style: getMediumStyle(
                                fontFamily: 'Cairo',
                                color: isLast ? Colors.white : Colors.black,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              dateStr,
                              style: getMediumStyle(
                                fontFamily: 'Cairo',
                                color: isLast ? Colors.white : Colors.black54,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                        avatar: isLast
                            ? const Icon(Icons.star,
                                color: Colors.white, size: 16)
                            : null,
                        backgroundColor: isLast
                            ? _getEvaluationColor(eval.rating)
                            : Colors.grey.shade200,
                      );

                      if (onEvaluationDelete != null) {
                        chip = InkWell(
                          onTap: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('حذف التقييم'),
                                content: const Text(
                                    'هل أنت متأكد من حذف هذا التقييم؟'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    style: TextButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                    child: const Text('إلغاء'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(ctx).pop(true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                    ),
                                    child: const Text('حذف'),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              final idx = student.evaluations.indexOf(eval);
                              if (idx != -1) {
                                onEvaluationDelete!(student.studentId, idx);
                              }
                            }
                          },
                          child: chip,
                        );
                      }

                      return chip;
                    }).toList(),
                  ),
                ),
              if (onEvaluationChanged != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: _buildEvaluationButtons(student.studentId),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEvaluationButtons(String studentId) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () => onEvaluationChanged?.call(studentId, 4),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          child: const Text('متميز'),
        ),
        ElevatedButton(
          onPressed: () => onEvaluationChanged?.call(studentId, 3),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
          child: const Text('ملتزم'),
        ),
        ElevatedButton(
          onPressed: () => onEvaluationChanged?.call(studentId, 2),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          child: const Text('مقصر'),
        ),
        ElevatedButton(
          onPressed: () => onEvaluationChanged?.call(studentId, 1),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: const Text('مهدد'),
        ),
      ],
    );
  }

  String _getEvaluationText(int? evaluation) {
    if (evaluation == null) return 'لا يوجد';
    switch (evaluation) {
      case 1:
        return 'مهدد بالفصل';
      case 2:
        return 'مقصر';
      case 3:
        return 'ملتزم';
      case 4:
        return 'متميز';
      default:
        return 'غير معروف';
    }
  }

  Color _getEvaluationColor(int rating) {
    switch (rating) {
      case 1:
        return Colors.red;
      case 2:
        return Colors.orange;
      case 3:
        return Colors.blue;
      case 4:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
