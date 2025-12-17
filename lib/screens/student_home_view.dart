import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth/auth_bloc.dart';
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Premium Header with Gradient
          Container(
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 40),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1E1E1E), Color(0xFF121212)], // Dark Gradient
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Hungry?",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFFFFC107), // Golden Yellow
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                        Text(
                          widget.userName,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                        icon: const Icon(Icons.logout, color: Color(0xFFFFC107)),
                        onPressed: () {
                          context.read<AuthBloc>().add(AuthLogoutRequested());
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 24),
      
                // Search Bar
                GestureDetector(
                  onTap: () => context.push('/search'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(27),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.search, color: Color(0xFFFFC107)), // Yellow Icon
                        SizedBox(width: 12),
                        Text(
                          "Find your craving...",
                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      
          const SizedBox(height: 24),
      
          // 2. Categories
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Explore Menu",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                // See All button if needed
                TextButton(
                    onPressed: (){}, 
                    child: const Text("See All", style: TextStyle(color: Color(0xFFFFC107)))
                )
              ],
            ),
          ),
          const SizedBox(height: 16),
      
          SizedBox(
            height: 130,
            child: FutureBuilder<List<MenuModel>>(
              future: _menusFuture,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator(color: Color(0xFFFFC107)));
                }
                if (snapshot.data!.isEmpty) {
                  return const Center(child: Text("No menu yet", style: TextStyle(color: Colors.white54)));
                }
      
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
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
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E1E), // Dark Card
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white10, width: 1),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFFC107).withOpacity(0.1),
                              ),
                              child: const Icon(
                                Icons.restaurant, 
                                size: 30,
                                color: Color(0xFFFFC107),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                menu.name,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
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
      
          const SizedBox(height: 32),
      
          // 3. Quick Actions Grid
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              "Your Dashboard",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          
          GridView.count(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 1.2,
            children: [
              _actionCard(
                context,
                "My Orders",
                Icons.receipt_long_rounded,
                const Color(0xFF4CAF50), // Green for Orders
                () => context.push('/orders'),
              ),
              _actionCard(
                context,
                "Profile",
                Icons.person_rounded,
                const Color(0xFFFFC107), // Yellow for Profile
                () => context.push('/my-profile-edit'),
              ),
              _actionCard(
                context,
                "Settings",
                Icons.settings_rounded,
                const Color(0xFFE0E0E0), // Grey
                () => context.push('/settings'),
              ),
              // Support or Help?
              _actionCard(
                context,
                 "Support",
                Icons.support_agent_rounded,
                const Color(0xFFE53935), // Red
                (){},
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
    
  }

  Widget _actionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color iconColor,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E), // Dark Card
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
               padding: const EdgeInsets.all(12),
               decoration: BoxDecoration(
                 color: iconColor.withOpacity(0.1),
                 shape: BoxShape.circle,
               ),
               child: Icon(icon, size: 28, color: iconColor),
            ),
            const SizedBox(height: 12),
            Text(
              title, 
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 15
              )
            ),
          ],
        ),
      ),
    );
  }
}
