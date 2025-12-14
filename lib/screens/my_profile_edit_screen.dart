import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:typed_data'; // Bytes
import 'package:image_picker/image_picker.dart'; // XFile
import '../models/user_model.dart';
import '../bloc/auth/auth_bloc.dart';
import '../services/user_service.dart';
import '../services/upload_service.dart';

class MyProfileEditScreen extends StatefulWidget {
  const MyProfileEditScreen({super.key});

  @override
  State<MyProfileEditScreen> createState() => _MyProfileEditScreenState();
}

class _MyProfileEditScreenState extends State<MyProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _uploadService = UploadService();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _regNumController;
  late TextEditingController _roleController;

  bool _isLoading = false;

  // Image Variables
  XFile? _selectedXFile;
  Uint8List? _selectedImageBytes;
  String? _currentImageUrl;

  @override
  void initState() {
    super.initState();
    final user = (context.read<AuthBloc>().state as AuthAuthenticated).user;

    _nameController = TextEditingController(text: user.fullName);
    _phoneController = TextEditingController(text: user.phoneNumber);
    _emailController = TextEditingController(text: user.email);
    _regNumController = TextEditingController(text: user.regNumber);
    _roleController = TextEditingController(text: user.role);

    setState(() {
      _currentImageUrl = user.imageUrl;
    });
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

  Future<void> _pickImage() async {
    final XFile? picked = await _uploadService.pickImage();
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _selectedXFile = picked;
        _selectedImageBytes = bytes;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final authBloc = context.read<AuthBloc>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final currentUser = (authBloc.state as AuthAuthenticated).user;

    setState(() => _isLoading = true);

    try {
      String? newImageUrl;

      // 1. Agar nayi image select ki hai
      if (_selectedXFile != null) {
        // A. Purani Image Delete karein (Agar hai to)
        if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
          await _uploadService.deleteFile(
            'image', // Correct Bucket Name
            'profiles',
            _currentImageUrl!,
          );
        }

        // B. Nayi Upload karein
        newImageUrl = await _uploadService.uploadImage(
          _selectedXFile!,
          'image', // Correct Bucket Name
          'profiles',
        );

        if (newImageUrl == null) throw Exception("Upload returned null.");
      }

      // 2. Database Update
      await UserService.updateSelfProfile(
        userId: currentUser.id,
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        imageUrl: newImageUrl,
      );

      // 3. Success Steps
      authBloc.add(AuthRefreshRequested()); // <--- YE ZAROORI HAI

      messenger.showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      navigator.pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? getImageProvider() {
      if (_selectedImageBytes != null) {
        return MemoryImage(_selectedImageBytes!); // Preview new
      }
      if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
        return NetworkImage(_currentImageUrl!); // Show old
      }
      return null;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: getImageProvider(),
                      child: getImageProvider() == null
                          ? const Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

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
                validator: (value) => value!.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone),
                ),
                validator: (value) => value!.isEmpty ? 'Enter phone' : null,
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
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
