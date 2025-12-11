class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String regNumber;
  final String role;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.regNumber,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String,
      // Database has a typo: 'registeration_number'.
      // Prioritizing the DB spelling, but keeping fallback just in case.
      regNumber: (json['registeration_number'] ?? json['registration_number'] ?? '') as String,
      role: json['role'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'registeration_number': regNumber, // Matches DB typo
      'role': role,
    };
  }
}
