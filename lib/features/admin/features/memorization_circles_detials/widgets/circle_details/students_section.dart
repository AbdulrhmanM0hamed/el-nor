import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../../../../core/utils/theme/app_colors.dart';
import '../../../../data/models/memorization_circle_model.dart';
import '../../../../shared/profile_image.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    double responsive(double size) => size * screenWidth / 375;

    Widget buildStudentsList() {
      if (circle.studentIds.isEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: responsive(16)),
          child: Center(
            child: Text(
              'لا يوجد طلاب مسجلين في هذه الحلقة',
              style: TextStyle(
                fontSize: responsive(14),
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        );
      } else if (isLoading ||
          (circle.students.isEmpty && circle.studentIds.isNotEmpty)) {
        return Container(
          height: responsive(120),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: AppColors.logoOrange),
              SizedBox(height: responsive(12)),
              Text(
                'جاري تحميل بيانات ${circle.studentIds.length} طالب...',
                style: TextStyle(
                  fontSize: responsive(14),
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
          separatorBuilder: (context, index) => SizedBox(height: responsive(8)),
          itemBuilder: (context, index) {
            final student = circle.students[index];
            return _buildStudentCard(context, student);
          },
        );
      }
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(responsive(12)),
      ),
      child: Padding(
        padding: EdgeInsets.all(responsive(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الطلاب',
                  style: TextStyle(
                    fontSize: responsive(16),
                    fontWeight: FontWeight.bold,
                    color: AppColors.logoTeal,
                  ),
                ),
                Text(
                  '${circle.studentIds.length} طالب',
                  style: TextStyle(
                    fontSize: responsive(14),
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            Divider(height: responsive(16)),
            buildStudentsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentCard(BuildContext context, CircleStudent student) {
    final screenWidth = MediaQuery.of(context).size.width;
    double responsive(double size) => size * screenWidth / 375;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(responsive(8)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(responsive(8)),
          onTap: () {
            // يمكن إضافة عملية عند الضغط على الطالب
          },
          child: Padding(
            padding: EdgeInsets.all(responsive(12)),
            child: Row(
              children: [
                ProfileImage(
                  imageUrl: student.profileImageUrl,
                  name: student.name,
                  color: AppColors.logoOrange,
                ),
                SizedBox(width: responsive(16)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: TextStyle(
                          fontSize: responsive(16),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: responsive(4)),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: responsive(14),
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: responsive(4)),
                          Text(
                            student.evaluations.isNotEmpty
                                ? _formatDate(student.evaluations.last.date)
                                : 'لا يوجد تقييم سابق',
                            style: TextStyle(
                              fontSize: responsive(12),
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
