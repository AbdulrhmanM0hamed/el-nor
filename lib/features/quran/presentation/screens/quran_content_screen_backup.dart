// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_pdfview/flutter_pdfview.dart';
// import 'package:path_provider/path_provider.dart';
// import '../cubit/quran_cubit.dart';
// import '../cubit/quran_state.dart';
// import '../widgets/table_of_contents.dart';
// import '../../data/models/bookmark_model.dart';
// import '../../../../core/utils/constant/font_manger.dart';
// import '../../../../core/utils/constant/styles_manger.dart';
// import '../../../../core/utils/theme/app_colors.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// /// A screen that displays the Quran content in a PDF viewer with RTL support
// class QuranContentScreen extends StatefulWidget {
//   const QuranContentScreen({Key? key}) : super(key: key);

//   @override
//   State<QuranContentScreen> createState() => _QuranContentScreenState();
// }

// class _QuranContentScreenState extends State<QuranContentScreen> with WidgetsBindingObserver {
//   // UI States
//   bool _isLoading = true;
//   bool _showControls = true;
//   bool _showBookmarks = false;
  
//   // PDF States
//   String? _pdfPath;
//   int _currentPage = 1;
//   int _totalPages = 604; // Total pages in Quran
//   PDFViewController? _pdfViewController;
  
//   // Text controller for bookmark title
//   final TextEditingController _bookmarkTitleController = TextEditingController();
  
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addObserver(this);
//     _showZoomHintDialogIfNeeded();
//     _loadDocument();
//   }
  
//   @override
//   void dispose() {
//     _bookmarkTitleController.dispose();
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }
  
//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     // Release resources when app is in background
//     if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
//       // PDF viewer handles memory management internally
//     }
//   }

//   // Load the PDF from assets
//   Future<void> _loadDocument() async {
//     try {
//       final ByteData data = await rootBundle.load('assets/pdf/quran.pdf');
//       final Directory tempDir = await getTemporaryDirectory();
//       final File tempFile = File('${tempDir.path}/quran.pdf');
//       await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
      
//       setState(() {
//         _pdfPath = tempFile.path;
//       });
//     } catch (e) {
//       debugPrint('Error loading PDF: $e');
//     }
//   }

//   // Toggle control visibility
//   void _toggleControls() {
//     setState(() => _showControls = !_showControls);
//   }
  
//   // Jump to a specific Quran page
//   void _jumpToQuranPage(int page) {
//     if (_pdfViewController != null) {
//       final pdfIndex = QuranCubit.convertToPdfIndex(page);
//       _pdfViewController!.setPage(pdfIndex);
//     }
//   }
  
//   // Show zoom hint dialog only once using shared_preferences
//   void _showZoomHintDialogIfNeeded() async {
//     final prefs = await SharedPreferences.getInstance();
//     final shown = prefs.getBool('zoom_hint_shown') ?? false;
//     if (!shown && mounted) {
//       await Future.delayed(const Duration(milliseconds: 400));
//       if (!mounted) return;
//       await showDialog(
//         context: context,
//         barrierDismissible: true,
//         builder: (context) => AlertDialog(
//           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//           contentPadding: const EdgeInsets.all(20),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Image.asset(
//                 'assets/images/zoom.png',
//                 width: 90,
//                 height: 90,
//                 fit: BoxFit.contain,
//               ),
//               const SizedBox(height: 18),
//               Text(
//                 'يمكنك تكبير أو تصغير صفحة المصحف بسهولة!\n\nاستخدم إصبعيك للتكبير (Zoom In) أو التصغير (Zoom Out) بحرية لقراءة أوضح وأكثر راحة.',
//                 textAlign: TextAlign.center,
//                 style: getMediumStyle(
//                   fontFamily: FontConstant.cairo,
//                   fontSize: 16,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               ElevatedButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: AppColors.primary,
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//                 child: Text(
//                   'فهمت',
//                   style: getBoldStyle(
//                     fontFamily: FontConstant.cairo,
//                     fontSize: 15,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//       await prefs.setBool('zoom_hint_shown', true);
//     }
//   }
  
//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<QuranCubit, QuranState>(
//       listenWhen: (previous, current) {
//         return previous.isTableOfContentsVisible != current.isTableOfContentsVisible ||
//                previous.currentPage != current.currentPage;
//       },
//       listener: (context, state) {
//         if (!_isLoading && _currentPage != state.currentPage) {
//           _jumpToQuranPage(state.currentPage);
//         }
//       },
//       builder: (context, state) {
//         return Scaffold(
//           backgroundColor: Colors.white,
//           appBar: _showControls ? _buildAppBar(context, state) : null,
//           body: Stack(
//             children: [
//               // Main content: PDF viewer or loading indicator
//               _pdfPath == null
//                   ? _buildLoadingIndicator()
//                   : GestureDetector(
//                       onTap: _toggleControls,
//                       child: _buildPdfViewer(context),
//                     ),
              
//               // Bookmarks overlay
//               if (_showBookmarks) _buildBookmarksOverlay(context, state.bookmarks),
              
//               // Table of Contents
//               const TableOfContents(),
//             ],
//           ),
//         );
//       },
//     );
//   }
  
//   // Build the bookmarks overlay
//   Widget _buildBookmarksOverlay(BuildContext context, List<QuranBookmark> bookmarks) {
//     return Container(
//       color: Colors.black.withOpacity(0.85),
//       child: SafeArea(
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//               color: AppColors.primary,
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.close, color: Colors.white),
//                     onPressed: () {
//                       setState(() {
//                         _showBookmarks = false;
//                       });
//                     },
//                   ),
//                   Expanded(
//                     child: Text(
//                       'الإشارات المرجعية',
//                       textAlign: TextAlign.center,
//                       style: getBoldStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 18,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 48), // Balance the close button
//                 ],
//               ),
//             ),
            
//             // Bookmarks list
//             Expanded(
//               child: bookmarks.isEmpty
//                   ? _buildEmptyBookmarksMessage()
//                   : ListView.builder(
//                       itemCount: bookmarks.length,
//                       padding: const EdgeInsets.all(16),
//                       itemBuilder: (context, index) {
//                         final bookmark = bookmarks[index];
//                         return _buildBookmarkCard(context, bookmark);
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   // Build a message when there are no bookmarks
//   Widget _buildEmptyBookmarksMessage() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(
//             Icons.bookmark_border,
//             size: 80,
//             color: Colors.white54,
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'لا توجد إشارات مرجعية حتى الآن',
//             textAlign: TextAlign.center,
//             style: getMediumStyle(
//               fontFamily: FontConstant.cairo,
//               fontSize: 18,
//               color: Colors.white70,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'اضغط على زر الإشارة المرجعية في الشريط العلوي لحفظ موقع القراءة الحالي',
//             textAlign: TextAlign.center,
//             style: getRegularStyle(
//               fontFamily: FontConstant.cairo,
//               fontSize: 16,
//               color: Colors.white54,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   // Build a bookmark card
//   Widget _buildBookmarkCard(BuildContext context, QuranBookmark bookmark) {
//     final formattedDate = _formatBookmarkDate(bookmark.timestamp);
    
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       color: Colors.white,
//       elevation: 4,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () {
//           // Navigate to the bookmarked page
//           context.read<QuranCubit>().navigateToPage(bookmark.pageNumber);
          
