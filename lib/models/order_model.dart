import 'order_item_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });

  // Supabase se data parhne ke liye
  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      totalAmount: (map['total_amount'] ?? 0).toDouble(),
      status: map['status'] ?? 'Pending',
      createdAt: DateTime.parse(map['created_at']),
      // Agar 'order_items' saath mein fetch huye hain to unhein map karein
      items: map['order_items'] != null
          ? (map['order_items'] as List)
              .map((item) => OrderItem.fromMap(item))
              .toList()
          : [],
    );
  }
}