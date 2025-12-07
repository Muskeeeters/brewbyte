class MenuItemModel {
  final String id;
  final String menuId; // Ye batayega ke ye item kis Menu ka hissa hai
  final String name;
  final double price;
  final String description;

  MenuItemModel({
    required this.id,
    required this.menuId,
    required this.name,
    required this.price,
    required this.description,
  });
}