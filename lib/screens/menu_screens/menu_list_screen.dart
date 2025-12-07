import 'package:flutter/material.dart';
import '../../models/menu_model.dart';
import '../../services/menu_service.dart';
import 'add_menu_screen.dart';

class MenuListScreen extends StatefulWidget {
  const MenuListScreen({super.key});

  @override
  State<MenuListScreen> createState() => _MenuListScreenState();
}

class _MenuListScreenState extends State<MenuListScreen> {
  final MenuService _menuService = MenuService();
  late List<MenuModel> _menus;

  @override
  void initState() {
    super.initState();
    _refreshMenu();
  }

  void _refreshMenu() {
    setState(() {
      _menus = _menuService.getMenus();
    });
  }

  void _deleteMenu(String id) {
    _menuService.deleteMenu(id);
    _refreshMenu();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Menu Deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Management'),
        backgroundColor: Colors.brown,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.brown,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          // Navigate to Add Screen and wait for return
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddMenuScreen()),
          );
          _refreshMenu(); // Wapis aane par list refresh karein
        },
      ),
      body: _menus.isEmpty
          ? const Center(child: Text("No Menus Available"))
          : ListView.builder(
              itemCount: _menus.length,
              itemBuilder: (context, index) {
                final menu = _menus[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: const Icon(Icons.restaurant_menu, color: Colors.brown),
                    title: Text(menu.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(menu.description),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteMenu(menu.id),
                    ),
                    onTap: () {
                      // Future: Yahan click kar ke MenuItem screen par jayenge
                      ScaffoldMessenger.of(context).showSnackBar(
                         SnackBar(content: Text('Viewing items for ${menu.name} (Coming Soon)')),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}