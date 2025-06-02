import 'package:beat_elslam/core/utils/constant/font_manger.dart';
import 'package:beat_elslam/core/utils/constant/styles_manger.dart';
import 'package:beat_elslam/core/utils/theme/app_colors.dart';
import 'package:flutter/material.dart';
import '../../models/azkar_model.dart';

class AzkarDetailsScreen extends StatefulWidget {
  static const String routeName = '/azkar-details';

  final AzkarCategory category;

  const AzkarDetailsScreen({Key? key, required this.category})
    : super(key: key);

  @override
  State<AzkarDetailsScreen> createState() => _AzkarDetailsScreenState();
}

class _AzkarDetailsScreenState extends State<AzkarDetailsScreen> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category.name,
          style: getBoldStyle(
            fontFamily: FontConstant.cairo,
            fontSize: FontSize.size20,
            color: AppColors.primary,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Page indicator
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${_currentIndex + 1}/${widget.category.items.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),

          // Page view of azkar
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.category.items.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                final zikr = widget.category.items[index];
                return _buildZikrCard(zikr);
              },
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed:
                      _currentIndex > 0
                          ? () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                  ),
                  child: const Icon(Icons.arrow_back_ios),
                ),
                ElevatedButton(
                  onPressed:
                      _currentIndex < widget.category.items.length - 1
                          ? () {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(12),
                  ),
                  child: const Icon(Icons.arrow_forward_ios),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildZikrCard(Zikr zikr) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Main zikr text
                    Text(
                      zikr.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        height: 1.8,
                        fontFamily: 'Cairo',
                        
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Source if available
                    if (zikr.source != null && zikr.source!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          zikr.source!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                            fontFamily: 'Cairo',
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    // Virtue if available
                    if (zikr.fadl != null && zikr.fadl!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'الفضل',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                                fontFamily: 'Cairo',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              zikr.fadl!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.green[700],
                                fontFamily: 'Cairo',
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Counter
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                'التكرار: ${zikr.count} مرات',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                  fontFamily: 'Cairo',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
