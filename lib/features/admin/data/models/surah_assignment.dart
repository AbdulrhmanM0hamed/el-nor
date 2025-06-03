import 'package:uuid/uuid.dart';

class SurahAssignment {
  final String id;
  final String surahName;
  final int startVerse;
  final int endVerse;
  final String? notes;
  final DateTime assignedDate;

  SurahAssignment({
    required this.id,
    required this.surahName,
    required this.startVerse,
    required this.endVerse,
    this.notes,
    required this.assignedDate,
  });

  factory SurahAssignment.create({
    required String surahName,
    required int startVerse,
    required int endVerse,
    String? notes,
  }) {
    return SurahAssignment(
      id: const Uuid().v4(),
      surahName: surahName,
      startVerse: startVerse,
      endVerse: endVerse,
      notes: notes,
      assignedDate: DateTime.now(),
    );
  }

  SurahAssignment copyWith({
    String? id,
    String? surahName,
    int? startVerse,
    int? endVerse,
    String? notes,
    DateTime? assignedDate,
  }) {
    return SurahAssignment(
      id: id ?? this.id,
      surahName: surahName ?? this.surahName,
      startVerse: startVerse ?? this.startVerse,
      endVerse: endVerse ?? this.endVerse,
      notes: notes ?? this.notes,
      assignedDate: assignedDate ?? this.assignedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surah_name': surahName,
      'start_verse': startVerse,
      'end_verse': endVerse,
      'notes': notes,
      'assigned_date': assignedDate.toIso8601String(),
    };
  }

  factory SurahAssignment.fromJson(Map<String, dynamic> json) {
    return SurahAssignment(
      id: json['id'],
      surahName: json['surah_name'],
      startVerse: json['start_verse'],
      endVerse: json['end_verse'],
      notes: json['notes'],
      assignedDate: DateTime.parse(json['assigned_date']),
    );
  }
}
