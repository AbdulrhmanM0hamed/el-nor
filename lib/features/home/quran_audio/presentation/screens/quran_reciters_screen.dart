import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubit/quran_audio_cubit.dart';
import '../cubit/quran_audio_state.dart';
import '../widgets/quran_collection_card.dart';
import '../../../../../core/utils/theme/app_colors.dart';

class QuranRecitersScreen extends StatefulWidget {
  static const String routeName = '/quran-reciters';

  const QuranRecitersScreen({Key? key}) : super(key: key);

  @override
  State<QuranRecitersScreen> createState() => _QuranRecitersScreenState();
}

class _QuranRecitersScreenState extends State<QuranRecitersScreen> {
  @override
  void initState() {
    super.initState();
    context.read<QuranAudioCubit>().getReciters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر القارئ'),
        backgroundColor: AppColors.logoTeal,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<QuranAudioCubit, QuranAudioState>(
        builder: (context, state) {
          if (state is QuranAudioLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.logoTeal,
              ),
            );
          } else if (state is QuranAudioLoaded) {
            if (state.reciters.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_off,
                      size: 64.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'لا يوجد قراء متاحون',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              );
            }
            
            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: state.reciters.length,
              itemBuilder: (context, index) {
                final reciter = state.reciters[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: QuranCollectionCard(collection: reciter),
                );
              },
            );
          } else if (state is QuranAudioError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // تغيير الأيقونة حسب نوع الخطأ
                  Icon(
                    state.message.contains('اتصال بالإنترنت') || 
                    state.message.contains('الاتصال بالخادم') ? 
                    Icons.wifi_off : Icons.error_outline,
                    size: 64.sp,
                    color: state.message.contains('اتصال بالإنترنت') || 
                           state.message.contains('الاتصال بالخادم') ? 
                           Colors.blue[700] : Colors.red,
                  ),
                  SizedBox(height: 16.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text(
                      state.message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: state.message.contains('اتصال بالإنترنت') || 
                               state.message.contains('الاتصال بالخادم') ? 
                               Colors.blue[700] : Colors.red[700],
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // إضافة نص توضيحي إضافي في حالة مشكلة الاتصال
                  if (state.message.contains('اتصال بالإنترنت') || 
                      state.message.contains('الاتصال بالخادم'))
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        'تأكد من اتصالك بالإنترنت وحاول مرة أخرى',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<QuranAudioCubit>().getReciters();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.logoTeal,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                    ),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }
}