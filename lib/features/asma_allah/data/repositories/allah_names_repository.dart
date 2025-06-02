import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import '../../models/allah_name_model.dart';

abstract class AllahNamesRepository {
  Future<List<AllahName>> getAllahNames();
}

class AllahNamesRepositoryImpl implements AllahNamesRepository {
  static final AllahNamesRepositoryImpl _instance = AllahNamesRepositoryImpl._internal();
  final Logger _logger = Logger();
  
  factory AllahNamesRepositoryImpl() {
    return _instance;
  }
  
  AllahNamesRepositoryImpl._internal();
  
  List<AllahName>? _cachedNames;

  @override
  Future<List<AllahName>> getAllahNames() async {
    if (_cachedNames != null && _cachedNames!.isNotEmpty) {
      _logger.i('Returning cached Names of Allah: ${_cachedNames!.length} names');
      return _cachedNames!;
    }
    
    try {
      _logger.i('Loading Names of Allah from JSON file...');
      final String jsonData = await rootBundle.loadString('assets/json/Names_Of_Allah.json');
      _logger.i('JSON data loaded successfully, length: ${jsonData.length}');
      
      final List<dynamic> jsonList = json.decode(jsonData);
      _logger.i('JSON decoded successfully, found ${jsonList.length} names');
      
      _cachedNames = jsonList.map((item) => AllahName.fromJson(item)).toList();
      _logger.i('Names of Allah parsed successfully');
      
      // Update the static list for faster access
      AllahNamesList.namesList = _cachedNames!;
      
      return _cachedNames!;
    } catch (e, stackTrace) {
      _logger.e('Error loading Names of Allah', error: e, stackTrace: stackTrace);
      return [];
    }
  }
} 