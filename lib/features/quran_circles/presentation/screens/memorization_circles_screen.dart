import 'package:beat_elslam/features/quran_circles/presentation/cubit/memorization_circles_state.dart';
import 'package:beat_elslam/features/quran_circles/presentation/screens/memorization_circles/widgets/memorization_circle_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  bool _isAllCircles = true;
  bool _isMemorizationOnly = false;
  bool _isExamOnly = false;
  bool _isDisposed = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadCircles();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  void _loadCircles() {
    if (!mounted || _isDisposed) return;
    context.read<MemorizationCirclesCubit>().loadMemorizationCircles();
  }

  Future<Map<String, dynamic>> _getCurrentUserPermissions() async {
    try {
      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser == null) {
        return {'role': UserRole.student, 'userId': '', 'isTeacher': false};
      }

      final userData = await Supabase.instance.client
          .from('students')
          .select('id, is_admin, is_teacher')
          .eq('id', currentUser.id)
          .single();

      if (userData == null) {
        return {'role': UserRole.student, 'userId': currentUser.id, 'isTeacher': false};
      }

      UserRole role;
      if (userData['is_admin'] == true) {
        role = UserRole.admin;
      } else if (userData['is_teacher'] == true) {
        role = UserRole.teacher;
      } else {
        role = UserRole.student;
      }

      return {
        'role': role,
        'userId': currentUser.id,
        'isTeacher': userData['is_teacher'] == true,
      };
    } catch (e) {
      return {'role': UserRole.student, 'userId': '', 'isTeacher': false};
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return FutureBuilder<Map<String, dynamic>>(
      future: _getCurrentUserPermissions(),
      builder: (context, snapshot) {
        final permissions = snapshot.data ?? {
          'role': UserRole.student,
          'userId': '',
          'isTeacher': false,
        };

        return Scaffold(
          appBar: AppBar(
            title: Text(
              _getScreenTitle(permissions['role']),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            backgroundColor: Theme.of(context).primaryColor,
            centerTitle: true,
          ),
          body: Column(
            key: const PageStorageKey<String>('memorization_circles_list'),
            children: [
              if (permissions['role'] == UserRole.admin) ...[
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
                    if (state is MemorizationCirclesLoading) {
                      return _buildLoadingState();
                    } else if (state is MemorizationCirclesLoaded) {
                      var circles = permissions['role'] == UserRole.admin 
                          ? _filterCircles(state.circles)
                          : state.circles;
                      circles = _filterCirclesByRole(circles, permissions);

                      if (circles.isEmpty) {
                        return _buildEmptyState(permissions['role']);
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
                              userRole: permissions['role'],
                              userId: permissions['userId'],
                              onTap: () => _navigateToCircleDetails(
                                  context, circles[index], permissions),
                            );
                          },
                        ),
                      );
                    } else if (state is MemorizationCirclesError) {
                      return _buildErrorState(state.message);
                    }
                    return _buildEmptyState(permissions['role']);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _getScreenTitle(UserRole role) {
    switch (role) {
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
      List<MemorizationCircle> circles, Map<String, dynamic> permissions) {
    final userId = permissions['userId'];
    if (userId.isEmpty) {
      return [];
    }

    switch (permissions['role']) {
      case UserRole.admin:
        return circles;
      case UserRole.teacher:
        return circles.where((circle) => circle.teacherId == userId).toList();
      case UserRole.student:
        return circles.where((circle) => circle.studentIds.contains(userId)).toList();
      default:
        return [];
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

  Widget _buildEmptyState(UserRole role) {
    String message;
    String submessage;

    switch (role) {
      case UserRole.admin:
        message = 'لا توجد حلقات حفظ حالياً';
        submessage = 'سيتم إضافة حلقات جديدة قريباً';
        break;
      case UserRole.teacher:
        message = 'لا توجد حلقات مسندة إليك';
        submessage = 'سيتم إسناد حلقات جديدة قريباً';
        break;
      case UserRole.student:
        message = 'لم يتم تسجيلك في أي حلقة';
        submessage = 'سيتم تسجيلك في حلقة قريباً';
        break;
      default:
        message = 'لا توجد حلقات متاحة';
        submessage = 'حاول مرة أخرى لاحقاً';
    }

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
            message,
            style: TextStyle(
              fontSize: 18.sp,
              color: Theme.of(context).textTheme.titleLarge?.color,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            submessage,
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

  Future<void> _navigateToCircleDetails(
      BuildContext context, MemorizationCircle circle, Map<String, dynamic> permissions) async {
    if (!mounted || _isDisposed) return;
    
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MemorizationCircleDetailsScreenWrapper(
          circle: circle,
          userRole: permissions['role'],
          userId: permissions['userId'],
        ),
      ),
    );

    // Only refresh if we got a result indicating changes were made
    if (mounted && !_isDisposed && result == true) {
      // Force refresh only the specific circle that was modified
      context.read<MemorizationCirclesCubit>().loadCircleDetails(circle.id);
    }
  }
}
