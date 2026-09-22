import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'login_page.dart';

class ProfilePage extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userRole;

  const ProfilePage({
    super.key,
    this.userName = 'User',
    this.userEmail = 'user@sahyog.com',
    this.userRole = 'Citizen',
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();

  bool isLoading = true;
  bool isLoggingOut = false;

  String userName = 'User';
  String userEmail = 'user@sahyog.com';
  String userRole = 'Citizen';

  @override
  void initState() {
    super.initState();

    // Temporary values are used immediately while
    // the real Supabase profile is being loaded.
    userName = widget.userName;
    userEmail = widget.userEmail;
    userRole = widget.userRole;

    _loadProfile();
  }

  // ============================================================
  // LOAD PROFILE FROM SUPABASE
  // ============================================================

  Future<void> _loadProfile() async {
    try {
      final profile = await _authService.getProfile();

      if (!mounted) return;

      setState(() {
        userName = (profile['full_name'] as String?)?.trim().isNotEmpty == true
            ? profile['full_name'] as String
            : widget.userName;

        userEmail = (profile['email'] as String?)?.trim().isNotEmpty == true
            ? profile['email'] as String
            : widget.userEmail;

        userRole = (profile['role'] as String?)?.trim().isNotEmpty == true
            ? _formatRole(profile['role'] as String)
            : widget.userRole;

        isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not load your profile from Supabase.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // FORMAT ROLE
  // ============================================================

  String _formatRole(String role) {
    switch (role.toLowerCase()) {
      case 'citizen':
        return 'Citizen';

      case 'university':
        return 'University';

      case 'industry':
        return 'Industry';

      case 'government':
        return 'Government';

      default:
        if (role.isEmpty) {
          return 'User';
        }

        return role[0].toUpperCase() + role.substring(1);
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================

  Future<void> _logout() async {
    if (isLoggingOut) return;

    setState(() {
      isLoggingOut = true;
    });

    try {
      await _authService.logout();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const LoginPage(),
        ),
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoggingOut = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Logout failed. Please try again.',
          ),
        ),
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),

      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,

        actions: [
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
            ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: _loadProfile,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // ==================================================
              // PROFILE IMAGE
              // ==================================================

              CircleAvatar(
                radius: 55,
                backgroundColor: const Color(0xFFE8F5E9),
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: Color(0xFF2E7D32),
                ),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // NAME
              // ==================================================

              Text(
                userName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              // ==================================================
              // ROLE
              // ==================================================

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  userRole,
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ==================================================
              // PROFILE INFORMATION
              // ==================================================

              _buildInfoCard(
                icon: Icons.person_outline,
                title: 'Name',
                value: userName,
              ),

              const SizedBox(height: 12),

              _buildInfoCard(
                icon: Icons.email_outlined,
                title: 'Email',
                value: userEmail,
              ),

              const SizedBox(height: 12),

              _buildInfoCard(
                icon: Icons.badge_outlined,
                title: 'Role',
                value: userRole,
              ),

              const SizedBox(height: 30),

              // ==================================================
              // EDIT PROFILE
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Edit Profile will be connected to Supabase next.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Profile'),
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // CHANGE PASSWORD
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Change Password will be connected next.',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.lock_outline),
                  label: const Text('Change Password'),
                ),
              ),

              const SizedBox(height: 12),

              // ==================================================
              // LOGOUT
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: isLoggingOut
                      ? null
                      : () {
                          _showLogoutDialog(context);
                        },
                  icon: isLoggingOut
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.logout),
                  label: Text(
                    isLoggingOut ? 'Logging out...' : 'Logout',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // INFORMATION CARD
  // ============================================================

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF2E7D32),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // LOGOUT CONFIRMATION
  // ============================================================

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text(
            'Are you sure you want to logout?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Cancel'),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _logout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }
}