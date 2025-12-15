import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth/auth_bloc.dart';
import '../services/auth_service.dart'; // Service import ki

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    context.read<AuthBloc>().add(AuthLoginRequested(
      email: _emailController.text,
      password: _passwordController.text,
    ));
  }

  // ⭐ FORGOT PASSWORD DIALOG LOGIC
  void _showForgotPasswordDialog() {
    final resetEmailController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Reset Password"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Enter your email to receive a reset link."),
            const SizedBox(height: 10),
            TextField(
              controller: resetEmailController,
              decoration: const InputDecoration(labelText: "Email", border: OutlineInputBorder()),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              final email = resetEmailController.text.trim();
              if (email.isEmpty) return;

              Navigator.pop(context); // Close dialog first

              try {
                // Call Service
                await AuthService.sendPasswordResetEmail(email);
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Reset link sent! Check your email.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text("Send Link"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
             ScaffoldMessenger.of(context).showSnackBar(
               const SnackBar(
                 content: Text('Login successful!'),
                 backgroundColor: Colors.green,
                 duration: Duration(seconds: 1),
               ),
             );
             context.go('/home');
          }
          if (state is AuthError) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Login Failed'),
                content: Text(state.message),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   const Text(
                    'Welcome Back',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                  const SizedBox(height: 32),
                  
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    enabled: !isLoading,
                  ),
                  const SizedBox(height: 16),
                  
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: 'Password'),
                    obscureText: true,
                    enabled: !isLoading,
                  ),
                  
                  // ⭐ FORGOT PASSWORD BUTTON
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: isLoading ? null : _showForgotPasswordDialog,
                      child: const Text("Forgot Password?", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: 20),
                  
                  ElevatedButton(
                    onPressed: isLoading ? null : _signIn,
                    child: isLoading 
                      ? const SizedBox(
                          height: 20, 
                          width: 20, 
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black87)
                        )
                      : const Text('Log In'),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: isLoading ? null : () => context.push('/signup'), 
                    child: const Text('Don\'t have an account? Sign Up'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}