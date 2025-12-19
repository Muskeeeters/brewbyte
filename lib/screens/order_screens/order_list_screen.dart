import 'dart:async'; // ⭐ IMPORT NEEDED FOR TIMER
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../services/order_service.dart';
import '../../models/order_model.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/cart/cart_bloc.dart';
import '../../bloc/cart/cart_state.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  final OrderService _orderService = OrderService();
  late Future<List<OrderModel>> _ordersFuture;
  Timer? _timer; // ⭐ TIMER VARIABLE

  @override
  void initState() {
    super.initState();
    _loadOrders();

    // ⭐ AUTO REFRESH LOGIC (Every 10 Seconds)
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted) {
        setState(() {
          _ordersFuture = _orderService.getOrders();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // ⭐ CLEANUP
    super.dispose();
  }

  void _loadOrders() {
    setState(() {
      _ordersFuture = _orderService.getOrders();
    });
  }

  // --- ACTIONS ---

  void _showStatusDialog(OrderModel order) {
    final shortId = order.id.substring(0, 5).toUpperCase();
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          backgroundColor: const Color(0xFF1E1E1E),
          title: Text(
            "Update Status for #$shortId",
            style: const TextStyle(color: Color(0xFFFFC107)),
          ),
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

  Future<void> _cancelOrder(String orderId) async {
    bool confirm =
        await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: const Color(0xFF1E1E1E),
            title: const Text(
              "Cancel Order?",
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              "Are you sure?",
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("No", style: TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  "Yes, Cancel",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;

    if (confirm) {
      await _orderService.updateOrderStatus(orderId, 'Cancelled');
      _loadOrders();
    }
  }

  Widget _statusOption(String orderId, String status, Color color) {
    return SimpleDialogOption(
      onPressed: () async {
        Navigator.pop(context);
        await _orderService.updateOrderStatus(orderId, status);
        _loadOrders();
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          children: [
            Icon(Icons.circle, color: color, size: 14),
            const SizedBox(width: 10),
            Text(
              status,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    final isManager =
        authState is AuthAuthenticated && authState.user.role == 'manager';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isManager ? "Manage Orders" : "My Orders",
          style: const TextStyle(color: Color(0xFFFFC107)),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFC107)),
          onPressed: () => context.go('/home'),
        ),
        actions: [
          if (!isManager)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: BlocBuilder<CartBloc, CartState>(
                builder: (context, state) {
                  int count = state is CartLoaded ? state.items.length : 0;
                  return Stack(
                    alignment: Alignment.topRight,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.shopping_cart),
                        onPressed: () => context.push('/cart'),
                      ),
                      if (count > 0)
                        Positioned(
                          right: 5,
                          top: 5,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButton: !isManager
          ? FloatingActionButton.extended(
              backgroundColor: const Color(0xFFFFC107),
              icon: const Icon(Icons.add, color: Colors.black),
              label: const Text(
                "Start New Order",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => context.push('/menu_list'),
            )
          : null,

      body: FutureBuilder<List<OrderModel>>(
        future: _ordersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFFFC107)),
            );
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No orders found.",
                style: TextStyle(color: Colors.white54),
              ),
            );
          }

          final orders = snapshot.data!;
          return ListView.builder(
            itemCount: orders.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final order = orders[index];
              final dt = order.createdAt;
              final formattedTime =
                  "${dt.day}/${dt.month} • ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ORDER #${order.id.substring(0, 5).toUpperCase()}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFFFFC107),
                                ),
                              ),
                              Text(
                                formattedTime,
                                style: const TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          if (isManager)
                            InkWell(
                              onTap: () => _showStatusDialog(order),
                              child: _statusBadge(order.status, true),
                            )
                          else if (order.status == 'Pending')
                            OutlinedButton(
                              onPressed: () => _cancelOrder(order.id),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red,
                                side: const BorderSide(color: Colors.red),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                              ),
                              child: const Text("Cancel"),
                            )
                          else
                            _statusBadge(order.status, false),
                        ],
                      ),
                      const Divider(color: Colors.white10, height: 32),
                      ...order.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Text(
                                "${item.quantity}x ",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFFFC107),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  item.name,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total Amount",
                            style: TextStyle(color: Colors.white54),
                          ),
                          Text(
                            "PKR ${order.totalAmount}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
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

  Widget _statusBadge(String status, bool showEdit) {
    Color color = Colors.grey;
    if (status == 'Pending') color = Colors.orange;
    if (status == 'Preparing') color = Colors.blue;
    if (status == 'Completed') color = Colors.green;
    if (status == 'Cancelled') color = Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
          if (showEdit) ...[
            const SizedBox(width: 4),
            Icon(Icons.edit, size: 12, color: color),
          ],
        ],
      ),
    );
  }
}
