import 'package:uuid/uuid.dart';

class TeacherModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? profileImageUrl;
  final String? specialization;
  final DateTime createdAt;
  final DateTime updatedAt;

  TeacherModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.profileImageUrl,
    this.specialization,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      profileImageUrl: json['profile_image_url'],
      specialization: json['specialization'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'profile_image_url': profileImageUrl,
      'specialization': specialization,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // للإنشاء الأولي قبل الحفظ في قاعدة البيانات
  factory TeacherModel.create({
    required String name,
    required String email,
    String? phone,
    String? profileImageUrl,
    String? specialization,
  }) {
    final now = DateTime.now();
    return TeacherModel(
      id: const Uuid().v4(),
      name: name,
      email: email,
      phone: phone,
      profileImageUrl: profileImageUrl,
      specialization: specialization,
      createdAt: now,
      updatedAt: now,
    );
  }

  TeacherModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? profileImageUrl,
    String? specialization,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TeacherModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      specialization: specialization ?? this.specialization,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
