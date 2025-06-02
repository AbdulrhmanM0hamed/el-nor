import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

class Surah {
  final int id;
  final String name;
  final String transliteration;
  final String translation;
  final String type;
  final int totalVerses;
  int pageNumber;

  Surah({
    required this.id,
    required this.name,
    required this.transliteration,
    required this.translation,
    required this.type,
    required this.totalVerses,
    required this.pageNumber,
  });

  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      id: json['id'],
      name: json['name'],
      transliteration: json['transliteration'],
      translation: json['translation'],
      type: json['type'],
      totalVerses: json['total_verses'],
      pageNumber: json['id'],
    );
  }

  bool get isMakki => type == 'meccan';
  
  int get originalPageNumber {
    switch (id) {
      case 1: return 1;
      case 2: return 2;
      case 3: return 50;
      case 4: return 77;
      case 5: return 106;
      case 6: return 128;
      case 7: return 151;
      case 8: return 177;
      case 9: return 187;
      case 10: return 208;
      case 11: return 221;
      case 12: return 235;
      case 13: return 249;
      case 14: return 255;
      case 15: return 262;
      case 16: return 267;
      case 17: return 282;
      case 18: return 293;
      case 19: return 305;
      case 20: return 312;
      case 21: return 322;
      case 22: return 332;
      case 23: return 342;
      case 24: return 350;
      case 25: return 359;
      case 26: return 367;
      case 27: return 377;
      case 28: return 385;
      case 29: return 396;
      case 30: return 404;
      case 31: return 411;
      case 32: return 415;
      case 33: return 418;
      case 34: return 428;
      case 35: return 434;
      case 36: return 440;
      case 37: return 446;
      case 38: return 453;
      case 39: return 458;
      case 40: return 467;
      case 41: return 477;
      case 42: return 483;
      case 43: return 489;
      case 44: return 496;
      case 45: return 499;
      case 46: return 502;
      case 47: return 507;
      case 48: return 511;
      case 49: return 515;
      case 50: return 518;
      case 51: return 520;
      case 52: return 523;
      case 53: return 526;
      case 54: return 528;
      case 55: return 531;
      case 56: return 534;
      case 57: return 537;
      case 58: return 542;
      case 59: return 545;
      case 60: return 549;
      case 61: return 551;
      case 62: return 553;
      case 63: return 554;
      case 64: return 556;
      case 65: return 558;
      case 66: return 560;
      case 67: return 562;
      case 68: return 564;
      case 69: return 566;
      case 70: return 568;
      case 71: return 570;
      case 72: return 572;
      case 73: return 574;
      case 74: return 575;
      case 75: return 577;
      case 76: return 578;
      case 77: return 580;
      case 78: return 582;
      case 79: return 583;
      case 80: return 585;
      case 81: return 586;
      case 82: return 587;
      case 83: return 587;
      case 84: return 589;
      case 85: return 590;
      case 86: return 591;
      case 87: return 591;
      case 88: return 592;
      case 89: return 593;
      case 90: return 594;
      case 91: return 595;
      case 92: return 595;
      case 93: return 596;
      case 94: return 596;
      case 95: return 597;
      case 96: return 597;
      case 97: return 598;
      case 98: return 598;
      case 99: return 599;
      case 100: return 599;
      case 101: return 600;
      case 102: return 600;
      case 103: return 601;
      case 104: return 601;
      case 105: return 601;
      case 106: return 602;
      case 107: return 602;
      case 108: return 602;
      case 109: return 603;
      case 110: return 603;
      case 111: return 603;
      case 112: return 604;
      case 113: return 604;
      case 114: return 604;
      default: return 1;
    }
  }
}

class SurahList {
  static List<Surah> surahs = [];
  static List<dynamic> rawJsonData = [];
  static bool jsonLoaded = false;
  static bool _isLoading = false;
  static Map<int, List<Surah>> _cachedPagedSurahs = {}; // Cache for paginated results
  
  // Pre-initialize the JSON data at app start but without blocking
  static void preInitialize() {
    loadJsonData();
  }
  
