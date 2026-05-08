import 'package:flutter/material.dart';

/// App color palette based on the original HTML/CSS design
class AppColors {
  AppColors._();

  // Primary Background Colors
  static const Color backgroundTop = Color(0xFFC7CAEF);
  static const Color backgroundMiddle = Color(0xFF101347);
  static const Color backgroundBottom = Color(0xFF080C42);

  // Primary Colors
  static const Color primary = Color(0xFF6b8cff);
  static const Color primaryLight = Color(0xFFc0c0e0);
  static const Color primaryDark = Color(0xFF1a1a4a);

  // Secondary Colors
  static const Color secondary = Color(0xFFa0a0c0);
  static const Color accent = Color(0xFF8b8bff);

  // Status Colors
  static const Color success = Color(0xFF4caf50);
  static const Color warning = Color(0xFFff9800);
  static const Color error = Color(0xFF1a1a4a);
  static const Color info = Color(0xFF2196F3);

  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFFd0d0e0);
  static const Color textMuted = Color(0xFFb0b0d0);
  static const Color textDark = Color(0xFF1a1a4a);

  // Card & Surface Colors
  static const Color cardBackground = Color(0x1AFFFFFF); // 10% white
  static const Color surfaceLight = Color(0x33FFFFFF); // 20% white
  static const Color surfaceDark = Color(0xFF1e1e3c);

  // Border Colors
  static const Color borderLight = Color(0x1AFFFFFF);
  static const Color borderDark = Color(0xFF3a3a5a);

  // Gradient Colors for Buttons
  static const LinearGradient primaryButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primaryLight, secondary],
  );

  // Splash Gradient
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.9997, 0.9998, 0.9999],
    colors: [
      Color(0xFFC7CAEF),
      Color(0xFF101347),
      Color(0xFF353539),
      Color(0xFF080C42),
    ],
  );

  // Background Gradient (all screens)
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.8846, 1.0],
    colors: [
      Color(0xFF262948),
      Color(0xFF3F426E),
      Color(0xFF545890),
    ],
  );

  // App Gradient (all other screens)
  static const LinearGradient appGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    stops: [0.0, 0.8846, 1.0],
    colors: [
      Color(0xFF262948),
      Color(0xFF3F426E),
      Color(0xFF545890),
    ],
  );

  // Toggle Colors
  static const Color toggleActive = success;
  static const Color toggleInactive = Color(0xFF666666);

  // Rating Color
  static const Color rating = Color(0xFFffd700);

  // Map Colors
  static const Color mapMarker = primary;
}
