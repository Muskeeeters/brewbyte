class MenuItemModel {
  final String? id;
  final String menuId;
  final String name;
  final double price;
  final String description;

  MenuItemModel({
    this.id,
    required this.menuId,
    required this.name,
    required this.price,
    required this.description,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'],
      menuId: json['menu_id'], // Database column name match hona chahiye
      name: json['name'],
      price: double.parse(json['price'].toString()), // Safe conversion
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_id': menuId,
      'name': name,
      'price': price,
      'description': description,
    };
  }
}