  static Future<void> loadJsonData() async {
    if (jsonLoaded || _isLoading) {
      debugPrint('SurahList: JSON data already loaded or loading in progress');
      return;
    }
    
    _isLoading = true;
    try {
      // Load the JSON data from the assets file
      debugPrint('SurahList: Loading JSON data from assets');
      final String jsonString = await rootBundle.loadString('assets/json/name_quran.json');
      rawJsonData = json.decode(jsonString);
      jsonLoaded = true;
      debugPrint('SurahList: JSON data loaded successfully with ${rawJsonData.length} items');
    } catch (e) {
      rawJsonData = [];
      jsonLoaded = false;
      debugPrint('SurahList: Error loading surah data: $e');
    } finally {
      _isLoading = false;
    }
  }
  
  static Future<List<Surah>> loadSurahs() async {
    if (!jsonLoaded) {
      debugPrint('SurahList: JSON not loaded, loading now...');
      await loadJsonData();
    }

    if (surahs.isEmpty && rawJsonData.isNotEmpty) {
      // Process in a separate isolate to avoid UI freezes
      debugPrint('SurahList: Processing surahs from raw data...');
      surahs = await compute(_processSurahsFromJsonIsolate, rawJsonData);
      debugPrint('SurahList: Processed ${surahs.length} surahs');
    } else {
      debugPrint('SurahList: Surahs already loaded (${surahs.length}) or raw data is empty (${rawJsonData.length})');
    }

    return surahs;
  }
  
  // For processing in a separate isolate
  static List<Surah> _processSurahsFromJsonIsolate(List<dynamic> data) {
    return _processAndReturnSurahs(data);
  }
  
  static Future<List<Surah>> loadSurahsPaginated({required int page, required int pageSize}) async {
    if (!jsonLoaded) {
      await loadJsonData();
    }

    if (rawJsonData.isEmpty) {
      return [];
    }
    
    // Check if this page is already cached
    if (_cachedPagedSurahs.containsKey(page)) {
      return _cachedPagedSurahs[page]!;
    }

    // Calculate start and end indices
    final int startIndex = (page - 1) * pageSize;
    int endIndex = startIndex + pageSize;
    
    // Ensure end index doesn't exceed the data length
    if (endIndex > rawJsonData.length) {
      endIndex = rawJsonData.length;
    }

    // Check if requested page is valid
    if (startIndex >= rawJsonData.length) {
      return [];
    }

    // Get the subset of data for the requested page
    final List<dynamic> paginatedData = rawJsonData.sublist(startIndex, endIndex);
    
    // Process the paginated data in a separate isolate for better performance
    final List<Surah> paginatedSurahs = await compute(_processPageIsolate, paginatedData);
    
    // Cache the results for future use
    _cachedPagedSurahs[page] = paginatedSurahs;
    
    // Ensure we update the static surahs list if we're loading all data
    if (surahs.isEmpty && page == 1 && pageSize >= rawJsonData.length) {
      surahs = paginatedSurahs;
    }
    
    return paginatedSurahs;
  }
  
  // For processing paginated data in a separate isolate
  static List<Surah> _processPageIsolate(List<dynamic> data) {
    return _processAndReturnSurahs(data);
  }
  
  static int getTotalPages(int pageSize) {
    if (rawJsonData.isEmpty) {
      return 0;
    }
    
    return (rawJsonData.length / pageSize).ceil();
  }
  
  static int getTotalSurahs() {
    return rawJsonData.length;
  }
  
  static List<Surah> _processSurahsFromJson(List<dynamic> jsonData) {
    return _processAndReturnSurahs(jsonData);
  }
  
