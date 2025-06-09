// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../home/data/repositories/quran_repository.dart';
// import '../../../home/data/models/quran_reciter_model.dart';
// import '../../../home/presentation/widgets/quran_collection_card.dart';
// import '../../../../core/utils/theme/app_colors.dart';

// class QuranAudioScreen extends StatefulWidget {
//   static const String routeName = '/quran-audio';

//   const QuranAudioScreen({Key? key}) : super(key: key);

//   @override
//   State<QuranAudioScreen> createState() => _QuranAudioScreenState();
// }

// class _QuranAudioScreenState extends State<QuranAudioScreen> {
//   final _quranRepository = QuranRepository();
//   List<QuranCollection> _collections = [];
//   bool _isLoading = false;
//   String? _error;
//   bool _isDisposed = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadCollections();
//   }

//   @override
//   void dispose() {
//     _isDisposed = true;
//     super.dispose();
//   }

//   void _safeSetState(VoidCallback fn) {
//     if (mounted && !_isDisposed) {
//       setState(fn);
//     }
//   }

//   Future<void> _loadCollections() async {
//     _safeSetState(() {
//       _isLoading = true;
//       _error = null;
//     });

//     try {
//       final result = await _quranRepository.getReciters();
//       if (!mounted || _isDisposed) return;

//       result.fold(
//         (failure) {
//           _safeSetState(() {
//             _error = failure.message;
//             _isLoading = false;
//           });
//         },
//         (collections) {
//           _safeSetState(() {
//             _collections = collections;
//             _isLoading = false;
//           });
//         },
//       );
//     } catch (e) {
//       if (!mounted || _isDisposed) return;
//       _safeSetState(() {
//         _error = e.toString();
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'أصوات القرآن الكريم',
//           style: TextStyle(
//             fontSize: 18.sp,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: AppColors.logoTeal,
//         centerTitle: true,
//       ),
//       body: RefreshIndicator(
//         onRefresh: _loadCollections,
//         color: AppColors.logoTeal,
//         child: _buildBody(),
//       ),
//     );
//   }

//   Widget _buildBody() {
//     if (_isLoading) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircularProgressIndicator(
//               valueColor: AlwaysStoppedAnimation<Color>(AppColors.logoTeal),
//             ),
//             SizedBox(height: 16.h),
//             Text(
//               'جاري تحميل المصاحف...',
//               style: TextStyle(
//                 fontSize: 16.sp,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     if (_error != null) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.error_outline,
//               size: 64.sp,
//               color: Colors.red,
//             ),
//             SizedBox(height: 16.h),
//             Text(
//               _error!,
//               style: TextStyle(
//                 fontSize: 16.sp,
//                 color: Colors.grey[700],
//               ),
//               textAlign: TextAlign.center,
//             ),
//             SizedBox(height: 16.h),
//             ElevatedButton(
//               onPressed: _loadCollections,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: AppColors.logoTeal,
//               ),
//               child: const Text('إعادة المحاولة'),
//             ),
//           ],
//         ),
//       );
//     }

//     if (_collections.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(
//               Icons.queue_music,
//               size: 64.sp,
//               color: Colors.grey[400],
//             ),
//             SizedBox(height: 16.h),
//             Text(
//               'لا توجد مصاحف متاحة حالياً',
//               style: TextStyle(
//                 fontSize: 16.sp,
//                 color: Colors.grey[700],
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               'اسحب للأسفل للتحديث',
//               style: TextStyle(
//                 fontSize: 14.sp,
//                 color: Colors.grey[600],
//               ),
//             ),
//           ],
//         ),
//       );
//     }

//     return ListView.builder(
//       padding: EdgeInsets.symmetric(vertical: 8.h),
//       itemCount: _collections.length,
//       itemBuilder: (context, index) {
//         return QuranCollectionCard(
//           collection: _collections[index],
//         );
//       },
//     );
//   }
// } 