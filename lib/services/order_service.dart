import '../models/order_model.dart';
import '../models/order_item_model.dart';

class OrderService {
  // DUMMY DATA (Database simulation)
  // 'static' isliye use kiya taake app reload hone tak data save rahe
  static final List<OrderModel> _dummyOrders = [
    OrderModel(
      id: 'ORD-001',
      userId: 'user_123',
      items: [
        OrderItem(id: '1', name: 'Cappuccino', price: 450, quantity: 2),
        OrderItem(id: '2', name: 'Blueberry Muffin', price: 300, quantity: 1),
      ],
      totalAmount: 1200,
      status: 'Completed',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    OrderModel(
      id: 'ORD-002',
      userId: 'user_123',
      items: [
        OrderItem(id: '3', name: 'Iced Latte', price: 500, quantity: 1),
      ],
      totalAmount: 500,
      status: 'Pending',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];

  // 1. Get All Orders
  Future<List<OrderModel>> getOrders() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Fake network delay
    return _dummyOrders;
  }

  // 2. Create New Order (For User)
  Future<void> createOrder(List<OrderItem> items) async {
    await Future.delayed(const Duration(seconds: 1));
    
    double total = items.fold(0, (sum, item) => sum + item.total);
    
    final newOrder = OrderModel(
      id: 'ORD-${DateTime.now().millisecondsSinceEpoch}', // Unique ID based on time
      userId: 'user_123', // Dummy user ID
      items: items,
      totalAmount: total,
      status: 'Pending', // Default status for new order
      createdAt: DateTime.now(),
    );

    _dummyOrders.insert(0, newOrder); // Add to top of list
  }

  // 3. Update Order Status (For Manager)
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await Future.delayed(const Duration(milliseconds: 500)); // Fake processing delay
    
    final index = _dummyOrders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      final oldOrder = _dummyOrders[index];
      
      // Create updated copy of the order
      _dummyOrders[index] = OrderModel(
        id: oldOrder.id,
        userId: oldOrder.userId,
        items: oldOrder.items,
        totalAmount: oldOrder.totalAmount,
        status: newStatus, // Only status changes
        createdAt: oldOrder.createdAt,
      );
    }
  }
}