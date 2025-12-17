import 'package:flutter/material.dart';
import '../../models/menu_model.dart';
import '../../services/menu_service.dart';

class AddMenuScreen extends StatefulWidget {
  const AddMenuScreen({super.key});

  @override
  State<AddMenuScreen> createState() => _AddMenuScreenState();
}

class _AddMenuScreenState extends State<AddMenuScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final MenuService _menuService = MenuService();
  bool _isLoading = false;

  Future<void> _saveMenu() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final newMenu = MenuModel(
        name: _nameController.text,
        description: _descController.text,
      );

      try {
        await _menuService.addMenu(newMenu);
        if (mounted) {
           Navigator.pop(context); 
        }
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Add New Category"),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFFFC107), // Gold
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF121212), // Deep Black
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
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
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                        prefixIcon: Icon(Icons.category_outlined, color: Color(0xFFFFC107)),
                      ),
                      validator: (value) => value!.isEmpty ? 'Please enter name' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Description (Optional)',
                        prefixIcon: Icon(Icons.description_outlined, color: Color(0xFFFFC107)),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveMenu,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107), // Gold
                          foregroundColor: Colors.black,
                        ),
                        child: _isLoading 
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.black),
                            )
                          : const Text("SAVE CATEGORY"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}