import 'package:beat_elslam/core/utils/constant/font_manger.dart';
import 'package:beat_elslam/core/utils/constant/styles_manger.dart';
import 'package:beat_elslam/core/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../models/azkar_model.dart';
import '../../services/azkar_service.dart';
import '../widgets/azkar_category_item.dart';

class AzkarScreen extends StatefulWidget {
  static const String routeName = '/athkar';

  const AzkarScreen({super.key});

  @override
  State<AzkarScreen> createState() => _AzkarScreenState();
}

class _AzkarScreenState extends State<AzkarScreen> {
  final AzkarService _azkarService = AzkarService();
  bool _isLoading = true;
  List<AzkarCategory> _categories = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadAzkar();
  }

  Future<void> _loadAzkar() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final categories = await _azkarService.getCategories();

      setState(() {
        _categories = categories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'حدث خطأ أثناء تحميل الأذكار: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الأذكار',
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
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAzkar,
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_categories.isEmpty) {
      return const Center(child: Text('لا توجد أذكار متاحة'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return AzkarCategoryItem(
          category: category,
          onTap:
              () => Navigator.pushNamed(
                context,
                '/azkar-details',
                arguments: category,
              ),
        );
      },
    );
  }
}
