class MenuItemModel {
  final String? id;
  final String menuId;
  final String name;
  final double price;
  final String description;
  final String? imageUrl; // 🆕 Added this field

  MenuItemModel({
    this.id,
    required this.menuId,
    required this.name,
    required this.price,
    required this.description,
    this.imageUrl, // 🆕 Added to constructor
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json['id'],
      menuId: json['menu_id'],
      name: json['name'],
      price: double.parse(json['price'].toString()),
      description: json['description'] ?? '',
      imageUrl: json['image_url'], // 🆕 Map from DB
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menu_id': menuId,
      'name': name,
      'price': price,
      'description': description,
      'image_url': imageUrl, // 🆕 Send to DB
    };
  }
}