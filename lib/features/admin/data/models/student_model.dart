import 'package:uuid/uuid.dart';

class StudentModel {
  final String id;
  final String name;
  final String email;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? phoneNumber;
  final String? parentName;
  final String? parentPhone;
  final String? profileImageUrl;
  final List<EvaluationModel> evaluations;
  final bool isAdmin;
  final bool isTeacher;

  StudentModel({
    required this.id,
    required this.name,
    required this.email,
    required this.createdAt,
    required this.updatedAt,
    this.phoneNumber,
    this.parentName,
    this.parentPhone,
    this.profileImageUrl,
    this.evaluations = const [],
    required this.isAdmin,
    required this.isTeacher,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    List<EvaluationModel> evaluations = [];
    if (json['evaluations'] != null) {
      evaluations = List<EvaluationModel>.from(
        (json['evaluations'] as List).map(
          (e) => EvaluationModel.fromJson(e),
        ),
      );
    }

    return StudentModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
      phoneNumber: json['phone_number'],
      parentName: json['parent_name'],
      parentPhone: json['parent_phone'],
      profileImageUrl: json['profile_image_url'],
      evaluations: evaluations,
      isAdmin: json['is_admin'] ?? false,
      isTeacher: json['is_teacher'] ?? false,
    );
  }

  factory StudentModel.create({
    required String name,
    required String email,
    String? phoneNumber,
    String? parentName,
    String? parentPhone,
    bool isAdmin = false,
    bool isTeacher = false,
  }) {
    final now = DateTime.now();
    return StudentModel(
      id: const Uuid().v4(),
      name: name,
      email: email,
      createdAt: now,
      updatedAt: now,
      phoneNumber: phoneNumber,
      parentName: parentName,
      parentPhone: parentPhone,
      evaluations: [],
      isAdmin: isAdmin,
      isTeacher: isTeacher,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'phone_number': phoneNumber,
      'parent_name': parentName,
      'parent_phone': parentPhone,
      'profile_image_url': profileImageUrl,
      'evaluations': evaluations.map((e) => e.toJson()).toList(),
      'is_admin': isAdmin,
      'is_teacher': isTeacher,
    };
  }

  StudentModel copyWith({
    String? id,
    String? name,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? phoneNumber,
    String? parentName,
    String? parentPhone,
    String? profileImageUrl,
    List<EvaluationModel>? evaluations,
    bool? isAdmin,
    bool? isTeacher,
  }) {
    return StudentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      evaluations: evaluations ?? this.evaluations,
      isAdmin: isAdmin ?? this.isAdmin,
      isTeacher: isTeacher ?? this.isTeacher,
    );
  }
}

class EvaluationModel {
  final String id;
  final DateTime date;
  final int score;
  final String? notes;

  EvaluationModel({
    required this.id,
    required this.date,
    required this.score,
    this.notes,
  });

  factory EvaluationModel.fromJson(Map<String, dynamic> json) {
    return EvaluationModel(
      id: json['id'] ?? const Uuid().v4(),
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      score: json['score'] ?? 0,
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'score': score,
      'notes': notes,
    };
  }

  EvaluationModel copyWith({
    String? id,
    DateTime? date,
    int? score,
    String? notes,
  }) {
    return EvaluationModel(
      id: id ?? this.id,
      date: date ?? this.date,
      score: score ?? this.score,
      notes: notes ?? this.notes,
    );
  }
}
