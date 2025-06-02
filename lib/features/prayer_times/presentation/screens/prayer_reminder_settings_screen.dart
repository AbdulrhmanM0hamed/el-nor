import 'package:flutter/material.dart';
import '../../../../core/utils/theme/app_colors.dart';
import '../../../../core/utils/constant/font_manger.dart';
import '../../../../core/utils/constant/styles_manger.dart';
import '../../services/prayer_reminder_service.dart';

class PrayerReminderSettingsScreen extends StatefulWidget {
  static const String routeName = '/prayer-reminder-settings';

  const PrayerReminderSettingsScreen({Key? key}) : super(key: key);

  @override
  State<PrayerReminderSettingsScreen> createState() => _PrayerReminderSettingsScreenState();
}

class _PrayerReminderSettingsScreenState extends State<PrayerReminderSettingsScreen> {
  final PrayerReminderService _reminderService = PrayerReminderService();
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    // تهيئة خدمة التذكير
    await _reminderService.initialize();
    
    setState(() {
      _isLoading = false;
    });
  }
  
  // فتح إعدادات البطارية مباشرة
  Future<void> _openBatterySettings() async {
    try {
      // استخدام intent مباشرة لفتح إعدادات البطارية
      await _reminderService.openBatteryOptimizationSettings();
    } catch (e) {
      debugPrint('❌ Error opening battery settings: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لا يمكن فتح إعدادات البطارية. يرجى فتحها يدويًا.'),
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('إعدادات التطبيق'),
          backgroundColor: AppColors.primary,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'إعدادات التطبيق',
          style: getBoldStyle(
            fontFamily: FontConstant.cairo,
            fontSize: FontSize.size18,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // قسم خاص بإعدادات نظام التشغيل
          const SectionTitle(title: 'إعدادات متقدمة'),
          
          // زر فتح إعدادات البطارية
          BatteryOptimizationCard(
            onTap: _openBatterySettings,
          ),
          
          const SizedBox(height: 16),
          
          // معلومات حول التطبيق
          const InfoCard(
            title: 'معلومات مهمة حول التطبيق',
            content: 'لضمان عمل التطبيق بشكل صحيح حتى عندما يكون مغلقًا، يجب إيقاف تحسينات البطارية للتطبيق من إعدادات الجهاز.\n\nقم بالنقر على زر "إيقاف تحسينات البطارية" أعلاه وقم بالبحث عن تطبيق "Beat Elslam" في القائمة، ثم اختر "عدم التحسين" أو "السماح بالاستهلاك العالي للطاقة".\n\nيختلف مسار الإعدادات حسب نوع الهاتف، لكن غالبًا يكون:\nالإعدادات > البطارية > تحسينات البطارية/استهلاك الطاقة > البحث عن التطبيق',
          ),
          
          const SizedBox(height: 24),
          
          // توضيح قيود نظام التشغيل
          const InfoCard(
            title: 'ملاحظة حول قيود نظام التشغيل',
            content: 'بعض أجهزة Android (خاصة الإصدارات 10 وما فوق) قد تفرض قيودًا صارمة على التطبيقات التي تعمل في الخلفية، حتى مع إيقاف تحسينات البطارية.\n\nإذا كنت تستخدم هاتف Xiaomi أو Huawei أو Oppo أو Vivo، قد تحتاج إلى إعدادات إضافية مثل "بدء التشغيل التلقائي" أو "التشغيل في الخلفية".',
          ),
        ],
      ),
    );
  }
}

// مكون عنوان القسم
class SectionTitle extends StatelessWidget {
  final String title;

  const SectionTitle({Key? key, required this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: getBoldStyle(
          fontFamily: FontConstant.cairo,
          fontSize: FontSize.size16,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

// مكون بطاقة تحسينات البطارية
class BatteryOptimizationCard extends StatelessWidget {
  final VoidCallback onTap;

  const BatteryOptimizationCard({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      color: Colors.orange[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orange[200]!, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.orange[100],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.battery_alert,
                      color: Colors.orange,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'إيقاف تحسينات البطارية',
                      style: getBoldStyle(
                        fontFamily: FontConstant.cairo,
                        fontSize: FontSize.size16,
                        color: Colors.orange[800],
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      'مهم',
                      style: getBoldStyle(
                        fontFamily: FontConstant.cairo,
                        fontSize: FontSize.size12,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'مطلوب لعمل التطبيق في الخلفية بشكل صحيح',
                style: getMediumStyle(
                  fontFamily: FontConstant.cairo,
                  fontSize: FontSize.size13,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'انقر هنا لفتح إعدادات البطارية وإيقاف تحسينات البطارية للتطبيق',
                style: getRegularStyle(
                  fontFamily: FontConstant.cairo,
                  fontSize: FontSize.size12,
                  color: Colors.orange[700],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.touch_app,
                    color: Colors.orange,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'اضغط للانتقال إلى الإعدادات',
                    style: getBoldStyle(
                      fontFamily: FontConstant.cairo,
                      fontSize: FontSize.size12,
                      color: Colors.orange[800],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// مكون بطاقة المعلومات
class InfoCard extends StatelessWidget {
  final String title;
  final String content;

  const InfoCard({Key? key, required this.title, required this.content}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: Colors.blue[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Colors.blue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: getBoldStyle(
                      fontFamily: FontConstant.cairo,
                      fontSize: FontSize.size14,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              content,
              style: getRegularStyle(
                fontFamily: FontConstant.cairo,
                fontSize: FontSize.size12,
                color: Colors.blue[900],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 