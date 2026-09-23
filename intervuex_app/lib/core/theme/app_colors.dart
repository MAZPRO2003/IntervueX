import 'package:flutter/material.dart';

/// Accent theme variants — controls primary/secondary accent colors only.
/// Dark/Light canvas (scaffold bg, surface) is controlled separately by ThemeMode.
enum AppThemeVariant {
  ocean,
  purple,
  emerald,
  sunset,
  rose,
  midnight,
}

extension AppThemeVariantExt on AppThemeVariant {
  String get displayName {
    switch (this) {
      case AppThemeVariant.ocean:
        return 'Ocean';
      case AppThemeVariant.purple:
        return 'Purple';
      case AppThemeVariant.emerald:
        return 'Emerald';
      case AppThemeVariant.sunset:
        return 'Sunset';
      case AppThemeVariant.rose:
        return 'Rose';
      case AppThemeVariant.midnight:
        return 'Midnight';
    }
  }

  String get prefKey {
    switch (this) {
      case AppThemeVariant.ocean:
        return 'ocean';
      case AppThemeVariant.purple:
        return 'purple';
      case AppThemeVariant.emerald:
        return 'emerald';
      case AppThemeVariant.sunset:
        return 'sunset';
      case AppThemeVariant.rose:
        return 'rose';
      case AppThemeVariant.midnight:
        return 'midnight';
    }
  }

  Color get primary {
    switch (this) {
      case AppThemeVariant.ocean:
        return const Color(0xFF0EA5E9);
      case AppThemeVariant.purple:
        return const Color(0xFF4F46E5);
      case AppThemeVariant.emerald:
        return const Color(0xFF10B981);
      case AppThemeVariant.sunset:
        return const Color(0xFFF97316);
      case AppThemeVariant.rose:
        return const Color(0xFFE11D48);
      case AppThemeVariant.midnight:
        return const Color(0xFF6366F1);
    }
  }

  Color get light {
    switch (this) {
      case AppThemeVariant.ocean:
        return const Color(0xFF38BDF8);
      case AppThemeVariant.purple:
        return const Color(0xFF818CF8);
      case AppThemeVariant.emerald:
        return const Color(0xFF34D399);
      case AppThemeVariant.sunset:
        return const Color(0xFFFB923C);
      case AppThemeVariant.rose:
        return const Color(0xFFFB7185);
      case AppThemeVariant.midnight:
        return const Color(0xFFA5B4FC);
    }
  }

  Color get gradientEnd {
    switch (this) {
      case AppThemeVariant.ocean:
        return const Color(0xFF0369A1);
      case AppThemeVariant.purple:
        return const Color(0xFF7C3AED);
      case AppThemeVariant.emerald:
        return const Color(0xFF059669);
      case AppThemeVariant.sunset:
        return const Color(0xFFEA580C);
      case AppThemeVariant.rose:
        return const Color(0xFF9F1239);
      case AppThemeVariant.midnight:
        return const Color(0xFF4338CA);
    }
  }

  LinearGradient get gradient {
    return LinearGradient(
      colors: [primary, gradientEnd],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  IconData get icon {
    switch (this) {
      case AppThemeVariant.ocean:
        return Icons.water_rounded;
      case AppThemeVariant.purple:
        return Icons.auto_awesome_rounded;
      case AppThemeVariant.emerald:
        return Icons.eco_rounded;
      case AppThemeVariant.sunset:
        return Icons.wb_sunny_rounded;
      case AppThemeVariant.rose:
        return Icons.local_florist_rounded;
      case AppThemeVariant.midnight:
        return Icons.nightlight_round;
    }
  }
}

class AppColors {
  // Canvas / Surface (theme-mode dependent)
  static const Color primaryDark = Color(0xFF0B0F19);
  static const Color surfaceDark = Color(0xFF131B2E);
  static const Color surfaceDarkElevated = Color(0xFF1E293B);

  static const Color primaryLight = Color(0xFFF8FAFC);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceLightElevated = Color(0xFFF1F5F9);

  // Default brand accent (Purple — matches legacy code)
  static const Color electricIndigo = Color(0xFF4F46E5);
  static const Color indigoLight = Color(0xFF818CF8);
  static const Color electricBlue = Color(0xFF2563EB);
  static const Color cyanAccent = Color(0xFF06B6D4);

  // Semantic status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Text
  static const Color textDarkPrimary = Color(0xFFF8FAFC);
  static const Color textDarkSecondary = Color(0xFF94A3B8);
  static const Color textDarkMuted = Color(0xFF64748B);

  static const Color textLightPrimary = Color(0xFF0F172A);
  static const Color textLightSecondary = Color(0xFF475569);
  static const Color textLightMuted = Color(0xFF94A3B8);

  // Legacy gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF151C2C), Color(0xFF0F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient heroCardGradient = LinearGradient(
    colors: [Color(0xFF1E1B4B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Dynamic Theme-Aware Helpers
  static LinearGradient dynamicPrimaryGradient(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final secondary = Theme.of(context).colorScheme.secondary;
    return LinearGradient(
      colors: [primary, secondary],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  static LinearGradient dynamicHeroGradient(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return LinearGradient(
      colors: isDark
          ? [primary.withOpacity(0.35), primaryDark]
          : [primary.withOpacity(0.12), primaryLight],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // Helper: get active accent colors from theme variant
  static Color accentPrimary(AppThemeVariant v) => v.primary;
  static Color accentLight(AppThemeVariant v) => v.light;
  static LinearGradient accentGradient(AppThemeVariant v) => v.gradient;
}

