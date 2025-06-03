import 'package:beat_elslam/features/admin/presentation/widgets/shared/profile_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/utils/theme/app_colors.dart';
import '../../data/models/memorization_circle_model.dart';
import '../../data/models/teacher_model.dart';
import '../cubit/admin_cubit.dart';
import '../cubit/admin_state.dart';
import '../widgets/circle_details/circle_info_card.dart';
import '../widgets/circle_details/students_section.dart';
import '../widgets/circle_details/teacher_section_fixed.dart';
import '../widgets/shared/loading_error_handler.dart';

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
    TeacherModel? matchingTeacher;
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
      // First, check if we have a valid teacher ID but no teacher data
      final bool needsTeacherData = _circle.teacherId != null && 
                                   _circle.teacherId!.isNotEmpty && 
                                   (_circle.teacherName == null || _circle.teacherName!.isEmpty);
      
      if (needsTeacherData) {
        print('CircleDetailsScreen: Circle has teacherId but no teacherName, prioritizing teacher data loading');
      }
      
      // Always load teachers first to ensure they're available
      print('CircleDetailsScreen: Loading teachers');
      await _adminCubit.loadTeachers();
      
      // Short delay to allow state to update
      await Future.delayed(const Duration(milliseconds: 300));
      
      // If the current state has teachers, try to find the teacher for this circle
      final currentState = _adminCubit.state;
      if (currentState is AdminTeachersLoaded && 
          _circle.teacherId != null && 
          _circle.teacherId!.isNotEmpty) {
        
        final teachers = currentState.teachers;
        print('CircleDetailsScreen: ${teachers.length} teachers loaded, looking for teacher ${_circle.teacherId}');
        
        // Try to find the teacher by ID
        final matchingTeachers = teachers.where((t) => t.id == _circle.teacherId).toList();
        if (matchingTeachers.isNotEmpty) {
          final teacher = matchingTeachers.first;
          print('CircleDetailsScreen: Found matching teacher: ${teacher.name}');
          
          // Update the circle with the teacher name if it's missing
          if (_circle.teacherName == null || _circle.teacherName!.isEmpty) {
            setState(() {
              _circle = _circle.copyWith(teacherName: teacher.name);
            });
            print('CircleDetailsScreen: Updated circle with teacher name: ${teacher.name}');
          }
        } else {
          print('CircleDetailsScreen: No matching teacher found for ID: ${_circle.teacherId}');
        }
      }
      
      // Then load the latest circle data to ensure it's up to date
      print('CircleDetailsScreen: Loading all circles');
      await _adminCubit.loadAllCircles();
      
      // Update our circle with the latest data
      _updateCircleFromState();
      
      // Only load students if needed
      if (_circle.students.isEmpty && _circle.studentIds.isNotEmpty) {
        print('CircleDetailsScreen: Loading students for circle ${_circle.id}');
        // Load students directly for this specific circle
        await _adminCubit.loadCircleStudents(_circle.id, _circle.studentIds);
      }
      
      // Final update of circle data
      _updateCircleFromState();
      print('CircleDetailsScreen: Circle updated - Teacher ID: ${_circle.teacherId}, Teacher Name: ${_circle.teacherName}');
      
      // Ensure we're not stuck in a loading state even if teacher data is missing
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        // Force a refresh of the teacher section
        if (_circle.teacherId != null && _circle.teacherId!.isNotEmpty) {
          print('CircleDetailsScreen: Forcing refresh of teacher data');
          _adminCubit.loadTeachers(); // Non-awaited to prevent blocking UI
        }
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
        // Determine if we should show loading state
        bool isLoadingTeachers = false;
        if (state is AdminLoading) {
          isLoadingTeachers = true;
        }
        
        // Get the list of teachers if available
        List<TeacherModel> teachers = [];
        if (state is AdminTeachersLoaded) {
          teachers = state.teachers;
          print('CircleDetailsScreen: TeacherSection has ${teachers.length} teachers available');
        }
        
        // If we have a teacher ID but no teachers loaded, show loading
        if (_circle.teacherId != null && 
            _circle.teacherId!.isNotEmpty && 
            teachers.isEmpty) {
          isLoadingTeachers = true;
          print('CircleDetailsScreen: Has teacher ID but no teachers loaded, showing loading');
        }
        
        return TeacherSection(
          circle: _circle,
          teachers: teachers,
          isLoading: isLoadingTeachers,
          onAssignTeacher: null, // Removed ability to change teacher from details screen
        );
      },
    );
  }

  // Removed _showAssignTeacherDialog and _buildTeacherSelectionContent methods
  // Teacher assignment should only be done from the edit circle dialog
    }
  