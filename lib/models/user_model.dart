class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String regNumber;
  final String role;
  final String? imageUrl; // 🆕 Added this field

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.regNumber,
    required this.role,
    this.imageUrl, // 🆕 Added to constructor
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      fullName: json['full_name'] as String,
      email: json['email'] as String,
      phoneNumber: json['phone_number'] as String,
      // Database typo handling preserved
      regNumber: (json['registeration_number'] ?? json['registration_number'] ?? '') as String,
      role: json['role'] as String,
      imageUrl: json['image_url'] as String?, // 🆕 Map from DB
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'registeration_number': regNumber,
      'role': role,
      'image_url': imageUrl, // 🆕 Send to DB
    };
  }
}