import 'package:beat_elslam/features/admin/presentation/widgets/circle_details/teacher_section_fixed.dart';
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
import '../widgets/circle_details/teacher_section_improved.dart';
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
  bool _isLoading = false;
  bool _isRefreshing = false;
  String? _errorMessage;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    _adminCubit = context.read<AdminCubit>();
    _circle = widget.circle;
    // Load data with a slight delay to allow the UI to build first
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

  Future<void> _loadCircleData() async {
    if (_isRefreshing) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // Always load teachers first to ensure they're available
      print('CircleDetailsScreen: Loading teachers');
      await _adminCubit.loadTeachers();
      
      // Then load the latest circle data to ensure it's up to date
      print('CircleDetailsScreen: Loading all circles');
      await _adminCubit.loadAllCircles();
      
      // Only load students if needed
      if (_circle.students.isEmpty && _circle.studentIds.isNotEmpty) {
        print('CircleDetailsScreen: Loading students for circle ${_circle.id}');
        // Load students directly for this specific circle
        await _adminCubit.loadCircleStudents(_circle.id, _circle.studentIds);
      }
      
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
  
  // Pull-to-refresh implementation
  Future<void> _refreshData() async {
    if (_isLoading) return;
    
    setState(() {
      _isRefreshing = true;
    });
    
    try {
      // Force reload teachers to get fresh data
      print('CircleDetailsScreen: Refreshing teachers');
      await _adminCubit.reloadTeachers();
      
      // Then reload all circles
      print('CircleDetailsScreen: Refreshing all circles');
      await _adminCubit.loadAllCircles();
      
      // Reload students if we have student IDs
      if (_circle.studentIds.isNotEmpty) {
        print('CircleDetailsScreen: Refreshing students for circle ${_circle.id}');
        await _adminCubit.loadCircleStudents(_circle.id, _circle.studentIds);
      }
      
      if (mounted) {
        setState(() {
          _isRefreshing = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      print('CircleDetailsScreen: Error refreshing data: $e');
      if (mounted) {
        setState(() {
          _isRefreshing = false;
          _errorMessage = e.toString();
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ أثناء تحديث البيانات: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _refreshIndicatorKey.currentState?.show();
            },
            tooltip: 'تحديث البيانات',
          ),
        ],
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
          child: RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: _refreshData,
            color: AppColors.logoTeal,
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
      ),
    );
  }

  Widget _buildTeacherSection() {
    return BlocBuilder<AdminCubit, AdminState>(
      builder: (context, state) {
        List<TeacherModel> teachers = [];
        if (state is AdminTeachersLoaded) {
          teachers = state.teachers;
          print('CircleDetailsScreen: ${teachers.length} teachers loaded');
        }

        return TeacherSection(
          circle: _circle,
          teachers: teachers,
          onAssignTeacher: _showAssignTeacherDialog,
        );
      },
    );
  }

  void _showAssignTeacherDialog(String circleId, String circleName) {
    print('CircleDetailsScreen: Showing assign teacher dialog for circle: $circleId, $circleName');
    
    // Capture the AdminCubit before showing the dialog
    final adminCubit = context.read<AdminCubit>();
    
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider<AdminCubit>.value(
          value: adminCubit,
          child: AlertDialog(
            title: Text('تعيين معلم لحلقة $circleName'),
            content: BlocBuilder<AdminCubit, AdminState>(
              builder: (context, state) {
                if (state is AdminTeachersLoaded) {
                  final teachers = state.teachers;
                  
                  if (teachers.isEmpty) {
                    return const Text('لا يوجد معلمين متاحين');
                  }
                  
                  return SizedBox(
                    width: double.maxFinite,
                    height: 300.h,
                    child: ListView.builder(
                      itemCount: teachers.length,
                      itemBuilder: (context, index) {
                        final teacher = teachers[index];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.logoTeal.withOpacity(0.2),
                            child: Text(
                              teacher.name.isNotEmpty ? teacher.name[0].toUpperCase() : '?',
                              style: TextStyle(
                                color: AppColors.logoTeal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(teacher.name),
                          subtitle: Text(teacher.email),
                          onTap: () {
                            // Assign the selected teacher to the circle
                            adminCubit.assignTeacherToCircle(
                              circleId: circleId,
                              teacherId: teacher.id,
                              teacherName: teacher.name,
                            );
                            Navigator.pop(dialogContext);
                          },
                        );
                      },
                    ),
                  );
                } else if (state is AdminLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AdminError) {
                  return Text('خطأ: ${state.message}');
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('إلغاء'),
              ),
            ],
          ),
        );
      },
    );
  }
}