//           // Close the bookmarks overlay
//           setState(() {
//             _showBookmarks = false;
//           });
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               // Page indicator
//               Container(
//                 width: 50,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Center(
//                   child: Text(
//                     '${bookmark.pageNumber}',
//                     style: getBoldStyle(
//                       fontFamily: FontConstant.cairo,
//                       fontSize: 18,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               // Bookmark details
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       bookmark.title,
//                       style: getBoldStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 16,
//                         color: AppColors.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       formattedDate,
//                       style: getRegularStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 14,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Navigate icon
//               const Icon(
//                 Icons.arrow_forward_ios,
//                 size: 16,
//                 color: AppColors.textSecondary,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
  
//   // Format the bookmark date
//   String _formatBookmarkDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);
    
//     if (difference.inDays == 0) {
//       if (difference.inHours == 0) {
//         return 'منذ ${difference.inMinutes} دقيقة';
//       }
//       return 'منذ ${difference.inHours} ساعة';
//     } else if (difference.inDays < 7) {
//       return 'منذ ${difference.inDays} يوم';
//     } else {
//       return '${date.year}/${date.month}/${date.day}';
//     }
//   }
  
//   // Build the app bar with bookmark button
//   PreferredSizeWidget _buildAppBar(BuildContext context, QuranState state) {
//     return AppBar(
//       backgroundColor: AppColors.primary,
//       elevation: 4,
//       title: Text(
//         'القرآن الكريم - صفحة ${state.currentPage}',
//         style: getBoldStyle(
//           fontFamily: FontConstant.cairo,
//           fontSize: 18,
//           color: Colors.white,
//         ),
//       ),
//       leading: IconButton(
//         icon: const Icon(Icons.menu_book, color: Colors.white),
//         onPressed: () {
//           context.read<QuranCubit>().toggleTableOfContents();
//         },
//       ),
//       actions: [
//         // Bookmark button
//         _buildBookmarkButton(context),
        
//         // Bookmarks list button
//         IconButton(
//           icon: const Icon(Icons.bookmarks, color: Colors.white),
//           onPressed: () {
//             setState(() {
//               _showBookmarks = !_showBookmarks;
//             });
//           },
//           tooltip: 'الإشارات المرجعية',
//         ),
//       ],
//     );
//   }
  
//   // Build the bookmarks overlay
//   Widget _buildBookmarksOverlay(BuildContext context, List<QuranBookmark> bookmarks) {
//     return Container(
//       color: Colors.black.withOpacity(0.85),
//       child: SafeArea(
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//               color: AppColors.primary,
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.close, color: Colors.white),
//                     onPressed: () {
//                       setState(() {
//                         _showBookmarks = false;
//                       });
//                     },
//                   ),
//                   Expanded(
//                     child: Text(
//                       'الإشارات المرجعية',
//                       textAlign: TextAlign.center,
//                       style: getBoldStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 18,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 48), // Balance the close button
//                 ],
//               ),
//             ),
            
//             // Bookmarks list
//             Expanded(
//               child: bookmarks.isEmpty
//                   ? _buildEmptyBookmarksMessage()
//                   : ListView.builder(
//                       itemCount: bookmarks.length,
//                       padding: const EdgeInsets.all(16),
//                       itemBuilder: (context, index) {
//                         final bookmark = bookmarks[index];
//                         return _buildBookmarkCard(context, bookmark);
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   // Build a message when there are no bookmarks
//   Widget _buildEmptyBookmarksMessage() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(
//             Icons.bookmark_border,
//             size: 80,
//             color: Colors.white54,
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'لا توجد إشارات مرجعية حتى الآن',
//             textAlign: TextAlign.center,
//             style: getMediumStyle(
//               fontFamily: FontConstant.cairo,
//               fontSize: 18,
//               color: Colors.white70,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'اضغط على زر الإشارة المرجعية في الشريط العلوي لحفظ موقع القراءة الحالي',
//             textAlign: TextAlign.center,
//             style: getRegularStyle(
//               fontFamily: FontConstant.cairo,
//               fontSize: 16,
//               color: Colors.white54,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   // Build a bookmark card
//   Widget _buildBookmarkCard(BuildContext context, QuranBookmark bookmark) {
//     final formattedDate = _formatBookmarkDate(bookmark.timestamp);
    
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       color: Colors.white,
//       elevation: 4,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () {
//           // Navigate to the bookmarked page
//           context.read<QuranCubit>().navigateToPage(bookmark.pageNumber);
          
//           // Close the bookmarks overlay
//           setState(() {
//             _showBookmarks = false;
//           });
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               // Page indicator
//               Container(
//                 width: 50,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Center(
//                   child: Text(
//                     '${bookmark.pageNumber}',
//                     style: getBoldStyle(
//                       fontFamily: FontConstant.cairo,
//                       fontSize: 18,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               // Bookmark details
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       bookmark.title,
//                       style: getBoldStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 16,
//                         color: AppColors.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       formattedDate,
//                       style: getRegularStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 14,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Navigate icon
//               const Icon(
//                 Icons.arrow_forward_ios,
//                 size: 16,
//                 color: AppColors.textSecondary,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
  
//   // Format the bookmark date
//   String _formatBookmarkDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);
    
//     if (difference.inDays == 0) {
//       if (difference.inHours == 0) {
//         return 'منذ ${difference.inMinutes} دقيقة';
//       }
//       return 'منذ ${difference.inHours} ساعة';
//     } else if (difference.inDays < 7) {
//       return 'منذ ${difference.inDays} يوم';
//     } else {
//       return '${date.year}/${date.month}/${date.day}';
//     }
//   }

//   // Bookmark button for the app bar
//   Widget _buildBookmarkButton(BuildContext context) {
//     return BlocBuilder<QuranCubit, QuranState>(
//       buildWhen: (previous, current) => 
//         previous.bookmarks != current.bookmarks || 
//         previous.currentPage != current.currentPage,
//       builder: (context, state) {
//         final isBookmarked = state.bookmarks.any(
//           (bookmark) => bookmark.pageNumber == state.currentPage
//         );
        
