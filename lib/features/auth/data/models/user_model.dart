import 'package:equatable/equatable.dart';
import '../../../../core/utils/user_role.dart';

class UserModel extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String? profileImageUrl;
  final bool isAdmin;
  final bool isTeacher;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    this.profileImageUrl,
    this.isAdmin = false,
    this.isTeacher = false,
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
      phoneNumber: json['phone'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      isAdmin: json['is_admin'] as bool? ?? false,
      isTeacher: json['is_teacher'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phoneNumber,
      'profile_image_url': profileImageUrl,
      'is_admin': isAdmin,
      'is_teacher': isTeacher,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    bool? isAdmin,
    bool? isTeacher,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      isAdmin: isAdmin ?? this.isAdmin,
      isTeacher: isTeacher ?? this.isTeacher,
    );
  }

  @override
  List<Object?> get props => [id, name, email, phoneNumber, profileImageUrl, isAdmin, isTeacher];
}
