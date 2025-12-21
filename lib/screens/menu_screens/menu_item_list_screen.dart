import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // Import Bloc
import 'package:go_router/go_router.dart';
import '../../bloc/auth/auth_bloc.dart'; // Import AuthBloc
import '../../models/menu_item_model.dart';
import '../../services/menu_service.dart';
import 'add_menu_item_screen.dart';
import '../../widgets/cart_icon_badge.dart';

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
    // RBAC Check
    final isManager = context.select((AuthBloc bloc) {
      final state = bloc.state;
      return state is AuthAuthenticated && state.user.role == 'manager';
    });

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(widget.menuName, style: const TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: const Color(0xFFFFC107),
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
        actions: const [
           Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CartIconBadge(color: Color(0xFFFFC107)),
          ),
        ],
      ),
      // Only show FAB if Manager
      floatingActionButton: isManager ? FloatingActionButton(
        backgroundColor: const Color(0xFFFFC107),
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMenuItemScreen(menuId: widget.menuId)),
          );
          _refreshItems();
        },
      ) : null,
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF121212),
        ),
        child: FutureBuilder<List<MenuItemModel>>(
          future: _itemsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
               return const Center(child: CircularProgressIndicator(color: Color(0xFFFFC107)));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
               return const Center(child: Text("No items found.", style: TextStyle(color: Colors.white54)));
            }

            final items = snapshot.data!;
            return ListView.builder(
              itemCount: items.length,
              padding: const EdgeInsets.fromLTRB(16, 100, 16, 80),
              itemBuilder: (context, index) {
                final item = items[index];
                final bool hasImage = item.imageUrl != null && item.imageUrl!.isNotEmpty;

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    onTap: () {
                      context.push('/product_detail', extra: item);
                    },
                    leading: Hero(
                      tag: 'food_${item.id}',
                      child: Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.grey[800],
                          image: hasImage 
                             ? DecorationImage(
                                 image: NetworkImage("${item.imageUrl!}?t=${DateTime.now().millisecondsSinceEpoch}"),
                                 fit: BoxFit.cover,
                               )
                             : null,
                        ),
                        child: !hasImage 
                           ? const Icon(Icons.fastfood, color: Colors.white54)
                           : null,
                      ),
                    ),
                    title: Text(
                      item.name, 
                      style: const TextStyle(
                        fontWeight: FontWeight.bold, 
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                       item.description,
                       maxLines: 2,
                       overflow: TextOverflow.ellipsis,
                       style: const TextStyle(color: Colors.white54),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Rs ${item.price.toInt()}", 
                          style: const TextStyle(
                            color: Color(0xFFFFC107), 
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          )
                        ),
                        // Only show delete if Manager
                        if (isManager) ...[
                          const SizedBox(height: 4),
                          InkWell(
                            onTap: () => _deleteItem(item.id!),
                            child: const Icon(Icons.delete_outline, color: Color(0xFFE53935), size: 20),
                          ),
                        ]
                      ],
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