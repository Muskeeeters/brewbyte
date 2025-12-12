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
      // Delay redirect to avoid build errors
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Redirect unauthorized users
        const SnackBar(content: Text('Unauthorized access.'));
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
          SnackBar(content: Text('Updated ${user.fullName} to $newRole')),
        );
        _loadProfiles(); // Refresh list to reflect changes
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update role: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine current user ID to prevent editing self-role if needed, 
    // or just to highlight.
    final currentUser = (context.read<AuthBloc>().state as AuthAuthenticated).user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Profiles'),
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
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No profiles found.'));
          }

          final users = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: users.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final user = users[index];
              final isSelf = user.id == currentUser.id;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isSelf 
                    ? Theme.of(context).primaryColor 
                    : Colors.grey.shade300,
                  foregroundColor: Colors.black,
                  child: Text(user.fullName[0].toUpperCase()),
                ),
                title: Text(
                  user.fullName + (isSelf ? ' (You)' : ''),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.email),
                    Text("Reg: ${user.regNumber}"),
                  ],
                ),
                trailing: DropdownButton<String>(
                  value: _validRoles.contains(user.role) ? user.role : null,
                  hint: Text(user.role),
                  onChanged: (newValue) {
                     // Confirm dialog could be good here, but for now direct update
                     _updateRole(user, newValue);
                  },
                  items: _validRoles.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value.toUpperCase(),
                        style: TextStyle(
                          color: value == 'manager' ? Colors.red : Colors.black,
                          fontWeight: value == 'manager' ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
