import 'package:flutter/material.dart';
import '../pages/login_page.dart';
import '../pages/signup_page.dart';
import '../pages/auth_gate.dart';
import '../pages/home_page.dart';

final Map<String,WidgetBuilder> appRoutes = {
  '/': (context) => const AuthGate(),
  '/login':(context) => const LoginPage(),
  '/signup':(context)=> const SignupPage(),
  '/home':(context) => const HomePage(),
};