import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/auth_service.dart';
import '../../models/user_model.dart'; // Import Zaroori hai

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckStatus>(_onCheckStatus);
    on<AuthLoginRequested>(_onLogin);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthLogoutRequested>(_onLogout);
    on<AuthRefreshRequested>(_onRefresh); // ⭐ New Handler
  }

  // App Start / Reload Handler
  Future<void> _onCheckStatus(
    AuthCheckStatus event,
    Emitter<AuthState> emit,
  ) async {
    final session = AuthService.supabase.auth.currentSession;
    if (session != null) {
      try {
        // Centralized method use kar rahe hain
        final user = await AuthService.getCurrentProfile();
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(AuthError("Profile not found"));
        }
      } catch (e) {
        emit(AuthError("Failed to fetch user profile: $e"));
      }
    } else {
      emit(AuthUnauthenticated());
    }
  }

  // ⭐ New Handler: Jab Profile Edit ho jaye to UI update karo
  Future<void> _onRefresh(
    AuthRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // 1. Chota sa delay dein taake Database update complete ho jaye
      await Future.delayed(const Duration(milliseconds: 500));

      // 2. Ab naya data maangein
      final user = await AuthService.getCurrentProfile();

      if (user != null) {
        print("DEBUG: AuthBloc Refreshed! New Image: ${user.imageUrl}");
        // 3. UI Update karein
        emit(AuthAuthenticated(user: user));
      }
    } catch (e) {
      print("Refresh failed: $e");
    }
  }

  Future<void> _onLogin(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await AuthService.signIn(event.email, event.password);
      emit(AuthAuthenticated(user: user));
    } on AuthFailure catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError("An unexpected error occurred: $e"));
    }
  }

  Future<void> _onSignUp(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
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

      // Signup ke baad auto-login (profile fetch)
      final user = await AuthService.getCurrentProfile();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthError("Signup successful but failed to load profile."));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogout(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await AuthService.signOut();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}
