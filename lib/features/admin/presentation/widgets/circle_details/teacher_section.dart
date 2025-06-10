import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/utils/theme/app_colors.dart';
import '../../../data/models/memorization_circle_model.dart';
import '../../../data/models/student_model.dart';
import '../../cubit/admin_cubit.dart';
import '../../cubit/admin_state.dart';
import '../shared/profile_image_fixed.dart';

class TeacherSection extends StatefulWidget {
  final MemorizationCircleModel circle;
  final List<StudentModel> teachers;
  final Function(String, String)? onAssignTeacher;
  final bool isLoading;

  const TeacherSection({
    Key? key,
    required this.circle,
    required this.teachers,
    this.onAssignTeacher,
    this.isLoading = false,
  }) : super(key: key);

  @override
  State<TeacherSection> createState() => _TeacherSectionState();
}

class _TeacherSectionState extends State<TeacherSection> {
  late StudentModel _teacher;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initTeacher();
    _isLoading = widget.isLoading;
  }

  @override
  void didUpdateWidget(TeacherSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isLoading != oldWidget.isLoading) {
      setState(() {
        _isLoading = widget.isLoading;
      });
    }

    if (widget.circle.teacherId != oldWidget.circle.teacherId ||
        widget.teachers != oldWidget.teachers) {
      _initTeacher();
    }
  }

  void _initTeacher() {
    if (widget.teachers.isNotEmpty && widget.circle.teacherId != null) {
      final exactMatch = widget.teachers
          .where((t) => t.id == widget.circle.teacherId)
          .toList();

      if (exactMatch.isNotEmpty) {
        final matchedTeacher = exactMatch.first;
        setState(() {
          _teacher = matchedTeacher;
          _isLoading = false;
        });
        return;
      }
    }

    // إنشاء معلم افتراضي بالمعلومات المتوفرة من الحلقة
    final defaultTeacher = StudentModel(
      id: widget.circle.teacherId ?? '',
      name: widget.circle.teacherName ?? 'لم يتم تعيين معلم بعد',
      email: widget.circle.teacherEmail ?? '',
      phoneNumber: widget.circle.teacherPhone,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isTeacher: true,
      isAdmin: false,
      profileImageUrl:
          widget.circle.teacherImageUrl, // استخدام URL الصورة من الحلقة
    );

    setState(() {
      _teacher = defaultTeacher;
      _isLoading = widget.isLoading;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminCubit, AdminState>(
      listener: (context, state) {
        if (state is AdminTeacherAssigned) {
          if (state.circleId == widget.circle.id) {
            setState(() {
              _isLoading = false;
            });
            context.read<AdminCubit>().loadTeachers();
          }
        } else if (state is AdminTeachersLoaded) {
          _initTeacher();
        } else if (state is AdminLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is AdminError) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        margin: EdgeInsets.symmetric(horizontal: 0.w, vertical: 8.h),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'المعلم',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Divider(height: 16.h),
              if (_isLoading)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(
                          color: AppColors.logoTeal,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'جاري تحميل بيانات المعلم...',
                          style: TextStyle(fontSize: 14.sp),
                        ),
                      ],
                    ),
                  ),
                )
              else
                _buildTeacherCard(_teacher),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherCard(StudentModel teacher) {
    // التأكد من أن عنوان URL الصورة صالح قبل استخدامه
    final hasValidImage =
        teacher.profileImageUrl != null && teacher.profileImageUrl!.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ProfileImage(
                color: AppColors.logoTeal,
                imageUrl: hasValidImage ? teacher.profileImageUrl! : '',
                name: teacher.name,
                showDebugLogs: true,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher.name,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (teacher.isTeacher)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h),
                        child: Text(
                          'معلم',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.logoTeal,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (teacher.email.isNotEmpty || teacher.phoneNumber != null)
            SizedBox(height: 16.h),
          if (teacher.email.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Icon(Icons.email, size: 16.sp, color: Colors.grey.shade600),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      teacher.email,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          if (teacher.phoneNumber != null && teacher.phoneNumber!.isNotEmpty)
            Row(
              children: [
                Icon(Icons.phone, size: 16.sp, color: Colors.grey.shade600),
                SizedBox(width: 8.w),
                Text(
                  teacher.phoneNumber!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
