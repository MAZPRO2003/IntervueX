import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.primaryDark,
      primaryColor: AppColors.electricIndigo,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.electricIndigo,
        secondary: AppColors.indigoLight,
        surface: AppColors.surfaceDark,
        background: AppColors.primaryDark,
        error: AppColors.danger,
        onPrimary: Colors.white,
        onSurface: AppColors.textDarkPrimary,
      ),
      textTheme: AppTypography.textTheme(true),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryDark,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.textDarkPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF1E293B), width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF0F172A),
        indicatorColor: AppColors.electricIndigo.withOpacity(0.25),
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textDarkSecondary),
        ),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: AppColors.indigoLight);
          }
          return const IconThemeData(color: AppColors.textDarkMuted);
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.electricIndigo,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDark,
        hintStyle: const TextStyle(color: AppColors.textDarkMuted, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF334155)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.electricIndigo, width: 1.5),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.primaryLight,
      primaryColor: AppColors.electricIndigo,
      colorScheme: const ColorScheme.light(
        primary: AppColors.electricIndigo,
        secondary: AppColors.electricBlue,
        surface: AppColors.surfaceLight,
        background: AppColors.primaryLight,
        error: AppColors.danger,
        onPrimary: Colors.white,
        onSurface: AppColors.textLightPrimary,
      ),
      textTheme: AppTypography.textTheme(false),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryLight,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: AppColors.textLightPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: AppColors.electricIndigo.withOpacity(0.12),
        labelTextStyle: MaterialStateProperty.all(
          const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textLightSecondary),
        ),
        iconTheme: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return const IconThemeData(color: AppColors.electricIndigo);
          }
          return const IconThemeData(color: AppColors.textLightMuted);
        }),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.electricIndigo,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        hintStyle: const TextStyle(color: AppColors.textLightMuted, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.electricIndigo, width: 1.5),
        ),
      ),
    );
  }
}
