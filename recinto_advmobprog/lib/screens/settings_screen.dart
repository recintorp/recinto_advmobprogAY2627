import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';
import '../services/user_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final UserService _userService = UserService();

  // Handles secure logout based on the active session type
  Future<void> _handleLogout() async {
    final user = await _userService.getUserData();
    if (user['loginType'] == 'firebase') {
      await _userService.signOut();
    } else {
      await _userService.logout();
    }
    
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/signin', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    // Premium Apple-inspired color palette
    final bgColor = isDark ? const Color(0xFF000000) : const Color(0xFFF2F2F7);
    final cardColor = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    // ignore: deprecated_member_use
    final subtitleColor = isDark ? const Color(0xFFEBEBF5).withOpacity(0.6) : const Color(0xFF3C3C43).withOpacity(0.6);
    final dividerColor = isDark ? const Color(0xFF38383A) : const Color(0xFFC6C6C8);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textColor),
        title: Text(
          'Settings',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preferences Group
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                children: [
                  _buildSettingItem(
                    title: 'Dark Mode',
                    icon: Icons.dark_mode_rounded,
                    iconBgColor: const Color(0xFF5856D6),
                    textColor: textColor,
                    trailing: Switch.adaptive(
                      value: isDark,
                      onChanged: (_) => themeProvider.toggleTheme(),
                      // ignore: deprecated_member_use
                      activeColor: const Color(0xFF34C759),
                    ),
                  ),
                  Divider(height: 1, thickness: 0.5, color: dividerColor, indent: 56),
                  _buildSettingItem(
                    title: 'Language',
                    icon: Icons.language_rounded,
                    iconBgColor: const Color(0xFF007AFF),
                    textColor: textColor,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('English', style: TextStyle(color: subtitleColor, fontSize: 16)),
                        const SizedBox(width: 8),
                        const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
                      ],
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Support Group
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Column(
                children: [
                  _buildSettingItem(
                    title: 'Help & Support',
                    icon: Icons.help_rounded,
                    iconBgColor: const Color(0xFF34C759),
                    textColor: textColor,
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
                    onTap: () {},
                  ),
                  Divider(height: 1, thickness: 0.5, color: dividerColor, indent: 56),
                  _buildSettingItem(
                    title: 'About',
                    icon: Icons.info_rounded,
                    iconBgColor: const Color(0xFF8E8E93),
                    textColor: textColor,
                    trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey, size: 20),
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 48),

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
                  onTap: _handleLogout,
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
      ),
    );
  }

  // Reusable list item builder for settings options
  Widget _buildSettingItem({
    required String title,
    required IconData icon,
    required Color iconBgColor,
    required Color textColor,
    required Widget trailing,
    VoidCallback? onTap,
  }) {
    final item = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 14),
          Text(
            title,
            style: TextStyle(fontSize: 16, color: textColor),
          ),
          const Spacer(),
          trailing,
        ],
      ),
    );

    if (onTap == null) return item;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: item,
      ),
    );
  }
}