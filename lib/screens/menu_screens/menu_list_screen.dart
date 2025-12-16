import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/menu_model.dart';
import '../../services/menu_service.dart';

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
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
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
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}"));
          if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No menus found. Add one!"));

          final menus = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: menus.length,
            itemBuilder: (context, index) {
              final menu = menus[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    // Navigate to Items
                    context.push('/menu_items', extra: {'menuId': menu.id, 'menuName': menu.name});
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(menu.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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