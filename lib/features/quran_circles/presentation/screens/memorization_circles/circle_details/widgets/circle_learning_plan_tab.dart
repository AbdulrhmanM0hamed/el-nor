import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class CircleLearningPlanTab extends StatelessWidget {
  final String? learningPlanUrl;

  const CircleLearningPlanTab({
    Key? key,
    required this.learningPlanUrl,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (learningPlanUrl == null || learningPlanUrl!.isEmpty) {
      return const Center(
        child: Text('لم يتم رفع خطة التعلم بعد'),
      );
    }

    return GestureDetector(
      onTap: () {}, // This prevents navigation when tapping on the PDF
      child: SfPdfViewer.network(
        learningPlanUrl!,
        enableDoubleTapZooming: true,
        enableDocumentLinkAnnotation: true,
        onDocumentLoaded: (details) {
          // Handle document loaded if needed
        },
      ),
    );
  }
}