//         return IconButton(
//           icon: Icon(
//             isBookmarked ? Icons.bookmark : Icons.bookmark_add_outlined,
//             color: Colors.white,
//           ),
//           onPressed: () => _showAddBookmarkDialog(context),
//           tooltip: isBookmarked ? 'تعديل الإشارة المرجعية' : 'إضافة إشارة مرجعية',
//         );
//       },
//     );
//   }
  
//   // Build the bookmarks overlay
//   Widget _buildBookmarksOverlay(BuildContext context, List<QuranBookmark> bookmarks) {
//     return Container(
//       color: Colors.black.withOpacity(0.85),
//       child: SafeArea(
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//               color: AppColors.primary,
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.close, color: Colors.white),
//                     onPressed: () {
//                       setState(() {
//                         _showBookmarks = false;
//                       });
//                     },
//                   ),
//                   Expanded(
//                     child: Text(
//                       'الإشارات المرجعية',
//                       textAlign: TextAlign.center,
//                       style: getBoldStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 18,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 48), // Balance the close button
//                 ],
//               ),
//             ),
            
//             // Bookmarks list
//             Expanded(
//               child: bookmarks.isEmpty
//                   ? _buildEmptyBookmarksMessage()
//                   : ListView.builder(
//                       itemCount: bookmarks.length,
//                       padding: const EdgeInsets.all(16),
//                       itemBuilder: (context, index) {
//                         final bookmark = bookmarks[index];
//                         return _buildBookmarkCard(context, bookmark);
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   // Build a message when there are no bookmarks
//   Widget _buildEmptyBookmarksMessage() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(
//             Icons.bookmark_border,
//             size: 80,
//             color: Colors.white54,
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'لا توجد إشارات مرجعية حتى الآن',
//             textAlign: TextAlign.center,
//             style: getMediumStyle(
//               fontFamily: FontConstant.cairo,
//               fontSize: 18,
//               color: Colors.white70,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'اضغط على زر الإشارة المرجعية في الشريط العلوي لحفظ موقع القراءة الحالي',
//             textAlign: TextAlign.center,
//             style: getRegularStyle(
//               fontFamily: FontConstant.cairo,
//               fontSize: 16,
//               color: Colors.white54,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   // Build a bookmark card
//   Widget _buildBookmarkCard(BuildContext context, QuranBookmark bookmark) {
//     final formattedDate = _formatBookmarkDate(bookmark.timestamp);
    
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       color: Colors.white,
//       elevation: 4,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () {
//           // Navigate to the bookmarked page
//           context.read<QuranCubit>().navigateToPage(bookmark.pageNumber);
          
//           // Close the bookmarks overlay
//           setState(() {
//             _showBookmarks = false;
//           });
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               // Page indicator
//               Container(
//                 width: 50,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Center(
//                   child: Text(
//                     '${bookmark.pageNumber}',
//                     style: getBoldStyle(
//                       fontFamily: FontConstant.cairo,
//                       fontSize: 18,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               // Bookmark details
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       bookmark.title,
//                       style: getBoldStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 16,
//                         color: AppColors.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       formattedDate,
//                       style: getRegularStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 14,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Navigate icon
//               const Icon(
//                 Icons.arrow_forward_ios,
//                 size: 16,
//                 color: AppColors.textSecondary,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
  
//   // Format the bookmark date
//   String _formatBookmarkDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);
    
//     if (difference.inDays == 0) {
//       if (difference.inHours == 0) {
//         return 'منذ ${difference.inMinutes} دقيقة';
//       }
//       return 'منذ ${difference.inHours} ساعة';
//     } else if (difference.inDays < 7) {
//       return 'منذ ${difference.inDays} يوم';
//     } else {
//       return '${date.year}/${date.month}/${date.day}';
//     }
//   }
  
//   // Loading indicator widget
//   Widget _buildLoadingIndicator() {
//     return Container(
//       color: Colors.white,
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.menu_book_rounded,
//               size: 70,
//               color: AppColors.primary.withOpacity(0.5),
//             ),
//             const SizedBox(height: 20),
//             Text(
//               'جاري تجهيز المصحف...',
//               style: getMediumStyle(
//                 fontFamily: FontConstant.cairo,
//                 fontSize: 18,
//                 color: AppColors.textSecondary,
//               ),
//             ),
//             const SizedBox(height: 20),
//             const CircularProgressIndicator(),
//           ],
//         ),
//       ),
//     );
//   }
  
//   // Build the bookmarks overlay
//   Widget _buildBookmarksOverlay(BuildContext context, List<QuranBookmark> bookmarks) {
//     return Container(
//       color: Colors.black.withOpacity(0.85),
//       child: SafeArea(
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//               color: AppColors.primary,
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.close, color: Colors.white),
//                     onPressed: () {
//                       setState(() {
//                         _showBookmarks = false;
//                       });
//                     },
//                   ),
//                   Expanded(
//                     child: Text(
//                       'الإشارات المرجعية',
//                       textAlign: TextAlign.center,
//                       style: getBoldStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 18,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 48), // Balance the close button
//                 ],
//               ),
//             ),
            
//             // Bookmarks list
//             Expanded(
//               child: bookmarks.isEmpty
//                   ? _buildEmptyBookmarksMessage()
//                   : ListView.builder(
//                       itemCount: bookmarks.length,
//                       padding: const EdgeInsets.all(16),
//                       itemBuilder: (context, index) {
//                         final bookmark = bookmarks[index];
//                         return _buildBookmarkCard(context, bookmark);
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   // Build a message when there are no bookmarks
//   Widget _buildEmptyBookmarksMessage() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(
//             Icons.bookmark_border,
//             size: 80,
//             color: Colors.white54,
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'لا توجد إشارات مرجعية حتى الآن',
//             textAlign: TextAlign.center,
//             style: getMediumStyle(
//               fontFamily: FontConstant.cairo,
//               fontSize: 18,
//               color: Colors.white70,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'اضغط على زر الإشارة المرجعية في الشريط العلوي لحفظ موقع القراءة الحالي',
//             textAlign: TextAlign.center,
//             style: getRegularStyle(
//               fontFamily: FontConstant.cairo,
//               fontSize: 16,
//               color: Colors.white54,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   // Build a bookmark card
//   Widget _buildBookmarkCard(BuildContext context, QuranBookmark bookmark) {
//     final formattedDate = _formatBookmarkDate(bookmark.timestamp);
    
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       color: Colors.white,
//       elevation: 4,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () {
//           // Navigate to the bookmarked page
//           context.read<QuranCubit>().navigateToPage(bookmark.pageNumber);
          
