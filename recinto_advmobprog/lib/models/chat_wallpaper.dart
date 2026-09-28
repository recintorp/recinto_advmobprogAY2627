import 'package:flutter/material.dart';

// A preset chat wallpaper. Only the [key] is saved in Firestore;
// the colors live here in the app, so no image files are needed.
class ChatWallpaper {
  final String key;
  final String name;

  // null means "no wallpaper" (use the normal app background).
  final List<Color>? colors;

  const ChatWallpaper({required this.key, required this.name, this.colors});

  static const List<ChatWallpaper> presets = [
    ChatWallpaper(key: 'default', name: 'Default'),
    ChatWallpaper(
      key: 'sky',
      name: 'Sky',
      colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
    ),
    ChatWallpaper(
      key: 'mint',
      name: 'Mint',
      colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
    ),
    ChatWallpaper(
      key: 'sunset',
      name: 'Sunset',
      colors: [Color(0xFFFFF3E0), Color(0xFFFFCCBC)],
    ),
    ChatWallpaper(
      key: 'lavender',
      name: 'Lavender',
      colors: [Color(0xFFEDE7F6), Color(0xFFD1C4E9)],
    ),
    ChatWallpaper(
      key: 'night',
      name: 'Night',
      colors: [Color(0xFF0F1226), Color(0xFF1B1F4B)],
    ),
  ];

  // Finds a preset by its saved key. Unknown or missing keys fall back to default.
  static ChatWallpaper byKey(String? key) {
    return presets.firstWhere(
      (w) => w.key == key,
      orElse: () => presets.first,
    );
  }

  bool get isDark => colors != null && colors!.first.computeLuminance() < 0.3;

  BoxDecoration? get decoration {
    if (colors == null) return null;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: colors!,
      ),
    );
  }
}