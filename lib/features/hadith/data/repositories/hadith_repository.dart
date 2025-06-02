import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/hadith_model.dart';

abstract class HadithRepository {
  Future<List<HadithCollection>> getHadithCollections();
}

class HadithRepositoryImpl implements HadithRepository {
  @override
  Future<List<HadithCollection>> getHadithCollections() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/json/hadith.json');
      final List<dynamic> decodedJson = json.decode(jsonString) as List<dynamic>;
      
      return decodedJson.map((item) {
        try {
          return HadithCollection.fromJson(item as Map<String, dynamic>);
        } catch (e) {
          throw Exception('Error parsing hadith item: ${e.toString()}');
        }
      }).toList();
    } catch (e) {
      throw Exception('Failed to load hadith data: ${e.toString()}');
    }
  }
} 