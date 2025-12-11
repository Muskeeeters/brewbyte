

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';
import '../bloc/auth/auth_bloc.dart';
import '../pages/login_page.dart';
import '../pages/signup_page.dart';
import '../pages/auth_gate.dart';

import '../screens/home_screen.dart';
import '../screens/profile_management_screen.dart';

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuthenticated = authState is AuthAuthenticated;
      final isLoggingIn = state.uri.toString() == '/login';
      final isSigningUp = state.uri.toString() == '/signup';
      final isRoot = state.uri.toString() == '/';

      if (!isAuthenticated) {
        // If not authenticated and trying to access protected routes (like home), redirect to login.
        // Allowing root '/' to go to AuthGate is fine, but if we want strictly /login:
        if (!isLoggingIn && !isSigningUp && !isRoot) {
           return '/login';
        }
      }

      if (isAuthenticated) {
        // If authenticated and trying to go to login or signup, redirect to home.
        if (isLoggingIn || isSigningUp || isRoot) {
          return '/home';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthGate(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupPage(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
       GoRoute(
        path: '/profile_management',
        builder: (context, state) => const ProfileManagementScreen(),
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
