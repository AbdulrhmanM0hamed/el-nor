import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../../core/utils/theme/app_colors.dart';
import '../../../../data/models/memorization_circle_model.dart';
import '../../../../data/models/student_model.dart';
import '../../../user_management/presentation/cubit/admin_cubit.dart';
import '../../../user_management/presentation/cubit/admin_state.dart';
import '../../../../shared/profile_image_fixed.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    double responsive(double size) => size * screenWidth / 375;

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
          borderRadius: BorderRadius.circular(responsive(12)),
        ),
        margin: EdgeInsets.symmetric(
            horizontal: responsive(0), vertical: responsive(8)),
        child: Padding(
          padding: EdgeInsets.all(responsive(16)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'المعلم',
                    style: TextStyle(
                      fontSize: responsive(18),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Divider(height: responsive(16)),
              if (_isLoading)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: responsive(20)),
                    child: Column(
                      children: [
                        const CircularProgressIndicator(
                          color: AppColors.logoTeal,
                        ),
                        SizedBox(height: responsive(8)),
                        Text(
                          'جاري تحميل بيانات المعلم...',
                          style: TextStyle(fontSize: responsive(14)),
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
    final screenWidth = MediaQuery.of(context).size.width;
    double responsive(double size) => size * screenWidth / 375;

    // التأكد من أن عنوان URL الصورة صالح قبل استخدامه
    final hasValidImage =
        teacher.profileImageUrl != null && teacher.profileImageUrl!.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(responsive(16)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(responsive(8)),
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
              SizedBox(width: responsive(16)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      teacher.name,
                      style: TextStyle(
                        fontSize: responsive(16),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (teacher.isTeacher)
                      Padding(
                        padding: EdgeInsets.only(top: responsive(4)),
                        child: Text(
                          'معلم',
                          style: TextStyle(
                            fontSize: responsive(12),
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
            SizedBox(height: responsive(16)),
          if (teacher.email.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: responsive(8)),
              child: Row(
                children: [
                  Icon(Icons.email,
                      size: responsive(16), color: Colors.grey.shade600),
                  SizedBox(width: responsive(8)),
                  Expanded(
                    child: Text(
                      teacher.email,
                      style: TextStyle(
                        fontSize: responsive(14),
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
                Icon(Icons.phone,
                    size: responsive(16), color: Colors.grey.shade600),
                SizedBox(width: responsive(8)),
                Text(
                  teacher.phoneNumber!,
                  style: TextStyle(
                    fontSize: responsive(14),
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
