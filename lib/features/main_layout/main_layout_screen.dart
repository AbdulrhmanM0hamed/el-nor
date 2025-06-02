import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/custom_bottom_navigation.dart';
import '../../core/utils/theme/app_colors.dart';
import '../home/view/home_View.dart';
import '../quran_circles/presentation/screens/memorization_circles_screen.dart';
import '../home/quran/presentation/cubit/quran_cubit.dart';
import '../quran_circles/presentation/cubit/memorization_circles_cubit.dart';


class MainLayoutScreen extends StatefulWidget {
  static const routeName = '/main';

  const MainLayoutScreen({Key? key}) : super(key: key);

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;
  
  // قائمة الشاشات التي سيتم التنقل بينها
  final List<Widget> _screens = [
    const HomeView(),
    const MemorizationCirclesScreen(), // شاشة حلقات الحفظ (الزر المركزي)
    const ProfileScreen(), // شاشة الملف الشخصي (يمكن إنشاؤها لاحقاً)
  ];

  // قائمة عناوين الشاشات
  final List<String> _screenTitles = [
    'الرئيسية',
    'حلقات الحفظ',
    'الملف الشخصي',
  ];

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<QuranCubit>(
          create: (context) => QuranCubit(),
        ),
        BlocProvider<MemorizationCirclesCubit>(
          create: (context) => MemorizationCirclesCubit(),
        ),
      ],
      child: Scaffold(
        appBar: _currentIndex == 0 ? _buildHomeAppBar() : _buildAppBar(),
        body: IndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: CustomBottomNavigation(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
        ),
      ),
    );
  }
  
  // شريط تطبيق للشاشة الرئيسية
  AppBar _buildHomeAppBar() {
    return AppBar(
      title: Text(
        _screenTitles[_currentIndex],
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColors.logoTeal.withOpacity(0.9),
      foregroundColor: Colors.white,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            // إضافة وظيفة الإشعارات لاحقًا
          },
        ),
      ],
    );
  }
  
  // شريط تطبيق للشاشات الأخرى
  AppBar _buildAppBar() {
    return AppBar(
      title: Text(
        _screenTitles[_currentIndex],
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppColors.logoTeal,
      foregroundColor: Colors.white,
      elevation: 0,
    );
  }
}

// شاشة مؤقتة للملف الشخصي (يمكن استبدالها بالشاشة الفعلية لاحقاً)
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
   
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.logoTeal,
              child: Icon(
                Icons.person,
                size: 60,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20.h),
            const Text(
              'طالب القرآن',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10.h),
            const Text(
              'سجل حفظك وتقدمك في رحلة حفظ القرآن الكريم',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 30.h),
            _buildStatCard('الآيات المحفوظة', '237', Icons.check_circle),
            SizedBox(height: 10.h),
            _buildStatCard('السور المكتملة', '4', Icons.book),
            SizedBox(height: 10.h),
            _buildStatCard('أيام المتابعة', '28', Icons.calendar_today),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      width: 300.w,
      padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.logoTeal, size: 30),
          SizedBox(width: 15.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
