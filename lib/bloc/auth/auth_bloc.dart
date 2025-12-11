import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // Can be injected, but using static service as per current codebase style
  
  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthLoginRequested>(_onLogin);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthLogoutRequested>(_onLogout);
  }

  Future<void> _onCheckStatus(AuthCheckStatus event, Emitter<AuthState> emit) async {
    final session = AuthService.supabase.auth.currentSession;
    if (session != null) {
      try {
        final data = await AuthService.supabase
            .from('profiles')
            .select()
            .eq('id', session.user.id)
            .single();
        final user = UserModel.fromJson(data);
        emit(AuthAuthenticated(user: user));
      } catch (e) {
        // If profile fetch fails, treating as unauthenticated or error?
        // Let's treat as unauthenticated for safety, or error.
        emit(AuthError("Failed to fetch user profile: $e"));
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLogin(AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final user = await AuthService.signIn(event.email, event.password);
      print("AuthBloc Login Success: ${user.email}");
      emit(AuthAuthenticated(user: user));
    } on AuthFailure catch (e) {
      print("AuthBloc Login Error (AuthFailure): ${e.message}");
      emit(AuthError(e.message));
    } catch (e) {
      print("AuthBloc Login Error (Unknown): $e");
      emit(AuthError("An unexpected error occurred: $e"));
    }
  }

  Future<void> _onSignUp(AuthSignUpRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await AuthService.signUp(
        fullName: event.fullName,
        email: event.email,
        phone: event.phone,
        regNumber: event.regNumber,
        role: event.role,
        password: event.password,
      );
      // Assuming auto-login after signup
      final user = AuthService.supabase.auth.currentUser;
      if (user != null) {
        // Fetch profile to emit authenticated state
        final data = await AuthService.supabase
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();
        emit(AuthAuthenticated(user: UserModel.fromJson(data)));
      } else {
        emit(AuthError("Signup successful. Please verify email if required."));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      await AuthService.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
