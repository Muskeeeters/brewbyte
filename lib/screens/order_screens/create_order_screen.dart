import 'package:flutter/material.dart';
import '../../services/order_service.dart';
import '../../models/order_item_model.dart';
import 'package:go_router/go_router.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final OrderService _orderService = OrderService();
  bool _isLoading = false;

  // Temporary menu for testing (Jab Talal ka kaam ho jaye, wahan se data aayega)
  final List<Map<String, dynamic>> _menuItems = [
    {'id': '101', 'name': 'Espresso', 'price': 250.0},
    {'id': '102', 'name': 'Chicken Sandwich', 'price': 550.0},
    {'id': '103', 'name': 'Cheesecake', 'price': 400.0},
  ];

  // Cart to hold selected items
  final List<OrderItem> _cart = [];

  void _addToCart(Map<String, dynamic> item) {
    setState(() {
      _cart.add(OrderItem(
        id: item['id'],
        name: item['name'],
        price: item['price'],
        quantity: 1, // Default 1 for simplicity
      ));
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${item['name']} added to cart!")),
    );
  }

  void _placeOrder() async {
    if (_cart.isEmpty) return;

    setState(() => _isLoading = true);
    await _orderService.createOrder(_cart);
    setState(() => _isLoading = false);

    if (mounted) {
      context.pop(); // Go back to history
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Order")),
      body: Column(
        children: [
          // Menu List
          Expanded(
            child: ListView.builder(
              itemCount: _menuItems.length,
              itemBuilder: (context, index) {
                final item = _menuItems[index];
                return ListTile(
                  title: Text(item['name']),
                  subtitle: Text("PKR ${item['price']}"),
                  trailing: IconButton(
                    icon: const Icon(Icons.add_circle, color: Color(0xFFFFC107)),
                    onPressed: () => _addToCart(item),
                  ),
                );
              },
            ),
          ),
          // Cart Summary Bottom Sheet
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Items in Cart: ${_cart.length}", style: const TextStyle(fontSize: 16)),
                    Text(
                      "Total: PKR ${_cart.fold(0.0, (sum, item) => sum + item.total)}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _cart.isEmpty || _isLoading ? null : _placeOrder,
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.black) 
                      : const Text("Place Order"),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}