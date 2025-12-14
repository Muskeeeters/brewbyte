import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/menu_model.dart';
import '../../services/menu_service.dart';
// Note: Yahan MenuItemListScreen ka import nahi chahiye agar hum GoRouter path use kar rahe hain
// Agar navigation direct kar rahe hain to chahiye, par router use ho raha hai.

class MenuListScreen extends StatefulWidget {
  const MenuListScreen({super.key});

  @override
  State<MenuListScreen> createState() => _MenuListScreenState();
}

class _MenuListScreenState extends State<MenuListScreen> {
  final MenuService _menuService = MenuService();
  late Future<List<MenuModel>> _menusFuture;

  @override
  void initState() {
    super.initState();
    _refreshMenus();
  }

  void _refreshMenus() {
    setState(() {
      _menusFuture = _menuService.getMenus();
    });
  }

  Future<void> _deleteMenu(String id) async {
    try {
      await _menuService.deleteMenu(id);
      _refreshMenus();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Menu Deleted")));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu Categories"),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      // Sirf Manager naya Menu bana sake
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await context.push('/add_menu');
          _refreshMenus();
        },
      ),
      body: FutureBuilder<List<MenuModel>>(
        future: _menusFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No menus found. Add one!"));
          }

          final menus = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: menus.length,
            itemBuilder: (context, index) {
              final menu = menus[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  // ⭐ Jab Menu pe click ho -> Items ki screen khule
                  onTap: () {
                    context.push(
                      '/menu_items',
                      extra: {'menuId': menu.id, 'menuName': menu.name},
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              menu.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (menu.description.isNotEmpty)
                              Text(
                                menu.description,
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteMenu(menu.id!),
                        ),
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
