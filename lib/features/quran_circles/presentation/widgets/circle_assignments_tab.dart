import 'package:beat_elslam/core/utils/theme/app_colors.dart';
import 'package:beat_elslam/features/quran_circles/data/models/surah_assignment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/memorization_circle_model.dart';
import 'surah_assignment_card.dart';

class CircleAssignmentsTab extends StatelessWidget {
  final List<SurahAssignment> assignments;
  final bool isEditable;
  final VoidCallback? onAddSurah;

  const CircleAssignmentsTab({
    Key? key,
    required this.assignments,
    this.isEditable = false,
    this.onAddSurah,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (assignments.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.r),
      itemCount: assignments.length,
      itemBuilder: (context, index) {
        return SurahAssignmentCard(
          assignment: assignments[index],
          isEditable: isEditable,
          onEdit: isEditable ? () => _onEditAssignment(context, assignments[index]) : null,
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
            Icons.menu_book,
            size: 64.sp,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد سور مقررة',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'لم يتم تعيين سور للحفظ في هذه الحلقة بعد',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
          if (isEditable && onAddSurah != null)
            Padding(
              padding: EdgeInsets.only(top: 16.h),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('إضافة سورة'),
                onPressed: onAddSurah,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.logoTeal,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onEditAssignment(BuildContext context, SurahAssignment assignment) {
    // في نسخة لاحقة: عرض نموذج تعديل السورة
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم إضافة ميزة تعديل السورة قريباً'),
        backgroundColor: AppColors.logoTeal,
      ),
    );
  }
}
