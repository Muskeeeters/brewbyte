import 'package:flutter/material.dart';
import '../../models/menu_item_model.dart';
// Note: Cart Logic abhi hum Local Variable se handle karenge,
// baad mein Order Flow se connect karenge.

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
      extendBodyBehindAppBar: true, // Image header ke peeche jaye
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black, blurRadius: 10)],
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- 1. BIG IMAGE HEADER ---
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                image: hasImage
                    ? DecorationImage(
                        image: NetworkImage(item.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: !hasImage
                  ? const Icon(Icons.fastfood, size: 100, color: Colors.grey)
                  : null,
            ),

            // --- 2. DETAILS SECTION ---
            Transform.translate(
              offset: const Offset(
                0,
                -20,
              ), // Thora upar khiskao taake rounded lage
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          "Rs ${item.price.toInt()}",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.description.isNotEmpty
                          ? item.description
                          : "No description available.",
                      style: const TextStyle(color: Colors.grey, height: 1.5),
                    ),
                    const SizedBox(height: 30),

                    // Quantity Selector
                    Row(
                      children: [
                        const Text(
                          "Quantity",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Spacer(),
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
                            ),
                          ),
                        ),
                        _quantityButton(Icons.add, () {
                          setState(() => _quantity++);
                        }),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Add to Cart Button (Abhi sirf message dega)
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          // Yahan hum Cart logic lagayenge (Halima's part later)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                "Added $_quantity ${item.name} to Order!",
                              ),
                            ),
                          );
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: Text(
                          "Add to Order (Rs ${(item.price * _quantity).toInt()})",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
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
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20),
      ),
    );
  }
}