//           // Close the bookmarks overlay
//           setState(() {
//             _showBookmarks = false;
//           });
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               // Page indicator
//               Container(
//                 width: 50,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Center(
//                   child: Text(
//                     '${bookmark.pageNumber}',
//                     style: getBoldStyle(
//                       fontFamily: FontConstant.cairo,
//                       fontSize: 18,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               // Bookmark details
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       bookmark.title,
//                       style: getBoldStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 16,
//                         color: AppColors.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       formattedDate,
//                       style: getRegularStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 14,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Navigate icon
//               const Icon(
//                 Icons.arrow_forward_ios,
//                 size: 16,
//                 color: AppColors.textSecondary,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
  
//   // Format the bookmark date
//   String _formatBookmarkDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);
    
//     if (difference.inDays == 0) {
//       if (difference.inHours == 0) {
//         return 'منذ ${difference.inMinutes} دقيقة';
//       }
//       return 'منذ ${difference.inHours} ساعة';
//     } else if (difference.inDays < 7) {
//       return 'منذ ${difference.inDays} يوم';
//     } else {
//       return '${date.year}/${date.month}/${date.day}';
//     }
//   }
  
//   // PDF Viewer widget
//   Widget _buildPdfViewer(BuildContext context) {
//     final cubit = context.read<QuranCubit>();
//     final initialQuranPage = cubit.state.currentPage;
//     final initialPdfPageIndex = QuranCubit.convertToPdfIndex(initialQuranPage);
    
//     debugPrint('=== PDF Viewer Setup ===');
//     debugPrint('Initial Quran page from cubit: $initialQuranPage');
//     debugPrint('Initial PDF page index: $initialPdfPageIndex');
//     debugPrint('Total pages: $_totalPages');
    
//     return PDFView(
//       filePath: _pdfPath!,
//       enableSwipe: true,
//       swipeHorizontal: true,
//       autoSpacing: false,
//       pageFling: true,
//       pageSnap: true,
//       defaultPage: initialPdfPageIndex,
//       fitPolicy: FitPolicy.WIDTH,
//       preventLinkNavigation: false,
//       onRender: (_pages) {
//         debugPrint('PDF Rendered with ${_pages ?? 0} pages');
//         setState(() {
//           _isLoading = false;
//           _totalPages = _pages!;
          
//           // Get the current page from the cubit
//           _currentPage = cubit.state.currentPage;
//           debugPrint('Current page after render: $_currentPage');
//         });
//       },
//       onError: (error) {
//         debugPrint('PDF Error: $error');
//       },
//       onPageChanged: (int? pdfPageIndex, int? total) {
//         if (pdfPageIndex != null && total != null) {
//           // نحول من فهرس PDF إلى رقم صفحة قرآن أصلي
//           final originalQuranPage = QuranCubit.convertFromPdfIndex(pdfPageIndex);
          
//           debugPrint('PDF Page changed: index=$pdfPageIndex, converted to original Quran page=$originalQuranPage');
          
//           setState(() {
//             _currentPage = originalQuranPage;
//           });
          
//           // حفظ الصفحة في حالة الـ cubit
//           cubit.onPageChanged(pdfPageIndex);
//         }
//       },
//       onViewCreated: (PDFViewController controller) {
//         _pdfViewController = controller;
        
//         // Set initial page based on cubit state
//         final initialQuranPage = cubit.state.currentPage;
//         final initialPdfPageIndex = QuranCubit.convertToPdfIndex(initialQuranPage);
        
//         debugPrint('PDF View Created:');
//         debugPrint('Initial Quran page: $initialQuranPage');
//         debugPrint('Initial PDF index: $initialPdfPageIndex');
        
//         Future.delayed(const Duration(milliseconds: 100), () {
//           _pdfViewController?.setPage(initialPdfPageIndex);
//           debugPrint('Delayed setPage to $initialPdfPageIndex');
//         });
//       },
//     );
//   }
  
//   // Build the bookmarks overlay
//   Widget _buildBookmarksOverlay(BuildContext context, List<QuranBookmark> bookmarks) {
//     return Container(
//       color: Colors.black.withOpacity(0.85),
//       child: SafeArea(
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//               color: AppColors.primary,
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.close, color: Colors.white),
//                     onPressed: () {
//                       setState(() {
//                         _showBookmarks = false;
//                       });
//                     },
//                   ),
//                   Expanded(
//                     child: Text(
//                       'الإشارات المرجعية',
//                       textAlign: TextAlign.center,
//                       style: getBoldStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 18,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 48), // Balance the close button
//                 ],
//               ),
//             ),
            
//             // Bookmarks list
//             Expanded(
//               child: bookmarks.isEmpty
//                   ? _buildEmptyBookmarksMessage()
//                   : ListView.builder(
//                       itemCount: bookmarks.length,
//                       padding: const EdgeInsets.all(16),
//                       itemBuilder: (context, index) {
//                         final bookmark = bookmarks[index];
//                         return _buildBookmarkCard(context, bookmark);
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   // Build a message when there are no bookmarks
//   Widget _buildEmptyBookmarksMessage() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(
//             Icons.bookmark_border,
//             size: 80,
//             color: Colors.white54,
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'لا توجد إشارات مرجعية حتى الآن',
//             textAlign: TextAlign.center,
//             style: getMediumStyle(
//               fontFamily: FontConstant.cairo,
//               fontSize: 18,
//               color: Colors.white70,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'اضغط على زر الإشارة المرجعية في الشريط العلوي لحفظ موقع القراءة الحالي',
//             textAlign: TextAlign.center,
//             style: getRegularStyle(
//               fontFamily: FontConstant.cairo,
//               fontSize: 16,
//               color: Colors.white54,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   // Build a bookmark card
//   Widget _buildBookmarkCard(BuildContext context, QuranBookmark bookmark) {
//     final formattedDate = _formatBookmarkDate(bookmark.timestamp);
    
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       color: Colors.white,
//       elevation: 4,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () {
//           // Navigate to the bookmarked page
//           context.read<QuranCubit>().navigateToPage(bookmark.pageNumber);
          
//           // Close the bookmarks overlay
//           setState(() {
//             _showBookmarks = false;
//           });
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               // Page indicator
//               Container(
//                 width: 50,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Center(
//                   child: Text(
//                     '${bookmark.pageNumber}',
//                     style: getBoldStyle(
//                       fontFamily: FontConstant.cairo,
//                       fontSize: 18,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               // Bookmark details
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       bookmark.title,
//                       style: getBoldStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 16,
//                         color: AppColors.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       formattedDate,
//                       style: getRegularStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 14,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Navigate icon
//               const Icon(
//                 Icons.arrow_forward_ios,
//                 size: 16,
//                 color: AppColors.textSecondary,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
  
//   // Format the bookmark date
//   String _formatBookmarkDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);
    
