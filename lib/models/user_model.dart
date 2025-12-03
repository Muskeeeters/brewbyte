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

  factory UserModel.fromSupabaseMap(Map<String,dynamic> map){
    return UserModel(id:map['id'],
                     fullName:map['full_name'],
                     email:map['email'],
                     phoneNumber:map['phone_number'],
                     regNumber:map['registerationNumber'],
                     role:map['role']
    );
  }

  Map <String,dynamic> toSupabaseMap() {
    return {
      'full_name':fullName,
      'phone_number':phoneNumber,
      'registeration_number':regNumber,
      'role':role
    };
  }
}