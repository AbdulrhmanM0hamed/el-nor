import 'package:beat_elslam/features/admin/presentation/widgets/shared/profile_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/services/service_locator.dart';
import '../../data/models/memorization_circle_model.dart';
import '../../data/models/student_model.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../widgets/circle_details/circle_info_card.dart';
import '../widgets/circle_details/students_section.dart';
import '../widgets/circle_details/teacher_section.dart';
import '../widgets/circle_details/surah_assignments_section.dart';
import '../widgets/shared/loading_error_handler.dart';

// Wrapper لتوفير AdminCubit
class CircleDetailsScreenWrapper extends StatelessWidget {
  final MemorizationCircleModel circle;

  const CircleDetailsScreenWrapper({
    Key? key,
    required this.circle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AdminCubit>(
      create: (context) => sl<AdminCubit>(),
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
  late AdminCubit _adminCubit;
  late MemorizationCircleModel _circle;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _circle = widget.circle;
    _adminCubit = context.read<AdminCubit>();
    
    // Ensure we have the latest circle data
    print('CircleDetailsScreen: Initializing with circle ID: ${_circle.id}');
    print('CircleDetailsScreen: Initial teacher ID: ${_circle.teacherId}, name: ${_circle.teacherName}');
    
    // Load data when the screen is first shown, with a slight delay to allow build to complete
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCircleData();
    });
  }
  
  @override
  void dispose() {
    // When leaving this screen, ensure we reload circles in the parent screen
    // This prevents the issue where circles disappear when returning
    _adminCubit.loadAllCircles();
    super.dispose();
  }
  
  // Update our local circle with the latest data from state
  void _updateCircleFromState() {
    final currentState = _adminCubit.state;
    
    // First check if we have teacher data available
    StudentModel? matchingTeacher;
    if (currentState is AdminTeachersLoaded && 
        _circle.teacherId != null && 
        _circle.teacherId!.isNotEmpty) {
      
      // Try to find the teacher by ID
      final teachers = currentState.teachers;
      final matchingTeachers = teachers.where((t) => t.id == _circle.teacherId).toList();
      if (matchingTeachers.isNotEmpty) {
        matchingTeacher = matchingTeachers.first;
        print('CircleDetailsScreen: Found matching teacher in state: ${matchingTeacher.name}');
      }
    }
    
    // Then check for updated circle data
    if (currentState is AdminCirclesLoaded) {
      // Find our circle in the updated list
      final updatedCircle = currentState.circles.firstWhere(
        (c) => c.id == _circle.id,
        orElse: () => _circle,
      );
      
      // If we found a matching teacher but the circle doesn't have the teacher name, update it
      if (matchingTeacher != null && 
          (updatedCircle.teacherName == null || updatedCircle.teacherName!.isEmpty)) {
        // Create a new circle with the teacher name
        final circleWithTeacherName = updatedCircle.copyWith(teacherName: matchingTeacher.name);
        print('CircleDetailsScreen: Adding teacher name ${matchingTeacher.name} to circle');
        
        setState(() {
          _circle = circleWithTeacherName;
        });
        return;
      }
      
      // Otherwise just update with the circle from state if it's different
      if (updatedCircle != _circle) {
        print('CircleDetailsScreen: Updating circle data from state');
        print('CircleDetailsScreen: Circle updated - Teacher ID: ${updatedCircle.teacherId}, Teacher Name: ${updatedCircle.teacherName}');
        setState(() {
          _circle = updatedCircle;
        });
      }
    }
  }

  Future<void> _loadCircleData() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // تحميل المعلمين أولاً
      final teachers = await _adminCubit.loadTeachers();
      print('CircleDetailsScreen: ${teachers.length} teachers loaded initially');
      
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
          print('CircleDetailsScreen: Found matching teacher: ${matchingTeacher.name}');
          setState(() {
            _circle = _circle.copyWith(teacherName: matchingTeacher.name);
          });
        }
      }
      
      // تحميل بيانات الحلقة المحدثة
      final circles = await _adminCubit.loadAllCircles();
      final updatedCircle = circles.firstWhere(
        (c) => c.id == _circle.id,
        orElse: () => _circle,
      );
      
      setState(() {
        _circle = updatedCircle;
        _isLoading = false;
      });
      
      // تحميل الطلاب إذا كان ضرورياً
      if (_circle.students.isEmpty && _circle.studentIds.isNotEmpty) {
        await _adminCubit.loadCircleStudents(_circle.id, _circle.studentIds);
      }
    } catch (e) {
      print('CircleDetailsScreen: Error loading data: $e');
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
            
            print('CircleDetailsScreen: Circle updated - Teacher ID: ${updatedCircle.teacherId}, Teacher Name: ${updatedCircle.teacherName}');
            
            // Update the circle data and loading state
            setState(() {
              _circle = updatedCircle;
              _isLoading = false;
              _isRefreshing = false;
              _errorMessage = null;
            });
          } else if (state is AdminTeacherAssigned) {
            if (state.circleId == _circle.id) {
              print('CircleDetailsScreen: Teacher assigned - ID: ${state.teacherId}, Name: ${state.teacherName}');
              
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
                  StudentsSection(circle: _circle, isLoading: _isLoading || _isRefreshing),
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
          print('CircleDetailsScreen: ${teachers.length} teachers loaded');
          print('CircleDetailsScreen: Circle teacher ID: ${_circle.teacherId}');
          print('CircleDetailsScreen: Available teacher IDs: ${teachers.map((t) => t.id).join(', ')}');
          
          // إذا لدينا معرف معلم ولكن لم نجده في القائمة
          if (_circle.teacherId != null && 
              _circle.teacherId!.isNotEmpty && 
              !teachers.any((t) => t.id == _circle.teacherId)) {
            print('CircleDetailsScreen: Teacher with ID ${_circle.teacherId} not found in loaded teachers');
            // تحميل المعلمين مرة أخرى
            _adminCubit.loadTeachers();
            isLoadingTeachers = true;
          }
        }

        return TeacherSection(
          circle: _circle,
          teachers: teachers,
          isLoading: isLoadingTeachers,
          onAssignTeacher: null, // تم إزالة القدرة على تغيير المعلم من شاشة التفاصيل
        );
      },
    );
  }

  // Removed _showAssignTeacherDialog and _buildTeacherSelectionContent methods
  // Teacher assignment should only be done from the edit circle dialog
}