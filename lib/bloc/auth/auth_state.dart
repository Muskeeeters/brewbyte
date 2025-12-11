part of 'auth_bloc.dart';

// Since this is a part file, it shares imports with the parent, 
// but we need to ensure UserModel is available to the parent or accessible here.
// However, 'part of' files cannot have imports if they are not modifying the original library structure carefully. 
// But here, we can rely on `auth_bloc.dart` importing `user_model.dart`.
// Wait, `auth_bloc.dart` currently imports `auth_service.dart` but maybe not `user_model.dart` directly unless through it.
// Let's check `auth_bloc.dart` again.
// Actually, it's safer to ensure `auth_bloc.dart` imports `user_model.dart`.
// For now, I will assume the parent imports it. 
// CHECK: Does `auth_bloc.dart` import `user_model.dart`? 
// The `view_file` of `auth_bloc.dart` showed:
// 1: import 'package:flutter_bloc/flutter_bloc.dart';
// 2: import '../../services/auth_service.dart';
// It does NOT import `user_model.dart` explicitly, but `auth_service.dart` does.
// However, types used in `part` files must be visible.
// I should add the import to `auth_bloc.dart`.


abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final UserModel user;
  
  AuthAuthenticated({required this.user});
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError(this.message);
}
