class SurahAssignment {
  final String id;
  final String surahName;
  final int startVerse;
  final int endVerse;
  final DateTime? dueDate;
  final bool isCompleted;

  const SurahAssignment({
    required this.id,
    required this.surahName,
    required this.startVerse,
    required this.endVerse,
    this.dueDate,
    this.isCompleted = false,
  });

  factory SurahAssignment.fromJson(Map<String, dynamic> json) {
    return SurahAssignment(
      id: json['id'] as String,
      surahName: json['surah_name'] as String,
      startVerse: json['start_verse'] as int,
      endVerse: json['end_verse'] as int,
      dueDate: json['due_date'] != null 
        ? DateTime.parse(json['due_date'] as String) 
        : null,
      isCompleted: json['is_completed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'surah_name': surahName,
      'start_verse': startVerse,
      'end_verse': endVerse,
      'due_date': dueDate?.toIso8601String(),
      'is_completed': isCompleted,
    };
  }

  SurahAssignment copyWith({
    String? id,
    String? surahName,
    int? startVerse,
    int? endVerse,
    DateTime? dueDate,
    bool? isCompleted,
  }) {
    return SurahAssignment(
      id: id ?? this.id,
      surahName: surahName ?? this.surahName,
      startVerse: startVerse ?? this.startVerse,
      endVerse: endVerse ?? this.endVerse,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
} 