import 'package:flutter/material.dart';
import '../../../../core/utils/constant/app_dimensions.dart';
import '../../../../core/utils/constant/font_manger.dart';
import '../../../../core/utils/constant/styles_manger.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../models/allah_name_model.dart';

class AllahNameDetailsScreen extends StatelessWidget {
  final AllahName name;
  final int index;

  const AllahNameDetailsScreen({
    Key? key,
    required this.name,
    required this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              AppColors.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.paddingM),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppDimensions.paddingM),
                
                // Name index indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'الاسم',
                      style: getMediumStyle(
                        fontFamily: FontConstant.cairo,
                        fontSize: FontSize.size16,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          index.toString(),
                          style: getBoldStyle(
                            fontFamily: FontConstant.cairo,
                            fontSize: FontSize.size16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'من ${AllahNamesList.namesList.length}',
                      style: getMediumStyle(
                        fontFamily: FontConstant.cairo,
                        fontSize: FontSize.size16,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppDimensions.paddingXL),
                
                // Name display with light rays
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Light effect
                    Container(
                      width: screenSize.width * 0.7,
                      height: screenSize.width * 0.7,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.2),
                            Colors.transparent,
                          ],
                          stops: const [0.6, 1.0],
                        ),
                      ),
                    ),
                    
                    // Main name container
                    Container(
                      width: double.infinity,
                      margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                      padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.paddingL,
                        horizontal: AppDimensions.paddingM,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                        border: Border.all(
                          color: AppColors.primary,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Name text in Arabic
                          Text(
                            name.name,
                            style: getBoldStyle(
                              fontFamily: FontConstant.cairo,
                              fontSize: FontSize.size30,
                              color: AppColors.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          
                          const Divider(
                            color: Colors.black12,
                            thickness: 1,
                            height: 40,
                          ),
                          
                          // Name explanation
                          Text(
                            name.text,
                            style: getMediumStyle(
                              fontFamily: FontConstant.cairo,
                              fontSize: FontSize.size18,
                              color: AppColors.black
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: AppDimensions.paddingXL),
                
                // Navigation buttons
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppDimensions.paddingM),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Previous button
                      if (index > 1)
                        _buildNavigationButton(
                          context: context,
                          icon: Icons.arrow_back_ios,
                          label: 'السابق',
                          targetIndex: index - 1,
                        )
                      else
                        const SizedBox(width: 80), // Placeholder to keep layout balanced
                      
                      // Display current index / total
                      Text(
                        '$index / ${AllahNamesList.namesList.length}',
                        style: getBoldStyle(
                          fontFamily: FontConstant.cairo,
                          fontSize: FontSize.size16,
                          color: AppColors.primary,
                        ),
                      ),
                      
                      // Next button
                      if (index < AllahNamesList.namesList.length)
                        _buildNavigationButton(
                          context: context,
                          icon: Icons.arrow_forward_ios,
                          label: 'التالي',
                          targetIndex: index + 1,
                        )
                      else
                        const SizedBox(width: 80), // Placeholder to keep layout balanced
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int targetIndex,
  }) {
    return ElevatedButton.icon(
      onPressed: () {
        final targetName = AllahNamesList.namesList[targetIndex - 1];
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => AllahNameDetailsScreen(
              name: targetName,
              index: targetIndex,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              var begin = Offset(
                icon == Icons.arrow_forward_ios ? 1.0 : -1.0, 
                0.0
              );
              var end = Offset.zero;
              var curve = Curves.easeInOut;
              var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);
              
              return SlideTransition(
                position: offsetAnimation,
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
        );
      },
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        textStyle: getBoldStyle(
          fontFamily: FontConstant.cairo,
          fontSize: FontSize.size14,
          color: Colors.white,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
      ),
    );
  }
} 