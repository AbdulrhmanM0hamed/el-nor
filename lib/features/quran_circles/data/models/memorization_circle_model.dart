// La importación de material.dart es necesaria para los tipos de datos como Color
import 'package:equatable/equatable.dart';
import '../models/student_record.dart';
import '../models/surah_assignment.dart';

/// Modelo para representar un estudiante en un círculo de memorización
class MemorizationStudent {
  final String id;
  final String name;
  final String? profileImageUrl;
  final int evaluation;
  final bool isPresent;

  const MemorizationStudent({
    required this.id,
    required this.name,
    this.profileImageUrl,
    this.evaluation = 0,
    this.isPresent = true,
  });

  // Crear una copia del estudiante con valores actualizados
  MemorizationStudent copyWith({
    String? id,
    String? name,
    String? profileImageUrl,
    int? evaluation,
    bool? isPresent,
  }) {
    return MemorizationStudent(
      id: id ?? this.id,
      name: name ?? this.name,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      evaluation: evaluation ?? this.evaluation,
      isPresent: isPresent ?? this.isPresent,
    );
  }
}

/// Modelo para representar un círculo de memorización del Quran
class MemorizationCircle extends Equatable {
  final String id;
  final String name;
  final String description;
  final String teacherId;
  final String teacherName;
  final bool isExam;
  final DateTime startDate;
  final DateTime? endDate;
  final String status;
  final List<SurahAssignment> assignments;
  final List<StudentRecord> students;
  final List<String> studentIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MemorizationCircle({
    required this.id,
    required this.name,
    this.description = '',
    required this.teacherId,
    required this.teacherName,
    this.isExam = false,
    required this.startDate,
    this.endDate,
    this.status = 'active',
    this.assignments = const [],
    this.students = const [],
    this.studentIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  factory MemorizationCircle.fromJson(Map<String, dynamic> json) {
    return MemorizationCircle(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      teacherId: json['teacher_id'] as String? ?? '',
      teacherName: json['teacher_name'] as String? ?? '',
      isExam: json['is_exam'] as bool? ?? false,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null 
        ? DateTime.parse(json['end_date'] as String)
        : null,
      status: json['status'] as String? ?? 'active',
      assignments: (json['surah_assignments'] as List?)
          ?.map((e) => SurahAssignment.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      students: (json['students'] as List?)
          ?.map((e) => StudentRecord.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      studentIds: (json['student_ids'] as List?)
          ?.map((e) => e.toString())
          .toList() ?? [],
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'teacher_id': teacherId,
      'is_exam': isExam,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status': status,
      'surah_assignments': assignments.map((x) => x.toJson()).toList(),
      'students': students.map((x) => x.toJson()).toList(),
      'student_ids': studentIds,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id, 
    name, 
    description,
    teacherId,
    teacherName,
    isExam,
    startDate,
    endDate,
    status,
    assignments,
    students,
    studentIds,
    createdAt,
    updatedAt,
  ];

  MemorizationCircle copyWith({
    String? id,
    String? name,
    String? description,
    String? teacherId,
    String? teacherName,
    bool? isExam,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    List<SurahAssignment>? assignments,
    List<StudentRecord>? students,
    List<String>? studentIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MemorizationCircle(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      teacherId: teacherId ?? this.teacherId,
      teacherName: teacherName ?? this.teacherName,
      isExam: isExam ?? this.isExam,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      assignments: assignments ?? this.assignments,
      students: students ?? this.students,
      studentIds: studentIds ?? this.studentIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Método para generar datos de ejemplo
  // static List<MemorizationCircle> getSampleCircles() {
  //   print('MemorizationCircle: إنشاء بيانات تجريبية للحلقات');
  //   final circles = [
  //     MemorizationCircle(
  //       id: '1',
  //       name: 'حلقة حفظ جزء عم',
  //       teacherName: 'محمد أحمد',
  //       teacherId: '79550bdb-f10c-4089-a0b3-ee9a2969e0e9', // استخدام معرف المستخدم الحقيقي
  //       description: 'حلقة لحفظ سور جزء عم للمبتدئين',
  //       startDate: DateTime.now().add(const Duration(days: 2)),
  //       endDate: DateTime.now().add(const Duration(days: 30)),
  //       isExam: false,
  //       assignments: [
  //         SurahAssignment(
  //           id: '1',
  //           surahName: 'الناس',
  //           startVerse: 1,
  //           endVerse: 6,
  //         ),
  //         SurahAssignment(
  //           id: '2',
  //           surahName: 'الفلق',
  //           startVerse: 1,
  //           endVerse: 5,
  //         ),
  //       ],
  //       students: [
  //         StudentRecord(
  //           createdAt: DateTime.now(),
  //           studentId: '79550bdb-f10c-4089-a0b3-ee9a2969e0e9',
  //           name: 'محمد أحمد',
  //           profileImageUrl: 'assets/images/student1.jpg',
  //           evaluations: [
  //             EvaluationRecord(
  //               date: DateTime.now(),
  //               rating: 4,
  //             ),
  //           ],
  //           attendance: [
  //             AttendanceRecord(
  //               date: DateTime.now(),
  //               isPresent: true,
  //             ),
  //           ],
  //         ),
  //       ],
  //       studentIds: ['79550bdb-f10c-4089-a0b3-ee9a2969e0e9'],
  //       createdAt: DateTime.now(),
  //       updatedAt: DateTime.now(),
  //     ),
  //     MemorizationCircle(
  //       id: '2',
  //       name: 'امتحان حفظ سورة البقرة',
  //       teacherName: 'أحمد إبراهيم',
  //       teacherId: 'teacher2',
  //       description: 'امتحان حفظ للجزء الأول من سورة البقرة',
  //       startDate: DateTime.now().add(const Duration(days: 5)),
  //       endDate: DateTime.now().add(const Duration(days: 35)),
  //       isExam: true,
  //       assignments: [
  //         SurahAssignment(
  //           id: '3',
  //           surahName: 'البقرة',
  //           startVerse: 1,
  //           endVerse: 141,
  //         ),
  //       ],
  //       students: [
  //         StudentRecord(
  //           createdAt: DateTime.now(),
  //           studentId: '4',
  //           name: 'أحمد محمد',
  //           profileImageUrl: 'assets/images/student4.jpg',
  //           evaluations: [
  //             EvaluationRecord(
  //               date: DateTime.now(),
  //               rating: 0,
  //             ),
  //           ],
  //           attendance: [
  //             AttendanceRecord(
  //               date: DateTime.now(),
  //               isPresent: true,
  //             ),
  //           ],
  //         ),
  //         StudentRecord(
  //           createdAt: DateTime.now(),
  //           studentId: '5',
  //           name: 'عمر خالد',
  //           profileImageUrl: 'assets/images/student5.jpg',
  //           evaluations: [
  //             EvaluationRecord(
  //               date: DateTime.now(),
  //               rating: 0,
  //             ),
  //           ],
  //           attendance: [
  //             AttendanceRecord(
  //               date: DateTime.now(),
  //               isPresent: true,
  //             ),
  //           ],
  //         ),
  //       ],
  //       studentIds: ['4', '5'],
  //       createdAt: DateTime.now(),
  //       updatedAt: DateTime.now(),
  //     ),
  //     MemorizationCircle(
  //       id: '3',
  //       name: 'حلقة حفظ سورة يس',
  //       teacherName: 'إبراهيم محمود',
  //       teacherId: 'teacher3',
  //       description: 'حلقة لحفظ سورة يس كاملة',
  //       startDate: DateTime.now().add(const Duration(days: 1)),
  //       endDate: DateTime.now().add(const Duration(days: 60)),
  //       isExam: false,
  //       assignments: [
  //         SurahAssignment(
  //           id: '4',
  //           surahName: 'يس',
  //           startVerse: 1,
  //           endVerse: 83,
  //         ),
  //       ],
  //       students: [
  //         StudentRecord(
  //           createdAt: DateTime.now(),
  //           studentId: '6',
  //           name: 'خالد محمود',
  //           profileImageUrl: 'assets/images/student6.jpg',
  //           evaluations: [
  //             EvaluationRecord(
  //               date: DateTime.now(),
  //               rating: 4,
  //             ),
  //           ],
  //           attendance: [
  //             AttendanceRecord(
  //               date: DateTime.now(),
  //               isPresent: true,
  //             ),
  //           ],
  //         ),
  //         StudentRecord(
  //           createdAt: DateTime.now(),
  //           studentId: '7',
  //           name: 'عبد الله أحمد',
  //           profileImageUrl: 'assets/images/student7.jpg',
  //           evaluations: [
  //             EvaluationRecord(
  //               date: DateTime.now(),
  //               rating: 3,
  //             ),
  //           ],
  //           attendance: [
  //             AttendanceRecord(
  //               date: DateTime.now(),
  //               isPresent: true,
  //             ),
  //           ],
  //         ),
  //       ],
  //       studentIds: ['6', '7'],
  //       createdAt: DateTime.now(),
  //       updatedAt: DateTime.now(),
  //     ),
  //   ];
  //   print('MemorizationCircle: تم إنشاء ${circles.length} حلقة تجريبية');
  //   return circles;
  // }
}
