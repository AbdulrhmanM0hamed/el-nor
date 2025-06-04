import 'package:equatable/equatable.dart';

class StudentRecord extends Equatable {
  final String studentId;
  final String name;
  final String? profileImageUrl;
  final List<AttendanceRecord> attendance;
  final List<EvaluationRecord> evaluations;

  const StudentRecord({
    required this.studentId,
    required this.name,
    this.profileImageUrl,
    this.attendance = const [],
    this.evaluations = const [],
  });

  // Factory constructor from JSON
  factory StudentRecord.fromJson(Map<String, dynamic> json) {
    return StudentRecord(
      studentId: json['student_id'] as String,
      name: json['name'] as String,
      profileImageUrl: json['profile_image_url'] as String?,
      attendance: (json['attendance'] as List?)
              ?.map((e) => AttendanceRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      evaluations: (json['evaluations'] as List?)
              ?.map((e) => EvaluationRecord.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'name': name,
      'profile_image_url': profileImageUrl,
      'attendance': attendance.map((x) => x.toJson()).toList(),
      'evaluations': evaluations.map((x) => x.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [studentId, name, profileImageUrl, attendance, evaluations];
}

class AttendanceRecord extends Equatable {
  final DateTime date;
  final bool isPresent;
  final String? notes;

  const AttendanceRecord({
    required this.date,
    required this.isPresent,
    this.notes,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      date: DateTime.parse(json['date'] as String),
      isPresent: json['is_present'] as bool,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'is_present': isPresent,
      'notes': notes,
    };
  }

  @override
  List<Object?> get props => [date, isPresent, notes];
}

class EvaluationRecord extends Equatable {
  final DateTime date;
  final int rating;
  final String? notes;

  const EvaluationRecord({
    required this.date,
    required this.rating,
    this.notes,
  });

  factory EvaluationRecord.fromJson(Map<String, dynamic> json) {
    return EvaluationRecord(
      date: DateTime.parse(json['date'] as String),
      rating: json['rating'] as int,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'rating': rating,
      'notes': notes,
    };
  }

  @override
  List<Object?> get props => [date, rating, notes];
} 