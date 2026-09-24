import 'package:flutter/material.dart';

class AppColors {
  // Primary brand palette - White & Royal Blue Luxury Palette
  static const Color primaryDarkBlue = Color(0xFF0F172A); // Deep Navy Slate
  static const Color secondaryDarkBlue = Color(0xFF1E3A8A); // Deep Royal Navy
  static const Color cardDarkBlue = Color(0xFF1E293B); // Slate 800
  static const Color accentBlue = Color(0xFF2563EB); // Vibrant Royal Blue
  static const Color accentBlueDark = Color(0xFF1D4ED8); // Deep Sapphire Blue
  static const Color blueLight = Color(0xFFEFF6FF); // Soft Ice Blue tint
  static const Color blueMedium = Color(0xFFDBEAFE); // Azure Border tint

  // Harmonized to Royal Blue for White & Blue Theme
  static const Color accentOrange = Color(0xFF2563EB); // Royal Blue accent
  static const Color orangeLight = Color(0xFFEFF6FF); // Ice Blue surface tint

  // Background and cards
  static const Color backgroundLight = Color(0xFFF8FAFC); // Clean crisp Slate 50
  static const Color surfaceLight = Color(0xFFF0F7FF); // Clean Azure-tinted surface
  static const Color cardWhite = Colors.white;
  static const Color borderLight = Color(0xFFE2E8F0); // Crisp Slate 200
  static const Color borderSubtle = Color(0xFFF1F5F9); // Soft Slate 100
  static const Color borderBlue = Color(0xFFBFDBFE); // Soft Blue Border
  static const Color borderDark = Color(0x22FFFFFF);

  // Functional Status Accents
  static const Color accentGreen = Color(0xFF10B981); // Emerald 500 (عمل)
  static const Color greenDark = Color(0xFF047857);
  static const Color greenLight = Color(0xFFECFDF5);

  static const Color accentRed = Color(0xFFEF4444); // Rose/Red 500 (غياب)
  static const Color redLight = Color(0xFFFEF2F2);

  static const Color accentAmber = Color(0xFFF59E0B); // Amber 500 (راحة)
  static const Color amberDark = Color(0xFFB45309);
  static const Color amberLight = Color(0xFFFFFBEB);

  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color purpleLight = Color(0xFFF5F3FF);

  // Typography
  static const Color textPrimary = Color(0xFF0F172A); // Deep Navy Text
  static const Color textSecondary = Color(0xFF475569); // Slate Text
  static const Color textMuted = Color(0xFF94A3B8); // Muted Text
  static const Color textBlue = Color(0xFF1E40AF); // Royal Blue Text
  static const Color textWhite = Colors.white;

  // Gradients for Modern Depth & Smooth Visuals (White & Royal Blue)
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E40AF)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient orangeGradient = LinearGradient(
    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)], // Pure Royal Blue
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient blueGradient = LinearGradient(
    colors: [Color(0xFF60A5FA), Color(0xFF1D4ED8)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  static const LinearGradient cardHeaderGradient = LinearGradient(
    colors: [Color(0xFF1E40AF), Color(0xFF2563EB)],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );

  // Soft modern box shadows
  static List<BoxShadow> get softShadow => [
        const BoxShadow(
          color: Color(0x0A1E40AF),
          offset: Offset(0, 4),
          blurRadius: 16,
          spreadRadius: 0,
        ),
        const BoxShadow(
          color: Color(0x060F172A),
          offset: Offset(0, 1),
          blurRadius: 4,
          spreadRadius: 0,
        ),
      ];

  static List<BoxShadow> get cardElevation => [
        const BoxShadow(
          color: Color(0x0F1E40AF),
          offset: Offset(0, 6),
          blurRadius: 20,
          spreadRadius: -2,
        ),
        const BoxShadow(
          color: Color(0x060F172A),
          offset: Offset(0, 2),
          blurRadius: 6,
          spreadRadius: 0,
        ),
      ];
}
