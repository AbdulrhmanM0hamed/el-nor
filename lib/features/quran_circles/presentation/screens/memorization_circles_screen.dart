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
  State<MemorizationCirclesScreen> createState() => _MemorizationCirclesScreenState();
}

class _MemorizationCirclesScreenState extends State<MemorizationCirclesScreen> {
  late UserRole _userRole = UserRole.student; // مستخدم عادي افتراضياً
  late String _userId = '';
  bool _isTeacherCirclesOnly = false; // فلتر لعرض حلقات المعلم فقط
  bool _isAllCircles = true; // Filtro para mostrar todos los círculos
  bool _isMemorizationOnly = false; // Filtro para mostrar solo círculos de memorización
  bool _isExamOnly = false; // Filtro para mostrar solo exámenes

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  Future<void> _initializeUserData() async {
    final authCubit = context.read<AuthCubit>();
    final currentUser = authCubit.currentUser;
    print('MemorizationCirclesScreen: تهيئة بيانات المستخدم');
    print('MemorizationCirclesScreen: المستخدم الحالي - ${currentUser?.name}');
    print('MemorizationCirclesScreen: معرف المستخدم - ${currentUser?.id}');
    
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
      });
      print('MemorizationCirclesScreen: تم تحديث البيانات');
      print('MemorizationCirclesScreen: الدور - $_userRole');
      print('MemorizationCirclesScreen: معرف المستخدم - $_userId');
    } else {
      print('MemorizationCirclesScreen: لم يتم العثور على بيانات المستخدم');
    }

    await Future.delayed(Duration.zero); // انتظار حتى يتم تحديث الحالة
    _loadCircles();
  }

  void _loadCircles() {
    print('MemorizationCirclesScreen: بدء تحميل الحلقات');
    context.read<MemorizationCirclesCubit>().loadMemorizationCircles();
  }

  @override
  Widget build(BuildContext context) {
    // تحديث معرف المستخدم في كل مرة يتم فيها بناء الواجهة
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
      body: Column(
        children: [
          if (_userRole != UserRole.student) ...[
            Container(
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              color: Colors.white,
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
                print('MemorizationCirclesScreen: حالة BlocBuilder الحالية - ${state.runtimeType}');
                
                if (state is MemorizationCirclesLoading) {
                  print('MemorizationCirclesScreen: عرض حالة التحميل');
                  return _buildLoadingState();
                } else if (state is MemorizationCirclesLoaded) {
                  print('MemorizationCirclesScreen: تم تحميل الحلقات - ${state.circles.length} حلقة');
                  var circles = _filterCircles(state.circles);
                  print('MemorizationCirclesScreen: بعد التصفية - ${circles.length} حلقة');
                  
                  // فلترة إضافية حسب الدور
                  circles = _filterCirclesByRole(circles);
                  print('MemorizationCirclesScreen: بعد فلترة الدور - ${circles.length} حلقة');
                  
                  if (circles.isEmpty) {
                    print('MemorizationCirclesScreen: لا توجد حلقات للعرض - عرض الحالة الفارغة');
                    return _buildEmptyState();
                  }
                  
                  return RefreshIndicator(
                    color: AppColors.logoTeal,
                    onRefresh: () async {
                      print('MemorizationCirclesScreen: تحديث القائمة');
                      await context.read<MemorizationCirclesCubit>().loadMemorizationCircles();
                    },
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      itemCount: circles.length,
                      itemBuilder: (context, index) {
                        return MemorizationCircleCard(
                          circle: circles[index],
                          userRole: _userRole,
                          userId: _userId,
                          onTap: () => _navigateToCircleDetails(context, circles[index]),
                        );
                      },
                    ),
                  );
                } else if (state is MemorizationCirclesError) {
                  print('MemorizationCirclesScreen: عرض حالة الخطأ - ${state.message}');
                  return _buildErrorState(state.message);
                }
                print('MemorizationCirclesScreen: عرض الحالة الفارغة الافتراضية');
                return _buildEmptyState();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _userRole == UserRole.admin
          ? FloatingActionButton(
              backgroundColor: AppColors.logoTeal,
              child: const Icon(Icons.add),
              onPressed: () {
                _showAddCircleDialog();
              },
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
    print('MemorizationCirclesScreen: فلترة الحلقات حسب الدور - $_userRole');
    print('MemorizationCirclesScreen: معرف المستخدم الحالي - ${_userId.isEmpty ? "فارغ" : _userId}');
    
    // إذا كان معرف المستخدم فارغاً، أعد كل الحلقات
    if (_userId.isEmpty) {
      print('MemorizationCirclesScreen: معرف المستخدم فارغ - عرض كل الحلقات');
      return circles;
    }
    
    switch (_userRole) {
      case UserRole.admin:
        print('MemorizationCirclesScreen: المستخدم مشرف - عرض كل الحلقات');
        return circles;
      case UserRole.teacher:
        if (_isTeacherCirclesOnly) {
          print('MemorizationCirclesScreen: المستخدم معلم - عرض حلقاته فقط');
          final filteredCircles = circles.where((circle) => circle.teacherId == _userId).toList();
          print('MemorizationCirclesScreen: عدد حلقات المعلم - ${filteredCircles.length}');
          return filteredCircles;
        }
        print('MemorizationCirclesScreen: المستخدم معلم - عرض كل الحلقات');
        return circles;
      case UserRole.student:
        print('MemorizationCirclesScreen: المستخدم طالب - عرض الحلقات المسجل فيها');
        final studentCircles = circles.where((circle) => 
          circle.studentIds.contains(_userId) ||
          circle.teacherId == _userId
        ).toList();
        print('MemorizationCirclesScreen: تفاصيل الحلقات المتاحة للطالب:');
        for (var circle in circles) {
          print('- حلقة: ${circle.name}');
          print('  معرف المعلم: ${circle.teacherId}');
          print('  معرفات الطلاب: ${circle.studentIds}');
        }
        print('MemorizationCirclesScreen: عدد الحلقات المتاحة للطالب - ${studentCircles.length}');
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
            color: Colors.grey[400],
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد حلقات حفظ حالياً',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'سيتم إضافة حلقات جديدة قريباً',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
  
  // Filtrar círculos según los filtros seleccionados
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
          const CircularProgressIndicator(color: AppColors.logoTeal),
          SizedBox(height: 16.h),
          Text(
            'جاري تحميل حلقات الحفظ...',
            style: TextStyle(
              fontSize: 16.sp,
              color: Colors.grey[700],
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

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تصفية حلقات الحفظ',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.logoTeal,
                ),
              ),
              SizedBox(height: 16.h),
              _buildFilterOption('جميع الحلقات', Icons.all_inclusive),
              _buildFilterOption('حلقات الحفظ فقط', Icons.menu_book),
              _buildFilterOption('امتحانات الحفظ فقط', Icons.assignment),
              _buildFilterOption('الحلقات القادمة', Icons.event),
              _buildFilterOption('الحلقات السابقة', Icons.history),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String label, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.logoTeal),
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        // Aplicar filtro
      },
    );
  }

  void _showAddCircleDialog() {
    // En una aplicación real, esto mostraría un formulario para agregar un nuevo círculo
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('سيتم إضافة هذه الميزة قريباً'),
        backgroundColor: AppColors.logoTeal,
      ),
    );
  }

  // Helper method to navigate to circle details
  void _navigateToCircleDetails(BuildContext context, MemorizationCircle circle) {
    // Get both cubits before navigation
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
    ).then((_) {
      _loadCircles();
    });
  }
}
