import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/services/service_locator.dart';
import '../../data/models/memorization_circle_model.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../widgets/circle_form_dialog.dart';
import 'circle_details_screen.dart';
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
                      padding: EdgeInsets.symmetric(
                          horizontal: 24.w, vertical: 12.h),
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

  Widget _buildCirclesList(List<MemorizationCircleModel> circles) {
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
                  '${circle.studentIds.length} طالب',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
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
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                      ),
                      icon: const Icon(Icons.person_add),
                      label: const Text('تعيين معلم'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        _showCircleDetailsDialog(circle);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.logoOrange,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
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

  void _showAddCircleDialog() async {
    // Obtener la referencia al cubit
    final adminCubit = context.read<AdminCubit>();

    // Cargar profesores y estudiantes antes de mostrar el diálogo
    final teachers = await adminCubit.loadTeachers();
    final students = await adminCubit.loadStudents();

    if (!mounted) return; // Verificar si el widget todavía está montado

    showDialog(
      context: context,
      builder: (context) => CircleFormDialog(
        title: 'إضافة حلقة حفظ جديدة',
        availableTeachers: teachers,
        availableStudents: students,
        onSave: (name, description, startDate, teacherId, teacherName, surahs,
            studentIds) {
          adminCubit.createCircle(
            name: name,
            description: description,
            startDate: startDate,
            teacherId: teacherId,
            teacherName: teacherName,
            surahs: surahs,
            studentIds: studentIds,
          );
        },
      ),
    );
  }

  void _showEditCircleDialog(MemorizationCircleModel circle) async {
    // Obtener la referencia al cubit
    final adminCubit = context.read<AdminCubit>();

    // Cargar profesores y estudiantes antes de mostrar el diálogo
    final teachers = await adminCubit.loadTeachers();
    final students = await adminCubit.loadStudents();

    if (!mounted) return; // Verificar si el widget todavía está montado

    showDialog(
      context: context,
      builder: (context) => CircleFormDialog(
        title: 'تعديل حلقة الحفظ',
        initialName: circle.name,
        initialDescription: circle.description,
        initialDate: circle.startDate,
        initialSurahAssignments: circle.surahAssignments,
        initialStudentIds: circle.studentIds,
        availableTeachers: teachers,
        availableStudents: students,
        onSave: (name, description, startDate, teacherId, teacherName, surahs,
            studentIds) {
          adminCubit.updateCircle(
            id: circle.id,
            name: name,
            description: description,
            startDate: startDate,
            teacherId: teacherId,
            teacherName: teacherName,
            surahs: surahs,
            studentIds: studentIds,
          );
        },
      ),
    );
  }

  void _showDeleteConfirmationDialog(MemorizationCircleModel circle) {
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

  // التنقل إلى صفحة تفاصيل الحلقة
  void _showCircleDetailsDialog(MemorizationCircleModel circle) {
    // طباعة معلومات الحلقة للتصحيح
    print('عرض تفاصيل الحلقة: ${circle.name}');
    print('عدد الطلاب في studentIds: ${circle.studentIds.length}');
    print('عدد الطلاب في students: ${circle.students.length}');
    
    // التقاط AdminCubit قبل الانتقال
    final adminCubit = context.read<AdminCubit>();
    
    // الانتقال إلى صفحة تفاصيل الحلقة
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (routeContext) => BlocProvider.value(
          value: adminCubit,
          child: CircleDetailsScreen(circle: circle),
        ),
      ),
    );
  }

  // تم إزالة _loadTeacherDetails لأنه غير مستخدم
  // تم إزالة _formatDate و _buildInfoRow لأنهما غير مستخدمين بعد نقل الكود إلى صفحة تفاصيل الحلقة

  void _showAssignTeacherDialog(MemorizationCircleModel circle) {
    // التقاط AdminCubit قبل عرض مربع الحوار
    final adminCubit = context.read<AdminCubit>();

    // تحميل قائمة المعلمين
    adminCubit.loadTeachers();

    // عرض مربع الحوار
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: adminCubit, // استخدام نفس الـ cubit من الشاشة الأصلية
          child: Builder(
            builder: (builderContext) => BlocBuilder<AdminCubit, AdminState>(
              builder: (builderContext, state) {
                if (state is AdminTeachersLoaded) {
                  return TeacherAssignmentDialog(
                    teachers: state.teachers,
                    currentTeacherId: circle.teacherId,
                    onAssign: (teacherId, teacherName) {
                      // استخدام adminCubit المُلتقط مسبقاً
                      adminCubit.assignTeacherToCircle(
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
            ),
          ),
        );
      },
    );
  }
}
