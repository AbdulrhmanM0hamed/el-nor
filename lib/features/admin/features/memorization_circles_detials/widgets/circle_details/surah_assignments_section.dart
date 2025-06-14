import 'package:flutter/material.dart';
import '../../../../data/models/memorization_circle_model.dart';
import '../../../../data/models/surah_assignment.dart';

class SurahAssignmentsSection extends StatelessWidget {
  final MemorizationCircleModel circle;

  const SurahAssignmentsSection({
    Key? key,
    required this.circle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double responsive(double size) => size * screenWidth / 375;

    if (circle.surahAssignments.isEmpty) {
      return Card(
        margin: EdgeInsets.symmetric(vertical: responsive(8)),
        child: Padding(
          padding: EdgeInsets.all(responsive(16)),
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
      margin: EdgeInsets.symmetric(vertical: responsive(8)),
      child: Padding(
        padding: EdgeInsets.all(responsive(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.menu_book, size: responsive(24)),
                SizedBox(width: responsive(8)),
                Text(
                  'السور المخصصة',
                  style: TextStyle(
                    fontSize: responsive(18),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: responsive(16)),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: circle.surahAssignments.length,
              separatorBuilder: (context, index) =>
                  Divider(height: responsive(16)),
              itemBuilder: (context, index) {
                final assignment = circle.surahAssignments[index];
                return _buildSurahAssignmentCard(context, assignment);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahAssignmentCard(
      BuildContext context, SurahAssignment assignment) {
    final screenWidth = MediaQuery.of(context).size.width;
    double responsive(double size) => size * screenWidth / 375;

    return Container(
      padding: EdgeInsets.all(responsive(12)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(responsive(8)),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'سورة ${assignment.surahName}',
            style: TextStyle(
              fontSize: responsive(16),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: responsive(8)),
          Row(
            children: [
              Expanded(
                child: Text(
                  'من الآية: ${assignment.startVerse}',
                  style: TextStyle(fontSize: responsive(14)),
                ),
              ),
              Expanded(
                child: Text(
                  'إلى الآية: ${assignment.endVerse}',
                  style: TextStyle(fontSize: responsive(14)),
                ),
              ),
            ],
          ),
          if (assignment.notes != null && assignment.notes!.isNotEmpty) ...[
            SizedBox(height: responsive(8)),
            Text(
              'ملاحظات: ${assignment.notes}',
              style: TextStyle(
                fontSize: responsive(14),
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          SizedBox(height: responsive(8)),
          Text(
            'تاريخ التكليف: ${_formatDate(assignment.assignedDate)}',
            style: TextStyle(
              fontSize: responsive(12),
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