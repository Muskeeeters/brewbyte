import 'package:flutter/material.dart';
import 'dart:typed_data'; // Bytes handling (Web Safe)
import 'package:image_picker/image_picker.dart'; // XFile
import '../../models/menu_item_model.dart';
import '../../services/menu_service.dart';
import '../../services/upload_service.dart';

class AddMenuItemScreen extends StatefulWidget {
  final String menuId; // Category ID (e.g., Coffee, Bakery)

  const AddMenuItemScreen({super.key, required this.menuId});

  @override
  State<AddMenuItemScreen> createState() => _AddMenuItemScreenState();
}

class _AddMenuItemScreenState extends State<AddMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();

  // Services
  final MenuService _menuService = MenuService();
  final UploadService _uploadService = UploadService();

  bool _isLoading = false;

  // Image Variables (Web Safe)
  XFile? _selectedXFile;
  Uint8List? _selectedImageBytes; // Preview ke liye

  // --- PICK IMAGE ---
  Future<void> _pickImage() async {
    try {
      final XFile? picked = await _uploadService.pickImage();
      if (picked != null) {
        final bytes = await picked.readAsBytes(); // Bytes read karein
        setState(() {
          _selectedXFile = picked;
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint("Image pick error: $e");
    }
  }

  // --- SAVE ITEM ---
  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        String? imageUrl;

        // 1. Upload Image (Agar select ki hai)
        if (_selectedXFile != null) {
          imageUrl = await _uploadService.uploadImage(
              _selectedXFile!,
              'image', // ✅ Bucket Name
              'menu_items' // Folder Name
              );

          if (imageUrl == null) throw Exception("Image upload failed");
        }

        // 2. Save Item to DB
        final newItem = MenuItemModel(
          menuId: widget.menuId,
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          imageUrl: imageUrl, // ✅ URL database mein jayega
        );

        await _menuService.addMenuItem(newItem);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item added successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Wapis List par jao
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // UI Helper: Custom Input Decoration
  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFFFFC107)),
      // Theme handles the rest (Dark fill, white text)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Add New Item"),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFFFC107),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- IMAGE UPLOAD BOX ---
                    Center(
                      child: InkWell(
                        onTap: _pickImage,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          height: 180,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C2C2C),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _selectedImageBytes != null
                                  ? const Color(0xFFFFC107)
                                  : Colors.white24,
                              width: 2,
                            ),
                            image: _selectedImageBytes != null
                                ? DecorationImage(
                                    image: MemoryImage(_selectedImageBytes!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _selectedImageBytes == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Icon(Icons.add_a_photo_outlined,
                                        size: 50, color: Colors.white54),
                                    SizedBox(height: 10),
                                    Text(
                                      "Tap to upload image",
                                      style: TextStyle(
                                        color: Colors.white54,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                )
                              : Stack(
                                  children: [
                                    Positioned(
                                      right: 10,
                                      top: 10,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle
                                        ),
                                        child: const Icon(Icons.edit,
                                            size: 18, color: Color(0xFFFFC107)),
                                      ),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // --- FORM FIELDS ---
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('Item Name', Icons.coffee),
                      validator: (v) => v!.isEmpty ? 'Please enter a name' : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _priceController,
                      style: const TextStyle(color: Colors.white),
                      decoration:
                          _buildInputDecoration('Price (PKR)', Icons.attach_money),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Please enter price';
                        if (double.tryParse(v) == null) return 'Invalid number';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: _descController,
                      style: const TextStyle(color: Colors.white),
                      decoration:
                          _buildInputDecoration('Description', Icons.description),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 30),

                    // --- SAVE BUTTON ---
                    SizedBox(
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveItem,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107),
                          foregroundColor: Colors.black,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.black,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("SAVE ITEM"),
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