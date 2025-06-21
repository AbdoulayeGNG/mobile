enum UserRole { student, teacher, admin }

extension UserRoleDisplay on UserRole {
  String get display {
    switch (this) {
      case UserRole.student:
        return 'Élève';
      case UserRole.teacher:
        return 'Enseignant';
      case UserRole.admin:
        return 'Administrateur';
    }
  }

  String get value {
    return toString().split('.').last;
  }
}

class User {  final String id;
  final String email;
  final String password;
  final String name;
  final String role;
  final String? phoneNumber;
  final String? levelId;

  UserRole get userRole => UserRole.values.firstWhere(
    (e) => e.value == role,
    orElse: () => UserRole.student,
  );
  final String? profileImage;
  final DateTime createdAt;
  final DateTime updatedAt;
  User({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.role,
    this.phoneNumber,
    this.profileImage,
    this.levelId,
    required this.createdAt,
    required this.updatedAt,
  });
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      name: json['name'] as String,
      role: json['role'] as String,
      phoneNumber: json['phone_number'] as String?,
      profileImage: json['profile_image'] as String?,
      levelId: json['level_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'role': role,
      'phone_number': phoneNumber,
      'profile_image': profileImage,
      'level_id': levelId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool isStudent() => role == UserRole.student;
  bool isTeacher() => role == UserRole.teacher;
  bool isAdmin() => role == UserRole.admin;
}
