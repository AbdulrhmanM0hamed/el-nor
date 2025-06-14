import 'package:flutter/material.dart';

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
    final screenWidth = MediaQuery.of(context).size.width;
    final double bottomInset = MediaQuery.of(context).padding.bottom;
    return Container(
      height: screenWidth * 0.18 + bottomInset,
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Stack(
        children: [
          // منحنى في الخلفية
          CustomPaint(
            size: Size(screenWidth, screenWidth * 0.18),
            painter: NavBarPainter(context, screenWidth),
          ),

          // أزرار التنقل
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // الرئيسية - الصفحة الأولى (index 0)
              _buildNavItem(0, Icons.home_rounded, 'الرئيسية', screenWidth),

              // حلقات الحفظ - الصفحة الثانية (index 1)
              _buildCenterButton(screenWidth),

              // الملف الشخصي - الصفحة الثالثة (index 2)
              _buildNavItem(2, Icons.person_rounded, 'الملف', screenWidth),
            ],
          ),
        ],
      ),
    );
  }

  // بناء زر عادي في شريط التنقل
  Widget _buildNavItem(int index, IconData icon, String label, double screenWidth) {
    // التحقق مما إذا كان هذا الزر هو المحدد حاليًا
    final bool isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.02, vertical: screenWidth * 0.02),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: isSelected ? screenWidth * 0.07 : screenWidth * 0.06,
              color: isSelected ? AppColors.logoOrange : Colors.grey,
            ),
            SizedBox(height: screenWidth * 0.01),
            Text(
              label,
              style: TextStyle(
                fontSize: screenWidth * 0.03,
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
  Widget _buildCenterButton(double screenWidth) {
    // التحقق مما إذا كان زر الحلقات هو المحدد حاليًا (index 1)
    final bool isSelected = currentIndex == 1;

    return GestureDetector(
      onTap: () => onTap(1), // دائمًا يذهب إلى الصفحة الثانية (index 1)
      child: Container(
        width: screenWidth * 0.22,
        height: screenWidth * 0.22,
        margin: EdgeInsets.only(bottom: screenWidth * 0.05),
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
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: screenWidth * 0.025,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.groups_rounded, size: screenWidth * 0.075, color: Colors.white),
            Text(
              'الحلقات',
              style: TextStyle(fontSize: screenWidth * 0.03, color: Colors.white),
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
  final double screenWidth;

  NavBarPainter(this.context, this.screenWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Theme.of(context).cardColor
      ..style = PaintingStyle.fill;

    final double curveHeight = screenWidth * 0.05;

    final Path path = Path()
      ..moveTo(0, curveHeight) // بداية المنحنى
      ..quadraticBezierTo(size.width * 0.05, 0, size.width * 0.15, 0)
      ..lineTo(size.width * 0.35, 0)
      // المنحنى للزر الأوسط
      ..quadraticBezierTo(size.width * 0.4, 0, size.width * 0.4, curveHeight)
      ..arcToPoint(
        Offset(size.width * 0.6, curveHeight),
        radius: Radius.circular(screenWidth * 0.1),
        clockwise: false,
      )
      ..quadraticBezierTo(size.width * 0.6, 0, size.width * 0.65, 0)
      ..lineTo(size.width * 0.85, 0)
      ..quadraticBezierTo(size.width * 0.95, 0, size.width, curveHeight)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
