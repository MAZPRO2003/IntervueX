import 'package:flutter/material.dart';

class AppColors {
  // Brand Primary & Accents
  static const Color primaryDark = Color(0xFF0B0F19);    // Deep near-black navy
  static const Color surfaceDark = Color(0xFF131B2E);    // Card surface
  static const Color surfaceDarkElevated = Color(0xFF1E293B); // Elevated modal/cards
  
  static const Color primaryLight = Color(0xFFF8FAFC);   // Off-white canvas
  static const Color surfaceLight = Color(0xFFFFFFFF);   // Pure white surface
  static const Color surfaceLightElevated = Color(0xFFF1F5F9);

  // Vibrant Accents
  static const Color electricIndigo = Color(0xFF4F46E5); // Hero brand color
  static const Color indigoLight = Color(0xFF818CF8);    // Soft violet
  static const Color electricBlue = Color(0xFF2563EB);   // Accent blue
  static const Color cyanAccent = Color(0xFF06B6D4);     // Tech highlight

  // Semantic Status Colors
  static const Color success = Color(0xFF10B981);        // Verified green
  static const Color warning = Color(0xFFF59E0B);        // Caution amber
  static const Color danger = Color(0xFFEF4444);         // Risk coral
  static const Color info = Color(0xFF3B82F6);           // Info blue

  // Text Colors
  static const Color textDarkPrimary = Color(0xFFF8FAFC);
  static const Color textDarkSecondary = Color(0xFF94A3B8);
  static const Color textDarkMuted = Color(0xFF64748B);

  static const Color textLightPrimary = Color(0xFF0F172A);
  static const Color textLightSecondary = Color(0xFF475569);
  static const Color textLightMuted = Color(0xFF94A3B8);

  // Gradients
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
}
