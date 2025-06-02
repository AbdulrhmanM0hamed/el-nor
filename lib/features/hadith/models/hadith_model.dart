import 'dart:convert';

class HadithCollection {
  final int id;
  final String name;
  final String sectionName;
  final List<Hadith> hadiths;

  HadithCollection({
    required this.id,
    required this.name,
    required this.sectionName,
    required this.hadiths,
  });

  factory HadithCollection.fromJson(Map<String, dynamic> json) {
    final id = json['id'] as int;
    final data = json['data'] as Map<String, dynamic>;
    final metadata = data['metadata'] as Map<String, dynamic>;
    final section = metadata['section'] as Map<String, dynamic>;
    
    return HadithCollection(
      id: id,
      name: metadata['name'] as String,
      sectionName: section['name'] as String,
      hadiths: (data['hadiths'] as List)
          .map((hadith) => Hadith.fromJson(hadith as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Hadith {
  final int hadithNumber;
  final int arabicNumber;
  final String text;
  final List<Grade> grades;
  final String reference;

  Hadith({
    required this.hadithNumber,
    required this.arabicNumber,
    required this.text,
    required this.grades,
    required this.reference,
  });

  factory Hadith.fromJson(Map<String, dynamic> json) {
    List<Grade> gradesList = [];
    if (json.containsKey('grades') && json['grades'] != null) {
      gradesList = (json['grades'] as List)
          .map((grade) => Grade.fromJson(grade as Map<String, dynamic>))
          .toList();
    }

    return Hadith(
      hadithNumber: json['hadithnumber'] as int,
      arabicNumber: json['arabicnumber'] as int,
      text: json['text'] as String,
      grades: gradesList,
      reference: json['reference'] is Map ? '' : (json['reference'] as String? ?? ''),
    );
  }
}

class Grade {
  final String name;
  final String grade;

  Grade({
    required this.name,
    required this.grade,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
      name: json['name'] as String,
      grade: json['grade'] as String,
    );
  }
} 