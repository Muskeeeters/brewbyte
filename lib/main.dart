import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/auth/auth_bloc.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const supabaseUrl = "https://gymogmvfclamqgexjkja.supabase.co";
  const supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imd5bW9nbXZmY2xhbXFnZXhqa2phIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ2NzY5MTAsImV4cCI6MjA4MDI1MjkxMH0.KtAGt6QrHPu3TeRMgDxdgOXJa3RcNheaFmPLIggY0z0";
  
  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );
  
  runApp(
    BlocProvider(
      create: (context) => AuthBloc()..add(AuthCheckStatus()),
      child: const BrewByte(),
    ),
  );
}

class BrewByte extends StatelessWidget {
  const BrewByte({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Brew Byte',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark, // Dark Mode Base
        scaffoldBackgroundColor: const Color(0xFF121212), // Deep Matte Black
        primaryColor: const Color(0xFFFFC107), // Golden Yellow
        primaryColorDark: const Color(0xFFFFB300),
        
        // Color Scheme
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFC107), // Golden Yellow
          secondary: Color(0xFFE53935), // Food Red
          surface: Color(0xFF1E1E1E), // Dark Card Background
          error: Color(0xFFE53935),
          onPrimary: Colors.black, // Text on Yellow
          onSecondary: Colors.white, // Text on Red
          onSurface: Colors.white,
        ),

        // Typography
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          titleMedium: TextStyle(color: Colors.white),
        ),

        // AppBar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),

        // Input Decoration (Pill Shape + White Text)
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF2C2C2C), // Darker Grey for inputs
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(30)),
            borderSide: BorderSide(color: Color(0xFFFFC107), width: 2),
          ),
          errorBorder: OutlineInputBorder(
             borderRadius: BorderRadius.all(Radius.circular(30)),
             borderSide: BorderSide(color: Color(0xFFE53935)),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 18), // Larger padding for pill
          labelStyle: TextStyle(color: Colors.white70),
          hintStyle: TextStyle(color: Colors.white38),
        ),

        // Elevated Button (Red Pill by default or Yellow based on context? Plan says Red Pill for Auth)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFC107), // Yellow Default
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            elevation: 4,
            shadowColor: const Color(0xFFFFC107).withOpacity(0.4),
          ),
        ),

        // Text Button
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFFFC107), // Yellow for links
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routerConfig: createRouter(context.read<AuthBloc>()),
    );
  }
}


