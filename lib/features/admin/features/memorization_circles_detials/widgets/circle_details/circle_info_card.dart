import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../../../core/utils/theme/app_colors.dart';
import '../../../../data/models/memorization_circle_model.dart';

class CircleInfoCard extends StatelessWidget {
  final MemorizationCircleModel circle;

  const CircleInfoCard({
    Key? key,
    required this.circle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double responsive(double size) => size * screenWidth / 375;

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
            Text(
              'معلومات الحلقة',
              style: TextStyle(
                fontSize: responsive(16),
                fontWeight: FontWeight.bold,
                color: AppColors.logoTeal,
              ),
            ),
            Divider(height: responsive(16)),
            _buildInfoRow('اسم الحلقة:', circle.name, responsive),
            _buildInfoRow('تاريخ البدء:', _formatDate(circle.startDate), responsive),
            _buildInfoRow('عدد الطلاب:', '${circle.studentIds.length}', responsive),
            if (circle.description != null && circle.description!.isNotEmpty)
              _buildInfoRow('الوصف:', circle.description!, responsive),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, double Function(double) responsive) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: responsive(4)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: responsive(14),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: responsive(8)),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: responsive(14),
              ),
              textAlign: TextAlign.start,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'غير محدد';
    return DateFormat('dd/MM/yyyy').format(date);
  }
}
