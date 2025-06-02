import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/tafsir_model.dart';

abstract class TafsirRepository {
  Future<List<SurahModel>> getAllSurahsWithTafsir();
  Future<SurahModel?> getSurahWithTafsir(int surahId);
}

class TafsirRepositoryImpl implements TafsirRepository {
  @override
  Future<List<SurahModel>> getAllSurahsWithTafsir() async {
    try {
      // Load Quran data
      final String quranJsonString = await rootBundle.loadString('assets/json/warshData_v2-1.json');
      final List<dynamic> quranVerses = json.decode(quranJsonString) as List;
      
      // Load Tafsir data
      final String tafsirJsonString = await rootBundle.loadString('assets/json/ar_muyassar.json');
      final List<dynamic> tafsirJsonData = json.decode(tafsirJsonString) as List;
      
      // Convert to Tafsir models
      final List<TafsirModel> allTafsirs = tafsirJsonData
          .expand((surah) => (surah['data'] as List)
              .map((tafsir) => TafsirModel.fromJson(tafsir as Map<String, dynamic>)))
          .toList();
      
      // Process and group verses by surah
      Map<int, Map<String, dynamic>> surahMap = {};
      
      for (var verse in quranVerses) {
        final Map<String, dynamic> verseMap = verse as Map<String, dynamic>;
        final int surahNo = verseMap['sura_no'];
        
        if (!surahMap.containsKey(surahNo)) {
          surahMap[surahNo] = {
            'id': surahNo,
            'nameAr': verseMap['sura_name_ar'],
            'nameEn': verseMap['sura_name_en'],
            'type': _getSurahType(surahNo), // Determine type based on surah number
            'verses': <Map<String, dynamic>>[],
          };
        }
        
        surahMap[surahNo]!['verses'].add(verseMap);
      }
      
      // Calculate total verses and sort the verses
      List<SurahModel> surahs = [];
      surahMap.forEach((key, value) {
        // Sort verses by aya_no
        (value['verses'] as List).sort((a, b) => a['aya_no'].compareTo(b['aya_no']));
        
        // Set total verses
        value['totalVerses'] = (value['verses'] as List).length;
        
        // Create SurahModel
        final SurahModel surah = SurahModel.fromJson(value);
        surahs.add(surah);
      });
      
      // Sort surahs by id
      surahs.sort((a, b) => a.id.compareTo(b.id));
      
      // Merge tafsir with verses
      for (var surah in surahs) {
        for (var verse in surah.verses) {
          final tafsir = allTafsirs.firstWhere(
            (tafsir) => tafsir.surah == verse.surahNo && tafsir.ayah == verse.ayaNo,
            orElse: () => TafsirModel(id: 0, surah: 0, ayah: 0, text: 'لا يوجد تفسير'),
          );
          
          if (tafsir.id != 0) {
            verse.tafsir = tafsir.text;
          }
        }
      }
      
      return surahs;
    } catch (e) {
      throw Exception('Failed to load Quran and Tafsir data: $e');
    }
  }
  
  @override
  Future<SurahModel?> getSurahWithTafsir(int surahId) async {
    try {
      final surahs = await getAllSurahsWithTafsir();
      return surahs.firstWhere(
        (surah) => surah.id == surahId,
        orElse: () => throw Exception('Surah not found'),
      );
    } catch (e) {
      throw Exception('Failed to get Surah $surahId: $e');
    }
  }
  
  // Helper method to determine Surah type (Meccan or Medinan)
  String _getSurahType(int surahNo) {
    // Medinan Surahs: 2, 3, 4, 5, 8, 9, 24, 33, 47, 48, 49, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 98, 99, 110
    final List<int> medinanSurahs = [2, 3, 4, 5, 8, 9, 24, 33, 47, 48, 49, 57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 98, 99, 110];
    
    return medinanSurahs.contains(surahNo) ? 'medinan' : 'meccan';
  }
} 