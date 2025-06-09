import 'package:flutter/material.dart';
import '../../widgets/home_features_grid.dart';
import '../../widgets/last_read_card.dart';
import '../../widgets/islamic_content_grid.dart';
import '../../quran_audio/presentation/widgets/quran_audio_preview_card.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:  [
          SizedBox(height: 8),

          // Islamic features section
          HomeFeaturesGrid(),

          // Quran section
          LastReadCard(),

          // Quran Audio Preview
          QuranAudioPreviewCard(),

          // Islamic content section
          IslamicContentGrid(),

          // Bottom spacing
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
