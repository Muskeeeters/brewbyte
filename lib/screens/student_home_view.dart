import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // ✅ Import Added
import 'package:go_router/go_router.dart';
import '../bloc/auth/auth_bloc.dart'; // ✅ Import Added
import '../services/menu_service.dart';
import '../models/menu_model.dart';

class StudentHomeView extends StatefulWidget {
  final String userName;
  const StudentHomeView({super.key, required this.userName});

  @override
  State<StudentHomeView> createState() => _StudentHomeViewState();
}

class _StudentHomeViewState extends State<StudentHomeView> {
  final MenuService _menuService = MenuService();
  late Future<List<MenuModel>> _menusFuture;

  @override
  void initState() {
    super.initState();
    _menusFuture = _menuService.getMenus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Stylish Header (Updated with Logout)
        Container(
          padding: const EdgeInsets.fromLTRB(
            24,
            40,
            24,
            24,
          ), // Top padding for status bar
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // ⭐ Row: Greeting + Logout Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Text Column
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hungry, ${widget.userName}?",
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "What do you want to eat?",
                          style: TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),

                  // Logout Icon Button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.logout, color: Colors.black87),
                      onPressed: () {
                        // Logout Action
                        context.read<AuthBloc>().add(AuthLogoutRequested());
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Search Bar (Clickable)
              GestureDetector(
                onTap: () {
                  context.push('/search');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 10),
                      Text(
                        "Search for food...",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // 2. Categories (Horizontal)
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Categories",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 12),

        SizedBox(
          height: 110,
          child: FutureBuilder<List<MenuModel>>(
            future: _menusFuture,
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return const Center(child: CircularProgressIndicator());
              if (snapshot.data!.isEmpty)
                return const Center(child: Text("No menu yet"));

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final menu = snapshot.data![index];
                  return GestureDetector(
                    onTap: () {
                      context.push(
                        '/menu_items',
                        extra: {'menuId': menu.id, 'menuName': menu.name},
                      );
                    },
                    child: Container(
                      width: 100,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 5,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.fastfood,
                            size: 36,
                            color: Colors.orange,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            menu.name,
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),

        const SizedBox(height: 24),

        // 3. Quick Actions
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            "Quick Access",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: GridView.count(
            padding: const EdgeInsets.all(20),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _actionCard(
                context,
                "My Orders",
                Icons.receipt_long,
                Colors.blue,
                () => context.push('/orders'),
              ),
              _actionCard(
                context,
                "Profile",
                Icons.person,
                Colors.purple,
                () => context.push('/my-profile-edit'),
              ),
              _actionCard(
                context,
                "Settings",
                Icons.settings,
                Colors.grey,
                () => context.push('/settings'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _actionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
