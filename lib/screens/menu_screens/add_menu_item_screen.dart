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
    final XFile? picked = await _uploadService.pickImage();
    if (picked != null) {
      final bytes = await picked.readAsBytes(); // Bytes read karein
      setState(() {
        _selectedXFile = picked;
        _selectedImageBytes = bytes;
      });
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
            'image',     // ✅ Correct Bucket Name (small letters)
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Item added successfully!')));
          Navigator.pop(context); // Wapis List par jao
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
      appBar: AppBar(title: const Text("Add New Item")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // --- IMAGE UPLOAD BOX ---
                InkWell(
                  onTap: _pickImage,
                  child: Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      border: Border.all(color: Colors.grey.shade400),
                      borderRadius: BorderRadius.circular(12),
                      image: _selectedImageBytes != null 
                        ? DecorationImage(
                            image: MemoryImage(_selectedImageBytes!), // ✅ Web Safe Image
                            fit: BoxFit.cover
                          )
                        : null,
                    ),
                    child: _selectedImageBytes == null
                        ? const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, size: 50, color: Colors.grey),
                              SizedBox(height: 8),
                              Text("Tap to add food image", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                            ],
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 20),

                // Name Field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Item Name (e.g. Cappuccino)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.fastfood),
                  ),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Price Field
                TextFormField(
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price (PKR)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.attach_money),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),

                // Description Field
                TextFormField(
                  controller: _descController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 30),
                
                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFC107), 
                      foregroundColor: Colors.black
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator() 
                      : const Text("Save Item", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}