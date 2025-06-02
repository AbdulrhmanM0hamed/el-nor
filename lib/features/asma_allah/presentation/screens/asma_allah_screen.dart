import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../../../../core/utils/constant/app_dimensions.dart';
import '../../../../core/utils/constant/font_manger.dart';
import '../../../../core/utils/constant/styles_manger.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../data/repositories/allah_names_repository.dart';
import '../../models/allah_name_model.dart';
import '../cubit/asma_allah_cubit.dart';
import '../cubit/asma_allah_states.dart';
import '../widgets/name_card.dart';
import 'allah_name_details_screen.dart';

class AsmaAllahScreen extends StatefulWidget {
  static const String routeName = '/asma-allah';

  const AsmaAllahScreen({Key? key}) : super(key: key);

  @override
  State<AsmaAllahScreen> createState() => _AsmaAllahScreenState();
}

class _AsmaAllahScreenState extends State<AsmaAllahScreen> {
  final Logger _logger = Logger();
  bool _isInitialized = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _logger.i('AsmaAllahScreen initState called');
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      _logger.i('AsmaAllahScreen didChangeDependencies - loading names');
      _isInitialized = true;
      // Load directly from the repository first to check if there are any issues
      AllahNamesRepositoryImpl().getAllahNames().then((names) {
        _logger.i('Direct repository call returned ${names.length} names');
        context.read<AsmaAllahCubit>().loadAllahNames();
      }).catchError((error) {
        _logger.e('Error pre-loading names', error: error);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    _logger.i('AsmaAllahScreen build called');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'أسماء الله الحسنى',
          style: getBoldStyle(
            fontFamily: FontConstant.cairo,
            fontSize: FontSize.size20,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Header section with bismillah
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: AppDimensions.paddingM,
              horizontal: AppDimensions.paddingM,
            ),
            alignment: Alignment.center,
            child: Text(
              'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ',
              style: getBoldStyle(
                fontFamily: FontConstant.cairo,
                fontSize: FontSize.size18,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // List view with names
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    _logger.i('AsmaAllahScreen _buildBody called');
    return BlocBuilder<AsmaAllahCubit, AsmaAllahState>(
      builder: (context, state) {
        _logger.i('AsmaAllahScreen BlocBuilder state: $state');
        
        if (state is AsmaAllahLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is AsmaAllahError) {
          // Try direct access to repository as fallback
          return FutureBuilder<List<AllahName>>(
            future: AllahNamesRepositoryImpl().getAllahNames(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                return _buildNamesList(snapshot.data!);
              }
              
              // Show error if both approaches failed
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      state.errorMessage,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.paddingM),
                    ElevatedButton(
                      onPressed: () => context.read<AsmaAllahCubit>().loadAllahNames(),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            },
          );
        }

        if (state is AsmaAllahLoaded) {
          return _buildNamesList(state.allNames);
        }

        // Initial state - try direct repository access
        return FutureBuilder<List<AllahName>>(
          future: AllahNamesRepositoryImpl().getAllahNames(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              return _buildNamesList(snapshot.data!);
            }
            
            return const Center(child: CircularProgressIndicator());
          },
        );
      },
    );
  }

  Widget _buildNamesList(List<AllahName> names) {
    _logger.i('AsmaAllahScreen _buildNamesList called with ${names.length} names');
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppDimensions.paddingM),
      itemCount: names.length,
      itemBuilder: (context, index) {
        final name = names[index];
        final nameNumber = index + 1;
        
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(
            vertical: AppDimensions.paddingS,
       
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            side: BorderSide(
              color: AppColors.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllahNameDetailsScreen(name: name, index: nameNumber),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Row(
                children: [
                  // Number circle
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        nameNumber.toString(),
                        style: getBoldStyle(
                          fontFamily: FontConstant.cairo,
                          fontSize: FontSize.size14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.paddingM),
                  
                  // Name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.name,
                          style: getBoldStyle(
                            fontFamily: FontConstant.cairo,
                            fontSize: FontSize.size18,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          name.text.length > 100 
                              ? '${name.text.substring(0, 100)}...' 
                              : name.text,
                          style: getMediumStyle(
                            fontFamily: FontConstant.cairo,
                            fontSize: FontSize.size14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  
                  // Arrow
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
} 