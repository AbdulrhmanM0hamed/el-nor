import 'package:uuid/uuid.dart';
import 'surah_assignment.dart';

class MemorizationCircleModel {
  final String id;
  final String name;
  final String? description;
  final String? teacherId;
  final String? teacherName; // للعرض فقط
  final String? teacherImageUrl; // لعرض صورة المعلم
  final bool isExam;
  final DateTime startDate;
  final DateTime? endDate;
  final String status;
  final List<SurahAssignment> surahAssignments;
  final List<CircleStudent> students;
  final List<String> studentIds; // IDs de los estudiantes para facilitar la selección
  final DateTime createdAt;
  final DateTime updatedAt;

  MemorizationCircleModel({
    required this.id,
    required this.name,
    this.description,
    this.teacherId,
    this.teacherName,
    this.teacherImageUrl,
    required this.isExam,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.surahAssignments,
    required this.students,
    required this.studentIds,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MemorizationCircleModel.fromJson(Map<String, dynamic> json) {
    // تحويل قائمة السور من JSON
    List<SurahAssignment> surahAssignments = [];
    if (json['surah_assignments'] != null) {
      final List<dynamic> surahList = json['surah_assignments'];
      surahAssignments = surahList
          .map((surah) => SurahAssignment.fromJson(surah))
          .toList();
    }

    // تحويل قائمة الطلاب من JSON
    List<CircleStudent> students = [];
    if (json['students'] != null) {
      final List<dynamic> studentList = json['students'];
      students = studentList
          .map((student) => CircleStudent.fromJson(student))
          .toList();
    }
    
    // تحويل قائمة معرفات الطلاب من JSON
    List<String> studentIds = [];
    if (json['student_ids'] != null) {
      final List<dynamic> idsList = json['student_ids'];
      studentIds = idsList.map((id) => id.toString()).toList();
    }

    return MemorizationCircleModel(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      teacherId: json['teacher_id'],
      teacherName: json['teacher_name'], // قد يكون من استعلام JOIN
      teacherImageUrl: json['teacher_image_url'],
      isExam: json['is_exam'] ?? false,
      startDate: DateTime.parse(json['start_date']),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'])
          : null,
      status: json['status'] ?? 'active',
      surahAssignments: surahAssignments,
      students: students,
      studentIds: studentIds,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'teacher_id': teacherId,
      'teacher_image_url': teacherImageUrl,
      'is_exam': isExam,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status': status,
      'surah_assignments': surahAssignments.map((s) => s.toJson()).toList(),
      'students': students.map((s) => s.toJson()).toList(),
      // Eliminamos 'student_ids' ya que no existe en la base de datos
      // Esto debe manejarse en una tabla de relación separada
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // للإنشاء الأولي قبل الحفظ في قاعدة البيانات
  factory MemorizationCircleModel.create({
    required String name,
    String? description,
    String? teacherId,
    String? teacherName,
    String? teacherImageUrl,
    required bool isExam,
    required DateTime startDate,
    DateTime? endDate,
    List<SurahAssignment>? surahs,
    List<String>? studentIds,
  }) {
    final now = DateTime.now();
    return MemorizationCircleModel(
      id: const Uuid().v4(),
      name: name,
      description: description,
      teacherId: teacherId,
      teacherName: teacherName,
      teacherImageUrl: teacherImageUrl,
      isExam: isExam,
      startDate: startDate,
      endDate: endDate,
      status: 'active',
      surahAssignments: surahs ?? [],
      students: [],
      studentIds: studentIds ?? [],
      createdAt: now,
      updatedAt: now,
    );
  }

  MemorizationCircleModel copyWith({
    String? id,
    String? name,
    String? description,
    String? teacherId,
    String? teacherName,
    String? teacherImageUrl,
    bool? isExam,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    List<SurahAssignment>? surahAssignments,
    List<CircleStudent>? students,
    List<String>? studentIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MemorizationCircleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      teacherImageUrl: teacherImageUrl ?? this.teacherImageUrl,
      isExam: isExam ?? this.isExam,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      surahAssignments: surahAssignments ?? this.surahAssignments,
      students: students ?? this.students,
      studentIds: studentIds ?? this.studentIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Ahora usamos la clase SurahAssignment desde surah_assignment.dart

class CircleStudent {
  final String id;
  final String name;
  final String? profileImageUrl;
  final List<AttendanceRecord> attendance;
  final List<EvaluationRecord> evaluations;

  CircleStudent({
    required this.id,
    required this.name,
    this.profileImageUrl,
    required this.attendance,
    required this.evaluations,
  });

  factory CircleStudent.fromJson(Map<String, dynamic> json) {
    // تحويل سجلات الحضور
    List<AttendanceRecord> attendance = [];
    if (json['attendance'] != null) {
      final List<dynamic> attendanceList = json['attendance'];
      attendance = attendanceList
          .map((record) => AttendanceRecord.fromJson(record))
          .toList();
    }

    // تحويل سجلات التقييم
    List<EvaluationRecord> evaluations = [];
    if (json['evaluations'] != null) {
      final List<dynamic> evaluationList = json['evaluations'];
      evaluations = evaluationList
          .map((record) => EvaluationRecord.fromJson(record))
          .toList();
    }

    return CircleStudent(
      id: json['id'],
      name: json['name'],
      profileImageUrl: json['profile_image_url'],
      attendance: attendance,
      evaluations: evaluations,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'profile_image_url': profileImageUrl,
      'attendance': attendance.map((a) => a.toJson()).toList(),
      'evaluations': evaluations.map((e) => e.toJson()).toList(),
    };
  }

  CircleStudent copyWith({
    String? id,
    String? name,
    String? profileImageUrl,
    List<AttendanceRecord>? attendance,
    List<EvaluationRecord>? evaluations,
  }) {
    return CircleStudent(
      id: id ?? this.id,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      attendance: attendance ?? this.attendance,
      evaluations: evaluations ?? this.evaluations,
    );
  }
}

class AttendanceRecord {
  final DateTime date;
  final bool isPresent;
  final String? notes;

  AttendanceRecord({
    required this.date,
    required this.isPresent,
    this.notes,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      date: DateTime.parse(json['date']),
      isPresent: json['is_present'] ?? false,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'is_present': isPresent,
      'notes': notes,
    };
  }
}

class EvaluationRecord {
  final DateTime date;
  final String surahId;
  final int score; // 0-5
  final String? notes;

  EvaluationRecord({
    required this.date,
    required this.surahId,
    required this.score,
    this.notes,
  });

  factory EvaluationRecord.fromJson(Map<String, dynamic> json) {
    return EvaluationRecord(
      date: DateTime.parse(json['date']),
      surahId: json['surah_id'],
      score: json['score'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'surah_id': surahId,
      'score': score,
      'notes': notes,
    };
  }
}
