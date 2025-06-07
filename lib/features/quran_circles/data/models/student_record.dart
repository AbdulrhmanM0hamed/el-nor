
class StudentRecord {
  final String studentId;
  final String name;
  final String? profileImageUrl;
  final List<EvaluationRecord> evaluations;
  final List<AttendanceRecord> attendance;

  const StudentRecord({
    required this.studentId,
    required this.name,
    this.profileImageUrl,
    this.evaluations = const [],
    this.attendance = const [],
  });

  factory StudentRecord.fromJson(Map<String, dynamic> json) {
    return StudentRecord(
      studentId: json['student_id'] as String,
      name: json['name'] as String,
      profileImageUrl: json['profile_image_url'] as String?,
      evaluations: (json['evaluations'] as List<dynamic>?)
          ?.map((e) => EvaluationRecord.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      attendance: (json['attendance'] as List<dynamic>?)
          ?.map((a) => AttendanceRecord.fromJson(a as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'name': name,
      'profile_image_url': profileImageUrl,
      'evaluations': evaluations.map((e) => e.toJson()).toList(),
      'attendance': attendance.map((a) => a.toJson()).toList(),
    };
  }

  StudentRecord copyWith({
    String? studentId,
    String? name,
    String? profileImageUrl,
    List<EvaluationRecord>? evaluations,
    List<AttendanceRecord>? attendance,
  }) {
    return StudentRecord(
      studentId: studentId ?? this.studentId,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      evaluations: evaluations ?? this.evaluations,
      attendance: attendance ?? this.attendance,
    );
  }
}

class EvaluationRecord {
  final DateTime date;
  final int rating;

  const EvaluationRecord({
    required this.date,
    required this.rating,
  });

  factory EvaluationRecord.fromJson(Map<String, dynamic> json) {
    return EvaluationRecord(
      date: DateTime.parse(json['date'] as String),
      rating: json['rating'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'rating': rating,
    };
  }
}

class AttendanceRecord {
  final DateTime date;
  final bool isPresent;

  const AttendanceRecord({
    required this.date,
    required this.isPresent,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      date: DateTime.parse(json['date'] as String),
      isPresent: json['is_present'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'is_present': isPresent,
    };
  }
} 