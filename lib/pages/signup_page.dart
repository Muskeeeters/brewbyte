import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth/auth_bloc.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _regNumberController = TextEditingController();
  final _adminCodeController = TextEditingController();

  String _selectedRole = 'student';
  final List<String> _roles = ['student', 'manager'];
  static const String _managerSecretCode = "BREW2025";
  bool _isPasswordVisible = false;

  // Animation
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutBack,
    ));

    _animController.forward();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _regNumberController.dispose();
    _adminCodeController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _signUp() {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedRole == 'manager') {
      if (_adminCodeController.text.trim() != _managerSecretCode) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid Admin Code!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    final finalRegNumber = _selectedRole == 'student'
        ? _regNumberController.text.trim()
        : '';

    context.read<AuthBloc>().add(
      AuthSignUpRequested(
        fullName: _fullNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        regNumber: finalRegNumber,
        role: _selectedRole,
        password: _passwordController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(''),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFC107)),
          onPressed: () => context.canPop() ? context.pop() : null,
        ),
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Signup successful!'),
                backgroundColor: Colors.green,
              ),
            );
            context.go('/home');
          }
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFFC107)));
          }

          return Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
               color: Color(0xFF121212),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: SlideTransition(
              position: _slideAnimation,
              child: Center(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60), // Top Spacing
                        const Icon(Icons.person_add, size: 48, color: Color(0xFFFFC107)),
                         const SizedBox(height: 16),
                        const Text(
                          'Join BrewByte',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFFC107),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create your diverse food profile',
                          style: TextStyle(color: Colors.white54),
                        ),
                        const SizedBox(height: 32),

                        // Form Card
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1E1E),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.white10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _fullNameController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: 'Full Name',
                                  prefixIcon: Icon(Icons.person_outline, color: Color(0xFFFFC107)),
                                ),
                                validator: (value) => (value == null || value.isEmpty)
                                    ? 'Full Name is required'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _emailController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: Icon(Icons.email_outlined, color: Color(0xFFFFC107)),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Email is required';
                                  final emailRegex = RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  );
                                  if (!emailRegex.hasMatch(value))
                                    return 'Enter valid email';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _phoneController,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  labelText: 'Phone Number',
                                  prefixIcon: Icon(Icons.phone_outlined, color: Color(0xFFFFC107)),
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (value) => (value == null || value.length < 10)
                                    ? 'Enter valid phone number'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              
                              DropdownButtonFormField<String>(
                                value: _selectedRole,
                                dropdownColor: const Color(0xFF2C2C2C), // Dark Dropdown
                                decoration: const InputDecoration(
                                  labelText: 'Role',
                                  prefixIcon: Icon(Icons.verified_user_outlined, color: Color(0xFFFFC107)),
                                ),
                                style: const TextStyle(color: Colors.white),
                                items: _roles.map((String role) {
                                  return DropdownMenuItem<String>(
                                    value: role,
                                    child: Text(
                                      role[0].toUpperCase() + role.substring(1),
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null)
                                    setState(() => _selectedRole = newValue);
                                },
                              ),
                              const SizedBox(height: 16),

                              if (_selectedRole == 'student')
                                TextFormField(
                                  controller: _regNumberController,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    labelText: 'Registration Number',
                                    prefixIcon: Icon(Icons.badge_outlined, color: Color(0xFFFFC107)),
                                  ),
                                  validator: (value) => (value == null || value.isEmpty)
                                      ? 'Required'
                                      : null,
                                ),

                              if (_selectedRole == 'manager')
                                TextFormField(
                                  controller: _adminCodeController,
                                  obscureText: true,
                                  style: const TextStyle(color: Colors.white),
                                  decoration: const InputDecoration(
                                    labelText: 'Admin Secret Code',
                                    prefixIcon: Icon(Icons.security_outlined, color: Color(0xFFFFC107)),
                                    helperText: "Hint: BREW2025",
                                    helperStyle: TextStyle(color: Colors.orange),
                                  ),
                                  validator: (value) => (value == null || value.isEmpty)
                                      ? 'Required'
                                      : null,
                                ),

                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _passwordController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  labelText: 'Password',
                                  prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFFFC107)),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Colors.white54,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible = !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                                obscureText: !_isPasswordVisible,
                                validator: (value) {
                                  if (value == null || value.isEmpty)
                                    return 'Password is required';
                                  if (value.length < 6)
                                    return 'Password must be at least 6 characters';
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 32),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _signUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFE53935), // Red Action
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('CREATE ACCOUNT'),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: () => context.pop(),
                          child: RichText(
                            text: const TextSpan(
                              text: 'Already have an account? ',
                              style: TextStyle(color: Colors.white54),
                              children: [
                                TextSpan(
                                  text: 'Log In',
                                  style: TextStyle(
                                    color: Color(0xFFFFC107),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