//     if (difference.inDays == 0) {
//       if (difference.inHours == 0) {
//         return 'منذ ${difference.inMinutes} دقيقة';
//       }
//       return 'منذ ${difference.inHours} ساعة';
//     } else if (difference.inDays < 7) {
//       return 'منذ ${difference.inDays} يوم';
//     } else {
//       return '${date.year}/${date.month}/${date.day}';
//     }
//   }
  
//   // Bottom navigation bar
//   Widget _buildBottomNavBar(BuildContext context, QuranState state) {
//     return AnimatedOpacity(
//       opacity: 1.0,
//       duration: const Duration(milliseconds: 200),
//       child: Positioned(
//         bottom: 0,
//         left: 0,
//         right: 0,
//         child: Container(
//           height: 60,
//           color: Colors.black.withOpacity(0.6),
//           child: SafeArea(
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 // Next page button (right side in Arabic reading, moves to higher Quran page number)
//                 // In the reversed PDF, this means moving to a lower PDF page index
//                 _buildNavButton(
//                   label: 'التالية',
//                   icon: Icons.arrow_forward_ios,
//                   iconFirst: true,
//                   onPressed: () {
//                     if (_pdfViewController != null) {
//                       // Convert current Quran page to PDF index, then navigate to next Quran page
//                       // Since PDF is reversed, we need to decrease the PDF page index to move forward in the Quran
//                       final currentPdfPageIndex = QuranCubit.convertToPdfIndex(_currentPage);
//                       // We check if there are pages before the current one (in a reversed context)
//                       if (currentPdfPageIndex > 0) {
//                         _pdfViewController!.setPage(currentPdfPageIndex - 1);
//                       }
//                     }
//                   },
//                   tooltip: 'الصفحة التالية',
//                 ),
                
//                 // Table of contents button
//                 IconButton(
//                   icon: const Icon(Icons.menu, color: Colors.white),
//                   onPressed: () => context.read<QuranCubit>().toggleTableOfContents(),
//                   tooltip: 'الفهرس',
//                 ),
                
//                 // Bookmark button
//                 BlocBuilder<QuranCubit, QuranState>(
//                   buildWhen: (previous, current) => 
//                     previous.bookmarks != current.bookmarks || 
//                     previous.currentPage != current.currentPage,
//                   builder: (context, state) {
//                     final isBookmarked = state.bookmarks.any(
//                       (bookmark) => bookmark.pageNumber == state.currentPage
//                     );
//                     return IconButton(
//                       icon: Icon(
//                         isBookmarked ? Icons.bookmark : Icons.bookmark_border,
//                         color: Colors.white,
//                       ),
//                       onPressed: () => _showAddBookmarkDialog(context),
//                       tooltip: isBookmarked ? 'تعديل الإشارة المرجعية' : 'إضافة إشارة مرجعية',
//                     );
//                   },
//                 ),
                
//                 // Page indicator and jump to page
//                 _buildPageIndicator(context, state),
                
//                 // Previous page button (left side in Arabic reading, moves to lower Quran page number)
//                 // In the reversed PDF, this means moving to a higher PDF page index
//                 _buildNavButton(
//                   label: 'السابقة',
//                   icon: Icons.arrow_back_ios,
//                   iconFirst: false,
//                   onPressed: () {
//                     if (_pdfViewController != null) {
//                       // Convert current Quran page to PDF index, then navigate to previous Quran page
//                       // Since PDF is reversed, we need to increase the PDF page index to move backward in the Quran
//                       final currentPdfPageIndex = QuranCubit.convertToPdfIndex(_currentPage);
//                       // We check if there are pages after the current one (in a reversed context)
//                       if (currentPdfPageIndex < _totalPages - 1) {
//                         _pdfViewController!.setPage(currentPdfPageIndex + 1);
//                       }
//                     }
//                   },
//                   tooltip: 'الصفحة السابقة',
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
  
//   // Build the bookmarks overlay
//   Widget _buildBookmarksOverlay(BuildContext context, List<QuranBookmark> bookmarks) {
//     return Container(
//       color: Colors.black.withOpacity(0.85),
//       child: SafeArea(
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//               color: AppColors.primary,
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.close, color: Colors.white),
//                     onPressed: () {
//                       setState(() {
//                         _showBookmarks = false;
//                       });
//                     },
//                   ),
//                   Expanded(
//                     child: Text(
//                       'الإشارات المرجعية',
//                       textAlign: TextAlign.center,
//                       style: getBoldStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 18,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 48), // Balance the close button
//                 ],
//               ),
//             ),
            
//             // Bookmarks list
//             Expanded(
//               child: bookmarks.isEmpty
//                   ? _buildEmptyBookmarksMessage()
//                   : ListView.builder(
//                       itemCount: bookmarks.length,
//                       padding: const EdgeInsets.all(16),
//                       itemBuilder: (context, index) {
//                         final bookmark = bookmarks[index];
//                         return _buildBookmarkCard(context, bookmark);
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   // Build a message when there are no bookmarks
//   Widget _buildEmptyBookmarksMessage() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(
//             Icons.bookmark_border,
//             size: 80,
//             color: Colors.white54,
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'لا توجد إشارات مرجعية حتى الآن',
//             textAlign: TextAlign.center,
//             style: getMediumStyle(
//               fontFamily: FontConstant.cairo,
//               fontSize: 18,
//               color: Colors.white70,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'اضغط على زر الإشارة المرجعية في الشريط العلوي لحفظ موقع القراءة الحالي',
//             textAlign: TextAlign.center,
//             style: getRegularStyle(
//               fontFamily: FontConstant.cairo,
//               fontSize: 16,
//               color: Colors.white54,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   // Build a bookmark card
//   Widget _buildBookmarkCard(BuildContext context, QuranBookmark bookmark) {
//     final formattedDate = _formatBookmarkDate(bookmark.timestamp);
    
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       color: Colors.white,
//       elevation: 4,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () {
//           // Navigate to the bookmarked page
//           context.read<QuranCubit>().navigateToPage(bookmark.pageNumber);
          
//           // Close the bookmarks overlay
//           setState(() {
//             _showBookmarks = false;
//           });
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               // Page indicator
//               Container(
//                 width: 50,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Center(
//                   child: Text(
//                     '${bookmark.pageNumber}',
//                     style: getBoldStyle(
//                       fontFamily: FontConstant.cairo,
//                       fontSize: 18,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               // Bookmark details
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       bookmark.title,
//                       style: getBoldStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 16,
//                         color: AppColors.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       formattedDate,
//                       style: getRegularStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 14,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Navigate icon
//               const Icon(
//                 Icons.arrow_forward_ios,
//                 size: 16,
//                 color: AppColors.textSecondary,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
  
//   // Format the bookmark date
//   String _formatBookmarkDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);
    
