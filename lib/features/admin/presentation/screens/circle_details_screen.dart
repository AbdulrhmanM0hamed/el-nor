import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../core/utils/theme/app_colors.dart';
import '../../data/models/memorization_circle_model.dart'; // Contains CircleStudent class
import '../../data/models/teacher_model.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';

class CircleDetailsScreen extends StatefulWidget {
  final MemorizationCircleModel circle;

  const CircleDetailsScreen({Key? key, required this.circle}) : super(key: key);

  @override
  State<CircleDetailsScreen> createState() => _CircleDetailsScreenState();
}

class _CircleDetailsScreenState extends State<CircleDetailsScreen> {
  late AdminCubit _adminCubit;
  late MemorizationCircleModel _circle;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _adminCubit = context.read<AdminCubit>();
    _circle = widget.circle;
    _loadCircleData();
  }

  void _loadCircleData() {
    if (_circle.students.isEmpty && _circle.studentIds.isNotEmpty) {
      setState(() {
        _isLoading = true;
      });
      
      // Load teachers for display
      _adminCubit.loadTeachers();
      
      // Load students directly for this specific circle
      _adminCubit.loadCircleStudents(_circle.id, _circle.studentIds);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تفاصيل حلقة ${_circle.name}',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.logoTeal,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state is AdminCirclesLoaded) {
            // Find updated circle data
            final updatedCircle = state.circles.firstWhere(
              (c) => c.id == _circle.id,
              orElse: () => _circle,
            );
            
            // Update the circle data and loading state
            setState(() {
              _circle = updatedCircle;
              _isLoading = false;
            });
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCircleInfoCard(),
                SizedBox(height: 16.h),
                _buildTeacherSection(),
                SizedBox(height: 16.h),
                _buildStudentsSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircleInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'معلومات الحلقة',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.logoTeal,
              ),
            ),
            Divider(height: 16.h),
            _buildInfoRow('اسم الحلقة:', _circle.name),
            _buildInfoRow('تاريخ البدء:', _formatDate(_circle.startDate)),
            _buildInfoRow('عدد الطلاب:', '${_circle.studentIds.length}'),
            if (_circle.description != null && _circle.description!.isNotEmpty)
              _buildInfoRow('الوصف:', _circle.description!),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'المعلم',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.logoTeal,
              ),
            ),
            Divider(height: 16.h),
            FutureBuilder<List<TeacherModel>>(
              future: _adminCubit.loadTeachers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(color: AppColors.logoTeal),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Text(
                      'خطأ: ${snapshot.error}',
                      style: TextStyle(color: Colors.red, fontSize: 14.sp),
                    ),
                  );
                } else if (snapshot.hasData) {
                  final teachers = snapshot.data!;
                  final teacher = teachers.firstWhere(
                    (t) => t.id == _circle.teacherId,
                    orElse: () => TeacherModel(
                      id: '',
                      name: 'غير محدد',
                      email: '',
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now(),
                      profileImageUrl: '',
                    ),
                  );
                  return _buildTeacherCard(teacher);
                } else {
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('لا يوجد معلمين'),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeacherCard(TeacherModel teacher) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          _buildProfileImage(
            imageUrl: teacher.profileImageUrl,
            name: teacher.name,
            color: AppColors.logoTeal,
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
                    color: Colors.black87,
                  ),
                ),
                if (teacher.email.isNotEmpty) ...[
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        teacher.email,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentsSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الطلاب',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.logoTeal,
                  ),
                ),
                Text(
                  '${_circle.studentIds.length} طالب',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            Divider(height: 16.h),
            _buildStudentsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentsList() {
    if (_circle.studentIds.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 16.h),
        child: Center(
          child: Text(
            'لا يوجد طلاب مسجلين في هذه الحلقة',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );
    } else if (_isLoading || (_circle.students.isEmpty && _circle.studentIds.isNotEmpty)) {
      return Container(
        height: 120.h,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.logoOrange),
            SizedBox(height: 12.h),
            Text(
              'جاري تحميل بيانات ${_circle.studentIds.length} طالب...',
              style: TextStyle(
                fontSize: 14.sp,
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
        itemCount: _circle.students.length,
        separatorBuilder: (context, index) => SizedBox(height: 8.h),
        itemBuilder: (context, index) {
          final student = _circle.students[index];
          return _buildStudentCard(student);
        },
      );
    }
  }

  Widget _buildStudentCard(CircleStudent student) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8.r),
          onTap: () {
            // يمكن إضافة عملية عند الضغط على الطالب
          },
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Row(
              children: [
                _buildProfileImage(
                  imageUrl: student.profileImageUrl,
                  name: student.name,
                  color: AppColors.logoOrange,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14.sp,
                            color: Colors.grey.shade600,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            student.evaluations.isNotEmpty
                                ? _formatDate(student.evaluations.last.date)
                                : 'لا يوجد تقييم سابق',
                            style: TextStyle(
                              fontSize: 12.sp,
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

  Widget _buildProfileImage({
    required String? imageUrl,
    required String name,
    required Color color,
  }) {
    return Container(
      width: 50.w,
      height: 50.w,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25.r),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildNameInitial(name, color),
              )
            : _buildNameInitial(name, color),
      ),
    );
  }

  Widget _buildNameInitial(String name, Color color) {
    return Center(
      child: Text(
        name.isNotEmpty ? name[0] : '?',
        style: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
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
