import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';

class OrderService {
  final _supabase = Supabase.instance.client;

  // 1. GET ALL ORDERS (Real Database)
  Future<List<OrderModel>> getOrders() async {
    try {
      // 'orders' table se data lao, aur saath mein 'order_items' bhi join karo
      final response = await _supabase
          .from('orders')
          .select('*, order_items(*)') 
          .order('created_at', ascending: false); // Newest pehle

      // JSON list ko OrderModel list mein convert karo
      final List<dynamic> data = response;
      return data.map((json) => OrderModel.fromMap(json)).toList();
    } catch (e) {
      print('Error fetching orders: $e');
      return []; // Error aye to empty list dikhao crash mat karo
    }
  }

  // 2. CREATE NEW ORDER (Real Database)
  Future<void> createOrder(List<OrderItem> items) async {
    final user = _supabase.auth.currentUser;
    if (user == null) return; // Agar login nahi hai to wapis jao

    final double total = items.fold(0, (sum, item) => sum + item.total);

    try {
      // A. Pehle 'orders' table mein main entry karo
      final orderResponse = await _supabase
          .from('orders')
          .insert({
            'user_id': user.id,
            'total_amount': total,
            'status': 'Pending',
          })
          .select()
          .single(); // Hamein wapis ID chahiye

      final String newOrderId = orderResponse['id'];

      // B. Ab items prepare karo 'order_items' table ke liye
      final List<Map<String, dynamic>> itemsData = items.map((item) {
        return {
          'order_id': newOrderId,
          'name': item.name,      // Snapshot of name
          'price': item.price,    // Snapshot of price
          'quantity': item.quantity,
          
          // ⭐ CHANGE: Ab hum Real ID bhej rahe hain (Linked to Talal's Module)
          'menu_item_id': item.menuItemId, 
        };
      }).toList();

      // C. Saare items ek saath insert karo
      await _supabase.from('order_items').insert(itemsData);

    } catch (e) {
      print('Error creating order: $e');
      throw e; // Screen par error dikhane ke liye throw karo
    }
  }

  // 3. UPDATE ORDER STATUS (For Manager)
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _supabase
          .from('orders')
          .update({'status': newStatus})
          .eq('id', orderId); // Sirf us specific ID ko update karo
    } catch (e) {
      print('Error updating status: $e');
    }
  }
}