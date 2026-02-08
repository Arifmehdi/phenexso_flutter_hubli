import 'package:hubli/models/user_role.dart';

class User {
  final int id;
  final String name;
  final String email;
  final UserRole role;
  final bool is_admin;

  User({required this.id, required this.name, required this.email, required this.role, required this.is_admin});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => UserRole.seller, // Default to seller if role not found or null
      ),
      is_admin: json['is_admin'] ?? false, // Default to false if not provided
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString().split('.').last, // Convert enum to string
      'is_admin': is_admin,
    };
  }
}