//     if (difference.inDays == 0) {
//       if (difference.inHours == 0) {
//         return 'منذ ${difference.inMinutes} دقيقة';
//       }
//       return 'منذ ${difference.inHours} ساعة';
//     } else if (difference.inDays < 7) {
//       return 'منذ ${difference.inDays} يوم';
//     } else {
//       return '${date.year}/${date.month}/${date.day}';
//     }
//   }
  
//   // Navigation button (next/previous)
//   Widget _buildNavButton({
//     required String label,
//     required IconData icon,
//     required bool iconFirst,
//     required VoidCallback onPressed,
//     required String tooltip,
//   }) {
//     final children = [
//       Text(
//         label,
//         style: getRegularStyle(
//           fontFamily: FontConstant.cairo,
//           fontSize: 12,
//           color: Colors.white,
//         ),
//       ),
//       const SizedBox(width: 2),
//       Icon(icon, color: Colors.white, size: 16),
//     ];
    
//     return IconButton(
//       icon: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: iconFirst ? children.reversed.toList() : children,
//       ),
//       onPressed: onPressed,
//       tooltip: tooltip,
//     );
//   }
  
//   // Build the bookmarks overlay
//   Widget _buildBookmarksOverlay(BuildContext context, List<QuranBookmark> bookmarks) {
//     return Container(
//       color: Colors.black.withOpacity(0.85),
//       child: SafeArea(
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//               color: AppColors.primary,
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.close, color: Colors.white),
//                     onPressed: () {
//                       setState(() {
//                         _showBookmarks = false;
//                       });
//                     },
//                   ),
//                   Expanded(
//                     child: Text(
//                       'الإشارات المرجعية',
//                       textAlign: TextAlign.center,
//                       style: getBoldStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 18,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 48), // Balance the close button
//                 ],
//               ),
//             ),
            
//             // Bookmarks list
//             Expanded(
//               child: bookmarks.isEmpty
//                   ? _buildEmptyBookmarksMessage()
//                   : ListView.builder(
//                       itemCount: bookmarks.length,
//                       padding: const EdgeInsets.all(16),
//                       itemBuilder: (context, index) {
//                         final bookmark = bookmarks[index];
//                         return _buildBookmarkCard(context, bookmark);
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   // Build a message when there are no bookmarks
//   Widget _buildEmptyBookmarksMessage() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(
//             Icons.bookmark_border,
//             size: 80,
//             color: Colors.white54,
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'لا توجد إشارات مرجعية حتى الآن',
//             textAlign: TextAlign.center,
//             style: getMediumStyle(
//               fontFamily: FontConstant.cairo,
//               fontSize: 18,
//               color: Colors.white70,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'اضغط على زر الإشارة المرجعية في الشريط العلوي لحفظ موقع القراءة الحالي',
//             textAlign: TextAlign.center,
//             style: getRegularStyle(
//               fontFamily: FontConstant.cairo,
//               fontSize: 16,
//               color: Colors.white54,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   // Build a bookmark card
//   Widget _buildBookmarkCard(BuildContext context, QuranBookmark bookmark) {
//     final formattedDate = _formatBookmarkDate(bookmark.timestamp);
    
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       color: Colors.white,
//       elevation: 4,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () {
//           // Navigate to the bookmarked page
//           context.read<QuranCubit>().navigateToPage(bookmark.pageNumber);
          
//           // Close the bookmarks overlay
//           setState(() {
//             _showBookmarks = false;
//           });
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               // Page indicator
//               Container(
//                 width: 50,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Center(
//                   child: Text(
//                     '${bookmark.pageNumber}',
//                     style: getBoldStyle(
//                       fontFamily: FontConstant.cairo,
//                       fontSize: 18,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               // Bookmark details
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       bookmark.title,
//                       style: getBoldStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 16,
//                         color: AppColors.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       formattedDate,
//                       style: getRegularStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 14,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Navigate icon
//               const Icon(
//                 Icons.arrow_forward_ios,
//                 size: 16,
//                 color: AppColors.textSecondary,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
  
//   // Format the bookmark date
//   String _formatBookmarkDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);
    
//     if (difference.inDays == 0) {
//       if (difference.inHours == 0) {
//         return 'منذ ${difference.inMinutes} دقيقة';
//       }
//       return 'منذ ${difference.inHours} ساعة';
//     } else if (difference.inDays < 7) {
//       return 'منذ ${difference.inDays} يوم';
//     } else {
//       return '${date.year}/${date.month}/${date.day}';
//     }
//   }
  
//   // Page indicator with jump functionality
//   Widget _buildPageIndicator(BuildContext context, QuranState state) {
//     return InkWell(
//       onTap: () => _showJumpToPageDialog(context),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//         decoration: BoxDecoration(
//           color: AppColors.primary.withOpacity(0.8),
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Text(
//           'صفحة ${state.currentPage}',
//           style: getMediumStyle(
//             fontFamily: FontConstant.cairo,
//             fontSize: 14,
//             color: Colors.white,
//           ),
//         ),
//       ),
//     );
//   }
  
//   // Build the bookmarks overlay
//   Widget _buildBookmarksOverlay(BuildContext context, List<QuranBookmark> bookmarks) {
//     return Container(
//       color: Colors.black.withOpacity(0.85),
//       child: SafeArea(
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//               color: AppColors.primary,
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.close, color: Colors.white),
//                     onPressed: () {
//                       setState(() {
//                         _showBookmarks = false;
//                       });
//                     },
//                   ),
//                   Expanded(
//                     child: Text(
//                       'الإشارات المرجعية',
//                       textAlign: TextAlign.center,
//                       style: getBoldStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 18,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 48), // Balance the close button
//                 ],
//               ),
//             ),
            
//             // Bookmarks list
//             Expanded(
//               child: bookmarks.isEmpty
//                   ? _buildEmptyBookmarksMessage()
//                   : ListView.builder(
//                       itemCount: bookmarks.length,
//                       padding: const EdgeInsets.all(16),
//                       itemBuilder: (context, index) {
//                         final bookmark = bookmarks[index];
//                         return _buildBookmarkCard(context, bookmark);
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   // Build a message when there are no bookmarks
//   Widget _buildEmptyBookmarksMessage() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(
//             Icons.bookmark_border,
//             size: 80,
//             color: Colors.white54,
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'لا توجد إشارات مرجعية حتى الآن',
//             textAlign: TextAlign.center,
//             style: getMediumStyle(
//               fontFamily: FontConstant.cairo,
//               fontSize: 18,
//               color: Colors.white70,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'اضغط على زر الإشارة المرجعية في الشريط العلوي لحفظ موقع القراءة الحالي',
//             textAlign: TextAlign.center,
//             style: getRegularStyle(
//               fontFamily: FontConstant.cairo,
//               fontSize: 16,
//               color: Colors.white54,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   // Build a bookmark card
//   Widget _buildBookmarkCard(BuildContext context, QuranBookmark bookmark) {
//     final formattedDate = _formatBookmarkDate(bookmark.timestamp);
    
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       color: Colors.white,
//       elevation: 4,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () {
//           // Navigate to the bookmarked page
//           context.read<QuranCubit>().navigateToPage(bookmark.pageNumber);
          
