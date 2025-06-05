import 'package:beat_elslam/features/quran_circles/presentation/screens/memorization_circle_details_screen.dart';
import 'package:beat_elslam/features/quran_circles/presentation/screens/memorization_circles/widgets/circles_list_view.dart';
import 'package:beat_elslam/features/quran_circles/presentation/screens/memorization_circles/widgets/empty_circles_view.dart';
import 'package:beat_elslam/features/quran_circles/presentation/screens/memorization_circles/widgets/error_circles_view.dart';
import 'package:beat_elslam/features/quran_circles/presentation/screens/memorization_circles/widgets/loading_circles_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/theme/app_colors.dart';
import '../../../../../core/utils/user_role.dart';
import '../../../data/models/memorization_circle_model.dart';
import '../../cubit/memorization_circles_cubit.dart';
import '../../../../auth/presentation/cubit/auth_cubit.dart';


class MemorizationCirclesScreen extends StatefulWidget {
  const MemorizationCirclesScreen({Key? key}) : super(key: key);

  @override
  State<MemorizationCirclesScreen> createState() => _MemorizationCirclesScreenState();
}

class _MemorizationCirclesScreenState extends State<MemorizationCirclesScreen> {
  late UserRole _userRole = UserRole.student;
  late String _userId = '';
  bool _isTeacherCirclesOnly = false;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    final currentUser = context.read<AuthCubit>().currentUser;
    if (currentUser != null) {
      setState(() {
        _userId = currentUser.id;
        _userRole = currentUser.isAdmin 
          ? UserRole.admin 
          : currentUser.isTeacher 
            ? UserRole.teacher 
            : UserRole.student;
      });
    }
    _loadCircles();
  }

  void _loadCircles() {
    context.read<MemorizationCirclesCubit>().loadMemorizationCircles();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthCubit>().currentUser;
    if (currentUser != null && _userId != currentUser.id) {
      setState(() {
        _userId = currentUser.id;
        _userRole = currentUser.isAdmin 
          ? UserRole.admin 
          : currentUser.isTeacher 
            ? UserRole.teacher 
            : UserRole.student;
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getScreenTitle(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.logoTeal,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          if (_userRole == UserRole.teacher)
            IconButton(
              icon: Icon(
                _isTeacherCirclesOnly ? Icons.person : Icons.people,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isTeacherCirclesOnly = !_isTeacherCirclesOnly;
                });
                _loadCircles();
              },
              tooltip: _isTeacherCirclesOnly ? 'عرض كل الحلقات' : 'حلقاتي فقط',
            ),
        ],
      ),
      body: BlocBuilder<MemorizationCirclesCubit, MemorizationCirclesState>(
        builder: (context, state) {
          if (state is MemorizationCirclesLoading) {
            return const LoadingCirclesView();
          }
          
          if (state is MemorizationCirclesLoaded) {
            final circles = _filterCirclesByRole(state.circles);
            
            if (circles.isEmpty) {
              return const EmptyCirclesView();
            }
            
            return CirclesListView(
              circles: circles,
              userRole: _userRole,
              userId: _userId,
              onRefresh: _loadCircles,
              onCircleTap: (circle) => _navigateToCircleDetails(context, circle),
            );
          }
          
          if (state is MemorizationCirclesError) {
            return ErrorCirclesView(
              message: state.message,
              onRetry: _loadCircles,
            );
          }
          
          return const EmptyCirclesView();
        },
      ),
      floatingActionButton: _userRole == UserRole.admin
          ? FloatingActionButton(
              backgroundColor: AppColors.logoTeal,
              child: const Icon(Icons.add),
              onPressed: _showAddCircleDialog,
            )
          : null,
    );
  }

  String _getScreenTitle() {
    switch (_userRole) {
      case UserRole.admin:
        return 'إدارة حلقات التحفيظ';
      case UserRole.teacher:
        return 'حلقات التحفيظ';
      case UserRole.student:
        return 'حلقاتي';
      default:
        return 'حلقات التحفيظ';
    }
  }

  List<MemorizationCircle> _filterCirclesByRole(List<MemorizationCircle> circles) {
    if (_userId.isEmpty) return circles;
    
    switch (_userRole) {
      case UserRole.admin:
        return circles;
      case UserRole.teacher:
        if (_isTeacherCirclesOnly) {
          return circles.where((circle) => circle.teacherId == _userId).toList();
        }
        return circles;
      case UserRole.student:
        return circles.where((circle) => 
          circle.studentIds.contains(_userId) ||
          circle.teacherId == _userId
        ).toList();
      default:
        return circles;
    }
  }

  void _showAddCircleDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم إضافة هذه الميزة قريباً'),
        backgroundColor: AppColors.logoTeal,
      ),
    );
  }

  void _navigateToCircleDetails(BuildContext context, MemorizationCircle circle) {
    final authCubit = context.read<AuthCubit>();
    final memorizationCirclesCubit = context.read<MemorizationCirclesCubit>();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: authCubit),
            BlocProvider.value(value: memorizationCirclesCubit),
          ],
          child: MemorizationCircleDetailsScreen(
            circle: circle,
            userRole: _userRole,
            userId: _userId,
          ),
        ),
      ),
    ).then((_) => _loadCircles());
  }
} 