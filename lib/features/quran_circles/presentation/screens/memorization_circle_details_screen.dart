import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/utils/user_role.dart';
import '../../../../core/services/service_locator.dart';
import '../../data/models/memorization_circle_model.dart';
import '../../data/models/student_record.dart';
import '../cubit/memorization_circles_cubit.dart';
import '../cubit/memorization_circles_state.dart';
import 'memorization_circles/circle_details/widgets/circle_assignments_tab.dart';
import 'memorization_circles/circle_details/widgets/circle_students_tab.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Wrapper component to provide MemorizationCirclesCubit
class MemorizationCircleDetailsScreenWrapper extends StatelessWidget {
  final MemorizationCircle circle;
  final UserRole userRole;
  final String userId;

  const MemorizationCircleDetailsScreenWrapper({
    Key? key,
    required this.circle,
    required this.userRole,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MemorizationCirclesCubit>(
      create: (context) => sl<MemorizationCirclesCubit>(),
      child: MemorizationCircleDetailsScreen(
        circle: circle,
        userRole: userRole,
        userId: userId,
      ),
    );
  }
}

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

class _MemorizationCircleDetailsScreenState extends State<MemorizationCircleDetailsScreen> 
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  late MemorizationCircle _circle;
  bool _isDisposed = false;
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _circle = widget.circle;
  }

  @override
  void dispose() {
    _isDisposed = true;
    _tabController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _getCurrentUserPermissions() async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        return {'role': UserRole.student, 'userId': '', 'canManage': false};
      }

      final userData = await Supabase.instance.client
          .from('students')
          .select('id, is_admin, is_teacher')
          .eq('id', currentUser.id)
          .single();

      if (userData == null) {
        return {'role': UserRole.student, 'userId': currentUser.id, 'canManage': false};
      }

      UserRole role;
      if (userData['is_admin'] == true) {
        role = UserRole.admin;
      } else if (userData['is_teacher'] == true) {
        role = UserRole.teacher;
      } else {
        role = UserRole.student;
      }

      final bool canManage = role == UserRole.admin || 
          (_circle.teacherId != null && _circle.teacherId == currentUser.id);

      return {
        'role': role,
        'userId': currentUser.id,
        'canManage': canManage,
      };
    } catch (e) {
      return {'role': UserRole.student, 'userId': '', 'canManage': false};
    }
  }

  void _onEvaluationChanged(String studentId, int evaluation) {
    if (_isDisposed) return;

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
    if (_isDisposed) return;

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

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return WillPopScope(
      onWillPop: () async {
        // Return true to indicate changes were made
        Navigator.of(context).pop(true);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _circle.name,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.logoTeal,
          centerTitle: true,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: 'السور المقررة'),
              Tab(text: 'الطلاب'),
            ],
          ),
        ),
        body: BlocListener<MemorizationCirclesCubit, MemorizationCirclesState>(
          listener: (context, state) {
            if (state is MemorizationCirclesLoaded && !_isDisposed) {
              final updatedCircle = state.circles.firstWhere(
                (c) => c.id == _circle.id,
                orElse: () => _circle,
              );
              
              if (updatedCircle != _circle) {
                setState(() {
                  _circle = updatedCircle;
                });
              }
            }
          },
          child: TabBarView(
            controller: _tabController,
            children: [
              // تبويب السور المقررة
              CircleAssignmentsTab(
                key: const PageStorageKey<String>('assignments_tab'),
                assignments: _circle.assignments,
                isEditable: false,
                onAddSurah: null,
              ),
              
              // تبويب الطلاب
              FutureBuilder<Map<String, dynamic>>(
                future: _getCurrentUserPermissions(),
                builder: (context, snapshot) {
                  final permissions = snapshot.data ?? {
                    'role': UserRole.student,
                    'userId': '',
                    'canManage': false,
                  };
                  
                  return CircleStudentsTab(
                    key: const PageStorageKey<String>('students_tab'),
                    students: _circle.students,
                    teacherId: _circle.teacherId,
                    currentUserId: widget.userId,
                    onEvaluationChanged: permissions['canManage'] == true ? _onEvaluationChanged : null,
                    onAttendanceChanged: permissions['canManage'] == true ? _onAttendanceChanged : null,
                    onAddStudent: null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
