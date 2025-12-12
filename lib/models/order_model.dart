import 'order_item_model.dart';

class OrderModel {
  final String id;
  final String userId;
  final List<OrderItem> items;
  final double totalAmount;
  final String status; // Pending, Completed, Cancelled
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
  });
}