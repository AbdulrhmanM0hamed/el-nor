import 'package:noor_quran/features/quran_circles/data/repositories/circle_details_repository.dart';
import 'package:noor_quran/features/quran_circles/presentation/screens/memorization_circles/circle_details/widgets/circle_learning_plan_tab.dart';
import 'package:flutter/material.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/utils/user_role.dart' as core;
import '../../../../core/services/service_locator.dart';
import '../../data/models/memorization_circle_model.dart';
import '../cubit/circle_details_cubit.dart';
import '../cubit/circle_details_state.dart';
import 'memorization_circles/circle_details/widgets/circle_assignments_tab.dart';
import 'memorization_circles/circle_details/widgets/circle_students_tab.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Helper function to convert between UserRole types
UserRole _convertUserRole(core.UserRole role) {
  switch (role) {
    case core.UserRole.admin:
      return UserRole.admin;
    case core.UserRole.teacher:
      return UserRole.teacher;
    case core.UserRole.student:
      return UserRole.student;
  }
}

// Wrapper component to provide CircleDetailsCubit
class MemorizationCircleDetailsScreenWrapper extends StatelessWidget {
  final MemorizationCircle circle;
  final core.UserRole userRole;
  final String userId;

  const MemorizationCircleDetailsScreenWrapper({
    Key? key,
    required this.circle,
    required this.userRole,
    required this.userId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CircleDetailsCubit>(
      create: (context) => CircleDetailsCubit(
        repository: sl<CircleDetailsRepository>(),
        initialCircle: circle,
        userId: userId,
        userRole: _convertUserRole(userRole),
      ),
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
  final core.UserRole userRole;
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
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (didPop) return;
        final cubitState = context.read<CircleDetailsCubit>().state;
        final result = (cubitState is CircleDetailsLoaded)
            ? cubitState.circle
            : widget.circle;
        Navigator.of(context).pop(result);
      },
      child: BlocBuilder<CircleDetailsCubit, CircleDetailsState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                state is CircleDetailsLoaded ? state.circle.name : widget.circle.name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18 * (MediaQuery.of(context).size.width / 375),
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
                labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 14 * (MediaQuery.of(context).size.width / 375),
                      fontWeight: FontWeight.bold,
                    ),
                unselectedLabelStyle:
                    Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 14 * (MediaQuery.of(context).size.width / 375),
                        ),
                tabs: const [
                  Tab(text: 'السور المقررة'),
                  Tab(text: 'الطلاب'),
                  Tab(text: 'خطة التعلم'),
                ],
              ),
            ),
            body: state is CircleDetailsLoading
                ? const Center(child: CircularProgressIndicator())
                : state is CircleDetailsError
                    ? Center(child: Text(state.message))
                    : state is CircleDetailsLoaded
                        ? TabBarView(
                            controller: _tabController,
                            physics: const NeverScrollableScrollPhysics(), // منع التنقل بالسحب
                            children: [
                              // تبويب السور المقررة
                              CircleAssignmentsTab(
                                key: const PageStorageKey<String>('assignments_tab'),
                                assignments: state.circle.assignments,
                                isEditable: false,
                                onAddSurah: null,
                              ),
                              
                              // تبويب الطلاب
                              CircleStudentsTab(
                                key: const PageStorageKey<String>('students_tab'),
                                students: state.circle.students,
                                teacherId: state.circle.teacherId ?? '',
                                currentUserId: state.userId,
                                onEvaluationChanged: state.canManage 
                                    ? (studentId, rating) => context
                                        .read<CircleDetailsCubit>()
                                        .updateStudentEvaluation(studentId, rating)
                                    : null,
                                onEvaluationDelete: state.canManage
                                    ? (studentId, idx) => context
                                        .read<CircleDetailsCubit>()
                                        .deleteStudentEvaluation(studentId, idx)
                                    : null,
                                onAttendanceChanged: state.canManage
                                    ? (studentId, isPresent) => context
                                        .read<CircleDetailsCubit>()
                                        .updateStudentAttendance(studentId, isPresent)
                                    : null,
                                onAddStudent: null,
                              ),
                                CircleLearningPlanTab(
                                key: const PageStorageKey<String>('learning_plan_tab'),
                                learningPlanUrl: state.circle.learningPlanUrl,
                              ),
                            ],
                          )
                        : const SizedBox(),
          );
        },
      ),
    );
  }
}
