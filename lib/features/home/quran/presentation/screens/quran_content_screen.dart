import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path_provider/path_provider.dart';
import '../cubit/quran_cubit.dart';
import '../cubit/quran_state.dart';
import '../widgets/table_of_contents.dart';
import '../widgets/quran_pdf_viewer.dart';
import '../widgets/bookmarks_overlay.dart';
import '../widgets/quran_app_bar.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/quran_dialogs.dart';
import '../../data/models/bookmark_model.dart';

/// A screen that displays the Quran content in a PDF viewer with RTL support
/// 
/// This screen has been refactored to use separate widget components for:
/// - PDF viewer
/// - App bar
/// - Bookmarks overlay
/// - Loading indicator
/// - Dialogs
class QuranContentScreen extends StatefulWidget {
  const QuranContentScreen({Key? key}) : super(key: key);

  @override
  State<QuranContentScreen> createState() => _QuranContentScreenState();
}

class _QuranContentScreenState extends State<QuranContentScreen> with WidgetsBindingObserver {
  // UI States
  bool _showControls = true;
  bool _showBookmarks = false;
  
  // PDF States
  String? _pdfPath;
  int _currentPage = 1;
  
  // Text controller for bookmark title
  final TextEditingController _bookmarkTitleController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadDocument();
    
    // Show zoom hint dialog
    WidgetsBinding.instance.addPostFrameCallback((_) {
      QuranDialogs.showZoomHintDialogIfNeeded(context);
    });
  }
  
  @override
  void dispose() {
    _bookmarkTitleController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Release resources when app is in background
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      // PDF viewer handles memory management internally
    }
  }

  /// Load the PDF from assets
  Future<void> _loadDocument() async {
    try {
      final ByteData data = await rootBundle.load('assets/pdf/quran.pdf');
      final Directory tempDir = await getTemporaryDirectory();
      final File tempFile = File('${tempDir.path}/quran.pdf');
      await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
      
      setState(() {
        _pdfPath = tempFile.path;
      });
    } catch (e) {
      debugPrint('Error loading PDF: $e');
    }
  }

  /// Toggle control visibility
  void _toggleControls() {
    setState(() => _showControls = !_showControls);
  }
  
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuranCubit, QuranState>(
      listenWhen: (previous, current) {
        return previous.isTableOfContentsVisible != current.isTableOfContentsVisible ||
               previous.currentPage != current.currentPage;
      },
      listener: (context, state) {
        // No need to handle page jumps here as it's handled in the PDF viewer widget
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _showControls ? _buildAppBar() : null,
          body: Stack(
            children: [
              // Main content: PDF viewer or loading indicator
              _buildMainContent(),
              
              // Bookmarks overlay
              if (_showBookmarks) _buildBookmarksOverlay(state.bookmarks),
              
              // Table of Contents
              const TableOfContents(),
            ],
          ),
        );
      },
    );
  }
  
  /// Build the app bar with bookmark button
  PreferredSizeWidget _buildAppBar() {
    return QuranAppBar(
      onBookmarkPressed: () => _showAddBookmarkDialog(),
      onBookmarksListPressed: () {
        setState(() {
          _showBookmarks = !_showBookmarks;
        });
      },
    );
  }
  
  /// Build the main content (PDF viewer or loading indicator)
  Widget _buildMainContent() {
    if (_pdfPath == null) {
      return const LoadingIndicator();
    } else {
      return QuranPdfViewer(
        pdfPath: _pdfPath!,
        onTap: _toggleControls,
        currentPage: _currentPage,
        onRender: () {
          // PDF is fully rendered
        },
      );
    }
  }
  
  /// Build the bookmarks overlay
  Widget _buildBookmarksOverlay(List<QuranBookmark> bookmarks) {
    return BookmarksOverlay(
      bookmarks: bookmarks,
      onClose: () {
        setState(() {
          _showBookmarks = false;
        });
      },
    );
  }
  
  /// Show dialog to add or update a bookmark
  void _showAddBookmarkDialog() {
    QuranDialogs.showAddBookmarkDialog(context, _bookmarkTitleController);
  }
}
