import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/services/service_locator.dart';
import '../../data/models/memorization_circle_model.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../widgets/circle_management/circles_list.dart';
import 'circle_details_screen.dart';
import '../widgets/circle_form_dialog.dart';
// Removed unused import

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
      body: BlocConsumer<AdminCubit, AdminState>(
        listener: (context, state) {
          if (state is AdminError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AdminCircleCreated || state is AdminCircleUpdated) {
            // Refresh the circles list after successful create/update
            context.read<AdminCubit>().loadAllCircles(forceRefresh: true);
          }
        },
        builder: (context, state) {
          return CirclesList(
            circles: state is AdminCirclesLoaded ? state.circles : [],
            isLoading: state is AdminLoading,
            errorMessage: state is AdminError ? state.message : null,
            onRetry: () => context.read<AdminCubit>().loadAllCircles(),
            onCircleTap: (circle) => _showCircleDetailsDialog(circle),
            onEditCircle: (circle) => _showEditCircleDialog(circle),
            onDeleteCircle: (circle) => _showDeleteConfirmationDialog(circle),
          );
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

  void _showAddCircleDialog() async {
    // Obtener la referencia al cubit
    final adminCubit = context.read<AdminCubit>();

    // Cargar profesores y estudiantes antes de mostrar el diálogo
    final teachers = await adminCubit.loadTeachers();
    final students = await adminCubit.loadStudents();

    if (!mounted) return; // Verificar si el widget todavía está montado

    final result = await showDialog(
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

    // Refresh circles list if dialog was saved successfully
    if (result == true) {
      adminCubit.loadAllCircles();
    }
  }

  void _showEditCircleDialog(MemorizationCircleModel circle) async {
    // Obtener la referencia al cubit
    final adminCubit = context.read<AdminCubit>();

    // Cargar profesores y estudiantes antes de mostrar el diálogo
    final teachers = await adminCubit.loadTeachers();
    final students = await adminCubit.loadStudents();

    if (!mounted) return; // Verificar si el widget todavía está montado

    // Debug print to confirm teacher data is being passed
    print('CircleManagementScreen: Showing edit dialog for circle ${circle.id}');
    print('CircleManagementScreen: Teacher ID: ${circle.teacherId}, Teacher Name: ${circle.teacherName}');

    final result = await showDialog(
      context: context,
      builder: (context) => CircleFormDialog(
        title: 'تعديل حلقة ${circle.name}',
        initialName: circle.name,
        initialDescription: circle.description,
        initialDate: circle.startDate,
        initialTeacherId: circle.teacherId,
        initialTeacherName: circle.teacherName,
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

    // Refresh circles list if dialog was saved successfully
    if (result == true) {
      adminCubit.loadAllCircles();
    }
  }

  void _showDeleteConfirmationDialog(MemorizationCircleModel circle) {
    // Get cubit reference before showing dialog
    final adminCubit = context.read<AdminCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف حلقة "${circle.name}"؟'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
            },
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              adminCubit.deleteCircle(circle.id);
              Navigator.of(dialogContext).pop();
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
    
    // الانتقال إلى صفحة تفاصيل الحلقة مع الـ wrapper
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CircleDetailsScreenWrapper(circle: circle),
      ),
    );
  }

  // تم إزالة _loadTeacherDetails لأنه غير مستخدم
  // تم إزالة _formatDate و _buildInfoRow لأنهما غير مستخدمين بعد نقل الكود إلى صفحة تفاصيل الحلقة
  // تم إزالة _showAssignTeacherDialog لأنه غير مستخدم بعد استخدام CirclesList
}
