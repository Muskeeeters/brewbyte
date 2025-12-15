import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth/auth_bloc.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ⭐ CHANGE: BlocBuilder lagaya hai taake update sun sake
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        // Agar user login nahi hai ya data load ho raha hai
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = state.user;
        final isManager = user.role == 'manager';

        return Scaffold(
          appBar: AppBar(
            title: const Text('BrewByte Dashboard'),
            actions: [
              IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  context.read<AuthBloc>().add(AuthLogoutRequested());
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 2. Greeting Section (User Info + PICTURE)
                Container(
                  padding: const EdgeInsets.all(24),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // --- PROFILE PICTURE ---
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 30, // Size
                          backgroundColor: Colors.white.withOpacity(0.3),
                          // Logic: Agar Image URL hai to wo dikhao, warna Initials
                          backgroundImage:
                              (user.imageUrl != null &&
                                  user.imageUrl!.isNotEmpty)
                              ? NetworkImage(user.imageUrl!)
                              : null,
                          child:
                              (user.imageUrl == null || user.imageUrl!.isEmpty)
                              ? Text(
                                  user.fullName.isNotEmpty
                                      ? user.fullName[0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                )
                              : null,
                        ),
                      ),

                      const SizedBox(width: 16), // Gap
                      // Name and Role
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${user.fullName}!',
                              style: Theme.of(context).textTheme.headlineSmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    fontSize: 20,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your Role: ${user.role}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // 3. Dashboard Grid
                Text(
                  'Quick Actions',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: [
                    // --- ITEM 1: Menu ---
                    _DashboardCard(
                      title: isManager ? 'Manage Menu' : 'View Menu',
                      icon: Icons.restaurant_menu,
                      onTap: () {
                        context.push('/menu_list');
                      },
                    ),

                    // --- ITEM 2: Place Order ---
                    _DashboardCard(
                      title: 'Place Order',
                      icon: Icons.add_shopping_cart,
                      onTap: () {
                        context.push('/create_order');
                      },
                    ),

                    // --- ITEM 3: Order History ---
                    _DashboardCard(
                      title: 'Order History',
                      icon: Icons.receipt_long,
                      onTap: () {
                        context.push('/orders');
                      },
                    ),

                    // --- ITEM 4: My Profile ---
                    _DashboardCard(
                      title: 'My Profile',
                      icon: Icons.person,
                      onTap: () {
                        context.push('/my-profile-edit');
                      },
                    ),

                    // --- ITEM 5: Manage Profiles (Manager Only) ---
                    if (isManager)
                      _DashboardCard(
                        title: 'Manage Profiles',
                        icon: Icons.manage_accounts,
                        onTap: () {
                          context.push('/manage-profiles');
                        },
                      ),

                    // --- ITEM 6: Settings ---
                    _DashboardCard(
                      title: 'Settings',
                      icon: Icons.settings,
                      onTap: () {
                        context.push(
                          '/settings',
                        ); // <-- Ab ye Settings screen kholega
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: Theme.of(context).primaryColor),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
