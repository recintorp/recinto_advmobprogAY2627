import 'package:flutter/material.dart';
// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService();
  late Future<Map<String, dynamic>> _userDataFuture;

  @override
  void initState() {
    super.initState();
    _userDataFuture = _userService.getUserData();
  }

  // Refreshes the active user data
  void _refresh() {
    setState(() {
      _userDataFuture = _userService.getUserData();
    });
  }

  // Handles secure logout and redirects to sign in
  void _logout(Map<String, dynamic> user) async {
    if (user['loginType'] == 'firebase') {
      await _userService.signOut();
    } else {
      await _userService.logout();
    }
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
  }

  // Premium text field styling for dialogs
  InputDecoration _dialogInputDecoration(String label, bool isDark) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
      filled: true,
      fillColor: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  // Dialog for updating the username
  Future<void> _showUpdateUsernameDialog(Map<String, dynamic> user) async {
    final controller = TextEditingController(text: user['username']);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(
          child: Text('Update Username', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        ),
        content: TextField(
          controller: controller,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: _dialogInputDecoration('Username', isDark),
        ),
        actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context, controller.text.trim()),
                  child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (result == null || result.isEmpty) return;

    try {
      await _userService.updateUsername(username: result);
      _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Username updated.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update username: $e')));
    }
  }

  // Dialog for updating the user password securely
  Future<void> _showChangePasswordDialog(Map<String, dynamic> user) async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(
          child: Text('Change Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentController,
              obscureText: true,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: _dialogInputDecoration('Current Password', isDark),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newController,
              obscureText: true,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: _dialogInputDecoration('New Password', isDark),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Save', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed != true || currentController.text.isEmpty || newController.text.isEmpty) return;

    try {
      await _userService.resetPasswordFromCurrentPassword(
        currentPassword: currentController.text,
        newPassword: newController.text,
        email: user['email'],
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password updated.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update password: $e')));
    }
  }

  // Dialog to confirm account deletion
  Future<void> _showDeleteAccountDialog(Map<String, dynamic> user) async {
    final passwordController = TextEditingController();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(
          child: Text('Delete Account', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This cannot be undone. Enter your password to confirm.',
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: _dialogInputDecoration('Password', isDark),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey, fontSize: 16)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF3B30),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (confirmed != true || passwordController.text.isEmpty) return;

    try {
      await _userService.deleteAccount(
        email: user['email'],
        password: passwordController.text,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete account: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Minimalist colors
    final bgColor = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    // ignore: deprecated_member_use
    final subtitleColor = isDark ? const Color(0xFFEBEBF5).withOpacity(0.6) : const Color(0xFF3C3C43).withOpacity(0.6);
    final dividerColor = isDark ? const Color(0xFF38383A) : const Color(0xFFC6C6C8);
    
    // Accommodates the custom floating nav bar from HomeScreen
    final bottomNavOffset = MediaQuery.of(context).padding.bottom + 100.0;

    return Scaffold(
      backgroundColor: bgColor,
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.amber, strokeWidth: 2));
          } else if (snapshot.hasError) {
            return Center(child: Text('Something went wrong.', style: TextStyle(color: subtitleColor)));
          } else if (!snapshot.hasData || (snapshot.data!['email'] as String).isEmpty) {
            return Center(child: Text('No user data found.', style: TextStyle(color: subtitleColor)));
          }

          final user = snapshot.data!;
          final isFirebase = user['loginType'] == 'firebase';

          return SingleChildScrollView(
            padding: EdgeInsets.only(top: 40, bottom: bottomNavOffset),
            child: Column(
              children: [
                // Hero Avatar Section
                Column(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: cardColor,
                        image: (user['image'] as String).isNotEmpty
                            ? DecorationImage(image: NetworkImage(user['image']), fit: BoxFit.cover)
                            : null,
                      ),
                      child: (user['image'] as String).isEmpty
                          ? Icon(Icons.person, size: 48, color: subtitleColor)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '${user['firstName']} ${user['lastName']}',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5, color: textColor),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${user['username']} • ${isFirebase ? 'Firebase' : 'DummyJSON'}',
                      style: TextStyle(fontSize: 15, color: subtitleColor),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // User Information Section
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    children: [
                      _buildProfileItem(
                        icon: Icons.email_rounded,
                        iconColor: Colors.amber,
                        title: 'Email',
                        value: user['email'],
                        textColor: textColor,
                        subtitleColor: subtitleColor,
                      ),
                      Divider(height: 1, thickness: 0.5, color: dividerColor, indent: 52),
                      if (isFirebase) ...[
                        _buildProfileItem(
                          icon: Icons.cake_rounded,
                          iconColor: Colors.amber,
                          title: 'Age',
                          value: '${user['age']}',
                          textColor: textColor,
                          subtitleColor: subtitleColor,
                        ),
                        Divider(height: 1, thickness: 0.5, color: dividerColor, indent: 52),
                        _buildProfileItem(
                          icon: Icons.phone_rounded,
                          iconColor: Colors.amber,
                          title: 'Contact',
                          value: user['contactNo'],
                          textColor: textColor,
                          subtitleColor: subtitleColor,
                        ),
                      ] else ...[
                        _buildProfileItem(
                          icon: Icons.people_rounded,
                          iconColor: Colors.amber,
                          title: 'Gender',
                          value: user['gender'],
                          textColor: textColor,
                          subtitleColor: subtitleColor,
                        ),
                        Divider(height: 1, thickness: 0.5, color: dividerColor, indent: 52),
                        _buildProfileItem(
                          icon: Icons.badge_rounded,
                          iconColor: Colors.amber,
                          title: 'User ID',
                          value: '#${user['id']}',
                          textColor: textColor,
                          subtitleColor: subtitleColor,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                
                // Account Settings Section
                if (isFirebase)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      children: [
                        _buildActionItem(
                          icon: Icons.edit_rounded,
                          iconColor: const Color(0xFF007AFF),
                          title: 'Update Username',
                          textColor: textColor,
                          onTap: () => _showUpdateUsernameDialog(user),
                        ),
                        Divider(height: 1, thickness: 0.5, color: dividerColor, indent: 52),
                        _buildActionItem(
                          icon: Icons.lock_rounded,
                          iconColor: const Color(0xFF007AFF),
                          title: 'Change Password',
                          textColor: textColor,
                          onTap: () => _showChangePasswordDialog(user),
                        ),
                        Divider(height: 1, thickness: 0.5, color: dividerColor, indent: 52),
                        _buildActionItem(
                          icon: Icons.delete_rounded,
                          iconColor: const Color(0xFFFF3B30),
                          title: 'Delete Account',
                          textColor: const Color(0xFFFF3B30),
                          onTap: () => _showDeleteAccountDialog(user),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 32),

                // Destructive Log Out Action
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12.0),
                      onTap: () => _logout(user),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Text(
                            'Log Out',
                            style: TextStyle(
                              color: Color(0xFFFF3B30),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Reusable list item builder for displaying read-only profile info
  Widget _buildProfileItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required Color textColor,
    required Color subtitleColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, size: 22, color: iconColor),
          const SizedBox(width: 14),
          Text(title, style: TextStyle(fontSize: 16, color: textColor)),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 16, color: subtitleColor)),
        ],
      ),
    );
  }

  // Reusable list item builder for interactive settings
  Widget _buildActionItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
          child: Row(
            children: [
              Icon(icon, size: 22, color: iconColor),
              const SizedBox(width: 14),
              Text(title, style: TextStyle(fontSize: 16, color: textColor)),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded, size: 20, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}