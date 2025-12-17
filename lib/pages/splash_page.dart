import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Navigate to AuthGate after 4 seconds
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        context.go('/'); 
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Deep Black
      body: Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 2000),
          curve: Curves.easeOutExpo,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.scale(
                scale: 0.5 + (0.5 * value), // Scale from 0.5 to 1.0
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Logo Icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFFFC107), width: 3), // Golden Yellow Border
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFC107).withOpacity(0.3),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_cafe_rounded,
                  size: 80,
                  color: Color(0xFFFFC107), // Golden Yellow
                ),
              ),
              const SizedBox(height: 24),
              // Brand Text
              const Text(
                "BREWBYTE",
                style: TextStyle(
                  color: Color(0xFFFFC107),
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4.0,
                ),
              ),
              const SizedBox(height: 10),
              // Tagline
              const Text(
                "Gourmet Experience",
                style: TextStyle(
                  color: Color(0xFFE53935), // Food Red
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
