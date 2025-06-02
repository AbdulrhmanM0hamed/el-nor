import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../data/models/memorization_circle_model.dart';

class StudentEvaluationCard extends StatelessWidget {
  final MemorizationStudent student;
  final bool isAdmin;
  final Function(int, int)? onEvaluationChanged;
  final Function(int, bool)? onAttendanceChanged;

  const StudentEvaluationCard({
    Key? key,
    required this.student,
    this.isAdmin = false,
    this.onEvaluationChanged,
    this.onAttendanceChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            Row(
              children: [
                // Avatar del estudiante
                Container(
                  width: 50.w,
                  height: 50.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: AssetImage(student.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 16.w),
                
                // Información del estudiante
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            student.name,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.logoTeal,
                            ),
                          ),
                          SizedBox(width: 8.w),
                          if (student.isPresent)
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                'حاضر',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.green,
                                ),
                              ),
                            )
                          else
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                'غائب',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      
                      // Control de asistencia (solo para administradores)
                      if (isAdmin && onAttendanceChanged != null)
                        Row(
                          children: [
                            Text(
                              'الحضور:',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Switch(
                              value: student.isPresent,
                              activeColor: AppColors.logoTeal,
                              onChanged: (value) {
                                onAttendanceChanged?.call(student.id, value);
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            // Evaluación (estrellas)
            if (isAdmin && onEvaluationChanged != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
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
                          onEvaluationChanged?.call(student.id, index + 1);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Icon(
                            index < student.evaluation
                                ? Icons.star
                                : Icons.star_border,
                            color: AppColors.logoYellow,
                            size: 28.sp,
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              )
            else if (student.evaluation > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                            index < student.evaluation
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
              ),
          ],
        ),
      ),
    );
  }
}
