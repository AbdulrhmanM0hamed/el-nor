import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import '../../models/allah_name_model.dart';

abstract class AllahNamesRepository {
  Future<List<AllahName>> getAllahNames();
}

class AllahNamesRepositoryImpl implements AllahNamesRepository {
  static final AllahNamesRepositoryImpl _instance =
      AllahNamesRepositoryImpl._internal();
  final Logger _logger = Logger();

  factory AllahNamesRepositoryImpl() {
    return _instance;
  }

  AllahNamesRepositoryImpl._internal();

  List<AllahName>? _cachedNames;

  @override
  Future<List<AllahName>> getAllahNames() async {
    if (_cachedNames != null && _cachedNames!.isNotEmpty) {
      return _cachedNames!;
    }

    try {
      final String jsonData =
          await rootBundle.loadString('assets/json/Names_Of_Allah.json');

      final List<dynamic> jsonList = json.decode(jsonData);

      _cachedNames = jsonList.map((item) => AllahName.fromJson(item)).toList();

      // Update the static list for faster access
      AllahNamesList.namesList = _cachedNames!;

      return _cachedNames!;
    } catch (e, stackTrace) {
      _logger.e('Error loading Names of Allah',
          error: e, stackTrace: stackTrace);
      return [];
    }
  }
}
