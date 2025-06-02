import 'dart:convert';

class SurahModel {
  final int id;
  final String nameAr;
  final String nameEn;
  final String type; // meccan or medinan
  final int totalVerses;
  final List<VerseModel> verses;

  SurahModel({
    required this.id,
    required this.nameAr,
    required this.nameEn,
    required this.type,
    required this.totalVerses,
    required this.verses,
  });

  factory SurahModel.fromJson(Map<String, dynamic> json) {
    return SurahModel(
      id: json['id'],
      nameAr: json['nameAr'],
      nameEn: json['nameEn'],
      type: json['type'],
      totalVerses: json['totalVerses'],
      verses: (json['verses'] as List)
          .map((verse) => VerseModel.fromJson(verse))
          .toList(),
    );
  }
}

class VerseModel {
  final int id;
  final int surahNo;
  final int ayaNo;
  final int jozz;
  final String page;
  final String text;
  String? tafsir; // Might be null initially

  VerseModel({
    required this.id,
    required this.surahNo,
    required this.ayaNo,
    required this.jozz,
    required this.page,
    required this.text,
    this.tafsir,
  });

  factory VerseModel.fromJson(Map<String, dynamic> json) {
    // Get the original text
    String originalText = json['aya_text'] as String;
    
    // Remove the last two special characters if present
    String cleanedText = _cleanAyaText(originalText);
    
    return VerseModel(
      id: json['id'],
      surahNo: json['sura_no'],
      ayaNo: json['aya_no'],
      jozz: json['jozz'],
      page: json['page'],
      text: cleanedText,
      tafsir: null, // Will be loaded from the tafsir file
    );
  }

  // Helper method to clean the Quranic text by removing the special markers at the end
  static String _cleanAyaText(String text) {
    // Check if there are at least 2 characters
    if (text.length <= 2) return text;
    
    // Get the last character (which is usually a special marker)
    String lastChar = text[text.length - 1];
    
    // Check if the last character is in the range of special markers
    // Unicode range for these markers is around U+DC00 to U+DFFF or similar
    // We'll use a more general approach by checking if it's not a regular Arabic character
    // Regular Arabic characters are in the range U+0600 to U+06FF
    if (_isSpecialMarker(lastChar)) {
      // Remove the last character and any potential whitespace before it
      return text.substring(0, text.length - 1).trim();
    }
    
    return text;
  }
  
  // Check if a character is a special marker not part of regular Arabic text
  static bool _isSpecialMarker(String char) {
    if (char.isEmpty) return false;
    
    // Common verse markers in Quran text files
    const List<String> knownMarkers = ['ﰀ', 'ﰁ', 'ﰂ', 'ﰃ', 'ﰄ', 'ﰅ', 'ﰆ', 'ﰇ', 'ﰈ', 'ﰉ', 'ﰊ', 'ﰋ', 'ﰌ', 'ﰍ', 'ﰎ', 'ﰏ'];
    
    // Check if the character is in our known markers list
    if (knownMarkers.contains(char)) {
      return true;
    }
    
    // Check if it's outside the regular Arabic character range
    int code = char.codeUnitAt(0);
    bool isRegularArabic = code >= 0x0600 && code <= 0x06FF;
    bool isArabicSupplement = code >= 0x0750 && code <= 0x077F;
    bool isArabicExtendedA = code >= 0x08A0 && code <= 0x08FF;
    
    // If it's not a regular Arabic character or known supplement, it's likely a special marker
    return !(isRegularArabic || isArabicSupplement || isArabicExtendedA);
  }

  VerseModel copyWith({
    int? id,
    int? surahNo,
    int? ayaNo,
    int? jozz,
    String? page,
    String? text,
    String? tafsir,
  }) {
    return VerseModel(
      id: id ?? this.id,
      surahNo: surahNo ?? this.surahNo,
      ayaNo: ayaNo ?? this.ayaNo,
      jozz: jozz ?? this.jozz,
      page: page ?? this.page,
      text: text ?? this.text,
      tafsir: tafsir ?? this.tafsir,
    );
  }
}

class TafsirModel {
  final int id;
  final int surah;
  final int ayah;
  final String text;

  TafsirModel({
    required this.id,
    required this.surah,
    required this.ayah,
    required this.text,
  });

  factory TafsirModel.fromJson(Map<String, dynamic> json) {
    return TafsirModel(
      id: json['id'],
      surah: json['sura'],
      ayah: json['aya'],
      text: json['text'],
    );
  }
} 