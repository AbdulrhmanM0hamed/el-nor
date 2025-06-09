import 'package:equatable/equatable.dart';

class QuranCollection extends Equatable {
  final int id;
  final String title;
  final String description;
  final String type;
  final DateTime addDate;
  final List<QuranSurah> surahs;

  const QuranCollection({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.addDate,
    required this.surahs,
  });

  factory QuranCollection.fromJson(Map<String, dynamic> json) {
    final List<dynamic> attachments = json['attachments'] ?? [];
    return QuranCollection(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      type: json['type'] ?? '',
      addDate: DateTime.fromMillisecondsSinceEpoch((json['add_date'] ?? 0) * 1000),
      surahs: attachments.map((surah) => QuranSurah.fromJson(surah)).toList(),
    );
  }

  String get shortDescription {
    final descriptionParts = description.split('بصوت القُرَّاء :');
    if (descriptionParts.length > 1) {
      // استخراج أول قارئين فقط مع إضافة "وآخرون" إذا كان هناك أكثر من قارئين
      final recitersText = descriptionParts[1].trim();
      final reciters = recitersText.split('-').map((e) => e.trim()).toList();
      
      if (reciters.length <= 2) {
        return reciters.join(' - ');
      } else {
        return '${reciters[0]} - ${reciters[1]} وآخرون';
      }
    }
    
    // إذا كان الوصف طويلاً، قم بتقصيره
    if (description.length > 50) {
      return '${description.substring(0, 47)}...';
    }
    
    return description;
  }

  List<String> get reciters {
    final descriptionParts = description.split('بصوت القُرَّاء :');
    if (descriptionParts.length > 1) {
      return descriptionParts[1]
          .split('،')[0]
          .split('-')
          .map((e) => e.trim())
          .toList();
    }
    return [];
  }

  @override
  List<Object?> get props => [id, title, description, type, addDate, surahs];
}

class QuranSurah extends Equatable {
  final int order;
  final String size;
  final String description;
  final String url;

  const QuranSurah({
    required this.order,
    required this.size,
    required this.description,
    required this.url,
  });

  factory QuranSurah.fromJson(Map<String, dynamic> json) {
    return QuranSurah(
      order: json['order'] ?? 0,
      size: json['size'] ?? '',
      description: json['description'] ?? '',
      url: json['url'] ?? '',
    );
  }

  String get formattedName {
    // Convert ar-001-makkah-1441 to سورة الفاتحة
    final surahNames = [
      'الفاتحة', 'البقرة', 'آل عمران', 'النساء', 'المائدة', 'الأنعام', 'الأعراف', 'الأنفال', 'التوبة', 'يونس',
      'هود', 'يوسف', 'الرعد', 'إبراهيم', 'الحجر', 'النحل', 'الإسراء', 'الكهف', 'مريم', 'طه',
      'الأنبياء', 'الحج', 'المؤمنون', 'النور', 'الفرقان', 'الشعراء', 'النمل', 'القصص', 'العنكبوت', 'الروم',
      'لقمان', 'السجدة', 'الأحزاب', 'سبأ', 'فاطر', 'يس', 'الصافات', 'ص', 'الزمر', 'غافر',
      'فصلت', 'الشورى', 'الزخرف', 'الدخان', 'الجاثية', 'الأحقاف', 'محمد', 'الفتح', 'الحجرات', 'ق',
      'الذاريات', 'الطور', 'النجم', 'القمر', 'الرحمن', 'الواقعة', 'الحديد', 'المجادلة', 'الحشر', 'الممتحنة',
      'الصف', 'الجمعة', 'المنافقون', 'التغابن', 'الطلاق', 'التحريم', 'الملك', 'القلم', 'الحاقة', 'المعارج',
      'نوح', 'الجن', 'المزمل', 'المدثر', 'القيامة', 'الإنسان', 'المرسلات', 'النبأ', 'النازعات', 'عبس',
      'التكوير', 'الانفطار', 'المطففين', 'الانشقاق', 'البروج', 'الطارق', 'الأعلى', 'الغاشية', 'الفجر', 'البلد',
      'الشمس', 'الليل', 'الضحى', 'الشرح', 'التين', 'العلق', 'القدر', 'البينة', 'الزلزلة', 'العاديات',
      'القارعة', 'التكاثر', 'العصر', 'الهمزة', 'الفيل', 'قريش', 'الماعون', 'الكوثر', 'الكافرون', 'النصر',
      'المسد', 'الإخلاص', 'الفلق', 'الناس'
    ];
    
    return 'سورة ${surahNames[order - 1]}';
  }

  @override
  List<Object?> get props => [order, size, description, url];
}