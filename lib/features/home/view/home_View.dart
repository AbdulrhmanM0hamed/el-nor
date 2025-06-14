import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../features/auth/presentation/cubit/global_auth_cubit.dart';
import '../../../features/auth/presentation/cubit/auth_state.dart';
import '../../../core/utils/theme/app_colors.dart';
import '../../../features/auth/presentation/screens/login_screen.dart';
import 'widgets/home_view_body.dart';
import 'widgets/waiting_list_dialog.dart';

class HomeView extends StatefulWidget {
  static const String routeName = '/home';

  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    _checkAndShowDialog();
  }

  void _checkAndShowDialog() {
    final state = context.read<GlobalAuthCubit>().state;
    if (state is AuthAuthenticated && state.isNewUser) {
      Future.delayed(Duration.zero, () {
        if (mounted) {
          WaitingListDialog.show(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return BlocListener<GlobalAuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil(
            LoginScreen.routeName,
            (route) => false,
          );
        } else if (state is AuthAuthenticated && state.isNewUser) {
          WaitingListDialog.show(context);
        }
      },
      child: Scaffold(
        appBar: context.watch<GlobalAuthCubit>().state is AuthGuest ? AppBar(
          title: Text(
            'النور',
            style: TextStyle(
              fontSize: screenWidth * 0.06,
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
        ) : null,
        body: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: screenWidth * 0.08,
                child: Opacity(
                  opacity: 0.3,
                  child: SvgPicture.asset(
                    'assets/images/back1.svg',
                    width: MediaQuery.of(context).size.width * 0.8,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: screenWidth * 0.08,
                child: Opacity(
                  opacity: 0.3,
                  child: SvgPicture.asset(
                    'assets/images/back2.svg',
                    width: MediaQuery.of(context).size.width * 0.8,
                  ),
                ),
              ),
              const HomeViewBody(),
            ],
          ),
        ),
      ),
    );
  }
}
