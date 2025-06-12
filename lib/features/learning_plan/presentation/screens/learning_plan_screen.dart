import 'dart:io';

import 'package:beat_elslam/core/widgets/custom_app_bar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import '../../../../core/services/service_locator.dart' as di;
import '../../../auth/data/models/user_model.dart';
import '../cubit/learning_plan_cubit.dart';

class LearningPlanScreen extends StatelessWidget {
  static const String routeName = '/learning-plan';
  final UserModel user;

  const LearningPlanScreen({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LearningPlanCubit>(
      create: (_) =>
          di.sl<LearningPlanCubit>(param1: user.isAdmin)..fetchPlan(),
      child: const _LearningPlanView(),
    );
  }
}

class _LearningPlanView extends StatelessWidget {
  const _LearningPlanView();

  Future<void> _pickAndUpload(BuildContext context) async {
    final res = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (res != null && res.files.single.path != null) {
      final file = File(res.files.single.path!);
      context.read<LearningPlanCubit>().uploadPlan(file);
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف خطة التعلم'),
        content: const Text(
            'هل أنت متأكد من حذف الخطة؟ لا يمكن التراجع عن هذا الإجراء.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<LearningPlanCubit>().deletePlan();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.select<LearningPlanCubit, bool>((c) => c.isAdmin);

    return Scaffold(
      appBar: const CustomAppBar(title: 'خطة التعلم'),
      floatingActionButton: isAdmin
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: 'upload',
                  onPressed: () => _pickAndUpload(context),
                  child: const Icon(Icons.upload_file),
                ),
                SizedBox(height: 12.h),
                FloatingActionButton(
                  heroTag: 'delete',
                  backgroundColor: Colors.red,
                  onPressed: () => _confirmDelete(context),
                  child: const Icon(Icons.delete),
                ),
              ],
            )
          : null,
      body: BlocBuilder<LearningPlanCubit, LearningPlanState>(
        builder: (context, state) {
          if (state is LearningPlanLoading || state is LearningPlanUploading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is LearningPlanError) {
            return Center(child: Text(state.message));
          }

          if (state is LearningPlanEmpty) {
            return const Center(child: Text('لم يتم رفع خطة التعلم بعد'));
          }

          if (state is LearningPlanLoaded) {
            return Padding(
              padding: EdgeInsets.all(8.w),
              child: SfPdfViewer.network(state.url),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
