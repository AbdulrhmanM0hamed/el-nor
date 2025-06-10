import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../features/auth/presentation/cubit/global_auth_cubit.dart';

class WaitingListDialog extends StatelessWidget {
  const WaitingListDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const WaitingListDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Container(
        padding: EdgeInsets.all(20.sp),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/whatsapp.png',
              height: 80.h,
              width: 80.w,
            ),
            SizedBox(height: 20.h),
            Text(
              'أنت الآن على قائمة الانتظار',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.logoTeal,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.h),
            Text(
              'برجاء التواصل مع المسؤول ليتم إضافتك إلى حلقات الحفظ',
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            ElevatedButton(
              onPressed: () async {
                final Uri whatsappUrl = Uri.parse('https://wa.me/+201282933582');
                if (await canLaunchUrl(whatsappUrl)) {
                  await launchUrl(whatsappUrl);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.r),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/whatsapp.png',
                    height: 20.h,
                    width: 20.w,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'تواصل معنا',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            TextButton(
              onPressed: () {
                context.read<GlobalAuthCubit>().markWaitingDialogAsSeen();
                Navigator.of(context).pop();
              },
              child: Text(
                'حسناً',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: AppColors.logoTeal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 