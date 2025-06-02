import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/services/service_locator.dart' as di;
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  static const String routeName = '/splash';

  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
    
    // Verificar el estado de autenticación después de la animación
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        // Se verificará en el BlocListener después de que se monte el widget
        // No necesitamos llamar a checkCurrentUser() aquí porque lo haremos en el BlocProvider
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final authCubit = di.sl<AuthCubit>();
        // Verificar el estado de autenticación después de la animación
        Future.delayed(const Duration(seconds: 3), () {
          authCubit.checkCurrentUser();
        });
        return authCubit;
      },
      child: Scaffold(
        body: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthAuthenticated) {
              Navigator.pushReplacementNamed(context, '/main');
            } else if (state is AuthUnauthenticated) {
              Navigator.pushReplacementNamed(context, LoginScreen.routeName);
            }
          },
          child: Stack(
          children: [
            // Fondo superior
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SvgPicture.asset(
                'assets/images/back1.svg',
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fitWidth,
              ),
            ),
            
            // Fondo inferior
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SvgPicture.asset(
                'assets/images/back2.svg',
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fitWidth,
              ),
            ),
            
            // Contenido principal
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'النور',
                            style: TextStyle(
                              fontSize: 64.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.logoTeal,
                            ),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'لحفظ القرآن الكريم',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.w500,
                              color: AppColors.logoOrange,
                            ),
                          ),
                          SizedBox(height: 40.h),
                          CircularProgressIndicator(
                            color: AppColors.logoTeal,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    ));
  }
}
