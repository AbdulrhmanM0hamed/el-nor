import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../data/models/student_record.dart';

class StudentEvaluationCard extends StatelessWidget {
  final StudentRecord student;
  final String? currentUserId;
  final String teacherId;
  final Function(String, int)? onEvaluationChanged;
  final Function(String, bool)? onAttendanceChanged;

  const StudentEvaluationCard({
    Key? key,
    required this.student,
    required this.teacherId,
    this.currentUserId,
    this.onEvaluationChanged,
    this.onAttendanceChanged,
  }) : super(key: key);

  bool get _canManageStudent {
    print('StudentEvaluationCard Debug:');
    print('currentUserId: $currentUserId');
    print('teacherId: $teacherId');
    print('onEvaluationChanged: ${onEvaluationChanged != null}');
    print('onAttendanceChanged: ${onAttendanceChanged != null}');
    
    final canManage = currentUserId != null && 
      teacherId.isNotEmpty && 
      currentUserId == teacherId &&
      onEvaluationChanged != null &&
      onAttendanceChanged != null;
      
    print('canManageStudent: $canManage');
    return canManage;
  }
  
  int get _currentEvaluation => student.evaluations.isNotEmpty ? student.evaluations.last.rating : 0;
  bool get _isPresent => student.attendance.isNotEmpty ? student.attendance.last.isPresent : true;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: student.profileImageUrl != null
                        ? DecorationImage(
                            image: NetworkImage(
                              '${student.profileImageUrl!}?timestamp=${DateTime.now().millisecondsSinceEpoch}',
                              headers: const {'cache-control': 'no-cache'},
                            ),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: student.profileImageUrl == null
                      ? Center(
                          child: Text(
                            _getInitial(student.name),
                            style: TextStyle(
                              color: AppColors.logoTeal,
                              fontWeight: FontWeight.bold,
                              fontSize: 24.sp,
                            ),
                          ),
                        )
                      : null,
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
                          color: AppColors.logoTeal,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: _isPresent ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          _isPresent ? 'حاضر' : 'غائب',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: _isPresent ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            if (_canManageStudent) ...[
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'تسجيل الحضور:',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  Switch(
                    value: _isPresent,
                    activeColor: AppColors.logoTeal,
                    onChanged: (value) {
                      onAttendanceChanged?.call(student.studentId, value);
                    },
                  ),
                ],
              ),
            
              SizedBox(height: 16.h),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تقييم الحفظ:',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        onTap: () {
                          onEvaluationChanged?.call(student.studentId, index + 1);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Icon(
                            index < _currentEvaluation
                                ? Icons.star
                                : Icons.star_border,
                            color: const Color.fromARGB(255, 231, 198, 8),
                            size: 32.sp,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(height: 16.h),
              Row(
                children: [
                  Text(
                    'التقييم:',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < _currentEvaluation
                            ? Icons.star
                            : Icons.star_border,
                        color: AppColors.logoYellow,
                        size: 20.sp,
                      );
                    }),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getInitial(String name) {
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
