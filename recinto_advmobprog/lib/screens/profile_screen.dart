import 'package:flutter/material.dart';
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

  // Clears user data from storage and redirects to the sign-in screen.
  void _logout() async {
    await _userService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic theme variables for Dark/Light mode support
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF000000) : const Color(0xFFF5F7FA);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.grey.shade500;
    final shadowColor = isDark ? Colors.transparent : Colors.black.withValues(alpha: 0.04);
    final dividerColor = isDark ? Colors.white24 : Colors.grey.shade200;
    final avatarBgColor = isDark ? Colors.grey.shade800 : Colors.grey.shade200;

    return Scaffold(
      backgroundColor: bgColor,
      // Fetches and displays the saved user data from local storage.
      body: FutureBuilder<Map<String, dynamic>>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: textColor)));
          } else if (!snapshot.hasData || snapshot.data!['id'] == 0) {
            return Center(child: Text('No user data found. Please log in again.', style: TextStyle(color: textColor)));
          }

          final user = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.only(top: 24.0, left: 16.0, right: 16.0, bottom: 16.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: avatarBgColor,
                        backgroundImage: user['image'] != '' ? NetworkImage(user['image']) : null,
                        child: user['image'] == '' ? Icon(Icons.person, size: 40, color: subtitleColor) : null,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${user['firstName']} ${user['lastName']}',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '@${user['username']}',
                        style: TextStyle(fontSize: 14, color: subtitleColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: shadowColor,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.email_outlined, color: Colors.amber),
                        title: const Text('Email', style: TextStyle(fontSize: 13, color: Colors.grey)),
                        subtitle: Text(user['email'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                      ),
                      Divider(height: 1, color: dividerColor),
                      ListTile(
                        leading: const Icon(Icons.people_outline, color: Colors.amber),
                        title: const Text('Gender', style: TextStyle(fontSize: 13, color: Colors.grey)),
                        subtitle: Text(user['gender'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                      ),
                      Divider(height: 1, color: dividerColor),
                      ListTile(
                        leading: const Icon(Icons.badge_outlined, color: Colors.amber),
                        title: const Text('User ID', style: TextStyle(fontSize: 13, color: Colors.grey)),
                        subtitle: Text('#${user['id']}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrangeAccent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                    ),
                    onPressed: _logout,
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text('Log Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}