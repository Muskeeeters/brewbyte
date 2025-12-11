class MenuModel {
  // Naye code mein '?' lagaya hai, matlab ID shuru mein nahi hogi
  final String? id; 
  final String name;
  final String description;

  MenuModel({
    this.id, // Yahan se 'required' hata diya hai
    required this.name,
    required this.description,
  });

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'],
      name: json['name'],
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // JSON bhejte waqt hum ID nahi bhejenge
      'name': name,
      'description': description,
    };
  }
}