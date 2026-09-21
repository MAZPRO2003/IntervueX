import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String _themePrefKey = 'user_theme_mode';

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.dark) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themePrefKey);
      if (savedTheme == 'light') {
        state = ThemeMode.light;
      } else if (savedTheme == 'system') {
        state = ThemeMode.system;
      } else if (savedTheme == 'dark') {
        state = ThemeMode.dark;
      }
    } catch (_) {
      // Fallback to default dark mode if SharedPreferences fails
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (mode == ThemeMode.light) {
        await prefs.setString(_themePrefKey, 'light');
      } else if (mode == ThemeMode.system) {
        await prefs.setString(_themePrefKey, 'system');
      } else {
        await prefs.setString(_themePrefKey, 'dark');
      }
    } catch (_) {}
  }
}

final themeModeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});
