import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/user_model.dart';
import '../bloc/auth/auth_bloc.dart';
import '../services/user_service.dart';

class ManageAllProfilesScreen extends StatefulWidget {
  const ManageAllProfilesScreen({super.key});

  @override
  State<ManageAllProfilesScreen> createState() => _ManageAllProfilesScreenState();
}

class _ManageAllProfilesScreenState extends State<ManageAllProfilesScreen> {
  late Future<List<UserModel>> _profilesFuture;
  final List<String> _validRoles = ['customer', 'manager', 'staff']; // Define roles as needed

  @override
  void initState() {
    super.initState();
    // RBAC Check: Security Guard
    final state = context.read<AuthBloc>().state;
    if (state is! AuthAuthenticated || state.user.role != 'manager') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        const SnackBar(content: Text('Unauthorized access.', style: TextStyle(color: Colors.white)));
        Navigator.of(context).pop(); 
      });
    }

    _loadProfiles();
  }

  void _loadProfiles() {
    setState(() {
      _profilesFuture = UserService.fetchAllProfiles();
    });
  }

  Future<void> _updateRole(UserModel user, String? newRole) async {
    if (newRole == null || newRole == user.role) return;

    try {
      await UserService.updateUserRole(user.id, newRole);
      
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Updated ${user.fullName} to $newRole'),
            backgroundColor: const Color(0xFFFFC107),
          ),
        );
        _loadProfiles(); 
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update role: $e'),
            backgroundColor: const Color(0xFFE53935),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine current user ID
    final currentUserState = context.read<AuthBloc>().state;
    final currentUser = (currentUserState is AuthAuthenticated) ? currentUserState.user : null;

    if (currentUser == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Profiles', style: TextStyle(color: Color(0xFFFFC107))),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Color(0xFFFFC107)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadProfiles,
          ),
        ],
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _profilesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFFFC107)));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No profiles found.', style: TextStyle(color: Colors.white54)));
          }

          final users = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final user = users[index];
              final isSelf = user.id == currentUser.id;

              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: isSelf ? const Color(0xFFFFC107) : Colors.white10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Hero(
                    tag: 'profile_${user.id}',
                    child: CircleAvatar(
                      backgroundColor: isSelf 
                        ? const Color(0xFFFFC107) 
                        : const Color(0xFF2C2C2C),
                      foregroundColor: isSelf ? Colors.black : Colors.white,
                      backgroundImage: (user.imageUrl != null && user.imageUrl!.isNotEmpty)
                          ? NetworkImage("${user.imageUrl!}?t=${DateTime.now().millisecondsSinceEpoch}")
                          : null,
                      child: (user.imageUrl == null || user.imageUrl!.isEmpty)
                         ? Text(user.fullName[0].toUpperCase())
                         : null,
                    ),
                  ),
                  title: Text(
                    user.fullName + (isSelf ? ' (You)' : ''),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelf ? const Color(0xFFFFC107) : Colors.white
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.email, style: const TextStyle(color: Colors.white54)),
                      Text("Reg: ${user.regNumber}", style: const TextStyle(color: Colors.white38, fontSize: 12)),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2C),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: DropdownButton<String>(
                      value: _validRoles.contains(user.role) ? user.role : null,
                      hint: Text(user.role, style: const TextStyle(color: Colors.white)),
                      dropdownColor: const Color(0xFF2C2C2C),
                      underline: const SizedBox(), // Remove underline
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFFC107)),
                      onChanged: (newValue) {
                         _updateRole(user, newValue);
                      },
                      items: _validRoles.map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value.toUpperCase(),
                            style: TextStyle(
                              color: value == 'manager' 
                                  ? const Color(0xFFFFC107) // Yellow for Manager role
                                  : Colors.white,
                              fontWeight: value == 'manager' ? FontWeight.bold : FontWeight.normal,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
