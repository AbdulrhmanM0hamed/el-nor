import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../data/models/memorization_circle_model.dart';
import '../widgets/memorization_circle_card.dart';
import '../cubit/memorization_circles_cubit.dart';
import 'memorization_circle_details_screen.dart';

class MemorizationCirclesScreen extends StatefulWidget {
  const MemorizationCirclesScreen({Key? key}) : super(key: key);

  @override
  State<MemorizationCirclesScreen> createState() => _MemorizationCirclesScreenState();
}

class _MemorizationCirclesScreenState extends State<MemorizationCirclesScreen> {
  bool _isAdmin = true; // Simulando que el usuario es administrador
  bool _isAllCircles = true; // Filtro para mostrar todos los círculos
  bool _isMemorizationOnly = false; // Filtro para mostrar solo círculos de memorización
  bool _isExamOnly = false; // Filtro para mostrar solo exámenes

  @override
  void initState() {
    super.initState();
    _loadCircles();
  }

  void _loadCircles() {
    // Cargar círculos usando el Cubit
    context.read<MemorizationCirclesCubit>().loadMemorizationCircles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Column(
        children: [
          // Sección de filtros rápidos
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
          
          // Lista de círculos con BlocBuilder
          Expanded(
            child: BlocBuilder<MemorizationCirclesCubit, MemorizationCirclesState>(
              builder: (context, state) {
                if (state is MemorizationCirclesLoading) {
                  return _buildLoadingState();
                } else if (state is MemorizationCirclesLoaded) {
                  final circles = _filterCircles(state.circles);
                  
                  if (circles.isEmpty) {
                    return _buildEmptyState();
                  }
                  
                  return ListView.builder(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    itemCount: circles.length,
                    itemBuilder: (context, index) {
                      return MemorizationCircleCard(
                        circle: circles[index],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MemorizationCircleDetailsScreen(
                                circle: circles[index],
                                isAdmin: _isAdmin,
                              ),
                            ),
                          ).then((_) {
                            // Recargar la lista cuando regrese
                            _loadCircles();
                          });
                        },
                      );
                    },
                  );
                } else if (state is MemorizationCirclesError) {
                  return _buildErrorState(state.message);
                } else {
                  return _buildEmptyState();
                }
              },
            ),
          ),
        ],
      ),
      // Botón flotante para agregar nuevo círculo (solo para administradores)
      floatingActionButton: _isAdmin
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
}