  static List<Surah> _processAndReturnSurahs(List<dynamic> jsonData) {
    // Process each JSON object into a Surah
    return jsonData.map((json) {
      final Surah surah = Surah.fromJson(json);
      
      // Assign page numbers with the reversed mapping
      // Formula: reversedPage = 605 - originalPage
      // (605 instead of 604 because we're dealing with 1-indexed pages)
      switch (surah.id) {
        case 1: surah.pageNumber = 605 - 1; break; // 604
        case 2: surah.pageNumber = 605 - 2; break; // 603
        case 3: surah.pageNumber = 605 - 50; break; // 555
        case 4: surah.pageNumber = 605 - 77; break; // 528
        case 5: surah.pageNumber = 605 - 106; break; // 499
        case 6: surah.pageNumber = 605 - 128; break; // 477
        case 7: surah.pageNumber = 605 - 151; break; // 454
        case 8: surah.pageNumber = 605 - 177; break; // 428
        case 9: surah.pageNumber = 605 - 187; break; // 418
        case 10: surah.pageNumber = 605 - 208; break; // 397
        case 11: surah.pageNumber = 605 - 221; break; // 384
        case 12: surah.pageNumber = 605 - 235; break; // 370
        case 13: surah.pageNumber = 605 - 249; break; // 356
        case 14: surah.pageNumber = 605 - 255; break; // 350
        case 15: surah.pageNumber = 605 - 262; break; // 343
        case 16: surah.pageNumber = 605 - 267; break; // 338
        case 17: surah.pageNumber = 605 - 282; break; // 323
        case 18: surah.pageNumber = 605 - 293; break; // 312
        case 19: surah.pageNumber = 605 - 305; break; // 300
        case 20: surah.pageNumber = 605 - 312; break; // 293
        case 21: surah.pageNumber = 605 - 322; break; // 283
        case 22: surah.pageNumber = 605 - 332; break; // 273
        case 23: surah.pageNumber = 605 - 342; break; // 263
        case 24: surah.pageNumber = 605 - 350; break; // 255
        case 25: surah.pageNumber = 605 - 359; break; // 246
        case 26: surah.pageNumber = 605 - 367; break; // 238
        case 27: surah.pageNumber = 605 - 377; break; // 228
        case 28: surah.pageNumber = 605 - 385; break; // 220
        case 29: surah.pageNumber = 605 - 396; break; // 209
        case 30: surah.pageNumber = 605 - 404; break; // 201
        case 31: surah.pageNumber = 605 - 411; break; // 194
        case 32: surah.pageNumber = 605 - 415; break; // 190
        case 33: surah.pageNumber = 605 - 418; break; // 187
        case 34: surah.pageNumber = 605 - 428; break; // 177
        case 35: surah.pageNumber = 605 - 434; break; // 171
        case 36: surah.pageNumber = 605 - 440; break; // 165
        case 37: surah.pageNumber = 605 - 446; break; // 159
        case 38: surah.pageNumber = 605 - 453; break; // 152
        case 39: surah.pageNumber = 605 - 458; break; // 147
        case 40: surah.pageNumber = 605 - 467; break; // 138
        case 41: surah.pageNumber = 605 - 477; break; // 128
        case 42: surah.pageNumber = 605 - 483; break; // 122
        case 43: surah.pageNumber = 605 - 489; break; // 116
        case 44: surah.pageNumber = 605 - 496; break; // 109
        case 45: surah.pageNumber = 605 - 499; break; // 106
        case 46: surah.pageNumber = 605 - 502; break; // 103
        case 47: surah.pageNumber = 605 - 507; break; // 98
        case 48: surah.pageNumber = 605 - 511; break; // 94
        case 49: surah.pageNumber = 605 - 515; break; // 90
        case 50: surah.pageNumber = 605 - 518; break; // 87
        case 51: surah.pageNumber = 605 - 520; break; // 85
        case 52: surah.pageNumber = 605 - 523; break; // 82
        case 53: surah.pageNumber = 605 - 526; break; // 79
        case 54: surah.pageNumber = 605 - 528; break; // 77
        case 55: surah.pageNumber = 605 - 531; break; // 74
        case 56: surah.pageNumber = 605 - 534; break; // 71
        case 57: surah.pageNumber = 605 - 537; break; // 68
        case 58: surah.pageNumber = 605 - 542; break; // 63
        case 59: surah.pageNumber = 605 - 545; break; // 60
        case 60: surah.pageNumber = 605 - 549; break; // 56
        case 61: surah.pageNumber = 605 - 551; break; // 54
        case 62: surah.pageNumber = 605 - 553; break; // 52
        case 63: surah.pageNumber = 605 - 554; break; // 51
        case 64: surah.pageNumber = 605 - 556; break; // 49
        case 65: surah.pageNumber = 605 - 558; break; // 47
        case 66: surah.pageNumber = 605 - 560; break; // 45
        case 67: surah.pageNumber = 605 - 562; break; // 43
        case 68: surah.pageNumber = 605 - 564; break; // 41
        case 69: surah.pageNumber = 605 - 566; break; // 39
        case 70: surah.pageNumber = 605 - 568; break; // 37
        case 71: surah.pageNumber = 605 - 570; break; // 35
        case 72: surah.pageNumber = 605 - 572; break; // 33
        case 73: surah.pageNumber = 605 - 574; break; // 31
        case 74: surah.pageNumber = 605 - 575; break; // 30
        case 75: surah.pageNumber = 605 - 577; break; // 28
        case 76: surah.pageNumber = 605 - 578; break; // 27
        case 77: surah.pageNumber = 605 - 580; break; // 25
        case 78: surah.pageNumber = 605 - 582; break; // 23
        case 79: surah.pageNumber = 605 - 583; break; // 22
        case 80: surah.pageNumber = 605 - 585; break; // 20
        case 81: surah.pageNumber = 605 - 586; break; // 19
        case 82: surah.pageNumber = 605 - 587; break; // 18
        case 83: surah.pageNumber = 605 - 587; break; // 18
        case 84: surah.pageNumber = 605 - 589; break; // 16
        case 85: surah.pageNumber = 605 - 590; break; // 15
        case 86: surah.pageNumber = 605 - 591; break; // 14
        case 87: surah.pageNumber = 605 - 591; break; // 14
        case 88: surah.pageNumber = 605 - 592; break; // 13
        case 89: surah.pageNumber = 605 - 593; break; // 12
        case 90: surah.pageNumber = 605 - 594; break; // 11
        case 91: surah.pageNumber = 605 - 595; break; // 10
        case 92: surah.pageNumber = 605 - 595; break; // 10
        case 93: surah.pageNumber = 605 - 596; break; // 9
        case 94: surah.pageNumber = 605 - 596; break; // 9
        case 95: surah.pageNumber = 605 - 597; break; // 8
        case 96: surah.pageNumber = 605 - 597; break; // 8
        case 97: surah.pageNumber = 605 - 598; break; // 7
        case 98: surah.pageNumber = 605 - 598; break; // 7
        case 99: surah.pageNumber = 605 - 599; break; // 6
        case 100: surah.pageNumber = 605 - 599; break; // 6
        case 101: surah.pageNumber = 605 - 600; break; // 5
        case 102: surah.pageNumber = 605 - 600; break; // 5
        case 103: surah.pageNumber = 605 - 601; break; // 4
        case 104: surah.pageNumber = 605 - 601; break; // 4
        case 105: surah.pageNumber = 605 - 601; break; // 4
        case 106: surah.pageNumber = 605 - 602; break; // 3
        case 107: surah.pageNumber = 605 - 602; break; // 3
        case 108: surah.pageNumber = 605 - 602; break; // 3
        case 109: surah.pageNumber = 605 - 603; break; // 2
        case 110: surah.pageNumber = 605 - 603; break; // 2
        case 111: surah.pageNumber = 605 - 603; break; // 2
        case 112: surah.pageNumber = 605 - 604; break; // 1
        case 113: surah.pageNumber = 605 - 604; break; // 1
        case 114: surah.pageNumber = 605 - 604; break; // 1
        default: surah.pageNumber = 605 - 1; // Default to last page
      }
      
      return surah;
    }).toList();
  }

  // Directly load and process all surahs without pagination
  // This is a simpler approach that may be more reliable
  static Future<List<Surah>> loadAllSurahsDirectly() async {
    debugPrint('SurahList: Loading all surahs directly');
    
    if (!jsonLoaded) {
      await loadJsonData();
    }
    
    if (rawJsonData.isEmpty) {
      debugPrint('SurahList: Raw data is empty after loading');
      return [];
    }
    
    if (surahs.isEmpty) {
      surahs = _processAndReturnSurahs(rawJsonData);
      debugPrint('SurahList: Directly processed ${surahs.length} surahs');
    } else {
      debugPrint('SurahList: Surahs already loaded, returning ${surahs.length} surahs');
    }
    
    return surahs;
  }
} 