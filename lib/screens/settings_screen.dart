import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth/auth_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Color(0xFFFFC107))),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFFFFC107)),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader("Security"),
          _buildSettingItem(
            context,
            icon: Icons.lock_outline,
            title: "Change Password",
            onTap: () {
              context.push('/change_password'); 
            },
          ),
          
          const Divider(color: Colors.white10),

          _buildSectionHeader("General"),
          _buildSettingItem(
            context,
            icon: Icons.notifications_none,
            title: "Notifications",
            subtitle: "Coming Soon",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Coming Soon")));
            },
          ),

          _buildSettingItem(
            context,
            icon: Icons.dark_mode_outlined,
            title: "Appearance",
            subtitle: "Coming Soon",
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Coming Soon")));
            },
          ),

          const Divider(height: 40, color: Colors.white10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: OutlinedButton.icon(
              onPressed: () {
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
              icon: const Icon(Icons.logout, color: Color(0xFFE53935)),
              label: const Text("Logout", style: TextStyle(color: Color(0xFFE53935), fontWeight: FontWeight.bold)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFE53935)),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFFFFC107),
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSettingItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFFFC107).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: const Color(0xFFFFC107)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        subtitle: subtitle != null
            ? Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.white54))
            : null,
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.white24,
        ),
        onTap: onTap,
      ),
    );
  }
}
