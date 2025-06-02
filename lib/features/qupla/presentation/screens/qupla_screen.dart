import 'package:flutter/material.dart';
import '../../../../core/utils/constant/font_manger.dart';
import '../../../../core/utils/constant/styles_manger.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../widgets/qibla_compass.dart';

class QuplaScreen extends StatelessWidget {
  static const String routeName = '/qupla';

  const QuplaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'اتجاه القبلة',
          style: getBoldStyle(
            fontFamily: FontConstant.cairo,
            fontSize: FontSize.size22,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: QiblaDirection(),
      ),
    );
  }
} 