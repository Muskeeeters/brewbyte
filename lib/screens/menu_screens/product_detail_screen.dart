import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/menu_item_model.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../bloc/cart/cart_event.dart';
import '../../bloc/cart/cart_state.dart';

class ProductDetailScreen extends StatefulWidget {
  final MenuItemModel item;

  const ProductDetailScreen({super.key, required this.item});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  final TextEditingController _notesController = TextEditingController();
  
  // Hardcoded Add-ons for Demo (Premium feel)
  final Map<String, double> _availableAddons = {
    "Extra Cheese": 50.0,
    "Spicy Sauce": 20.0,
    "Raita": 30.0,
  };
  final Set<String> _selectedAddons = {};

  double get _totalPrice {
    double addonTotal = 0;
    for (var addon in _selectedAddons) {
      addonTotal += _availableAddons[addon]!;
    }
    return (widget.item.price + addonTotal) * _quantity;
  }

  void _addToCart() {
    // Format notes with addons
    String finalNotes = _notesController.text.trim();
    if (_selectedAddons.isNotEmpty) {
      final addonString = "Add-ons: ${_selectedAddons.join(', ')}";
      finalNotes = finalNotes.isEmpty ? addonString : "$finalNotes\n$addonString";
    }

    final cartItem = CartItem(
      id: widget.item.id ?? DateTime.now().toString(),
      name: widget.item.name,
      price: widget.item.price, // Base price, logic might need adjustment if logic requires unit price update
      quantity: _quantity,
      notes: finalNotes,
    );

    context.read<CartBloc>().add(CartItemAdded(cartItem));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Added $_quantity ${widget.item.name} to Cart"),
        backgroundColor: const Color(0xFF4CAF50), // Success Green
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final hasImage = item.imageUrl != null && item.imageUrl!.isNotEmpty;

    return Scaffold(
      extendBodyBehindAppBar: true, 
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 8, top: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      // STICKY BOTTOM ACTION BAR
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 10,
              offset: const Offset(0, -5),
            )
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              // Quantity Selector
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2C2C2C),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  children: [
                     IconButton(
                        icon: const Icon(Icons.remove, color: Colors.white, size: 20),
                        onPressed: () {
                          if (_quantity > 1) setState(() => _quantity--);
                        },
                     ),
                     Text(
                        '$_quantity',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                     ),
                     IconButton(
                        icon: const Icon(Icons.add, color: Colors.white, size: 20),
                        onPressed: () {
                          setState(() => _quantity++);
                        },
                     ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Add to Cart Button
              Expanded(
                child: ElevatedButton(
                  onPressed: _addToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE53935), // Food Red
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 5,
                  ),
                  child: Text(
                    "Add  Rs ${_totalPrice.toInt()}", 
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100), // Space for bottom bar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HERO IMAGE
            Hero(
              tag: 'food_${item.id}',
              child: Container(
                height: 350,
                width: double.infinity,
                decoration: BoxDecoration(
                 color: const Color(0xFF2C2C2C),
                  image: hasImage
                      ? DecorationImage(
                          image: NetworkImage("${item.imageUrl!}?t=${DateTime.now().millisecondsSinceEpoch}"),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: !hasImage
                    ? const Icon(Icons.fastfood, size: 100, color: Colors.white24)
                    : Container( 
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                             colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                             begin: Alignment.bottomCenter,
                             end: Alignment.topCenter, 
                          ),
                        ),
                      ),
              ),
            ),

            // 2. PRODUCT INFO
            transformContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.1,
                          ),
                        ),
                      ),
                      Text(
                        "Rs ${item.price.toInt()}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFFC107), // Golden
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    item.description.isNotEmpty ? item.description : "Tasty and delicious.",
                    style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.5),
                  ),
                  const SizedBox(height: 32),
          
                  // 3. ADD-ONS (Chips)
                  const Text(
                    "Add-ons",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _availableAddons.entries.map((entry) {
                      final isSelected = _selectedAddons.contains(entry.key);
                      return FilterChip(
                        selected: isSelected,
                        label: Text("${entry.key} (+Rs ${entry.value.toInt()})"),
                        labelStyle: TextStyle(
                            color: isSelected ? Colors.black : Colors.white,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal
                        ),
                        backgroundColor: const Color(0xFF2C2C2C),
                        selectedColor: const Color(0xFFFFC107),
                        checkmarkColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: isSelected ? Colors.transparent : Colors.white24)
                        ),
                        onSelected: (bool selected) {
                          setState(() {
                            if (selected) {
                              _selectedAddons.add(entry.key);
                            } else {
                              _selectedAddons.remove(entry.key);
                            }
                          });
                        },
                      );
                    }).toList(),
                  ),
          
                  const SizedBox(height: 32),
          
                  // 4. SPECIAL INSTRUCTIONS
                  const Text(
                    "Special Instructions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _notesController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                       hintText: "e.g. No onions, extra spicy...",
                       hintStyle: const TextStyle(color: Colors.white24),
                       filled: true,
                       fillColor: const Color(0xFF2C2C2C),
                       border: OutlineInputBorder(
                         borderRadius: BorderRadius.circular(16),
                         borderSide: BorderSide.none,
                       ),
                       contentPadding: const EdgeInsets.all(16),
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget transformContainer({required Widget child}) {
    return Transform.translate(
      offset: const Offset(0, -20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          color: const Color(0xFF121212),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
          boxShadow: [
             BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, -2),
             ),
          ],
        ),
        child: child,
      ),
    );
  }
}
