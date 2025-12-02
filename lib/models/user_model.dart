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

  factory UserModel.fromMap(Map<String,dynamic> map){
    return UserModel(id:map['id'],
                     fullName:map['full_name'],
                     email:map['email'],
                     phoneNumber:map['phone'],
                     regNumber:map['regNumber'],
                     role:map['role']
    );
  }

  Map <String,dynamic> toMap() {
    return {
      'id':id,
      'full_name':fullName,
      'email':email,
      'phoneNumber':phoneNumber,
      'regNumber':regNumber,
      'role':role
    };
  }
}