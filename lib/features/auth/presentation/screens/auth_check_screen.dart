import 'package:beat_elslam/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/service_locator.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

/// Pantalla invisible que solo verifica el estado de autenticación y redirige
/// Esta pantalla reemplaza a SplashScreen y trabaja con native_splash
class AuthCheckScreen extends StatefulWidget {
  static const String routeName = '/auth-check';

  const AuthCheckScreen({Key? key}) : super(key: key);

  @override
  State<AuthCheckScreen> createState() => _AuthCheckScreenState();
}

class _AuthCheckScreenState extends State<AuthCheckScreen> {
  @override
  void initState() {
    super.initState();
    // Verificar el estado de autenticación inmediatamente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('AuthCheckScreen: Verificando estado de autenticación');
      sl<AuthCubit>().checkCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      bloc: sl<AuthCubit>(),
      listener: (context, state) {
        print('AuthCheckScreen: تم استلام الحالة: ${state.runtimeType}');
        if (state is AuthAuthenticated) {
          print('AuthCheckScreen: المستخدم مصادق عليه، جاري الانتقال إلى الشاشة الرئيسية');
          Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);
        } else if (state is AuthUnauthenticated) {
          print('AuthCheckScreen: المستخدم غير مصادق عليه، جاري الانتقال إلى شاشة تسجيل الدخول');
          Navigator.of(context).pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);
        } else if (state is AuthLoading) {
          print('AuthCheckScreen: جاري التحقق من حالة المصادقة...');
        } else if (state is AuthError) {
          print('AuthCheckScreen: خطأ في المصادقة: ${state.message}');
          // في حالة الخطأ، الانتقال إلى شاشة تسجيل الدخول
          Navigator.of(context).pushNamedAndRemoveUntil(LoginScreen.routeName, (route) => false);
        }
      },
      // Pantalla vacía mientras se verifica la autenticación
      child: const Scaffold(
        body: SizedBox.shrink(),
      ),
    );
  }
}
