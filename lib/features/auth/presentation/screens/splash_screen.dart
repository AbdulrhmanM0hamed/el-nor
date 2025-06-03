// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import '../../../../core/utils/theme/app_colors.dart';
// import '../../../../core/services/service_locator.dart';
// import '../cubit/auth_cubit.dart';
// import '../cubit/auth_state.dart';
// import 'login_screen.dart';

// class SplashScreen extends StatefulWidget {
//   static const String routeName = '/splash';

//   const SplashScreen({Key? key}) : super(key: key);

//   @override
//   State<SplashScreen> createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _opacityAnimation;
//   late Animation<double> _scaleAnimation;
//   bool _animationComplete = false;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(seconds: 2),
//     );

//     _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
//       ),
//     );

//     _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _controller,
//         curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
//       ),
//     );

//     _controller.forward().then((_) {
//       setState(() {
//         _animationComplete = true;
//       });
//       // Solo verificar el estado de autenticación después de que la animación esté completa
//       if (mounted) {
//         sl<AuthCubit>().checkCurrentUser();
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<AuthCubit, AuthState>(
//       bloc: sl<AuthCubit>(),
//       listener: (context, state) {
//         if (_animationComplete) {
//           if (state is AuthAuthenticated) {
//             Navigator.pushReplacementNamed(context, '/main');
//           } else if (state is AuthUnauthenticated) {
//             Navigator.pushReplacementNamed(context, LoginScreen.routeName);
//           }
//         }
//       },
//       child: Scaffold(
//         body: Stack(
//           children: [
//             // Fondo superior
//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               child: SvgPicture.asset(
//                 'assets/images/back1.svg',
//                 width: MediaQuery.of(context).size.width,
//                 fit: BoxFit.fitWidth,
//               ),
//             ),
            
//             // Fondo inferior
//             Positioned(
//               bottom: 0,
//               left: 0,
//               right: 0,
//               child: SvgPicture.asset(
//                 'assets/images/back2.svg',
//                 width: MediaQuery.of(context).size.width,
//                 fit: BoxFit.fitWidth,
//               ),
//             ),
            
//             // Contenido principal
//             Center(
//               child: AnimatedBuilder(
//                 animation: _controller,
//                 builder: (context, child) {
//                   return Opacity(
//                     opacity: _opacityAnimation.value,
//                     child: Transform.scale(
//                       scale: _scaleAnimation.value,
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text(
//                             'النور',
//                             style: TextStyle(
//                               fontSize: 64.sp,
//                               fontWeight: FontWeight.bold,
//                               color: AppColors.logoTeal,
//                             ),
//                           ),
//                           SizedBox(height: 16.h),
//                           Text(
//                             'لحفظ القرآن الكريم',
//                             style: TextStyle(
//                               fontSize: 24.sp,
//                               fontWeight: FontWeight.w500,
//                               color: AppColors.logoOrange,
//                             ),
//                           ),
//                           SizedBox(height: 40.h),
//                         const  CircularProgressIndicator(
//                             color: AppColors.logoTeal,
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
