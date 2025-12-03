import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/home_page.dart';
import 'pages/auth_gate.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const Supabaseurl = "https://gymogmvfclamqgexjkja.supabase.co";
  const SupabaseAnnonkey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd5bW9nbXZmY2xhbXFnZXhqa2phIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ2NzY5MTAsImV4cCI6MjA4MDI1MjkxMH0.KtAGt6QrHPu3TeRMgDxdgOXJa3RcNheaFmPLIggY0z0";
  
  await Supabase.initialize(
    url : Supabaseurl,
    anonKey: SupabaseAnnonkey,
  );
  runApp(const BrewByte());
}

class BrewByte extends StatelessWidget {
  const BrewByte({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Brew Byte',
      home: const AuthGate(),
      theme: ThemeData(
        primarySwatch: Colors.yellow,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
          contentPadding: EdgeInsets.symmetric(horizontal: 16,vertical: 12),),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            )
          )
        ),
        
        initialRoute: '/',
        routes: {
        '/':(context) => AuthGate(),
        '/login':(context)=>const LoginPage(),
        '/signup':(context) => SignupPage(),
        '/home':(context) =>HomePage(),
    
  });
}}

