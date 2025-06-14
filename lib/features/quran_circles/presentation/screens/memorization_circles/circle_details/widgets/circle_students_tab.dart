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
    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveSize = screenWidth / 375;

    if (students.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64 * responsiveSize,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16 * responsiveSize),
            Text(
              'لا يوجد طلاب مسجلين',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontSize: 18 * responsiveSize,
                    color: Colors.grey[700],
                  ),
            ),
            if (onAddStudent != null) ...[
              SizedBox(height: 16 * responsiveSize),
              ElevatedButton.icon(
                onPressed: onAddStudent,
                icon: Icon(Icons.person_add, size: 20 * responsiveSize),
                label: Text(
                  'إضافة طالب',
                  style: TextStyle(fontSize: 14 * responsiveSize),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.logoTeal,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24 * responsiveSize,
                    vertical: 12 * responsiveSize,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16 * responsiveSize),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final lastEvaluation = student.evaluations.isNotEmpty
            ? student.evaluations.last.rating
            : null;

        return Card(
          margin: EdgeInsets.only(bottom: 16 * responsiveSize),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: CircleAvatar(
                  radius: 24 * responsiveSize,
                  backgroundImage: student.profileImageUrl != null
                      ? NetworkImage(student.profileImageUrl!)
                      : null,
                  child: student.profileImageUrl == null
                      ? Text(
                          student.name.isNotEmpty ? student.name[0] : '',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18 * responsiveSize,
                          ),
                        )
                      : null,
                ),
                title: Text(
                  student.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 16 * responsiveSize,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                subtitle: Text(
                  'آخر تقييم: ${_getEvaluationText(lastEvaluation)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12 * responsiveSize,
                      ),
                ),
                trailing: Text(
                  DateFormat('yyyy-MM-dd').format(student.createdAt.toLocal()),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 12 * responsiveSize,
                      ),
                ),
              ),
              if (student.evaluations.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.0 * responsiveSize,
                    vertical: 8 * responsiveSize,
                  ),
                  child: Wrap(
                    spacing: 8 * responsiveSize,
                    runSpacing: 8 * responsiveSize,
                    children: student.evaluations.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final eval = entry.value;
                      final isLast = idx == student.evaluations.length - 1;
                      final dateStr =
                          DateFormat('dd/MM/yyyy').format(eval.date);
                      Widget chip = Chip(
                        padding: EdgeInsets.all(4 * responsiveSize),
                        label: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _getEvaluationText(eval.rating),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color:
                                        isLast ? Colors.white : Colors.black,
                                    fontSize: 11 * responsiveSize,
                                  ),
                            ),
                            Text(
                              dateStr,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: isLast
                                        ? Colors.white70
                                        : Colors.black54,
                                    fontSize: 10 * responsiveSize,
                                  ),
                            ),
                          ],
                        ),
                        avatar: isLast
                            ? Icon(Icons.star,
                                color: Colors.white, size: 16 * responsiveSize)
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
                                title: Text('حذف التقييم',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                            fontSize: 18 * responsiveSize)),
                                content: Text(
                                    'هل أنت متأكد من حذف هذا التقييم؟',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                            fontSize: 14 * responsiveSize)),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(false),
                                    child: Text('إلغاء',
                                        style: TextStyle(
                                            fontSize: 14 * responsiveSize)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.of(ctx).pop(true),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: Text('حذف',
                                        style: TextStyle(
                                            fontSize: 14 * responsiveSize,
                                            color: Colors.white)),
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
                  padding: EdgeInsets.only(bottom: 8.0 * responsiveSize),
                  child: _buildEvaluationButtons(context, student.studentId),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEvaluationButtons(BuildContext context, String studentId) {
    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveSize = screenWidth / 375;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildEvaluationButton(context, 'متميز', 4, Colors.green, studentId,
            responsiveSize),
        _buildEvaluationButton(
            context, 'ملتزم', 3, Colors.blue, studentId, responsiveSize),
        _buildEvaluationButton(
            context, 'مقصر', 2, Colors.orange, studentId, responsiveSize),
        _buildEvaluationButton(
            context, 'مهدد', 1, Colors.red, studentId, responsiveSize),
      ],
    );
  }

  Widget _buildEvaluationButton(BuildContext context, String text, int rating,
      Color color, String studentId, double responsiveSize) {
    return ElevatedButton(
      onPressed: () => onEvaluationChanged?.call(studentId, rating),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(
          horizontal: 12 * responsiveSize,
          vertical: 8 * responsiveSize,
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12 * responsiveSize,
          color: Colors.white,
        ),
      ),
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
