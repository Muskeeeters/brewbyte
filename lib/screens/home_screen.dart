import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth/auth_bloc.dart';
import '../models/user_model.dart';
import 'student_home_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: _PulsingLoadingIndicator(),
          );
        }

        final user = state.user;
        final isManager = user.role == 'manager';

        if (!isManager) {
          return Scaffold(
            body: SafeArea(child: StudentHomeView(
              userName: user.fullName,
              imageUrl: user.imageUrl,
            )),
          );
        }

        return _ManagerDashboard(user: user);
      },
    );
  }
}

class _PulsingLoadingIndicator extends StatefulWidget {
  const _PulsingLoadingIndicator();

  @override
  State<_PulsingLoadingIndicator> createState() => _PulsingLoadingIndicatorState();
}

class _PulsingLoadingIndicatorState extends State<_PulsingLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ScaleTransition(
        scale: _animation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).primaryColor.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 5,
              )
            ],
          ),
          child: Icon(
            Icons.local_cafe,
            size: 64,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}

class _ManagerDashboard extends StatelessWidget {
  final UserModel user;

  const _ManagerDashboard({required this.user});

  @override
  Widget build(BuildContext context) {
    int delay = 0;
    const int step = 200;

    return Scaffold(
      backgroundColor: const Color(0xFF121212), // Deep Black
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. RESTRUCTURED HEADER
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
                    // Top Row: Role Badge & Logout
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE53935).withOpacity(0.2), // Red Tint
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFFE53935), width: 1),
                            ),
                            child: const Text(
                              "MANAGER",
                              style: TextStyle(
                                color: Color(0xFFE53935),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.logout, color: Colors.white70),
                            onPressed: () {
                              context.read<AuthBloc>().add(AuthLogoutRequested());
                            },
                          ),
                        ],
                      ),
                    ),

                    // Middle: Avatar
                    Hero(
                      tag: 'profile_${user.id}',
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFFFC107), width: 2), // Golden Border
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFFC107).withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: const Color(0xFF2C2C2C),
                          backgroundImage: (user.imageUrl != null && user.imageUrl!.isNotEmpty)
                              ? NetworkImage(user.imageUrl!)
                              : null,
                          child: (user.imageUrl == null || user.imageUrl!.isEmpty)
                              ? Text(
                                  user.fullName.isNotEmpty ? user.fullName[0].toUpperCase() : '?',
                                  style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Bottom: Greeting
                    _AnimatedSlideIn(
                      delay: 0,
                      child: Column(
                        children: [
                          const Text(
                            "Ready to manage,", // Manager specific greeting
                            style: TextStyle(
                              color: Color(0xFFFFC107), // Golden
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),

            // 2. Action Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.0,
                children: [
                  _AnimatedSlideIn(
                    delay: step * 1,
                    child: _DashboardCard(
                      title: 'Manage Menu',
                      subtitle: 'Update Items',
                      icon: Icons.restaurant_menu,
                      color: const Color(0xFFFFC107), 
                      onTap: () => context.push('/menu_list'),
                    ),
                  ),
                  _AnimatedSlideIn(
                    delay: step * 2,
                    child: _DashboardCard(
                      title: 'Orders',
                      subtitle: 'Track Status',
                      icon: Icons.receipt_long,
                      color: const Color(0xFFE53935),
                      onTap: () => context.push('/orders'),
                    ),
                  ),
                  _AnimatedSlideIn(
                    delay: step * 3,
                    child: _DashboardCard(
                      title: 'Profiles',
                      subtitle: 'Manage Users',
                      icon: Icons.people,
                      color: Colors.blue,
                      onTap: () => context.push('/manage-profiles'),
                    ),
                  ),
                  _AnimatedSlideIn(
                    delay: step * 4,
                    child: _DashboardCard(
                      title: 'My Profile',
                      subtitle: 'Edit Details',
                      icon: Icons.person,
                      color: Colors.white,
                      onTap: () => context.push('/my-profile-edit'),
                    ),
                  ),
                ],
              ),
            ),
             const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _AnimatedSlideIn extends StatelessWidget {
  final Widget child;
  final int delay;

  const _AnimatedSlideIn({required this.child, required this.delay});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutQuart,
      builder: (context, value, child) {
        return Transform.translate(
           offset: Offset(0, 50 * (1 - value)), // Slide up
           child: Opacity(
             opacity: value,
             child: child,
           ),
        );
      },
      child: child,
    );
  }
}

class _DashboardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Dark Card
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(color: color.withOpacity(0.2), width: 1),
                  ),
                  child: Icon(icon, color: color, size: 36),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
