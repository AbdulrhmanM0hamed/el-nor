import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widgets/custom_bottom_navigation.dart';
import '../../core/services/service_locator.dart' as di;
import '../home/view/home_View.dart';
import '../quran_circles/presentation/screens/memorization_circles_screen.dart';
import '../profile/presentation/screens/profile_screen.dart';
import '../home/quran/presentation/cubit/quran_cubit.dart';
import '../quran_circles/presentation/cubit/memorization_circles_cubit.dart';
import '../auth/presentation/cubit/auth_cubit.dart';


class MainLayoutScreen extends StatefulWidget {
  static const routeName = '/main';

  const MainLayoutScreen({Key? key}) : super(key: key);

  @override
  State<MainLayoutScreen> createState() => _MainLayoutScreenState();
}

class _MainLayoutScreenState extends State<MainLayoutScreen> {
  int _currentIndex = 0;
  
  // قائمة الشاشات التي سيتم التنقل بينها
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const HomeView(),
      BlocProvider(
        create: (context) => di.sl<MemorizationCirclesCubit>(),
        child: const MemorizationCirclesScreen(),
      ),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (context) {
            final authCubit = di.sl<AuthCubit>();
            authCubit.checkCurrentUser();
            return authCubit;
          },
        ),
        BlocProvider<QuranCubit>(
          create: (context) => di.sl<QuranCubit>(),
        ),
        BlocProvider<MemorizationCirclesCubit>(
          create: (context) => di.sl<MemorizationCirclesCubit>(),
        ),
      ],
      child: Scaffold(
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
}

// Se ha eliminado la clase ProfileScreen temporal y ahora se usa la implementación completa
// de la pantalla de perfil desde el archivo '../profile/presentation/screens/profile_screen.dart'
