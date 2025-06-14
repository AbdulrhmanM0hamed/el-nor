import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/theme/app_colors.dart';
import '../../data/models/memorization_circle_model.dart';
import '../../data/models/student_model.dart';
import '../../shared/loading_error_handler.dart';
import '../memorization_circles/presentation/cubit/circle_management_cubit.dart';
import '../memorization_circles/presentation/cubit/circle_management_state.dart';
import '../user_management/presentation/cubit/admin_cubit.dart';
import '../user_management/presentation/cubit/admin_state.dart';
import 'widgets/circle_details/circle_info_card.dart';
import 'widgets/circle_details/students_section.dart';
import 'widgets/circle_details/surah_assignments_section.dart';
import 'widgets/circle_details/teacher_section.dart';

// Wrapper to provide AdminCubit
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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCircleData();
    });
  }

  @override
  void dispose() {
    _circleManagementCubit.loadAllCircles();
    super.dispose();
  }

  Future<void> _loadCircleData() async {
    if (_isRefreshing) return;

    setState(() {
      _isLoading = true;
      _isRefreshing = false; // Reset refresh indicator
      _errorMessage = null;
    });

    try {
      // Load all necessary data in parallel
      await Future.wait([
        _adminCubit.loadTeachers(),
        _circleManagementCubit.loadAllCircles(),
      ]);

      // Get the latest state after loading
      final circleState = _circleManagementCubit.state;
      if (circleState is AdminCirclesLoaded) {
        final updatedCircle = circleState.circles.firstWhere(
          (c) => c.id == _circle.id,
          orElse: () => _circle, // fallback to current circle if not found
        );

        setState(() {
          _circle = updatedCircle;
        });

        // Load students if needed
        if (_circle.students.isEmpty && _circle.studentIds.isNotEmpty) {
          await _circleManagementCubit.loadCircleStudents(
              _circle.id, _circle.studentIds);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    double responsive(double size) => size * screenWidth / 375;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تفاصيل حلقة ${_circle.name}',
          style: TextStyle(
            fontSize: responsive(18),
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.logoTeal,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: BlocListener<CircleManagementCubit, AdminState>(
        listener: (context, state) {
          if (state is AdminCirclesLoaded) {
            final updatedCircle = state.circles.firstWhere(
              (c) => c.id == widget.circle.id,
              orElse: () => _circle,
            );
            if (mounted) {
              setState(() {
                _circle = updatedCircle;
              });
            }
          }
        },
        child: LoadingErrorHandler(
          isLoading: _isLoading,
          errorMessage: _errorMessage,
          onRetry: _loadCircleData,
          child: RefreshIndicator(
            onRefresh: _loadCircleData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.all(responsive(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CircleInfoCard(circle: _circle),
                  SizedBox(height: responsive(20)),
                  BlocBuilder<AdminCubit, AdminState>(
                    builder: (context, state) {
                      List<StudentModel> teachers = [];
                      bool isLoadingTeachers = false;

                      if (state is AdminLoading) {
                        isLoadingTeachers = true;
                      } else if (state is AdminTeachersLoaded) {
                        teachers = state.teachers;
                      }

                      return TeacherSection(
                        circle: _circle,
                        teachers: teachers,
                        isLoading: isLoadingTeachers,
                      );
                    },
                  ),
                  SizedBox(height: responsive(20)),
                  SurahAssignmentsSection(circle: _circle),
                  SizedBox(height: responsive(20)),
                  StudentsSection(
                    circle: _circle,
                    isLoading: _isLoading || _isRefreshing,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
