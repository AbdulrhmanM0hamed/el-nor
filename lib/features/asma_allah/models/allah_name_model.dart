import '../data/repositories/allah_names_repository.dart';

class AllahName {
  final String name;
  final String text;

  AllahName({
    required this.name,
    required this.text,
  });

  factory AllahName.fromJson(Map<String, dynamic> json) {
    return AllahName(
      name: json['name'] as String,
      text: json['text'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'text': text,
    };
  }
}

class AllahNamesList {
  static List<AllahName> namesList = [];

  static Future<void> preInitialize() async {
    if (namesList.isEmpty) {
      await loadNames();
    }
  }

  static Future<void> loadNames() async {
    try {
      final repository = AllahNamesRepositoryImpl();
      namesList = await repository.getAllahNames();
    } catch (e) {
      print('Error loading names: $e');
    }
  }
} 