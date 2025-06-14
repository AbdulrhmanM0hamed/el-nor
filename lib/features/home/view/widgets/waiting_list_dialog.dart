import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';
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
    final screenWidth = MediaQuery.of(context).size.width;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
      ),
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.05),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/whatsapp.png',
              height: screenWidth * 0.2,
              width: screenWidth * 0.2,
            ),
            SizedBox(height: screenWidth * 0.05),
            Text(
              'أنت الآن على قائمة الانتظار',
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
                color: AppColors.logoTeal,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenWidth * 0.025),
            Text(
              'برجاء التواصل مع المسؤول ليتم إضافتك إلى حلقات الحفظ',
              style: TextStyle(
                fontSize: screenWidth * 0.04,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenWidth * 0.05),
            SelectableText(
              '+972 56 900 9186',
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: screenWidth * 0.03),
            OutlinedButton(
              onPressed: () async {
                await Clipboard.setData(const ClipboardData(text: '+972569009186'));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم نسخ الرقم')),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.logoTeal,
                side: const BorderSide(color: AppColors.logoTeal),
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.06, vertical: screenWidth * 0.025),
              ),
              child: const Text('انسخ الرقم'),
            ),
            SizedBox(height: screenWidth * 0.03),
            ElevatedButton(
              onPressed: () async {
                final whatsappUrl =
                    Uri.parse("whatsapp://send?phone=972569009186");
                if (await canLaunchUrl(whatsappUrl)) {
                  await launchUrl(
                    whatsappUrl,
                    mode: LaunchMode.externalApplication,
                  );
                } else {
                  // جرب الرابط عبر المتصفح
                  final fallbackUrl = Uri.parse("https://wa.me/972569009186");
                  if (await canLaunchUrl(fallbackUrl)) {
                    await launchUrl(fallbackUrl,
                        mode: LaunchMode.externalApplication);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('تعذر فتح الرابط')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.logoTeal,
                padding: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.075, vertical: screenWidth * 0.03),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(screenWidth * 0.075),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.send, color: Colors.white),
                  SizedBox(width: screenWidth * 0.02),
                  Text(
                    'افتح واتساب',
                    style: TextStyle(fontSize: screenWidth * 0.04, color: Colors.white),
                  ),
                ],
              ),
            ),
            SizedBox(height: screenWidth * 0.025),
            TextButton(
              onPressed: () {
                context.read<GlobalAuthCubit>().markWaitingDialogAsSeen();
                Navigator.of(context).pop();
              },
              child: Text(
                'تخطي',
                style: TextStyle(
                  fontSize: screenWidth * 0.035,
                  color: Colors.grey[600],
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
