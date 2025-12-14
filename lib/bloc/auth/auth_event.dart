part of 'auth_bloc.dart';

abstract class AuthEvent {}

class AuthCheckStatus extends AuthEvent {}

// ⭐ NEW EVENT: To refresh user data without logging out
class AuthRefreshRequested extends AuthEvent {} 

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  AuthLoginRequested({required this.email, required this.password});
}

class AuthSignUpRequested extends AuthEvent {
  final String fullName;
  final String email;
  final String phone;
  final String regNumber;
  final String role;
  final String password;

  AuthSignUpRequested({
    required this.fullName,
    required this.email,
    required this.phone,
    required this.regNumber,
    required this.role,
    required this.password,
  });
}

class AuthLogoutRequested extends AuthEvent {}