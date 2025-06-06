import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/auth/presentation/cubit/global_auth_cubit.dart';
import '../../../features/auth/presentation/cubit/auth_state.dart';
import '../../../core/utils/theme/app_colors.dart';
import '../../../features/auth/presentation/screens/login_screen.dart';
import 'widgets/home_view_body.dart';

class HomeView extends StatelessWidget {
  static const String routeName = '/home';

  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<GlobalAuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            LoginScreen.routeName,
            (route) => false,
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'النور',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: AppColors.logoTeal,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.login_rounded, color: Colors.white),
            onPressed: () {
              context.read<GlobalAuthCubit>().signOut();
            },
          ),
        ),
        body: Stack(
          children: [
            // Top SVG background
            Positioned(
              top: 0,
              right: 30.w,
              child: Opacity(
                opacity: 0.3,
                child: SvgPicture.asset(
                  'assets/images/back1.svg',
                  width: MediaQuery.of(context).size.width * 0.8,
                ),
              ),
            ),
            
            // Bottom SVG background
            Positioned(
              bottom: 0,
              left: 30.w,
              child: Opacity(
                opacity: 0.3,
                child: SvgPicture.asset(
                  'assets/images/back2.svg',
                  width: MediaQuery.of(context).size.width * 0.8,
                ),
              ),
            ),
            
            // Main content
            const HomeViewBody(),
          ],
        ),
      ),
    );
  }
}
