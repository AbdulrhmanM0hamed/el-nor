import 'package:equatable/equatable.dart';

class MemorizationCircle extends Equatable {
  final String id;
  final String name;
  final String description;
  final String? teacherId;
  final String? teacherName;
  final int? studentsCount;
  final DateTime createdAt;

  const MemorizationCircle({
    required this.id,
    required this.name,
    required this.description,
    this.teacherId,
    this.teacherName,
    this.studentsCount,
    required this.createdAt,
  });

  factory MemorizationCircle.fromJson(Map<String, dynamic> json) {
    return MemorizationCircle(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
      teacherId: json['teacher_id'],
      teacherName: json['teacher_name'],
      studentsCount: json['students_count'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'teacher_id': teacherId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  MemorizationCircle copyWith({
    String? id,
    String? name,
    String? description,
    String? teacherId,
    String? teacherName,
    int? studentsCount,
    DateTime? createdAt,
  }) {
    return MemorizationCircle(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      studentsCount: studentsCount ?? this.studentsCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        teacherId,
        teacherName,
        studentsCount,
        createdAt,
      ];
}
