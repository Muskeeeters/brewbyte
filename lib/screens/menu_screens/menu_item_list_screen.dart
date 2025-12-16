import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/menu_item_model.dart';
import '../../services/menu_service.dart';
import 'add_menu_item_screen.dart';
// Note: ProductDetailScreen import ki zaroorat nahi agar hum context.push('/product_detail') use karein

class MenuItemListScreen extends StatefulWidget {
  final String menuId;
  final String menuName;

  const MenuItemListScreen({super.key, required this.menuId, required this.menuName});

  @override
  State<MenuItemListScreen> createState() => _MenuItemListScreenState();
}

class _MenuItemListScreenState extends State<MenuItemListScreen> {
  final MenuService _menuService = MenuService();
  late Future<List<MenuItemModel>> _itemsFuture;

  @override
  void initState() {
    super.initState();
    _refreshItems();
  }

  void _refreshItems() {
    setState(() {
      _itemsFuture = _menuService.getItemsByMenu(widget.menuId);
    });
  }

  Future<void> _deleteItem(String itemId) async {
    try {
      await _menuService.deleteMenuItem(itemId);
      _refreshItems();
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.menuName),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMenuItemScreen(menuId: widget.menuId)),
          );
          _refreshItems();
        },
      ),
      body: FutureBuilder<List<MenuItemModel>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No items found."));

          final items = snapshot.data!;
          return ListView.builder(
            itemCount: items.length,
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final item = items[index];
              final bool hasImage = item.imageUrl != null && item.imageUrl!.isNotEmpty;

              return Card(
                child: ListTile(
                  onTap: () {
                    // Navigate to Product Detail using Route
                    context.push('/product_detail', extra: item);
                  },
                  leading: hasImage 
                    ? Image.network(item.imageUrl!, width: 50, height: 50, fit: BoxFit.cover)
                    : const Icon(Icons.fastfood),
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Rs ${item.price.toInt()}", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteItem(item.id!),
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
}