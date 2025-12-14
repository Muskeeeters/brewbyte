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

  Future<void> _deleteItem(String itemId) async {
    try {
      await _menuService.deleteMenuItem(itemId);
      _refreshItems();
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
            padding: const EdgeInsets.all(10),
            itemBuilder: (context, index) {
              final item = items[index];
              
              // Check agar image URL hai
              final bool hasImage = item.imageUrl != null && item.imageUrl!.isNotEmpty;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    // ⭐ NEW: Image Section
                    leading: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                        image: hasImage 
                          ? DecorationImage(
                              image: NetworkImage(item.imageUrl!),
                              fit: BoxFit.cover,
                            )
                          : null,
                      ),
                      child: !hasImage
                          ? const Icon(Icons.fastfood, color: Colors.grey)
                          : null,
                    ),

                    // Title & Description
                    title: Text(
                      item.name, 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        item.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      ),
                    ),

                    // Price & Delete
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Rs ${item.price.toInt()}",
                          style: const TextStyle(
                            color: Colors.green, 
                            fontWeight: FontWeight.bold, 
                            fontSize: 15
                          ),
                        ),
                        // Delete Icon (Thora chota kiya taake fit aaye)
                        InkWell(
                          onTap: () => _deleteItem(item.id!),
                          child: const Padding(
                            padding: EdgeInsets.only(top: 8.0, left: 10),
                            child: Icon(Icons.delete, color: Colors.red, size: 20),
                          ),
                        )
                      ],
                    ),
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