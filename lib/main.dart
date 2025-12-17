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
        scaffoldBackgroundColor: const Color(0xFFF8F8F8), // Very Light Grey for differentiation
        primaryColor: const Color(0xFFFFC107), // Golden Yellow
        primaryColorDark: const Color(0xFFFFB300),
        
        // Color Scheme
        colorScheme: ColorScheme.fromSwatch(
          primarySwatch: Colors.amber, 
          backgroundColor: const Color(0xFFF8F8F8),
        ).copyWith(
          primary: const Color(0xFFFFC107), // Golden Yellow
          secondary: const Color(0xFFE53935), // Food Red
          surface: Colors.white,
          error: const Color(0xFFE53935),
          onPrimary: Colors.black, // Text on Yellow
          onSecondary: Colors.white, // Text on Red
        ),

        // Typography
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Colors.black87),
          bodyMedium: TextStyle(color: Colors.black87),
        ),

        // AppBar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: Colors.black87),
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),

        // Input Decoration
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Colors.black12),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Colors.black12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: Color(0xFFFFC107), width: 2),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          labelStyle: TextStyle(color: Colors.black54),
        ),

        // Elevated Button (Pill Shape)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFC107),
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
            foregroundColor: const Color(0xFFE53935), // Food Red for actions
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routerConfig: createRouter(context.read<AuthBloc>()),
    );
  }
}


