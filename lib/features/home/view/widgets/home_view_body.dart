import 'package:flutter/material.dart';
import '../../widgets/home_features_grid.dart';
import '../../widgets/last_read_card.dart';
import '../../widgets/islamic_content_grid.dart';
import '../../quran_audio/presentation/widgets/quran_audio_preview_card.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});
  
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:  [
          SizedBox(height: screenHeight * 0.01),

          // Islamic features section
          const HomeFeaturesGrid(),

          // Quran section
          const LastReadCard(),

          // Quran Audio Preview
          const QuranAudioPreviewCard(),

          // Islamic content section
          const IslamicContentGrid(),

          // Bottom spacing
          SizedBox(height: screenHeight * 0.02),
        ],
      ),
    );
  }
}