//           // Close the bookmarks overlay
//           setState(() {
//             _showBookmarks = false;
//           });
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               // Page indicator
//               Container(
//                 width: 50,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Center(
//                   child: Text(
//                     '${bookmark.pageNumber}',
//                     style: getBoldStyle(
//                       fontFamily: FontConstant.cairo,
//                       fontSize: 18,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               // Bookmark details
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       bookmark.title,
//                       style: getBoldStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 16,
//                         color: AppColors.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       formattedDate,
//                       style: getRegularStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 14,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Navigate icon
//               const Icon(
//                 Icons.arrow_forward_ios,
//                 size: 16,
//                 color: AppColors.textSecondary,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
  
//   // Format the bookmark date
//   String _formatBookmarkDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);
    
//     if (difference.inDays == 0) {
//       if (difference.inHours == 0) {
//         return 'منذ ${difference.inMinutes} دقيقة';
//       }
//       return 'منذ ${difference.inHours} ساعة';
//     } else if (difference.inDays < 7) {
//       return 'منذ ${difference.inDays} يوم';
//     } else {
//       return '${date.year}/${date.month}/${date.day}';
//     }
//   }
  
//   // Jump to page dialog
//   void _showJumpToPageDialog(BuildContext context) {
//     final controller = TextEditingController();
    
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         contentPadding: const EdgeInsets.all(20),
//         title: Text(
//           'الانتقال إلى صفحة',
//           textAlign: TextAlign.center,
//           style: getBoldStyle(
//             fontFamily: FontConstant.cairo,
//             fontSize: 18,
//           ),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(
//               controller: controller,
//               keyboardType: TextInputType.number,
//               textAlign: TextAlign.center,
//               decoration: InputDecoration(
//                 hintText: 'رقم الصفحة (1-604)',
//                 hintStyle: getRegularStyle(
//                   fontFamily: FontConstant.cairo,
//                   fontSize: 14,
//                   color: AppColors.textSecondary,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(
//                     color: AppColors.primary,
//                     width: 2,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: Text(
//                     'إلغاء',
//                     style: getMediumStyle(
//                       fontFamily: FontConstant.cairo,
//                       fontSize: 16,
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     final pageNumber = int.tryParse(controller.text);
//                     if (pageNumber != null && pageNumber >= 1 && pageNumber <= 604) {
//                       Navigator.of(context).pop();
//                       context.read<QuranCubit>().navigateToPage(pageNumber);
//                     }
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: Text(
//                     'انتقال',
//                     style: getBoldStyle(
//                       fontFamily: FontConstant.cairo,
//                       fontSize: 16,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   // Build the bookmarks overlay
//   Widget _buildBookmarksOverlay(BuildContext context, List<QuranBookmark> bookmarks) {
//     return Container(
//       color: Colors.black.withOpacity(0.85),
//       child: SafeArea(
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//               color: AppColors.primary,
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.close, color: Colors.white),
//                     onPressed: () {
//                       setState(() {
//                         _showBookmarks = false;
//                       });
//                     },
//                   ),
//                   Expanded(
//                     child: Text(
//                       'الإشارات المرجعية',
//                       textAlign: TextAlign.center,
//                       style: getBoldStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 18,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 48), // Balance the close button
//                 ],
//               ),
//             ),
            
//             // Bookmarks list
//             Expanded(
//               child: bookmarks.isEmpty
//                   ? _buildEmptyBookmarksMessage()
//                   : ListView.builder(
//                       itemCount: bookmarks.length,
//                       padding: const EdgeInsets.all(16),
//                       itemBuilder: (context, index) {
//                         final bookmark = bookmarks[index];
//                         return _buildBookmarkCard(context, bookmark);
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   // Build a message when there are no bookmarks
//   Widget _buildEmptyBookmarksMessage() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(
//             Icons.bookmark_border,
//             size: 80,
//             color: Colors.white54,
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'لا توجد إشارات مرجعية حتى الآن',
//             textAlign: TextAlign.center,
//             style: getMediumStyle(
//               fontFamily: FontConstant.cairo,
//               fontSize: 18,
//               color: Colors.white70,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'اضغط على زر الإشارة المرجعية في الشريط العلوي لحفظ موقع القراءة الحالي',
//             textAlign: TextAlign.center,
//             style: getRegularStyle(
//               fontFamily: FontConstant.cairo,
//               fontSize: 16,
//               color: Colors.white54,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   // Build a bookmark card
//   Widget _buildBookmarkCard(BuildContext context, QuranBookmark bookmark) {
//     final formattedDate = _formatBookmarkDate(bookmark.timestamp);
    
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       color: Colors.white,
//       elevation: 4,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () {
//           // Navigate to the bookmarked page
//           context.read<QuranCubit>().navigateToPage(bookmark.pageNumber);
          
//           // Close the bookmarks overlay
//           setState(() {
//             _showBookmarks = false;
//           });
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               // Page indicator
//               Container(
//                 width: 50,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Center(
//                   child: Text(
//                     '${bookmark.pageNumber}',
//                     style: getBoldStyle(
//                       fontFamily: FontConstant.cairo,
//                       fontSize: 18,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               // Bookmark details
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       bookmark.title,
//                       style: getBoldStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 16,
//                         color: AppColors.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       formattedDate,
//                       style: getRegularStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 14,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Navigate icon
//               const Icon(
//                 Icons.arrow_forward_ios,
//                 size: 16,
//                 color: AppColors.textSecondary,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
  
//   // Format the bookmark date
//   String _formatBookmarkDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);
    
//     if (difference.inDays == 0) {
//       if (difference.inHours == 0) {
//         return 'منذ ${difference.inMinutes} دقيقة';
//       }
//       return 'منذ ${difference.inHours} ساعة';
//     } else if (difference.inDays < 7) {
//       return 'منذ ${difference.inDays} يوم';
//     } else {
//       return '${date.year}/${date.month}/${date.day}';
//     }
//   }
  
//   // Show dialog to add or update a bookmark
//   void _showAddBookmarkDialog(BuildContext context) {
//     final cubit = context.read<QuranCubit>();
//     final isBookmarked = cubit.isCurrentPageBookmarked();
    
