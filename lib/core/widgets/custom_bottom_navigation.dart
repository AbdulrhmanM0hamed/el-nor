import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../utils/theme/app_colors.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigation({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      height: 70.h + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Stack(
        children: [
          // منحنى في الخلفية
          CustomPaint(
            size: Size(MediaQuery.of(context).size.width, 70.h),
            painter: NavBarPainter(context),
          ),

          // أزرار التنقل
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // الرئيسية - الصفحة الأولى (index 0)
              _buildNavItem(0, Icons.home_rounded, 'الرئيسية'),

              // حلقات الحفظ - الصفحة الثانية (index 1)
              _buildCenterButton(),

              // الملف الشخصي - الصفحة الثالثة (index 2)
              _buildNavItem(2, Icons.person_rounded, 'الملف'),
            ],
          ),
        ],
      ),
    );
  }

  // بناء زر عادي في شريط التنقل
  Widget _buildNavItem(int index, IconData icon, String label) {
    // التحقق مما إذا كان هذا الزر هو المحدد حاليًا
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isSelected ? 28.sp : 24.sp,
              color: isSelected ? AppColors.logoOrange : Colors.grey,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.logoOrange : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // بناء زر الوسط المميز (حلقات الحفظ)
  Widget _buildCenterButton() {
    // التحقق مما إذا كان زر الحلقات هو المحدد حاليًا (index 1)
    final bool isSelected = currentIndex == 1;

    return GestureDetector(
      onTap: () => onTap(1), // دائمًا يذهب إلى الصفحة الثانية (index 1)
      child: Container(
        width: 60.w,
        height: 60.h,
        margin: EdgeInsets.only(bottom: 20.h),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [AppColors.logoTeal, AppColors.logoTeal]
                : [AppColors.logoOrange, AppColors.logoTeal],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.logoTeal.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups_rounded,
              color: Colors.white,
              size: 26.sp,
            ),
            Text(
              'حلقات',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// رسم المنحنى في الخلفية
class NavBarPainter extends CustomPainter {
  final BuildContext context;

  NavBarPainter(this.context);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Theme.of(context).brightness == Brightness.dark
          ? Colors.black
          : Colors.white
      ..style = PaintingStyle.fill;

    Path path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width * 0.35, 0)
      ..quadraticBezierTo(
        size.width * 0.5,
        0,
        size.width * 0.65,
        0,
      )
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
