import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth/auth_bloc.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  // Global Key for Form Validation
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _adminCodeController = TextEditingController();

  String _selectedRole = 'student'; 
  final List<String> _roles = ['student', 'manager'];

  // Secret Key
  static const String _managerSecretCode = "BREW2025";

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _regNumberController.dispose();
    _adminCodeController.dispose();
    super.dispose();
  }

  void _signUp() {
    // 1. Run Validations (Red text dikhayega agar ghalat hua)
    if (!_formKey.currentState!.validate()) {
      return; 
    }

    // 2. Manager Security Check
    if (_selectedRole == 'manager') {
      if (_adminCodeController.text.trim() != _managerSecretCode) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid Admin Code! You cannot sign up as Manager.'),
            backgroundColor: Colors.red,
          ),
        );
        return; 
      }
    }

    // 3. Logic: Manager ke liye Reg Number empty
    final finalRegNumber = _selectedRole == 'student' 
        ? _regNumberController.text.trim() 
        : ''; 

    // 4. Send Data
    context.read<AuthBloc>().add(AuthSignUpRequested(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      regNumber: finalRegNumber,
      role: _selectedRole,
      password: _passwordController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Signup successful!'), backgroundColor: Colors.green),
            );
            context.go('/home'); 
          }
          if (state is AuthError) {
             ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: Colors.redAccent),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form( // ✅ Form Widget Zaroori hai validation ke liye
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     const Text(
                      'Create Your Account',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue),
                    ),
                    const SizedBox(height: 32),
                    
                    // --- Full Name ---
                    TextFormField(
                      controller: _fullNameController,
                      decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
                      validator: (value) => (value == null || value.isEmpty) ? 'Full Name is required' : null,
                    ),
                    const SizedBox(height: 16),

                    // --- Email (Validation Added) ---
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        }
                        // Regex for Email Validation
                        final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                        if (!emailRegex.hasMatch(value)) {
                          return 'Please enter a valid email (e.g. user@gmail.com)';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // --- Phone ---
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(labelText: 'Phone Number', prefixIcon: Icon(Icons.phone)),
                      keyboardType: TextInputType.phone,
                      validator: (value) => (value == null || value.length < 10) ? 'Enter valid phone number' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    // --- Role Dropdown ---
                    DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Icons.verified_user)),
                      items: _roles.map((String role) {
                        return DropdownMenuItem<String>(
                          value: role,
                          child: Text(role[0].toUpperCase() + role.substring(1)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedRole = newValue;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // --- Conditional Fields ---
                    if (_selectedRole == 'student')
                      TextFormField(
                        controller: _regNumberController,
                        decoration: const InputDecoration(labelText: 'Registration Number', prefixIcon: Icon(Icons.badge)),
                        validator: (value) => (value == null || value.isEmpty) ? 'Registration Number required' : null,
                      ),

                    if (_selectedRole == 'manager')
                      TextFormField(
                        controller: _adminCodeController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Admin Secret Code',
                          prefixIcon: Icon(Icons.security),
                          helperText: "Hint: BREW2025",
                          helperStyle: TextStyle(color: Colors.orange)
                        ),
                        validator: (value) => (value == null || value.isEmpty) ? 'Admin Code required' : null,
                      ),

                    const SizedBox(height: 16),

                    // --- Password ---
                    TextFormField(
                      controller: _passwordController,
                      decoration: const InputDecoration(labelText: 'Password', prefixIcon: Icon(Icons.lock)),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Password is required';
                        if (value.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    
                    // --- Button ---
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _signUp,
                        child: const Text('Sign Up', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => context.pop(), 
                      child: const Text('Already have an account? Log In'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}