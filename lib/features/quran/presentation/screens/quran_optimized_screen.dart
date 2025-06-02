import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/surah_model.dart';
import '../cubit/quran_cubit.dart';
import '../../../../core/utils/constant/font_manger.dart';
import '../../../../core/utils/constant/styles_manger.dart';
import '../../../../core/utils/theme/app_colors.dart';
import 'quran_content_screen.dart';

class QuranOptimizedScreen extends StatefulWidget {
  static const String routeName = '/quran';

  const QuranOptimizedScreen({Key? key}) : super(key: key);

  @override
  State<QuranOptimizedScreen> createState() => _QuranOptimizedScreenState();
}

class _QuranOptimizedScreenState extends State<QuranOptimizedScreen> with WidgetsBindingObserver {
  bool _isLoading = true;
  double _loadingProgress = 0.0;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Pre-load JSON data and ensure surahs are loaded
    _preloadData();
    
    // Start showing loading animation
    _startLoadingAnimation();
    
    // Navigate to actual content screen after 2.5 seconds
    // This allows Flutter to render fully and prepare memory
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _navigateToContentScreen();
      }
    });
  }
  
  Future<void> _preloadData() async {
    try {
      // Use the simpler, more direct approach to load all surahs
      final surahs = await SurahList.loadAllSurahsDirectly();
      debugPrint('Preloaded ${surahs.length} surahs in optimized screen');
      
      // Only try the other approaches if the direct method failed
      if (surahs.isEmpty) {
        // Try the original approach
        await SurahList.loadSurahs();
        
        // If still empty, try paginated approach as a last resort
        if (SurahList.surahs.isEmpty) {
          await SurahList.loadSurahsPaginated(page: 1, pageSize: 114);
          debugPrint('Paginated loading completed, surahs count: ${SurahList.surahs.length}');
        }
      }
    } catch (e) {
      debugPrint('Error preloading data: $e');
    }
  }
  
  void _startLoadingAnimation() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 100));
      if (!mounted || _loadingProgress >= 1.0) return false;
      
      setState(() {
        _loadingProgress += 0.05;
        if (_loadingProgress > 1.0) {
          _loadingProgress = 1.0;
        }
      });
      return true;
    });
  }
  
  void _navigateToContentScreen() {
    // Ensure loading progress is complete for better UX
    setState(() {
      _loadingProgress = 1.0;
    });
    
    // Wait just a tiny bit more for the progress bar to fill
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!mounted) return;
      
      // Get the page number from route arguments if available
      final pageNumber = ModalRoute.of(context)?.settings.arguments as int?;
      
      // Use replacement to prevent returning to this screen
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            // Wrap with BlocProvider to share the QuranCubit instance
            return BlocProvider(
              create: (context) {
                // Create the cubit with initial page if available
                final cubit = QuranCubit();
                if (pageNumber != null && pageNumber > 0 && pageNumber < 604) {
                  // Set initial page with a slight delay to ensure it's applied
                  Future.microtask(() => cubit.navigateToPage(pageNumber));
                }
                return cubit;
              },
              child: const QuranContentScreen(),
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    });
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes if needed
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo/icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child:const Icon(
                  Icons.menu_book_rounded,
                  size: 70,
                  color: AppColors.primary,
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Title
              Text(
                'القرآن الكريم',
                style: getBoldStyle(
                  fontFamily: FontConstant.cairo,
                  fontSize: 28,
                  color: AppColors.primary,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Bismillah
              Text(
                'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
                style: getMediumStyle(
                  fontFamily: FontConstant.cairo,
                  fontSize: 18,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Custom Progress Indicator
              Container(
                width: MediaQuery.of(context).size.width * 0.7,
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      widthFactor: _loadingProgress,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary.withOpacity(0.7),
                              AppColors.primary,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 20),
              
              Text(
                'جاري تجهيز المصحف...',
                style: getRegularStyle(
                  fontFamily: FontConstant.cairo,
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 