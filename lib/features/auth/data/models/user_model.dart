import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final int? age;
  final String? profileImageUrl;
  final DateTime createdAt;
  final bool isAdmin;
  final bool isTeacher; // حقل جديد لتحديد ما إذا كان المستخدم معلمًا

  const UserModel({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.age,
    this.profileImageUrl,
    required this.createdAt,
    this.isAdmin = false,
    this.isTeacher = false, // القيمة الافتراضية هي طالب (ليس معلمًا)
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      age: json['age'] as int?,
      profileImageUrl: json['profile_image_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      isAdmin: json['is_admin'] as bool? ?? false,
      isTeacher: json['is_teacher'] as bool? ?? false, // قراءة حقل is_teacher من JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'age': age,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt.toIso8601String(),
      'is_admin': isAdmin,
      'is_teacher': isTeacher, // إضافة حقل is_teacher إلى JSON
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? phone,
    int? age,
    String? profileImageUrl,
    DateTime? createdAt,
    bool? isAdmin,
    bool? isTeacher,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      isAdmin: isAdmin ?? this.isAdmin,
      isTeacher: isTeacher ?? this.isTeacher, // تحديث حقل isTeacher في نسخة جديدة
    );
  }

  @override
  List<Object?> get props => [id, email, name, phone, age, profileImageUrl, createdAt, isAdmin, isTeacher];
}