//     // Set the initial text in the controller
//     _bookmarkTitleController.text = isBookmarked 
//         ? cubit.state.bookmarks.firstWhere(
//             (b) => b.pageNumber == cubit.state.currentPage).title
//         : 'صفحة ${cubit.state.currentPage}';
    
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         contentPadding: const EdgeInsets.all(20),
//         title: Text(
//           isBookmarked ? 'تعديل الإشارة المرجعية' : 'إضافة إشارة مرجعية',
//           textAlign: TextAlign.center,
//           style: getBoldStyle(
//             fontFamily: FontConstant.cairo,
//             fontSize: 18,
//           ),
//         ),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             // Icon
//             const Icon(
//               Icons.bookmark,
//               size: 50,
//               color: AppColors.primary,
//             ),
//             const SizedBox(height: 16),
//             // Current page info
//             Text(
//               'الصفحة الحالية: ${cubit.state.currentPage}',
//               style: getMediumStyle(
//                 fontFamily: FontConstant.cairo,
//                 fontSize: 16,
//                 color: AppColors.textSecondary,
//               ),
//             ),
//             const SizedBox(height: 16),
//             // Title field
//             TextField(
//               controller: _bookmarkTitleController,
//               textAlign: TextAlign.right,
//               decoration: InputDecoration(
//                 hintText: 'عنوان الإشارة المرجعية',
//                 hintStyle: getRegularStyle(
//                   fontFamily: FontConstant.cairo,
//                   fontSize: 14,
//                   color: AppColors.textSecondary,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: const BorderSide(
//                     color: AppColors.primary,
//                     width: 2,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(height: 20),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 if (isBookmarked)
//                   TextButton(
//                     onPressed: () {
//                       Navigator.of(context).pop();
//                       cubit.removeBookmark(cubit.state.currentPage);
//                     },
//                     child: Text(
//                       'حذف',
//                       style: getMediumStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 16,
//                         color: Colors.red,
//                       ),
//                     ),
//                   ),
//                 TextButton(
//                   onPressed: () => Navigator.of(context).pop(),
//                   child: Text(
//                     'إلغاء',
//                     style: getMediumStyle(
//                       fontFamily: FontConstant.cairo,
//                       fontSize: 16,
//                       color: AppColors.textSecondary,
//                     ),
//                   ),
//                 ),
//                 ElevatedButton(
//                   onPressed: () {
//                     Navigator.of(context).pop();
//                     cubit.addBookmark(_bookmarkTitleController.text);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: AppColors.primary,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                   ),
//                   child: Text(
//                     isBookmarked ? 'تحديث' : 'حفظ',
//                     style: getBoldStyle(
//                       fontFamily: FontConstant.cairo,
//                       fontSize: 16,
//                       color: Colors.white,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   // Build the bookmarks overlay
//   Widget _buildBookmarksOverlay(BuildContext context, List<QuranBookmark> bookmarks) {
//     return Container(
//       color: Colors.black.withOpacity(0.85),
//       child: SafeArea(
//         child: Column(
//           children: [
//             // Header
//             Container(
//               padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
//               color: AppColors.primary,
//               child: Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.close, color: Colors.white),
//                     onPressed: () {
//                       setState(() {
//                         _showBookmarks = false;
//                       });
//                     },
//                   ),
//                   Expanded(
//                     child: Text(
//                       'الإشارات المرجعية',
//                       textAlign: TextAlign.center,
//                       style: getBoldStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 18,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 48), // Balance the close button
//                 ],
//               ),
//             ),
            
//             // Bookmarks list
//             Expanded(
//               child: bookmarks.isEmpty
//                   ? _buildEmptyBookmarksMessage()
//                   : ListView.builder(
//                       itemCount: bookmarks.length,
//                       padding: const EdgeInsets.all(16),
//                       itemBuilder: (context, index) {
//                         final bookmark = bookmarks[index];
//                         return _buildBookmarkCard(context, bookmark);
//                       },
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
  
//   // Build a message when there are no bookmarks
//   Widget _buildEmptyBookmarksMessage() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(
//             Icons.bookmark_border,
//             size: 80,
//             color: Colors.white54,
//           ),
//           const SizedBox(height: 24),
//           Text(
//             'لا توجد إشارات مرجعية حتى الآن',
//             textAlign: TextAlign.center,
//             style: getMediumStyle(
//               fontFamily: FontConstant.cairo,
//               fontSize: 18,
//               color: Colors.white70,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Text(
//             'اضغط على زر الإشارة المرجعية في الشريط العلوي لحفظ موقع القراءة الحالي',
//             textAlign: TextAlign.center,
//             style: getRegularStyle(
//               fontFamily: FontConstant.cairo,
//               fontSize: 16,
//               color: Colors.white54,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
  
//   // Build a bookmark card
//   Widget _buildBookmarkCard(BuildContext context, QuranBookmark bookmark) {
//     final formattedDate = _formatBookmarkDate(bookmark.timestamp);
    
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       color: Colors.white,
//       elevation: 4,
//       child: InkWell(
//         borderRadius: BorderRadius.circular(12),
//         onTap: () {
//           // Navigate to the bookmarked page
//           context.read<QuranCubit>().navigateToPage(bookmark.pageNumber);
          
//           // Close the bookmarks overlay
//           setState(() {
//             _showBookmarks = false;
//           });
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Row(
//             children: [
//               // Page indicator
//               Container(
//                 width: 50,
//                 height: 50,
//                 decoration: BoxDecoration(
//                   color: AppColors.primary.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Center(
//                   child: Text(
//                     '${bookmark.pageNumber}',
//                     style: getBoldStyle(
//                       fontFamily: FontConstant.cairo,
//                       fontSize: 18,
//                       color: AppColors.primary,
//                     ),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               // Bookmark details
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       bookmark.title,
//                       style: getBoldStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 16,
//                         color: AppColors.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       formattedDate,
//                       style: getRegularStyle(
//                         fontFamily: FontConstant.cairo,
//                         fontSize: 14,
//                         color: AppColors.textSecondary,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               // Navigate icon
//               const Icon(
//                 Icons.arrow_forward_ios,
//                 size: 16,
//                 color: AppColors.textSecondary,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
  
//   // Format the bookmark date
//   String _formatBookmarkDate(DateTime date) {
//     final now = DateTime.now();
//     final difference = now.difference(date);
    
//     if (difference.inDays == 0) {
//       if (difference.inHours == 0) {
//         return 'منذ ${difference.inMinutes} دقيقة';
//       }
//       return 'منذ ${difference.inHours} ساعة';
//     } else if (difference.inDays < 7) {
//       return 'منذ ${difference.inDays} يوم';
//     } else {
//       return '${date.year}/${date.month}/${date.day}';
//     }
//   }
// }