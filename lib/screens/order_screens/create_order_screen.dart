import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase import
import 'package:go_router/go_router.dart';
import '../../services/order_service.dart';
import '../../models/order_item_model.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final OrderService _orderService = OrderService();
  final _supabase = Supabase.instance.client; // Direct DB access for Menu
  
  bool _isLoading = false;
  List<Map<String, dynamic>> _menuItems = []; // Ab ye Empty list hai, DB se bharegi
  bool _isMenuLoading = true;

  // Cart to hold selected items
  final List<OrderItem> _cart = [];

  @override
  void initState() {
    super.initState();
    _fetchRealMenu(); // Screen khulte hi data lao
  }

  // Talal ke table se Menu Items lana
  Future<void> _fetchRealMenu() async {
    try {
      final response = await _supabase
          .from('menu_items')
          .select('id, name, price, is_available') // Sirf zaroori cheezein
          .eq('is_available', true); // Sirf jo available hain wo dikhao

      setState(() {
        _menuItems = List<Map<String, dynamic>>.from(response);
        _isMenuLoading = false;
      });
    } catch (e) {
      print("Error fetching menu: $e");
      setState(() => _isMenuLoading = false);
    }
  }

  void _addToCart(Map<String, dynamic> item) {
    setState(() {
      _cart.add(OrderItem(
        id: '', // OrderItem ki apni ID baad mein banegi
        menuItemId: item['id'], // <--- YE REAL LINK HAI TALAL K MODULE SE
        name: item['name'],
        price: (item['price'] as num).toDouble(), // Safe conversion
        quantity: 1,
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
      context.pop(); // Wapas list par jao
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Order")),
      body: Column(
        children: [
          // Menu List Area
          Expanded(
            child: _isMenuLoading
                ? const Center(child: CircularProgressIndicator())
                : _menuItems.isEmpty
                    ? const Center(child: Text("No menu items available yet."))
                    : ListView.builder(
                        itemCount: _menuItems.length,
                        itemBuilder: (context, index) {
                          final item = _menuItems[index];
                          return ListTile(
                            title: Text(item['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("PKR ${item['price']}"),
                            trailing: IconButton(
                              icon: const Icon(Icons.add_circle, color: Color(0xFFFFC107), size: 30),
                              onPressed: () => _addToCart(item),
                            ),
                          );
                        },
                      ),
          ),
          
          // Cart Summary Bottom Sheet
          if (_cart.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Items in Cart: ${_cart.length}", style: const TextStyle(fontSize: 16)),
                      Text(
                        "Total: PKR ${_cart.fold(0.0, (sum, item) => sum + item.total)}",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _placeOrder,
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