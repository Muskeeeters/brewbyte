import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth/auth_bloc.dart';
import '../services/menu_service.dart';
import '../models/menu_model.dart';
import '../widgets/cart_icon_badge.dart'; // Fixed Import

class StudentHomeView extends StatefulWidget {
  final String userName;
  final String? imageUrl;
  const StudentHomeView({super.key, required this.userName, this.imageUrl});

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
          // 1. RESTRUCTURED HEADER (Role -> Avatar -> Greeting)
          Container(
            padding: const EdgeInsets.only(bottom: 40),
            decoration: const BoxDecoration(
              color: Color(0xFF1E1E1E), // Dark Header BG
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  // Top Row: Role Badge (Left) & Logout (Right)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFC107).withOpacity(0.2), // Yellow Tint for Student
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFFC107), width: 1),
                          ),
                          child: const Text(
                            "STUDENT",
                            style: TextStyle(
                              color: Color(0xFFFFC107),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),

                        Row(
                          children: [
                            const CartIconBadge(color: Colors.white70), // Add Cart Icon
                            IconButton(
                              icon: const Icon(Icons.logout, color: Colors.white70),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: const Color(0xFF1E1E1E),
                                    title: const Text(
                                      "Logout?", 
                                      style: TextStyle(color: Color(0xFFFFC107))
                                    ),
                                    content: const Text(
                                      "Are you sure you want to log out?",
                                      style: TextStyle(color: Colors.white70)
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Cancel"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          context.read<AuthBloc>().add(AuthLogoutRequested());
                                        },
                                        child: const Text(
                                          "Logout", 
                                          style: TextStyle(color: Color(0xFFE53935))
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Middle: Avatar (Placeholder logic if no image provided in props, assuming generic for now as props only have name)
                  // Ideally StudentHomeView should take full User object or we fetch it. 
                  // For now, we use a generic styled avatar to match the design.
                  Hero(
                    tag: 'profile_student', // Generic tag since we don't have ID passed here easily without prop change
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFE53935), width: 2), // Red Accent
                        boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFE53935).withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
                          ],
                      ),
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFF2C2C2C),
                        backgroundImage: (widget.imageUrl != null && widget.imageUrl!.isNotEmpty)
                            ? NetworkImage(widget.imageUrl!)
                            : null,
                        child: (widget.imageUrl == null || widget.imageUrl!.isEmpty) 
                            ? Text(
                                widget.userName.isNotEmpty ? widget.userName[0].toUpperCase() : '?',
                                style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Bottom: Greeting
                  Column(
                    children: [
                      const Text(
                        "Hungry,", 
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${widget.userName}?",
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

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
                TextButton(
                    onPressed: (){
                      // Could navigate to full menu list if different View
                      context.push('/menu_list');
                    }, 
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
          boxShadow: [
             BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
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
