import 'package:flutter/material.dart';
import '../../../../../../core/utils/user_role.dart';
import '../../../../data/models/memorization_circle_model.dart';
import 'memorization_circle_card.dart';

class CirclesListView extends StatelessWidget {
  final List<MemorizationCircle> circles;
  final UserRole userRole;
  final String userId;
  final VoidCallback onRefresh;
  final Function(MemorizationCircle) onCircleTap;

  const CirclesListView({
    Key? key,
    required this.circles,
    required this.userRole,
    required this.userId,
    required this.onRefresh,
    required this.onCircleTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final responsiveSize = screenWidth / 375;

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 16 * responsiveSize),
        itemCount: circles.length,
        itemBuilder: (context, index) {
          return MemorizationCircleCard(
            circle: circles[index],
            userRole: userRole,
            userId: userId,
            onTap: () => onCircleTap(circles[index]),
          );
        },
      ),
    );
  }
} 