import 'package:flutter/material.dart';
import 'dart:typed_data'; 
import 'package:image_picker/image_picker.dart'; 
import '../../models/menu_item_model.dart';
import '../../services/menu_service.dart';
import '../../services/upload_service.dart';

class AddMenuItemScreen extends StatefulWidget {
  final String menuId; 
  final MenuItemModel? existingItem; // ⭐ NEW: Optional item for editing

  const AddMenuItemScreen({super.key, required this.menuId, this.existingItem});

  @override
  State<AddMenuItemScreen> createState() => _AddMenuItemScreenState();
}

class _AddMenuItemScreenState extends State<AddMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _priceController;

  final MenuService _menuService = MenuService();
  final UploadService _uploadService = UploadService();

  bool _isLoading = false;
  XFile? _selectedXFile;
  Uint8List? _selectedImageBytes;
  String? _currentImageUrl; // To show existing image in Edit mode

  @override
  void initState() {
    super.initState();
    // ⭐ Pre-fill logic for Edit Mode
    _nameController = TextEditingController(text: widget.existingItem?.name ?? '');
    _descController = TextEditingController(text: widget.existingItem?.description ?? '');
    _priceController = TextEditingController(text: widget.existingItem?.price.toString() ?? '');
    _currentImageUrl = widget.existingItem?.imageUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? picked = await _uploadService.pickImage();
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _selectedXFile = picked;
          _selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      debugPrint("Image pick error: $e");
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String? imageUrl;

      // 1. Upload New Image (if selected)
      if (_selectedXFile != null) {
        imageUrl = await _uploadService.uploadImage(
            _selectedXFile!,
            'image', 
            'menu_items' 
            );
        if (imageUrl == null) throw Exception("Image upload failed");
      }

      // ⭐ CHECK: Edit Mode vs Add Mode
      if (widget.existingItem != null) {
        // UPDATE EXISTING
        await _menuService.updateMenuItem(
          id: widget.existingItem!.id!,
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          imageUrl: imageUrl, // Will be null if no new image picked (Service handles this)
        );
      } else {
        // CREATE NEW
        final newItem = MenuItemModel(
          menuId: widget.menuId,
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          imageUrl: imageUrl, 
        );
        await _menuService.addMenuItem(newItem);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Helper for displaying image
  ImageProvider? _getImageProvider() {
    if (_selectedImageBytes != null) return MemoryImage(_selectedImageBytes!);
    if (_currentImageUrl != null) return NetworkImage(_currentImageUrl!);
    return null;
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFFFFC107)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existingItem != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(isEdit ? "Edit Item" : "Add New Item"),
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFFFC107),
      ),
      body: Container(
        height: double.infinity,
        decoration: const BoxDecoration(color: Color(0xFF121212)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 100, 24, 24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white10),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- IMAGE BOX ---
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
                            color: const Color(0xFFFFC107).withOpacity(0.5),
                            width: 2,
                          ),
                          image: _getImageProvider() != null
                              ? DecorationImage(
                                  image: _getImageProvider()!,
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: _getImageProvider() == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.white54),
                                  SizedBox(height: 10),
                                  Text("Tap to upload image", style: TextStyle(color: Colors.white54)),
                                ],
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration('Item Name', Icons.coffee),
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _priceController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration('Price (PKR)', Icons.attach_money),
                    keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _descController,
                    style: const TextStyle(color: Colors.white),
                    decoration: _buildInputDecoration('Description', Icons.description),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 30),

                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveItem,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFC107),
                        foregroundColor: Colors.black,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : Text(isEdit ? "UPDATE ITEM" : "SAVE ITEM"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}