import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:async';

// Auth & Pages
import '../bloc/auth/auth_bloc.dart';
import '../pages/login_page.dart';
import '../pages/signup_page.dart';
import '../pages/auth_gate.dart';

// Screens
import '../screens/home_screen.dart';
import '../screens/profile_management_screen.dart';
import '../screens/my_profile_edit_screen.dart';
import '../screens/manage_all_profiles_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/change_password_screen.dart';

// Menu Screens (Make sure file names match EXACTLY)
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
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuthenticated = authState is AuthAuthenticated;
      final isLoggingIn = state.uri.toString() == '/login';
      final isSigningUp = state.uri.toString() == '/signup';
      final isRoot = state.uri.toString() == '/';

      if (!isAuthenticated) {
        if (!isLoggingIn && !isSigningUp && !isRoot) return '/login';
      }
      if (isAuthenticated) {
        if (isLoggingIn || isSigningUp || isRoot) return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const AuthGate()),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
      GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),

      GoRoute(path: '/profile_management', builder: (context, state) => const ProfileManagementScreen()),
      GoRoute(path: '/my-profile-edit', builder: (context, state) => const MyProfileEditScreen()),
      GoRoute(path: '/manage-profiles', builder: (context, state) => const ManageAllProfilesScreen()),

      // Menus
      GoRoute(
        path: '/menu_list', 
        builder: (context, state) => const MenuListScreen() // Ab ye Error nahi dega
      ),
      GoRoute(path: '/add_menu', builder: (context, state) => const AddMenuScreen()),

      GoRoute(
        path: '/menu_items',
        builder: (context, state) {
          final args = state.extra as Map<String, dynamic>;
          return MenuItemListScreen(
            menuId: args['menuId'], 
            menuName: args['menuName']
          );
        },
      ),

      GoRoute(
        path: '/product_detail',
        builder: (context, state) {
          final item = state.extra as MenuItemModel;
          return ProductDetailScreen(item: item);
        },
      ),

      // Orders
      GoRoute(path: '/orders', builder: (context, state) => const OrderListScreen()),
      GoRoute(path: '/create_order', builder: (context, state) => const CreateOrderScreen()),

      // Settings
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
      GoRoute(path: '/change_password', builder: (context, state) => const ChangePasswordScreen()),
    ],
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