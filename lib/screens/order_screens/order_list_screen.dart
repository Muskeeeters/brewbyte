import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';
import '../../bloc/auth/auth_bloc.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final OrderService _orderService = OrderService();
  late Future<List<OrderModel>> _ordersFuture;

  @override
  void initState() {
    super.initState();
    _ordersFuture = _orderService.getOrders();
  }

  void _refreshOrders() {
    setState(() {
      _ordersFuture = _orderService.getOrders();
    });
  }

  // Status Change Dialog
  void _showStatusDialog(OrderModel order) {
    // Dialog mein bhi short ID dikhayein taake consistent lage
    final shortId = order.id.substring(0, 5).toUpperCase();
    
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          title: Text("Update Status for #$shortId"),
          children: [
            _statusOption(order.id, "Pending", Colors.orange),
            _statusOption(order.id, "Preparing", Colors.blue),
            _statusOption(order.id, "Completed", Colors.green),
            _statusOption(order.id, "Cancelled", Colors.red),
          ],
        );
      },
    );
  }

  Widget _statusOption(String orderId, String status, Color color) {
    return SimpleDialogOption(
      onPressed: () async {
        Navigator.pop(context); // Close dialog
        await _orderService.updateOrderStatus(orderId, status); // Update logic
        _refreshOrders(); // Refresh UI
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Status updated to $status")),
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(Icons.circle, color: color, size: 14),
            const SizedBox(width: 10),
            Text(status, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check User Role
    final authState = context.read<AuthBloc>().state;
    final isManager = authState is AuthAuthenticated && authState.user.role == 'manager';

    return Scaffold(
      appBar: AppBar(title: Text(isManager ? "Manage Orders" : "My Orders")),
      // Sirf Non-Manager (User) ko create button dikhana hai
      floatingActionButton: !isManager 
          ? FloatingActionButton(
              backgroundColor: const Color(0xFFFFC107),
              child: const Icon(Icons.add, color: Colors.black),
              onPressed: () async {
                await context.push('/create_order');
                _refreshOrders();
              },
            )
          : null, 
      
      body: FutureBuilder<List<OrderModel>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No orders found."));
          }

          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final order = orders[index];
              
              // Helper to Format Date Time nicely (e.g., 12:30)
              final dt = order.createdAt;
              final formattedTime = "${dt.day}/${dt.month} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --- HEADER ROW (Order ID + Status) ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left Side: Order ID & Date
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ORDER #${order.id.substring(0, 5).toUpperCase()}", // Clean ID
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formattedTime, // Date & Time
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                          
                          // Right Side: Status Badge/Button
                          isManager 
                          ? InkWell(
                              onTap: () => _showStatusDialog(order),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.black12)
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      order.status,
                                      style: TextStyle(
                                        color: _getStatusColor(order.status),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(Icons.edit, size: 14),
                                  ],
                                ),
                              ),
                            )
                          : Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(order.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                order.status,
                                style: TextStyle(
                                  color: _getStatusColor(order.status),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      
                      const Divider(height: 24),
                      
                      // --- ORDER ITEMS LIST ---
                      ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          children: [
                            Text("${item.quantity}x ", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFFFC107))),
                            Text(item.name),
                          ],
                        ),
                      )),
                      
                      const SizedBox(height: 12),
                      
                      // --- TOTAL AMOUNT ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total Amount", style: TextStyle(color: Colors.grey[600])),
                          Text("PKR ${order.totalAmount}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pending': return Colors.orange;
      case 'Preparing': return Colors.blue;
      case 'Completed': return Colors.green;
      case 'Cancelled': return Colors.red;
      default: return Colors.black;
    }
  }
}