import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import '../cubit/quran_cubit.dart';
import '../cubit/quran_state.dart';

/// A widget that displays the Quran PDF with proper page handling
class QuranPdfViewer extends StatefulWidget {
  /// Path to the PDF file
  final String pdfPath;
  
  /// Callback when the user taps on the PDF viewer
  final VoidCallback onTap;
  
  /// Current page in Quran numbering (1-604)
  final int currentPage;
  
  /// Callback when PDF is fully rendered
  final Function() onRender;
  
  const QuranPdfViewer({
    Key? key,
    required this.pdfPath,
    required this.onTap,
    required this.currentPage,
    required this.onRender,
  }) : super(key: key);

  @override
  State<QuranPdfViewer> createState() => _QuranPdfViewerState();
}

class _QuranPdfViewerState extends State<QuranPdfViewer> {
  /// Controller for the PDF view
  PDFViewController? _pdfViewController;
  
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuranCubit, QuranState>(
      listener: (context, state) {
        // Listen for page changes from outside (like table of contents navigation)
        // and update the PDF viewer accordingly
        if (_pdfViewController != null && state.currentPage != widget.currentPage) {
          debugPrint('QuranPdfViewer: Detected navigation to page ${state.currentPage}');
          _jumpToQuranPage(state.currentPage);
        }
      },
      builder: (context, state) {
        final cubit = context.read<QuranCubit>();
        
        return GestureDetector(
          onTap: widget.onTap,
          child: PDFView(
            filePath: widget.pdfPath,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: false,
            pageFling: true,
            pageSnap: true,
            fitPolicy: FitPolicy.BOTH,
            nightMode: false,
            onRender: (_pages) {
              widget.onRender();
            },
            onError: (error) {
              debugPrint('Error loading PDF: $error');
            },
            onPageError: (page, error) {
              debugPrint('Error loading page $page: $error');
            },
            onViewCreated: (PDFViewController pdfViewController) {
              _pdfViewController = pdfViewController;
              
              // Jump to the current page when PDF is loaded
              Future.delayed(const Duration(milliseconds: 300), () {
                debugPrint('QuranPdfViewer: Initial jump to page ${state.currentPage}');
                _jumpToQuranPage(state.currentPage);
              });
            },
            onPageChanged: (int? page, int? total) {
              if (page != null) {
                cubit.onPageChanged(page);
              }
            },
          ),
        );
      },
    );
  }
  
  /// Jump to a specific Quran page
  void _jumpToQuranPage(int page) {
    if (_pdfViewController != null) {
      final pdfIndex = QuranCubit.convertToPdfIndex(page);
      debugPrint('QuranPdfViewer: Jumping to page $page (PDF index: $pdfIndex)');
      _pdfViewController!.setPage(pdfIndex);
    } else {
      debugPrint('QuranPdfViewer: Cannot jump to page $page - controller is null');
    }
  }
}
