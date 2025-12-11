import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import '../models/user_model.dart';
import '../bloc/auth/auth_bloc.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  UserModel? _userProfile;
  bool _isLoading = true;
  static final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  // Fetches the user's profile data from the 'profiles' table
  Future<void> _fetchProfile() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        // Not authenticated, redirect will occur via AuthGate/Bloc
        return;
      }

      final data = await supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      if (mounted) {
        setState(() {
          _userProfile = UserModel.fromJson(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Error fetching profile: $e', isError: true);
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _signOut() {
    context.read<AuthBloc>().add(AuthLogoutRequested());
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticated) {
          context.go('/login');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Management Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _signOut,
              tooltip: 'Sign Out',
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _userProfile == null
                ? const Center(child: Text('Profile data not found.'))
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, ${_userProfile!.fullName}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Text('Your Role: ${_userProfile!.role.toUpperCase()}',
                            style: TextStyle(
                                fontSize: 18,
                                color: _userProfile!.role == 'manager' ? Colors.red.shade700 : Colors.blue.shade700,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 32),
                        const Text('Your Profile Details:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                        const Divider(),
                        _buildDetailRow('User ID', _userProfile!.id),
                        _buildDetailRow('Email', _userProfile!.email),
                        _buildDetailRow('Phone Number', _userProfile!.phoneNumber),
                        _buildDetailRow('Registration Number', _userProfile!.regNumber),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
