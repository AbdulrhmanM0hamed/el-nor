import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/azkar_model.dart';

class AzkarService {
  // Singleton implementation
  static final AzkarService _instance = AzkarService._internal();
  factory AzkarService() => _instance;
  AzkarService._internal();

  // Cached categories
  List<AzkarCategory>? _categories;

  // Get all Azkar categories
  Future<List<AzkarCategory>> getCategories() async {
    // Return cached data if available
    if (_categories != null) return _categories!;
    
    try {
      // Load azkar data from assets
      final String jsonData = await rootBundle.loadString('assets/json/azkar.json');
      final List<dynamic> categoriesJson = json.decode(jsonData);
      
      // Parse the JSON data
      _categories = categoriesJson.map((category) {
        return AzkarCategory(
          id: category['id'].toString(),
          name: category['category'],
          icon: category['filename'] ?? '',
          items: (category['array'] as List).map((item) => Zikr(
            id: item['id'].toString(),
            text: item['text'],
            fadl: item['fadl'],
            source: item['source'],
            count: item['count'],
          )).toList(),
        );
      }).toList();
      
      return _categories!;
    } catch (e) {
      throw Exception('Failed to load Azkar data: $e');
    }
  }

  // Get a specific Azkar category by ID
  Future<AzkarCategory?> getCategoryById(String id) async {
    final categories = await getCategories();
    
    try {
      return categories.firstWhere((category) => category.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get a specific category by name
  Future<AzkarCategory?> getCategoryByName(String name) async {
    final categories = await getCategories();
    try {
      return categories.firstWhere(
        (category) => category.name.contains(name),
      );
    } catch (e) {
      return null;
    }
  }
} 