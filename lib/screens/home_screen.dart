import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth/auth_bloc.dart';
import '../models/user_model.dart'; // Ensure we have access to Profile model
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

        // Student View (Unchanged Logic, just wrapped for safety)
        if (!isManager) {
          return Scaffold(
            body: SafeArea(child: StudentHomeView(userName: user.fullName)),
          );
        }

        // Manager Dashboard (New Visuals)
        return _ManagerDashboard(user: user);
      },
    );
  }
}

// -----------------------------------------------------------------------------
// NEW: Pulsing Loading Indicator (Yellow/Red Theme)
// -----------------------------------------------------------------------------
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
        child: div(
          child: Icon(
            Icons.local_cafe, // Cafe Icon
            size: 64,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }

  Widget div({required Widget child}) => Container(
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
    child: child,
  );
}

// -----------------------------------------------------------------------------
// NEW: Manager Dashboard with Animations
// -----------------------------------------------------------------------------
class _ManagerDashboard extends StatelessWidget {
  final UserModel user;

  const _ManagerDashboard({required this.user});

  @override
  Widget build(BuildContext context) {
    // Staggered delay base
    int delay = 0;
    const int step = 200;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Welcome Banner with Gradient
            _AnimatedSlideIn(
              delay: 0,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFFFC107), // Golden Yellow
                      Color(0xFFFF9800), // Orange
                      Color(0xFFE53935), // Food Red
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    // Profile Image with Hero
                    Hero(
                      tag: 'profile_${user.id}',
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                        ),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white,
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
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    )
                                  : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    // Greeting Text
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Welcome back,",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            user.fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "MANAGER ACCESS",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Logout Button (White Pill)
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: () {
                         context.read<AuthBloc>().add(AuthLogoutRequested());
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 30),

            // 2. Action Grid with Staggered Animation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _AnimatedSlideIn(
                    delay: step * 1,
                    child: const Text(
                      "QUICK ACTIONS",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Grid Custom Implementation
                  // We use Column -> Rows to control slide in easily per row or item
                  // Or just Wrap. Let's use a LayoutBuilder for flow or just simple Column of Rows for specific layout.
                  // Actually GridView inside Column needs shrinkWrap, which is fine here.
                  GridView.count(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1, // Slightly taller for icons
                    children: [
                      _AnimatedSlideIn(
                        delay: step * 2,
                        child: _DashboardCard(
                          title: 'Manage Menu',
                          subtitle: 'Items & Prices',
                          icon: Icons.restaurant_menu,
                          color: const Color(0xFFFFC107), // Yellow
                          onTap: () => context.push('/menu_list'),
                        ),
                      ),
                      _AnimatedSlideIn(
                        delay: step * 3,
                        child: _DashboardCard(
                          title: 'Orders',
                          subtitle: 'Incoming & Active',
                          icon: Icons.receipt_long,
                          color: const Color(0xFFE53935), // Red
                          onTap: () => context.push('/orders'),
                        ),
                      ),
                      _AnimatedSlideIn(
                        delay: step * 4,
                        child: _DashboardCard(
                          title: 'Profiles',
                          subtitle: 'Staff & Users',
                          icon: Icons.people,
                          color: Colors.black87,
                          onTap: () => context.push('/manage-profiles'),
                        ),
                      ),
                      _AnimatedSlideIn(
                        delay: step * 5,
                        child: _DashboardCard(
                          title: 'My Profile',
                          subtitle: 'Edit Details',
                          icon: Icons.person,
                          color: Colors.blueGrey,
                          onTap: () => context.push('/my-profile-edit'),
                        ),
                      ),
                      _AnimatedSlideIn(
                        delay: step * 6,
                        child: _DashboardCard(
                          title: 'Settings',
                          subtitle: 'App Config',
                          icon: Icons.settings,
                          color: Colors.grey,
                          onTap: () => context.push('/settings'),
                        ),
                      ),
                    ],
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

// -----------------------------------------------------------------------------
// Helper: Slide In Animation Wrapper
// -----------------------------------------------------------------------------
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
        // Only start moving after delay (simulated by value threshold or future)
        // TweenAnimationBuilder starts immediately. To allow staggered, we can use a FutureBuilder hack or just simple Translation offset.
        // Better approach for Staggered without complex controllers:
        // Use a stateful widget that starts animation after delay. 
        // But for simplicity in this visual revamp, we can use the `Tween` with a custom CurveInterval, 
        // OR just a simple separate Start Timer. 
        // Let's use a Future delay in a StatefulWidget wrapper.
        return _DelayedAnimation(delay: delay, child: child!);
      },
      child: child,
    );
  }
}

class _DelayedAnimation extends StatefulWidget {
  final Widget child;
  final int delay;
  const _DelayedAnimation({required this.child, required this.delay});

  @override
  State<_DelayedAnimation> createState() => _DelayedAnimationState();
}

class _DelayedAnimationState extends State<_DelayedAnimation> {
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) setState(() => _animate = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 600),
      opacity: _animate ? 1.0 : 0.0,
      curve: Curves.easeOut,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOutQuart,
        transform: Matrix4.translationValues(0, _animate ? 0 : 50, 0),
        child: widget.child,
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// NEW: Modern Dashboard Card
// -----------------------------------------------------------------------------
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const Spacer(),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
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
