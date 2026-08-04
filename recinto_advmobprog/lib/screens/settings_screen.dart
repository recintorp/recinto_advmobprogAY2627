import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart'; 

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // This is to access the global theme model of the application.
    final themeProvider = Provider.of<ThemeProvider>(context);

    final isDark = themeProvider.isDark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final iconColor = isDark ? Colors.white70 : Colors.blue;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF7F7F7),
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF7F7F7),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Account'),
            _buildSettingsCard(
              cardColor: cardColor,
              children: [
                _buildSettingsTile(
                  title: 'Rafael Alexis Recinto',
                  subtitle: 'Application Developer',
                  leadingWidget: CircleAvatar(
                    // ignore: deprecated_member_use
                    backgroundColor: iconColor.withOpacity(0.2),
                    radius: 22,
                    child: Text('RP', style: TextStyle(color: iconColor, fontWeight: FontWeight.bold)),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('App Settings'),
            _buildSettingsCard(
              cardColor: cardColor,
              children: [
                // This is where the dark mode switch functionality applies.
                _buildSettingsTile(
                  title: 'Dark Mode',
                  subtitle: 'Smoothly toggle themes',
                  icon: Icons.dark_mode_outlined,
                  iconColor: Colors.deepPurple,
                  trailing: Switch.adaptive( 
                    value: isDark,
                    onChanged: (_) => themeProvider.toggleTheme(), 
                    // ignore: deprecated_member_use
                    activeColor: Colors.blue,
                  ),
                ),
                _buildCardDivider(isDark),
                _buildSettingsTile(
                  title: 'Biometrics',
                  subtitle: 'Use FaceID/Fingerprint',
                  icon: Icons.fingerprint,
                  iconColor: Colors.teal,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {},
                ),
                _buildCardDivider(isDark),
                _buildSettingsTile(
                  title: 'Language',
                  subtitle: 'English (US)',
                  icon: Icons.language,
                  iconColor: Colors.amber[700],
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionHeader('System'),
            _buildSettingsCard(
              cardColor: cardColor,
              children: [
                _buildSettingsTile(
                  title: 'Help & Support',
                  icon: Icons.help_outline,
                  iconColor: Colors.green,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {},
                ),
                _buildCardDivider(isDark),
                _buildSettingsTile(
                  title: 'About',
                  subtitle: 'Version 1.0.0 BETA',
                  icon: Icons.info_outline,
                  iconColor: Colors.orange,
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 48),

            Center(
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text('Logout', style: TextStyle(color: Colors.red, fontSize: 16)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  // ignore: deprecated_member_use
                  backgroundColor: isDark ? Colors.red.withOpacity(0.1) : Colors.red.withOpacity(0.05),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({required Color cardColor, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),

        boxShadow: [
          if (cardColor == Colors.white)
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              spreadRadius: 1,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildCardDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 56, 
      color: isDark ? Colors.grey[800] : Colors.grey[200],
    );
  }

  Widget _buildSettingsTile({
    required String title,
    String? subtitle,
    IconData? icon,
    Color? iconColor,
    required Widget trailing,
    Widget? leadingWidget,
    VoidCallback? onTap,
  }) {
    final leading = leadingWidget ?? (icon != null ? _buildPremiumIcon(icon, iconColor ?? Colors.blue) : null);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      leading: leading,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            )
          : null,
      trailing: trailing,
    );
  }

  Widget _buildPremiumIcon(IconData icon, Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}