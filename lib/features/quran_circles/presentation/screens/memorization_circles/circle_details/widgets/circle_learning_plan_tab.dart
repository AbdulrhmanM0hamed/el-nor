import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class CircleLearningPlanTab extends StatefulWidget {
  final String learningPlanUrl;

  const CircleLearningPlanTab({
    Key? key,
    required this.learningPlanUrl,
  }) : super(key: key);

  @override
  State<CircleLearningPlanTab> createState() => _CircleLearningPlanTabState();
}

class _CircleLearningPlanTabState extends State<CircleLearningPlanTab> {
  late Future<Uint8List> _pdfFuture;

  @override
  void initState() {
    super.initState();
    _pdfFuture = _fetchPdf();
  }

  Future<Uint8List> _fetchPdf() async {
    final trimmedUrl = widget.learningPlanUrl.trim();
    if (trimmedUrl.isEmpty) {
      throw Exception('URL is empty.');
    }

    final uri = Uri.parse(trimmedUrl);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception(
          'Failed to load PDF. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.learningPlanUrl.trim().isEmpty) {
      return const Center(
        child: Text(
          'لا توجد خطة تعلم متاحة حالياً',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return FutureBuilder<Uint8List>(
      future: _pdfFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'فشل تحميل خطة التعلم: ',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ),
          );
        } else if (snapshot.hasData) {
          return SfPdfViewer.memory(snapshot.data!);
        } else {
          return const Center(
            child: Text(
              'لا يمكن عرض خطة التعلم',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }
      },
    );
  }
}
