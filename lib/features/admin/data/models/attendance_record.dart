import 'package:equatable/equatable.dart';

class AttendanceRecord extends Equatable {
  final DateTime date;
  final bool isPresent;
  final int? rating;  // من 0 إلى 5 نجوم
  final String? notes;

  const AttendanceRecord({
    required this.date,
    required this.isPresent,
    this.rating,
    this.notes,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      date: DateTime.parse(json['date'] as String),
      isPresent: json['is_present'] as bool,
      rating: json['rating'] as int?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String().split('T')[0],  // نأخذ فقط التاريخ بدون الوقت
      'is_present': isPresent,
      'rating': rating,
      'notes': notes,
    };
  }

  @override
  List<Object?> get props => [date, isPresent, rating, notes];
}

class StudentAttendanceRecord extends Equatable {
  final String studentId;
  final List<AttendanceRecord> records;

  const StudentAttendanceRecord({
    required this.studentId,
    required this.records,
  });

  factory StudentAttendanceRecord.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceRecord(
      studentId: json['student_id'] as String,
      records: (json['records'] as List<dynamic>)
          .map((record) => AttendanceRecord.fromJson(record as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'records': records.map((record) => record.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [studentId, records];
} 