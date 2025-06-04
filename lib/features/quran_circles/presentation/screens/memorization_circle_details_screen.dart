import 'package:flutter/material.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/utils/user_role.dart';
import '../../data/models/memorization_circle_model.dart';
import '../../data/models/student_record.dart';
import '../widgets/circle_students_tab.dart';
import '../widgets/circle_assignments_tab.dart';
import '../cubit/memorization_circles_cubit.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MemorizationCircleDetailsScreen extends StatefulWidget {
  final MemorizationCircle circle;
  final UserRole userRole;
  final String userId;

  const MemorizationCircleDetailsScreen({
    Key? key,
    required this.circle,
    required this.userRole,
    required this.userId,
  }) : super(key: key);

  @override
  State<MemorizationCircleDetailsScreen> createState() => _MemorizationCircleDetailsScreenState();
}

class _MemorizationCircleDetailsScreenState extends State<MemorizationCircleDetailsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late MemorizationCircle _circle;
  String? _currentUserId;
  
  // Helpers for user permissions
  bool get _canManageCircle => 
    widget.userRole == UserRole.admin || 
    (_circle.teacherId != null && _circle.teacherId == _currentUserId);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _circle = widget.circle;
    _updateCurrentUserId();
  }

  void _updateCurrentUserId() {
    final authCubit = context.read<AuthCubit>();
    setState(() {
      _currentUserId = authCubit.currentUser?.id;
    });
    print('Circle Details: Teacher ID = ${_circle.teacherId}, User ID = $_currentUserId');
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          setState(() {
            _currentUserId = state.user.id;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _circle.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (_circle.teacherId == _currentUserId)
                const Text(
                  'حلقتي',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.normal,
                  ),
                ),
            ],
          ),
          backgroundColor: _circle.isExam ? AppColors.logoOrange : AppColors.logoTeal,
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(text: 'السور المقررة'),
              Tab(text: 'الطلاب'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // تبويب السور المقررة
            CircleAssignmentsTab(
              assignments: _circle.assignments,
              isEditable: _canManageCircle,
              onAddSurah: _canManageCircle ? _showAddSurahDialog : null,
            ),
            
            // تبويب الطلاب
            CircleStudentsTab(
              students: _circle.students,
              teacherId: _circle.teacherId ?? '',
              currentUserId: _currentUserId ?? '',
              onEvaluationChanged: _canManageCircle && _circle.teacherId != null ? _onEvaluationChanged : null,
              onAttendanceChanged: _canManageCircle && _circle.teacherId != null ? _onAttendanceChanged : null,
              onAddStudent: _canManageCircle ? _showAddStudentDialog : null,
            ),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    if (!_canManageCircle) return null;

    final currentTab = _tabController.index;
    
    if (currentTab == 0) {
      return FloatingActionButton(
        backgroundColor: AppColors.logoTeal,
        child: const Icon(Icons.add),
        onPressed: _showAddSurahDialog,
        tooltip: 'إضافة سورة',
      );
    } else if (currentTab == 1) {
      return FloatingActionButton(
        backgroundColor: AppColors.logoTeal,
        child: const Icon(Icons.person_add),
        onPressed: _showAddStudentDialog,
        tooltip: 'إضافة طالب',
      );
    }
    
    return null;
  }

  void _onEvaluationChanged(String studentId, int evaluation) {
    final updatedStudents = List<StudentRecord>.from(_circle.students);
    final studentIndex = updatedStudents.indexWhere((s) => s.studentId == studentId);
    
    if (studentIndex != -1) {
      final student = updatedStudents[studentIndex];
      final now = DateTime.now();
      
      final evaluations = List<EvaluationRecord>.from(student.evaluations)
        ..add(EvaluationRecord(
          date: now,
          rating: evaluation,
        ));
      
      updatedStudents[studentIndex] = StudentRecord(
        studentId: student.studentId,
        name: student.name,
        profileImageUrl: student.profileImageUrl,
        evaluations: evaluations,
        attendance: student.attendance,
      );

      setState(() {
        _circle = MemorizationCircle(
          id: _circle.id,
          name: _circle.name,
          description: _circle.description,
          teacherId: _circle.teacherId,
          teacherName: _circle.teacherName,
          startDate: _circle.startDate,
          endDate: _circle.endDate,
          isExam: _circle.isExam,
          students: updatedStudents,
          assignments: _circle.assignments,
          studentIds: _circle.studentIds,
          status: _circle.status,
          createdAt: _circle.createdAt,
          updatedAt: DateTime.now(),
        );
      });

      // تحديث البيانات في قاعدة البيانات
      context.read<MemorizationCirclesCubit>().updateStudentEvaluation(
        _circle.id,
        studentId,
        evaluation,
      );
    }
  }

  void _onAttendanceChanged(String studentId, bool isPresent) {
    final updatedStudents = List<StudentRecord>.from(_circle.students);
    final studentIndex = updatedStudents.indexWhere((s) => s.studentId == studentId);
    
    if (studentIndex != -1) {
      final student = updatedStudents[studentIndex];
      final now = DateTime.now();
      
      final attendance = List<AttendanceRecord>.from(student.attendance)
        ..add(AttendanceRecord(
          date: now,
          isPresent: isPresent,
        ));
      
      updatedStudents[studentIndex] = StudentRecord(
        studentId: student.studentId,
        name: student.name,
        profileImageUrl: student.profileImageUrl,
        evaluations: student.evaluations,
        attendance: attendance,
      );

      setState(() {
        _circle = MemorizationCircle(
          id: _circle.id,
          name: _circle.name,
          description: _circle.description,
          teacherId: _circle.teacherId,
          teacherName: _circle.teacherName,
          startDate: _circle.startDate,
          endDate: _circle.endDate,
          isExam: _circle.isExam,
          students: updatedStudents,
          assignments: _circle.assignments,
          studentIds: _circle.studentIds,
          status: _circle.status,
          createdAt: _circle.createdAt,
          updatedAt: DateTime.now(),
        );
      });

      // تحديث البيانات في قاعدة البيانات
      context.read<MemorizationCirclesCubit>().updateStudentAttendance(
        _circle.id,
        studentId,
        isPresent,
      );
    }
  }

  void _showAddSurahDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم إضافة ميزة إضافة سورة قريباً'),
        backgroundColor: AppColors.logoTeal,
      ),
    );
  }

  void _showAddStudentDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم إضافة ميزة إضافة طالب قريباً'),
        backgroundColor: AppColors.logoTeal,
      ),
    );
  }
}
