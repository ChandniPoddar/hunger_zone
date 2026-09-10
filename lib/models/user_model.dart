class UserModel {
  final String id;
  final String name;
  final String email;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  // Compatibility getter
  String get phoneNumber => email;

  // Factory to create a User from MongoDB JSON response
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? json['phoneNumber'] ?? '',
      role: json['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': email,
      'role': role,
    };
  }
}
