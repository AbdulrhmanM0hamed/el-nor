import 'package:beat_elslam/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:beat_elslam/features/quran_circles/presentation/screens/memorization_circles/widgets/memorization_circle_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../data/models/memorization_circle_model.dart';
import '../cubit/memorization_circles_cubit.dart';
import 'memorization_circle_details_screen.dart';
import '../../../../core/utils/user_role.dart';

class MemorizationCirclesScreen extends StatefulWidget {
  const MemorizationCirclesScreen({Key? key}) : super(key: key);

  @override
  State<MemorizationCirclesScreen> createState() =>
      _MemorizationCirclesScreenState();
}

class _MemorizationCirclesScreenState extends State<MemorizationCirclesScreen>
    with AutomaticKeepAliveClientMixin {
  late UserRole _userRole = UserRole.student;
  late String _userId = '';
  bool _isTeacherCirclesOnly = false;
  bool _isAllCircles = true;
  bool _isMemorizationOnly = false;
  bool _isExamOnly = false;
  bool _isInitialized = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    if (_isInitialized) return;

    final authCubit = context.read<AuthCubit>();
    final currentUser = authCubit.currentUser;

    if (currentUser != null) {
      setState(() {
        _userId = currentUser.id;
        if (currentUser.isAdmin) {
          _userRole = UserRole.admin;
        } else if (currentUser.isTeacher) {
          _userRole = UserRole.teacher;
        } else {
          _userRole = UserRole.student;
        }
        _isInitialized = true;
      });
    }

    await Future.delayed(Duration.zero);
    _loadCircles();
  }

  void _loadCircles() {
    if (!mounted) return;
    context.read<MemorizationCirclesCubit>().loadMemorizationCircles();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final currentUser = context.read<AuthCubit>().currentUser;
    if (currentUser != null && _userId != currentUser.id) {
      setState(() {
        _userId = currentUser.id;
        if (currentUser.isAdmin) {
          _userRole = UserRole.admin;
        } else if (currentUser.isTeacher) {
          _userRole = UserRole.teacher;
        } else {
          _userRole = UserRole.student;
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getScreenTitle(),
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
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
      body: Column(
        key: const PageStorageKey<String>('memorization_circles_list'),
        children: [
          if (_userRole != UserRole.student) ...[
            Container(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              color: Theme.of(context).cardColor,
              child: Row(
                children: [
                  _buildFilterChip('الكل', _isAllCircles, () {
                    setState(() {
                      _isAllCircles = true;
                      _isMemorizationOnly = false;
                      _isExamOnly = false;
                    });
                  }),
                  SizedBox(width: 8.w),
                  _buildFilterChip('حلقات الحفظ', _isMemorizationOnly, () {
                    setState(() {
                      _isAllCircles = false;
                      _isMemorizationOnly = true;
                      _isExamOnly = false;
                    });
                  }),
                  SizedBox(width: 8.w),
                  _buildFilterChip('امتحانات', _isExamOnly, () {
                    setState(() {
                      _isAllCircles = false;
                      _isMemorizationOnly = false;
                      _isExamOnly = true;
                    });
                  }),
                ],
              ),
            ),
          ],
          Expanded(
            child: BlocBuilder<MemorizationCirclesCubit, MemorizationCirclesState>(
              builder: (context, state) {
                if (state is MemorizationCirclesLoading && !_isInitialized) {
                  return _buildLoadingState();
                } else if (state is MemorizationCirclesLoaded) {
                  var circles = _filterCircles(state.circles);
                  circles = _filterCirclesByRole(circles);

                  if (circles.isEmpty) {
                    return _buildEmptyState();
                  }

                  return RefreshIndicator(
                    color: AppColors.logoTeal,
                    onRefresh: () async {
                      await context
                          .read<MemorizationCirclesCubit>()
                          .loadMemorizationCircles();
                    },
                    child: ListView.builder(
                      key: const PageStorageKey<String>('circles_list_view'),
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      itemCount: circles.length,
                      itemBuilder: (context, index) {
                        return MemorizationCircleCard(
                          circle: circles[index],
                          userRole: _userRole,
                          userId: _userId,
                          onTap: () => _navigateToCircleDetails(
                              context, circles[index]),
                        );
                      },
                    ),
                  );
                } else if (state is MemorizationCirclesError) {
                  return _buildErrorState(state.message);
                }
                return _buildEmptyState();
              },
            ),
          ),
        ],
      ),
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

  List<MemorizationCircle> _filterCirclesByRole(
      List<MemorizationCircle> circles) {
    if (_userId.isEmpty) {
      return circles;
    }

    switch (_userRole) {
      case UserRole.admin:
        return circles;
      case UserRole.teacher:
        if (_isTeacherCirclesOnly) {
          final filteredCircles =
              circles.where((circle) => circle.teacherId == _userId).toList();
          return filteredCircles;
        }
        return circles;
      case UserRole.student:
        final studentCircles = circles
            .where((circle) =>
                circle.studentIds.contains(_userId) ||
                circle.teacherId == _userId)
            .toList();
        for (var circle in circles) {
       
        }
      
        return studentCircles;
      default:
        return circles;
    }
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.logoTeal : Colors.grey[100],
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book,
            size: 64.sp,
            color: Theme.of(context).disabledColor,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد حلقات حفظ حالياً',
            style: TextStyle(
              fontSize: 18.sp,
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'سيتم إضافة حلقات جديدة قريباً',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  List<MemorizationCircle> _filterCircles(List<MemorizationCircle> circles) {
    if (_isAllCircles) {
      return circles;
    } else if (_isMemorizationOnly) {
      return circles.where((circle) => !circle.isExam).toList();
    } else if (_isExamOnly) {
      return circles.where((circle) => circle.isExam).toList();
    }
    return circles;
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Theme.of(context).primaryColor),
          SizedBox(height: 16.h),
          Text(
            'جاري تحميل حلقات الحفظ...',
            style: TextStyle(
              fontSize: 16.sp,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: AppColors.error,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: _loadCircles,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.logoTeal,
            ),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  void _showAddCircleDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم إضافة هذه الميزة قريباً'),
        backgroundColor: AppColors.logoTeal,
      ),
    );
  }

  void _navigateToCircleDetails(
      BuildContext context, MemorizationCircle circle) {
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
    );
  }
}
