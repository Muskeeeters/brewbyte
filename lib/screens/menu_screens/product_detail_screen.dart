import 'package:flutter/material.dart';
import '../../models/menu_item_model.dart';

class ProductDetailScreen extends StatefulWidget {
  final MenuItemModel item;

  const ProductDetailScreen({super.key, required this.item});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

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
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.4),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. BIG IMAGE HEADER WITH HERO ---
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
                    : Container( // Dark overlay gradient for text visibility if needed
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                             colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                             begin: Alignment.bottomCenter,
                             end: Alignment.topCenter, 
                          ),
                        ),
                      ),
              ),
            ),

            // --- 2. DETAILS SECTION (Dark Sheet) ---
            Transform.translate(
              offset: const Offset(0, -30), 
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E), // Dark Sheet
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle Bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.white24,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title & Price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
                    const SizedBox(height: 24),

                    // Description
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.description.isNotEmpty
                          ? item.description
                          : "No description available.",
                      style: const TextStyle(color: Colors.white54, height: 1.5, fontSize: 14),
                    ),
                    const SizedBox(height: 30),

                    // Quantity Selector
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2C2C2C),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Quantity",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          Row(
                            children: [
                              _quantityButton(Icons.remove, () {
                                if (_quantity > 1) setState(() => _quantity--);
                              }),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  "$_quantity",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              _quantityButton(Icons.add, () {
                                setState(() => _quantity++);
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Add to Cart Button (Future Order Logic)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          // Placeholder for future logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Added $_quantity ${item.name} to Order!",
                                style: const TextStyle(color: Colors.black),
                              ),
                              backgroundColor: const Color(0xFFFFC107),
                            ),
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFC107), // Golden
                          foregroundColor: Colors.black,
                          shadowColor: const Color(0xFFFFC107).withOpacity(0.5),
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28), // Pill
                          ),
                        ),
                        child: Text(
                          "Add to Order (Rs ${(item.price * _quantity).toInt()})",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quantityButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: Colors.white),
      ),
    );
  }
}
