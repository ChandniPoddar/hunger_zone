class UserModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String role;

  UserModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.role,
  });

  // Factory to create a User from MongoDB JSON response
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'], // MongoDB uses _id
      name: json['name'],
      phoneNumber: json['phoneNumber'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'role': role,
    };
  }
}
