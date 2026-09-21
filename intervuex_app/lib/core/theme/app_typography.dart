import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextTheme textTheme(bool isDark) {
    final primary = isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary;
    final secondary = isDark ? AppColors.textDarkSecondary : AppColors.textLightSecondary;
    final muted = isDark ? AppColors.textDarkMuted : AppColors.textLightMuted;

    return TextTheme(
      displayLarge: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.w800, color: primary, letterSpacing: -0.5),
      displayMedium: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.5),
      displaySmall: GoogleFonts.inter(fontSize: 22, fontWeight: FontWeight.w700, color: primary),
      
      headlineMedium: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w600, color: primary),
      headlineSmall: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600, color: primary),
      
      titleLarge: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: primary),
      titleMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500, color: primary),
      titleSmall: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: secondary),
      
      bodyLarge: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, color: primary, height: 1.45),
      bodyMedium: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w400, color: secondary, height: 1.4),
      bodySmall: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w400, color: muted),
      
      labelLarge: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: primary, letterSpacing: 0.2),
      labelMedium: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: secondary),
    );
  }
}
