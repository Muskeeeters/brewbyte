import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth/auth_bloc.dart';
import 'student_home_view.dart'; // ✅ Import New View

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = state.user;
        final isManager = user.role == 'manager';

        // ⭐ IF STUDENT: Show New Cafe View
        if (!isManager) {
          return Scaffold(
            // Note: Student view has its own custom header, so no AppBar here
            body: SafeArea(child: StudentHomeView(userName: user.fullName)),
          );
        }

        // ⭐ IF MANAGER: Show Old Dashboard
        return Scaffold(
          appBar: AppBar(
            title: const Text('Manager Dashboard'),
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
                // Greeting Section (Same as before)
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
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white.withOpacity(0.3),
                          // ✅ Cache Buster Trick Added
                          backgroundImage:
                              (user.imageUrl != null &&
                                  user.imageUrl!.isNotEmpty)
                              ? NetworkImage(
                                  "${user.imageUrl!}?t=${DateTime.now().millisecondsSinceEpoch}",
                                )
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
                      const SizedBox(width: 16),
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
                              'Role: Manager',
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

                // Manager Options
                Text(
                  'Admin Actions',
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
                    _DashboardCard(
                      title: 'Manage Menu',
                      icon: Icons.restaurant_menu,
                      onTap: () => context.push('/menu_list'),
                    ),
                    _DashboardCard(
                      title: 'Manage Orders',
                      icon: Icons.assignment_turned_in,
                      onTap: () => context.push('/orders'),
                    ),
                    _DashboardCard(
                      title: 'Manage Profiles',
                      icon: Icons.manage_accounts,
                      onTap: () => context.push('/manage-profiles'),
                    ),
                    _DashboardCard(
                      title: 'My Profile',
                      icon: Icons.person,
                      onTap: () => context.push('/my-profile-edit'),
                    ),
                    _DashboardCard(
                      title: 'Settings',
                      icon: Icons.settings,
                      onTap: () => context.push('/settings'),
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
