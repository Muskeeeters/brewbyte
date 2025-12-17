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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Menu Categories"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFFFC107), // Golden
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.black.withOpacity(0.8), Colors.transparent],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFFFFC107),
        foregroundColor: Colors.black,
        icon: const Icon(Icons.add),
        label: const Text("Add Category", style: TextStyle(fontWeight: FontWeight.bold)),
        onPressed: () async {
          await context.push('/add_menu'); 
          _refreshMenus();
        },
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF121212), // Deep Black
        ),
        child: FutureBuilder<List<MenuModel>>(
          future: _menusFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFFFFC107)));
            }
            if (snapshot.hasError) return Center(child: Text("Error: ${snapshot.error}", style: const TextStyle(color: Colors.red)));
            if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text("No menus found. Add one!", style: TextStyle(color: Colors.white54)));

            final menus = snapshot.data!;
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 80), // Top padding for AppBar
              itemCount: menus.length,
              separatorBuilder: (context, index) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final menu = menus[index];
                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: InkWell(
                    onTap: () {
                      context.push('/menu_items', extra: {'menuId': menu.id, 'menuName': menu.name});
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFC107).withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.restaurant_menu, color: Color(0xFFFFC107), size: 28),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                menu.name, 
                                style: const TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Color(0xFFE53935)),
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
      ),
    );
  }
}