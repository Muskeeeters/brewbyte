import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          const SizedBox(height: 10),

          // --- Section 1: Security ---
          _buildSectionHeader("Security"),

          // Yeh Button click hone par '/change_password' par le jayega
          _buildSettingItem(
            context,
            icon: Icons.lock_outline,
            title: "Change Password",
            onTap: () {
              context.push('/change_password'); // <-- Navigation Logic
            },
          ),

          const Divider(),

          // --- Section 2: General (Future ke liye) ---
          _buildSectionHeader("General"),

          _buildSettingItem(
            context,
            icon: Icons.notifications_none,
            title: "Notifications",
            subtitle: "Coming Soon",
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Coming Soon")));
            },
          ),

          _buildSettingItem(
            context,
            icon: Icons.dark_mode_outlined,
            title: "Appearance",
            subtitle: "Coming Soon",
            onTap: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text("Coming Soon")));
            },
          ),

          const Divider(height: 40),

          // --- Logout Button ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton.icon(
              onPressed: () {
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
              icon: const Icon(Icons.logout, color: Colors.red),
              label: const Text("Logout", style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Header Design (e.g., SECURITY)
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // List Item Design (e.g., Change Password >)
  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black87),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null
          ? Text(subtitle, style: const TextStyle(fontSize: 12))
          : null,
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
