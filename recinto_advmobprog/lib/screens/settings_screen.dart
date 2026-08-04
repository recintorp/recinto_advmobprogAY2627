import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _themeDuration = Duration(milliseconds: 300);
  static const _themeCurve = Curves.easeInOut;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDark;

    final baseTheme = isDark ? ThemeData.dark() : ThemeData.light();

    // Every color that changes between light and dark lives in this one object.
    // AnimatedTheme blends it as a single package, so nothing can drift out of sync.
    final themeData = baseTheme.copyWith(
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF121212) : const Color(0xFFF7F7F7),
      cardColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      dividerColor: isDark ? Colors.grey[800] : Colors.grey[200],
      appBarTheme: AppBarTheme(
        backgroundColor:
            isDark ? const Color(0xFF121212) : const Color(0xFFF7F7F7),
        elevation: 0,
        centerTitle: true,
      ),
      colorScheme: baseTheme.colorScheme.copyWith(
        primary: isDark ? Colors.white70 : Colors.blue,
        // The shadow just fades its own opacity instead of popping on/off.
        shadow: isDark
            ? Colors.black.withValues(alpha: 0)
            : Colors.black.withValues(alpha: 0.03),
      ),
    );

    return AnimatedTheme(
      duration: _themeDuration,
      curve: _themeCurve,
      data: themeData,
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(
              title: const Text('Settings'),
              elevation: 0,
              backgroundColor: theme.appBarTheme.backgroundColor,
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Account'),
                  _buildSettingsCard(
                    context: context,
                    children: [
                      _buildSettingsTile(
                        title: 'Rafael Alexis Recinto',
                        subtitle: 'Application Developer',
                        leadingWidget: CircleAvatar(
                          backgroundColor:
                              theme.colorScheme.primary.withValues(alpha: 0.2),
                          radius: 22,
                          child: Text(
                            'RP',
                            style: TextStyle(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        trailing: const Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.grey),
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader('App Settings'),
                  _buildSettingsCard(
                    context: context,
                    children: [
                      _buildSettingsTile(
                        title: 'Dark Mode',
                        subtitle: 'Smoothly toggle themes',
                        icon: Icons.dark_mode_outlined,
                        iconColor: Colors.deepPurple,
                        trailing: Switch.adaptive(
                          value: isDark,
                          onChanged: (_) => themeProvider.toggleTheme(),
                          activeThumbColor: Colors.blue,
                          activeTrackColor: Colors.blue.withValues(alpha: 0.5),
                        ),
                      ),
                      _buildCardDivider(context),
                      _buildSettingsTile(
                        title: 'Biometrics',
                        subtitle: 'Use FaceID/Fingerprint',
                        icon: Icons.fingerprint,
                        iconColor: Colors.teal,
                        trailing: const Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.grey),
                        onTap: () {},
                      ),
                      _buildCardDivider(context),
                      _buildSettingsTile(
                        title: 'Language',
                        subtitle: 'English (US)',
                        icon: Icons.language,
                        iconColor: Colors.amber[700],
                        trailing: const Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.grey),
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _buildSectionHeader('System'),
                  _buildSettingsCard(
                    context: context,
                    children: [
                      _buildSettingsTile(
                        title: 'Help & Support',
                        icon: Icons.help_outline,
                        iconColor: Colors.green,
                        trailing: const Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.grey),
                        onTap: () {},
                      ),
                      _buildCardDivider(context),
                      _buildSettingsTile(
                        title: 'About',
                        subtitle: 'Version 1.0.0 BETA',
                        icon: Icons.info_outline,
                        iconColor: Colors.orange,
                        trailing: const Icon(Icons.arrow_forward_ios,
                            size: 16, color: Colors.grey),
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 48),

                  Center(
                    child: TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text('Logout',
                          style: TextStyle(color: Colors.red, fontSize: 16)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        backgroundColor: isDark
                            ? Colors.red.withValues(alpha: 0.1)
                            : Colors.red.withValues(alpha: 0.05),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
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

  // A plain Container, not its own AnimatedContainer.
  // It just reads whatever color AnimatedTheme is showing right now, so it
  // always matches everything else on screen instead of animating separately.
  Widget _buildSettingsCard({
    required BuildContext context,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow,
            blurRadius: 10,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildCardDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      indent: 56,
      color: Theme.of(context).dividerColor,
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
    final leading = leadingWidget ??
        (icon != null ? _buildPremiumIcon(icon, iconColor ?? Colors.blue) : null);

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
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: color, size: 20),
    );
  }
}