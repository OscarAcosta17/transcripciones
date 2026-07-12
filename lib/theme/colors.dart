import 'package:flutter/material.dart';

class AppColors {
  // Base Colors
  static const Color background = Color(0xFF0F172A);
  static const Color text = Color(0xFFF8FAFC);
  static const Color textMuted = Color(0xFF94A3B8);
  static const Color success = Color(0xFF10B981);
  static const Color danger = Color(0xFFEF4444);
  static const Color primary = Color(0xFF4361EE);
  static const Color glassBorder = Color(0x33FFFFFF);

  // Mesh Gradient Colors
  static const Color auroraCyan = Color(0xFF00F2FE);
  static const Color holographicPurple = Color(0xFF4FACFE);
  static const Color sunsetPink = Color(0xFFFA709A);

  // True Liquid Glass
  static const Color glassBackground = Color(0x0CFFFFFF); // ~5% opacity white
  static const Color glassBackgroundPressed = Color(0x26FFFFFF); // ~15% opacity white
  
  // Inner Border Highlight
  static const Gradient innerBorderLight = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x4DFFFFFF), // 30% white top-left
      Color(0x0DFFFFFF), // 5% white bottom-right
    ],
  );
}
