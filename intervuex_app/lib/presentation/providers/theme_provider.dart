import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intervuex_app/core/theme/app_colors.dart';

const String _themePrefKey = 'user_theme_mode';
const String _accentPrefKey = 'user_accent_theme';

// ─── Theme Mode (dark / light / system) ──────────────────────────────────────

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
      } else {
        state = ThemeMode.dark;
      }
    } catch (_) {}
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

// ─── Accent Variant (6 color palettes) ───────────────────────────────────────

class ThemeVariantNotifier extends StateNotifier<AppThemeVariant> {
  ThemeVariantNotifier() : super(AppThemeVariant.purple) {
    _loadVariant();
  }

  Future<void> _loadVariant() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_accentPrefKey);
      if (saved != null) {
        final match = AppThemeVariant.values.firstWhere(
          (v) => v.prefKey == saved,
          orElse: () => AppThemeVariant.purple,
        );
        state = match;
      }
    } catch (_) {}
  }

  Future<void> setVariant(AppThemeVariant variant) async {
    state = variant;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accentPrefKey, variant.prefKey);
    } catch (_) {}
  }
}

final themeVariantProvider =
    StateNotifierProvider<ThemeVariantNotifier, AppThemeVariant>((ref) {
  return ThemeVariantNotifier();
});
