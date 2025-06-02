import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/services/service_locator.dart';
import '../../../memorization_circles/data/models/memorization_circle_model.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../widgets/circle_form_dialog.dart';
import '../widgets/teacher_assignment_dialog.dart';

class CircleManagementScreen extends StatefulWidget {
  static const String routeName = '/circle-management';

  const CircleManagementScreen({Key? key}) : super(key: key);

  @override
  State<CircleManagementScreen> createState() => _CircleManagementScreenState();
}

// Wrapper para proporcionar el AdminCubit
class CircleManagementScreenWrapper extends StatelessWidget {
  static const String routeName = '/circle-management';

  const CircleManagementScreenWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminCubit>(
      create: (context) => sl<AdminCubit>(),
      child: const CircleManagementScreen(),
    );
  }
}

class _CircleManagementScreenState extends State<CircleManagementScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar los círculos de memorización al iniciar la pantalla
    context.read<AdminCubit>().loadAllCircles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة حلقات الحفظ'),
        backgroundColor: AppColors.logoTeal,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: BlocBuilder<AdminCubit, AdminState>(
        builder: (context, state) {
          if (state is AdminLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.logoTeal,
              ),
            );
          } else if (state is AdminCirclesLoaded) {
            return _buildCirclesList(state.circles);
          } else if (state is AdminError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64.sp,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    state.message,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AdminCubit>().loadAllCircles();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.logoTeal,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(
              child: Text('حدث خطأ غير متوقع'),
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddCircleDialog();
        },
        backgroundColor: AppColors.logoTeal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildCirclesList(List<MemorizationCircle> circles) {
    if (circles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_off,
              size: 64.sp,
              color: Colors.grey,
            ),
            SizedBox(height: 16.h),
            Text(
              'لا توجد حلقات حفظ حالياً',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'اضغط على زر الإضافة لإنشاء حلقة جديدة',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: circles.length,
      itemBuilder: (context, index) {
        final circle = circles[index];
        return Card(
          margin: EdgeInsets.only(bottom: 16.h),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.group,
                      color: AppColors.logoTeal,
                      size: 24.sp,
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        circle.name,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.logoTeal,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      color: AppColors.logoOrange,
                      onPressed: () {
                        _showEditCircleDialog(circle);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      color: Colors.red,
                      onPressed: () {
                        _showDeleteConfirmationDialog(circle);
                      },
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Text(
                  'الوصف: ${circle.description}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'المعلم: ${circle.teacherName ?? 'غير محدد'}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'عدد الطلاب: ${circle.studentsCount ?? 0}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        _showAssignTeacherDialog(circle);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.logoTeal,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      icon: const Icon(Icons.person_add),
                      label: const Text('تعيين معلم'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Ver detalles del círculo y sus estudiantes
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.logoOrange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      icon: const Icon(Icons.visibility),
                      label: const Text('عرض التفاصيل'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAddCircleDialog() {
    showDialog(
      context: context,
      builder: (context) => CircleFormDialog(
        title: 'إضافة حلقة حفظ جديدة',
        onSave: (name, description) {
          context.read<AdminCubit>().createCircle(
                name: name,
                description: description,
              );
        },
      ),
    );
  }

  void _showEditCircleDialog(MemorizationCircle circle) {
    showDialog(
      context: context,
      builder: (context) => CircleFormDialog(
        title: 'تعديل حلقة الحفظ',
        initialName: circle.name,
        initialDescription: circle.description,
        onSave: (name, description) {
          context.read<AdminCubit>().updateCircle(
                circleId: circle.id,
                name: name,
                description: description,
              );
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(MemorizationCircle circle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف حلقة "${circle.name}"؟'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              context.read<AdminCubit>().deleteCircle(circle.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showAssignTeacherDialog(MemorizationCircle circle) {
    // Cargar la lista de maestros
    context.read<AdminCubit>().loadTeachers();
    
    // Mostrar el diálogo cuando los maestros estén cargados
    showDialog(
      context: context,
      builder: (context) {
        return BlocBuilder<AdminCubit, AdminState>(
          builder: (context, state) {
            if (state is AdminTeachersLoaded) {
              return TeacherAssignmentDialog(
                teachers: state.teachers,
                currentTeacherId: circle.teacherId,
                onAssign: (teacherId, teacherName) {
                  context.read<AdminCubit>().assignTeacherToCircle(
                        circleId: circle.id,
                        teacherId: teacherId,
                        teacherName: teacherName,
                      );
                },
              );
            }
            return const AlertDialog(
              content: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        );
      },
    );
  }
}
