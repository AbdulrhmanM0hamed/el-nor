import 'package:noor_quran/features/admin/features/memorization_circles/presentation/cubit/circle_management_cubit.dart';
import 'package:noor_quran/features/admin/features/memorization_circles/presentation/cubit/circle_management_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/services/service_locator.dart';
import '../../data/models/memorization_circle_model.dart';
import '../../data/models/student_model.dart';
import '../user_management/presentation/cubit/admin_cubit.dart';
import '../user_management/presentation/cubit/admin_state.dart';
import 'widgets/circle_details/circle_info_card.dart';
import 'widgets/circle_details/students_section.dart';
import 'widgets/circle_details/teacher_section.dart';
import 'widgets/circle_details/surah_assignments_section.dart';
import '../../shared/loading_error_handler.dart';

// Wrapper لتوفير AdminCubit
class CircleDetailsScreenWrapper extends StatelessWidget {
  final MemorizationCircleModel circle;
  final CircleManagementCubit circleManagementCubit;
  final AdminCubit adminCubit;

  const CircleDetailsScreenWrapper({
    Key? key,
    required this.circle,
    required this.circleManagementCubit,
    required this.adminCubit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<CircleManagementCubit>.value(value: circleManagementCubit),
        BlocProvider<AdminCubit>.value(value: adminCubit),
      ],
      child: CircleDetailsScreen(circle: circle),
    );
  }
}

class CircleDetailsScreen extends StatefulWidget {
  final MemorizationCircleModel circle;

  const CircleDetailsScreen({Key? key, required this.circle}) : super(key: key);

  @override
  State<CircleDetailsScreen> createState() => _CircleDetailsScreenState();
}

class _CircleDetailsScreenState extends State<CircleDetailsScreen> {
  late CircleManagementCubit _circleManagementCubit;
  late AdminCubit _adminCubit;
  late MemorizationCircleModel _circle;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _circle = widget.circle;
    _circleManagementCubit = context.read<CircleManagementCubit>();
    _adminCubit = context.read<AdminCubit>();

    // Ensure we have the latest circle data

    // Load data when the screen is first shown, with a slight delay to allow build to complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCircleData();
    });
  }

  @override
  void dispose() {
    // When leaving this screen, ensure we reload circles in the parent screen
    // This prevents the issue where circles disappear when returning
    _circleManagementCubit.loadAllCircles();
    super.dispose();
  }

  // Update our local circle with the latest data from state

  Future<void> _loadCircleData() async {
    if (_isRefreshing) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // تحميل المعلمين أولاً
      final teachers = await _adminCubit.loadTeachers();

      // إذا وجدنا المعلم في القائمة، نقوم بتحديث اسم المعلم
      if (_circle.teacherId != null && _circle.teacherId!.isNotEmpty) {
        final matchingTeacher = teachers.firstWhere(
          (t) => t.id == _circle.teacherId,
          orElse: () => StudentModel(
            id: _circle.teacherId!,
            name: _circle.teacherName ?? '',
            email: '',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            isTeacher: true,
            isAdmin: false,
          ),
        );

        if (matchingTeacher.id == _circle.teacherId) {
          setState(() {
            _circle = _circle.copyWith(teacherName: matchingTeacher.name);
          });
        }
      }

      // تحميل بيانات الحلقة المحدثة
      await _circleManagementCubit.loadAllCircles();

      // انتظار حتى يتم تحديث حالة الحلقات
      await Future.delayed(const Duration(milliseconds: 100));

      // الحصول على الحلقة المحدثة من الحالة
      final updatedCircle = BlocProvider.of<CircleManagementCubit>(context)
              .state is AdminCirclesLoaded
          ? (BlocProvider.of<CircleManagementCubit>(context).state
                  as AdminCirclesLoaded)
              .circles
              .firstWhere(
                (c) => c.id == _circle.id,
                orElse: () => _circle,
              )
          : _circle;

      setState(() {
        _circle = updatedCircle;
        _isLoading = false;
      });

      // تحميل الطلاب إذا كان ضرورياً
      if (_circle.students.isEmpty && _circle.studentIds.isNotEmpty) {
        await _circleManagementCubit.loadCircleStudents(
            _circle.id, _circle.studentIds);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = e.toString();
        });
      }
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
              _isRefreshing = false;
              _errorMessage = null;
            });
          } else if (state is AdminTeacherAssigned) {
            if (state.circleId == _circle.id) {
              // Update the local circle data with the new teacher info
              setState(() {
                _circle = _circle.copyWith(
                  teacherId: state.teacherId,
                  teacherName: state.teacherName,
                );
              });
            }
          } else if (state is AdminError) {
            setState(() {
              _isLoading = false;
              _isRefreshing = false;
              _errorMessage = state.message;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: LoadingErrorHandler(
          isLoading: _isLoading && !_isRefreshing,
          errorMessage: _errorMessage,
          onRetry: _loadCircleData,
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isRefreshing)
                    Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: Center(
                        child: Text(
                          'جاري تحديث البيانات...',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ),
                  CircleInfoCard(circle: _circle),
                  SizedBox(height: 16.h),
                  _buildTeacherSection(),
                  SizedBox(height: 16.h),
                  SurahAssignmentsSection(circle: _circle),
                  SizedBox(height: 16.h),
                  StudentsSection(
                      circle: _circle, isLoading: _isLoading || _isRefreshing),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherSection() {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        // المعلمين المتاحين
        List<StudentModel> teachers = [];
        bool isLoadingTeachers = false;

        // فحص حالة التحميل
        if (state is AdminLoading) {
          isLoadingTeachers = true;
        }
        // فحص إذا كان لدينا معلمين
        else if (state is AdminTeachersLoaded) {
          teachers = state.teachers;

          // إذا لدينا معرف معلم ولكن لم نجده في القائمة
          if (_circle.teacherId != null &&
              _circle.teacherId!.isNotEmpty &&
              !teachers.any((t) => t.id == _circle.teacherId)) {
            _adminCubit.loadTeachers();
            isLoadingTeachers = true;
          }
        }

        return TeacherSection(
          circle: _circle,
          teachers: teachers,
          isLoading: isLoadingTeachers,
          onAssignTeacher:
              null, // تم إزالة القدرة على تغيير المعلم من شاشة التفاصيل
        );
      },
    );
  }

  // Removed _showAssignTeacherDialog and _buildTeacherSelectionContent methods
  // Teacher assignment should only be done from the edit circle dialog
}
