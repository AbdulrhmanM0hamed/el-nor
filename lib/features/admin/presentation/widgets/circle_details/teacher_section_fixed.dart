import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/utils/theme/app_colors.dart';
import '../../../data/models/memorization_circle_model.dart';
import '../../../data/models/teacher_model.dart';
import '../../cubit/admin_cubit.dart';
import '../../cubit/admin_state.dart';
import '../shared/profile_image_fixed.dart';

class TeacherSection extends StatefulWidget {
  final MemorizationCircleModel circle;
  final List<TeacherModel> teachers;
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
  late TeacherModel _teacher;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initTeacher();

    // Initialize loading state from widget
    _isLoading = widget.isLoading;
  }

  @override
  void didUpdateWidget(TeacherSection oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Update loading state if it changed from parent
    if (widget.isLoading != oldWidget.isLoading) {
      setState(() {
        _isLoading = widget.isLoading;
      });
    }

    // Re-initialize teacher if circle or teachers list changed
    if (widget.circle.teacherId != oldWidget.circle.teacherId ||
        widget.teachers != oldWidget.teachers) {
      _initTeacher();
    }
  }

  void _initTeacher() {
    // Check if we need to show loading state
    bool shouldShowLoading = false;

    // If we have a teacher ID but no teachers loaded yet, we should show loading
    if (widget.circle.teacherId != null &&
        widget.circle.teacherId!.isNotEmpty &&
        widget.teachers.isEmpty) {
      shouldShowLoading = true;
      print(
          'TeacherSection - Has teacher ID but no teachers loaded, showing loading state');
    }

    // Create a default teacher model with circle data as fallback
    final defaultName = widget.circle.teacherName ?? 'لم يتم تعيين معلم بعد';
    final defaultTeacher = TeacherModel(
      id: widget.circle.teacherId ?? '',
      name: defaultName,
      email: '',
      phone: '',
      profileImageUrl: '',
      specialization: '',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Debug prints to help diagnose issues
    print('TeacherSection - Circle teacherId: ${widget.circle.teacherId}');
    print('TeacherSection - Circle teacherName: ${widget.circle.teacherName}');
    print('TeacherSection - Available teachers: ${widget.teachers.length}');

    // List teacher IDs for debugging
    if (widget.teachers.isNotEmpty) {
      print(
          'TeacherSection - Teacher IDs in list: ${widget.teachers.map((t) => t.id).join(', ')}');
    }

    // Try to find the assigned teacher in the teachers list
    TeacherModel foundTeacher = defaultTeacher;
    bool teacherFound = false;

    if (widget.circle.teacherId != null &&
        widget.circle.teacherId!.isNotEmpty &&
        widget.teachers.isNotEmpty) {
      try {
        // First try to find by exact ID match
        final exactMatch = widget.teachers
            .where((t) => t.id == widget.circle.teacherId)
            .toList();

        if (exactMatch.isNotEmpty) {
          foundTeacher = exactMatch.first;
          teacherFound = true;
          print(
              'TeacherSection - Found exact teacher match: ${foundTeacher.name}, ID: ${foundTeacher.id}');
        } else {
          // If no exact match, try to find by name as fallback
          if (widget.circle.teacherName != null &&
              widget.circle.teacherName!.isNotEmpty) {
            final nameMatch = widget.teachers
                .where((t) =>
                    t.name.toLowerCase() ==
                    widget.circle.teacherName!.toLowerCase())
                .toList();

            if (nameMatch.isNotEmpty) {
              foundTeacher = nameMatch.first;
              teacherFound = true;
              print(
                  'TeacherSection - Found teacher by name: ${foundTeacher.name}, ID: ${foundTeacher.id}');
            } else {
              print(
                  'TeacherSection - No teacher found with ID ${widget.circle.teacherId} or name ${widget.circle.teacherName}');
            }
          }
        }

        // Check if we have a profile image
        final hasProfileImage = foundTeacher.profileImageUrl != null &&
            (foundTeacher.profileImageUrl?.isNotEmpty ?? false);

        if (hasProfileImage) {
          print(
              'TeacherSection - Profile image URL: ${foundTeacher.profileImageUrl}');
        } else {
          print(
              'TeacherSection - No profile image for teacher ${foundTeacher.name}');
        }
      } catch (e) {
        print('TeacherSection - Error finding teacher: $e');
      }
    } else {
      print(
          'TeacherSection - No teacher ID or empty teachers list, using default teacher');
    }

    // If we have a teacher ID but couldn't find the teacher, keep loading state
    if (widget.circle.teacherId != null &&
        widget.circle.teacherId!.isNotEmpty &&
        !teacherFound) {
      shouldShowLoading = true;
      print(
          'TeacherSection - Has teacher ID but teacher not found, keeping loading state');
    }

    // Update the teacher state
    setState(() {
      _teacher = foundTeacher;
      _isLoading = shouldShowLoading || widget.isLoading;
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

            // Force reload teachers to get updated data
            context.read<AdminCubit>().loadTeachers();
          }
        } else if (state is AdminTeachersLoaded) {
          // When teachers are loaded, update our teacher data
          _initTeacher();
          
          // Ensure we exit loading state after a maximum time
          setState(() {
            _isLoading = false;
          });
        } else if (state is AdminLoading) {
          // Only set loading state if we're not already loading
          if (!_isLoading) {
            setState(() {
              _isLoading = true;
            });
            
            // Add a safety timeout to prevent infinite loading
            Future.delayed(const Duration(seconds: 5), () {
              if (mounted && _isLoading) {
                setState(() {
                  _isLoading = false;
                });
                print('TeacherSection: Safety timeout triggered to prevent infinite loading');
              }
            });
          }
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
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with title and assign button
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
                  if (!_isLoading)
                    TextButton.icon(
                      onPressed: () => _showAssignTeacherDialog(context),
                      icon: Icon(
                        Icons.edit,
                        size: 16.sp,
                        color: AppColors.logoTeal,
                      ),
                      label: Text(
                        'تغيير',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.logoTeal,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                      ),
                    ),
                ],
              ),
              Divider(height: 16.h),

              // Show loading indicator, no teacher assigned, or teacher card
              if (_isLoading)
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Column(
                      children: [
                        CircularProgressIndicator(
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
              else if (widget.circle.teacherId == null ||
                  widget.circle.teacherId!.isEmpty)
                _buildNoTeacherAssigned(context)
              else
                _buildTeacherCard(_teacher),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoTeacherAssigned(BuildContext context) {
    return InkWell(
      onTap: () => _showAssignTeacherDialog(context),
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(
              Icons.person_add_alt_1,
              color: AppColors.logoTeal,
              size: 24.sp,
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                'لم يتم تعيين معلم لهذه الحلقة بعد. اضغط هنا لتعيين معلم.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherCard(TeacherModel teacher) {
    // Debug print for profile image URL
    print('TeacherCard - Profile image URL: ${teacher.profileImageUrl}');

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // Teacher profile image and name
          Row(
            children: [
              ProfileImage(
                color: AppColors.logoTeal,
                imageUrl: teacher.profileImageUrl ?? '',
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
                    if (teacher.specialization != null &&
                        teacher.specialization!.isNotEmpty)
                      Text(
                        teacher.specialization!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Teacher contact info
          if (teacher.email != null && teacher.email!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Row(
                children: [
                  Icon(Icons.email, size: 16.sp, color: Colors.grey.shade600),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      teacher.email!,
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

          if (teacher.phone != null && teacher.phone!.isNotEmpty)
            Row(
              children: [
                Icon(Icons.phone, size: 16.sp, color: Colors.grey.shade600),
                SizedBox(width: 8.w),
                Text(
                  teacher.phone!,
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

  void _showAssignTeacherDialog(BuildContext context) {
    print(
        'Showing assign teacher dialog for circle: ${widget.circle.id}, ${widget.circle.name}');
    // Call the onAssignTeacher callback to show the dialog from the parent
    if (widget.onAssignTeacher != null) {
      widget.onAssignTeacher!(widget.circle.id, widget.circle.name);
    } else {
      print('TeacherSection: onAssignTeacher is null, cannot show dialog');
    }
  }
}
