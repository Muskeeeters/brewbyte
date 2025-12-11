import 'package:flutter/material.dart';
import '../../models/menu_item_model.dart';
import '../../services/menu_service.dart';
import 'add_menu_item_screen.dart';


class MenuItemListScreen extends StatefulWidget {
  final String menuId;
  final String menuName;

  const MenuItemListScreen({
    super.key, 
    required this.menuId, 
    required this.menuName
  });

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

  // 👇 Ye naya function hai Item Delete karne ke liye
  Future<void> _deleteItem(String itemId) async {
    try {
      await _menuService.deleteMenuItem(itemId); // Service mein ye function hona chahiye
      _refreshItems(); // List refresh karein
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Item deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting item: $e')),
        );
      }
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
            MaterialPageRoute(
              builder: (context) => AddMenuItemScreen(menuId: widget.menuId),
            ),
          );
          _refreshItems();
        },
      ),
      body: FutureBuilder<List<MenuItemModel>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No items found. Add some!"));
          }

          final items = snapshot.data!;
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(item.description),
                  // 👇 Trailing mein Price aur Delete button dono laga diye
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Rs ${item.price.toInt()}",
                        style: const TextStyle(
                          color: Colors.green, 
                          fontWeight: FontWeight.bold, 
                          fontSize: 15
                        ),
                      ),
                      const SizedBox(width: 10),
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