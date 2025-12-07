import 'package:flutter/material.dart';
import '../pages/login_page.dart';
import '../pages/signup_page.dart';
import '../pages/auth_gate.dart';
import '../pages/home_page.dart';
import '../screens/menu_screens/menu_list_screen.dart';
import '../screens/menu_screens/add_menu_screen.dart';

final Map<String,WidgetBuilder> appRoutes = {
  '/': (context) => const AuthGate(),
  '/login':(context) => const LoginPage(),
  '/signup':(context)=> const SignupPage(),
  '/home':(context) => const HomePage(),

  '/menu_list': (context) => const MenuListScreen(),
  '/add_menu': (context) => const AddMenuScreen(),
};