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

      if (_selectedXFile != null) {
        if (_currentImageUrl != null && _currentImageUrl!.isNotEmpty) {
          await _uploadService.deleteFile(
            'image', 
            'profiles',
            _currentImageUrl!,
          );
        }

        newImageUrl = await _uploadService.uploadImage(
          _selectedXFile!,
          'image', 
          'profiles',
        );

        if (newImageUrl == null) throw Exception("Upload returned null.");
      }

      await UserService.updateSelfProfile(
        userId: currentUser.id,
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        imageUrl: newImageUrl,
      );

      authBloc.add(AuthRefreshRequested());

      messenger.showSnackBar(
        const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Color(0xFFFFC107),
        ),
      );
      navigator.pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
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
        return NetworkImage("${_currentImageUrl!}?t=${DateTime.now().millisecondsSinceEpoch}"); // Show old
      }
      return null;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile', style: TextStyle(color: Color(0xFFFFC107))),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFFFFC107)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar
              Center(
                child: Stack(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFC107), width: 2),
                      ),
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: const Color(0xFF2C2C2C),
                        backgroundImage: getImageProvider(),
                        child: getImageProvider() == null
                            ? const Icon(
                                Icons.person,
                                size: 60,
                                color: Colors.grey,
                              )
                            : null,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC107),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.black, width: 2),
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
              const SizedBox(height: 40),

              _buildReadOnlyField("Email", _emailController, Icons.email_outlined),
              const SizedBox(height: 16),
              _buildReadOnlyField("Role", _roleController, Icons.verified_user_outlined),
              const SizedBox(height: 16),
              _buildReadOnlyField("Registration Number", _regNumController, Icons.badge_outlined),
              const SizedBox(height: 32),

              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Edit Information",
                  style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold, 
                      color: Color(0xFFFFC107)
                  ),
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  prefixIcon: Icon(Icons.person_outline, color: Color(0xFFFFC107)),
                ),
                validator: (value) => value!.isEmpty ? 'Enter name' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _phoneController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined, color: Color(0xFFFFC107)),
                ),
                validator: (value) => value!.isEmpty ? 'Enter phone' : null,
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                height: 54, // Pill height
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  // Style is inherited from Theme (Yellow Pill)
                  child: _isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(color: Colors.black),
                        )
                      : const Text('SAVE CHANGES'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, TextEditingController controller, IconData icon) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      enabled: false,
      style: const TextStyle(color: Colors.white70),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.white38),
        filled: true,
        fillColor: const Color(0xFF1E1E1E), // Darker BG for read-only
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
