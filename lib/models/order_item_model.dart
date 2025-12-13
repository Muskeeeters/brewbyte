class OrderItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  final String? menuItemId; // Ye naya field hai link ke liye

  OrderItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.menuItemId,
  });

  // Supabase se data parhne ke liye
  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Unknown Item',
      // Supabase numeric/int bhejta hai, hum double mein convert karenge
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
      menuItemId: map['menu_item_id'],
    );
  }

  double get total => price * quantity;
}