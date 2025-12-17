import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

// Auth & Pages
import '../bloc/auth/auth_bloc.dart';
import '../pages/login_page.dart';
import '../pages/signup_page.dart';
import '../pages/auth_gate.dart';
import '../pages/splash_page.dart'; // 🆕 Import Splash

// Screens
import '../screens/home_screen.dart';
import '../screens/profile_management_screen.dart';
import '../screens/my_profile_edit_screen.dart';
import '../screens/manage_all_profiles_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/change_password_screen.dart';

// Menu Screens
import '../screens/menu_screens/menu_list_screen.dart'; 
import '../screens/menu_screens/add_menu_screen.dart';
import '../screens/menu_screens/menu_item_list_screen.dart'; 
import '../screens/menu_screens/product_detail_screen.dart';

// Models
import '../models/menu_item_model.dart'; 

// Order Screens
import '../screens/order_screens/order_list_screen.dart';
import '../screens/order_screens/create_order_screen.dart';

GoRouter createRouter(AuthBloc authBloc) {
  return GoRouter(
    initialLocation: '/splash', // 🆕 Start at Splash
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuthenticated = authState is AuthAuthenticated;
      
      final isSplash = state.uri.toString() == '/splash';
      final isLoggingIn = state.uri.toString() == '/login';
      final isSigningUp = state.uri.toString() == '/signup';
      final isRoot = state.uri.toString() == '/';

      // 1. Allow Splash to play out (Splash handles navigation to '/' after delay)
      if (isSplash) return null;

      // 2. Auth Logic
      if (!isAuthenticated) {
        if (!isLoggingIn && !isSigningUp && !isRoot) return '/login';
      }
      if (isAuthenticated) {
        if (isLoggingIn || isSigningUp || isRoot) return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => _fadeTransition(context, state, const SplashPage()),
      ),
      GoRoute(
        path: '/', 
        pageBuilder: (context, state) => _fadeTransition(context, state, const AuthGate())
      ),
      GoRoute(
        path: '/login', 
        pageBuilder: (context, state) => _fadeTransition(context, state, const LoginPage())
      ),
      GoRoute(
        path: '/signup', 
        pageBuilder: (context, state) => _fadeTransition(context, state, const SignupPage())
      ),
      GoRoute(
        path: '/home', 
        pageBuilder: (context, state) => _fadeTransition(context, state, const HomeScreen())
      ),

      GoRoute(
        path: '/profile_management', 
        pageBuilder: (context, state) => _fadeTransition(context, state, const ProfileManagementScreen())
      ),
      GoRoute(
        path: '/my-profile-edit', 
        pageBuilder: (context, state) => _fadeTransition(context, state, const MyProfileEditScreen())
      ),
      GoRoute(
        path: '/manage-profiles', 
        pageBuilder: (context, state) => _fadeTransition(context, state, const ManageAllProfilesScreen())
      ),

      // Menus
      GoRoute(
        path: '/menu_list', 
        pageBuilder: (context, state) => _fadeTransition(context, state, const MenuListScreen())
      ),
      GoRoute(
        path: '/add_menu', 
        pageBuilder: (context, state) => _fadeTransition(context, state, const AddMenuScreen())
      ),

      GoRoute(
        path: '/menu_items',
        pageBuilder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return _fadeTransition(
            context, 
            state, 
            MenuItemListScreen(menuId: args['menuId'], menuName: args['menuName'])
          );
        },
      ),

      GoRoute(
        path: '/product_detail',
        pageBuilder: (context, state) {
          final item = state.extra as MenuItemModel;
          return _fadeTransition(context, state, ProductDetailScreen(item: item));
        },
      ),

      // Orders
      GoRoute(
        path: '/orders', 
        pageBuilder: (context, state) => _fadeTransition(context, state, const OrderListScreen())
      ),
      GoRoute(
        path: '/create_order', 
        pageBuilder: (context, state) => _fadeTransition(context, state, const CreateOrderScreen())
      ),

      // Settings
      GoRoute(
        path: '/settings', 
        pageBuilder: (context, state) => _fadeTransition(context, state, const SettingsScreen())
      ),
      GoRoute(
        path: '/change_password', 
        pageBuilder: (context, state) => _fadeTransition(context, state, const ChangePasswordScreen())
      ),
    ],
  );
}

// Helper: Fade Transition
CustomTransitionPage _fadeTransition(BuildContext context, GoRouterState state, Widget child) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 400),
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((dynamic _) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _subscription;
  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}