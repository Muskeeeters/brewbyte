import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/user_model.dart';
import '../bloc/auth/auth_bloc.dart';
import '../services/user_service.dart';

class MyProfileEditScreen extends StatefulWidget {
  const MyProfileEditScreen({super.key});

  @override
  State<MyProfileEditScreen> createState() => _MyProfileEditScreenState();
}

class _MyProfileEditScreenState extends State<MyProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _regNumController;
  late TextEditingController _roleController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;
    
    _nameController = TextEditingController(text: user.fullName);
    _phoneController = TextEditingController(text: user.phoneNumber);
    // Read-only fields
    _emailController = TextEditingController(text: user.email);
    _regNumController = TextEditingController(text: user.regNumber);
    _roleController = TextEditingController(text: user.role);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _regNumController.dispose();
    _roleController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;

      await UserService.updateSelfProfile(
        userId: user.id,
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      // Refresh Auth Bloc to update UI globally (Home Screen greeting etc)
      // Ideally we would emit an event to re-fetch profile, or manually update it.
      // For now, let's show success message. The Home Screen might need a refresh logic 
      // or we can manually update the bloc state if AuthBloc supports it.
      // Assuming AuthBloc might need a "ProfileUpdated" event in future, 
      // but for this task scope, let's just save to DB. 
      // To reflect changes immediately, we can re-trigger a fetch if we had a LoadUser event.
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.pop(context); // Go back after save
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildReadOnlyField("Email", _emailController),
              const SizedBox(height: 16),
              _buildReadOnlyField("Role", _roleController),
              const SizedBox(height: 16),
              _buildReadOnlyField("Registration Number", _regNumController),
              const SizedBox(height: 32),
              
              const Text(
                "Editable Information",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) => 
                  value == null || value.isEmpty ? 'Please enter your name' : null,
              ),
              const SizedBox(height: 16),
              
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) => 
                  value == null || value.isEmpty ? 'Please enter your phone number' : null,
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.black,
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator()
                    : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.grey.shade200,
      ),
    );
  }
}
