import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../data/models/teacher_model.dart';

class TeacherAssignmentDialog extends StatefulWidget {
  final List<TeacherModel> teachers;
  final String? currentTeacherId;
  final Function(String teacherId, String teacherName) onAssign;

  const TeacherAssignmentDialog({
    Key? key,
    required this.teachers,
    this.currentTeacherId,
    required this.onAssign,
  }) : super(key: key);

  @override
  State<TeacherAssignmentDialog> createState() => _TeacherAssignmentDialogState();
}

class _TeacherAssignmentDialogState extends State<TeacherAssignmentDialog> {
  String? selectedTeacherId;
  String? selectedTeacherName;

  @override
  void initState() {
    super.initState();
    selectedTeacherId = widget.currentTeacherId;
    
    // Si hay un maestro seleccionado, buscar su nombre
    if (selectedTeacherId != null) {
      final teacher = widget.teachers.firstWhere(
        (teacher) => teacher.id == selectedTeacherId,
        orElse: () => TeacherModel(
          id: '',
          name: '',
          email: '',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      selectedTeacherName = teacher.name.isNotEmpty ? teacher.name : 'معلم';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'تعيين معلم للحلقة',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: AppColors.logoTeal,
        ),
        textAlign: TextAlign.center,
      ),
      content: SizedBox(
        width: 300.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'اختر المعلم المسؤول عن هذه الحلقة',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: selectedTeacherId,
                  hint: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Text(
                      'اختر معلماً',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ),
                  items: widget.teachers.map((teacher) {
                    return DropdownMenuItem<String>(
                      value: teacher.id,
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Text(
                          teacher.name,
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? teacherId) {
                    setState(() {
                      selectedTeacherId = teacherId;
                      if (teacherId != null) {
                        final teacher = widget.teachers.firstWhere(
                          (teacher) => teacher.id == teacherId,
                        );
                        selectedTeacherName = teacher.name.isNotEmpty ? teacher.name : 'معلم';
                      } else {
                        selectedTeacherName = null;
                      }
                    });
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(
            'إلغاء',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14.sp,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: selectedTeacherId == null || selectedTeacherName == null
              ? null
              : () {
                  widget.onAssign(
                    selectedTeacherId!,
                    selectedTeacherName!,
                  );
                  Navigator.of(context).pop();
                },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.logoTeal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            disabledBackgroundColor: Colors.grey,
          ),
          child: Text(
            'تعيين',
            style: TextStyle(
              fontSize: 14.sp,
            ),
          ),
        ),
      ],
    );
  }
}
