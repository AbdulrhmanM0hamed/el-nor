import 'package:equatable/equatable.dart';
import '../../../../core/utils/user_role.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final int? age;
  final String? profileImageUrl;
  final bool isAdmin;
  final bool isTeacher;
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.age,
    this.profileImageUrl,
    this.isAdmin = false,
    this.isTeacher = false,
    required this.createdAt,
  });

  // Helpers
  bool get isStudent => !isAdmin && !isTeacher;

  UserRole get role {
    if (isAdmin) return UserRole.admin;
    if (isTeacher) return UserRole.teacher;
    return UserRole.student;
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      age: json['age'] as int?,
      profileImageUrl: json['profile_image_url'] as String?,
      isAdmin: json['is_admin'] as bool? ?? false,
      isTeacher: json['is_teacher'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'age': age,
      'profile_image_url': profileImageUrl,
      'is_admin': isAdmin,
      'is_teacher': isTeacher,
      'created_at': createdAt.toIso8601String(),
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    int? age,
    String? profileImageUrl,
    bool? isAdmin,
    bool? isTeacher,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      age: age ?? this.age,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isAdmin: isAdmin ?? this.isAdmin,
      isTeacher: isTeacher ?? this.isTeacher,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        age,
        profileImageUrl,
        isAdmin,
        isTeacher,
        createdAt,
      ];
}
