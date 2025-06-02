import 'package:flutter/material.dart';
import '../../../home/presentation/widgets/home_features_grid.dart';
import '../../../home/presentation/widgets/last_read_card.dart';
import '../../../home/presentation/widgets/islamic_content_grid.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),

          // Islamic features section
          HomeFeaturesGrid(),

          // Quran section
          LastReadCard(),

          // Islamic content section

          IslamicContentGrid(),

          // Bottom spacing
          SizedBox(height: 16),
        ],
      ),
    );
  }
}
