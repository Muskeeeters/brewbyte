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

  // --- ACTIONS ---

  // 1. Manager: Change Status
  void _showStatusDialog(OrderModel order) {
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

  // 2. Student: Cancel Order Logic
  Future<void> _cancelOrder(String orderId) async {
    // Confirmation Dialog
    bool confirm = await showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: const Text("Cancel Order?"),
        content: const Text("Are you sure you want to cancel this order?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("No")),
          TextButton(
            onPressed: () => Navigator.pop(context, true), 
            child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
          ),
        ],
      )
    ) ?? false;

    if (confirm) {
      await _orderService.updateOrderStatus(orderId, 'Cancelled');
      _refreshOrders(); // UI Refresh
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Order Cancelled")));
      }
    }
  }

  Widget _statusOption(String orderId, String status, Color color) {
    return SimpleDialogOption(
      onPressed: () async {
        Navigator.pop(context); 
        await _orderService.updateOrderStatus(orderId, status); 
        _refreshOrders(); 
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
      // Sirf Student Order create kar sake
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
              
              // Helper to Format Date Time
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
                      // --- HEADER ROW (ID + STATUS/ACTION) ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left: ID & Date
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ORDER #${order.id.substring(0, 5).toUpperCase()}", 
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                formattedTime, 
                                style: TextStyle(color: Colors.grey[600], fontSize: 12),
                              ),
                            ],
                          ),
                          
                          // Right: Action Logic
                          // 1. Agar Manager hai -> Edit Button
                          if (isManager)
                             InkWell(
                              onTap: () => _showStatusDialog(order),
                              child: _statusBadge(order.status, true),
                            )
                          
                          // 2. Agar Student hai aur Order Pending hai -> CANCEL BUTTON
                          else if (order.status == 'Pending')
                            OutlinedButton(
                              onPressed: () => _cancelOrder(order.id),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
                              ),
                              child: const Text("Cancel"),
                            )

                          // 3. Agar Student hai aur Order Process ho chuka hai -> Sirf Badge
                          else
                            _statusBadge(order.status, false),
                        ],
                      ),
                      
                      const Divider(height: 24),
                      
                      // Items List
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
                      
                      // Total
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

  // Helper Widget for Status Badge
  Widget _statusBadge(String status, bool showEditIcon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getStatusColor(status).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _getStatusColor(status).withOpacity(0.3))
      ),
      child: Row(
        children: [
          Text(
            status,
            style: TextStyle(
              color: _getStatusColor(status),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          if (showEditIcon) ...[
            const SizedBox(width: 4),
            Icon(Icons.edit, size: 14, color: _getStatusColor(status)),
          ]
        ],
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