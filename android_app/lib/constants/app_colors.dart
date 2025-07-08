import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primary = Color(0xFF2E7D32);
  static const Color primaryLight = Color(0xFF60AD5E);
  static const Color primaryDark = Color(0xFF005005);
  
  // Secondary colors
  static const Color secondary = Color(0xFF1976D2);
  static const Color secondaryLight = Color(0xFF63A4FF);
  static const Color secondaryDark = Color(0xFF004BA0);
  
  // Emergency colors
  static const Color emergency = Color(0xFFD32F2F);
  static const Color emergencyLight = Color(0xFFFF6659);
  static const Color emergencyDark = Color(0xFF9A0007);
  
  // Medical colors
  static const Color medicalPrimary = Color(0xFF1976D2);
  static const Color medicalSecondary = Color(0xFF42A5F5);
  static const Color medicalAccent = Color(0xFF81C784);
  
  // Education colors
  static const Color educationPrimary = Color(0xFFFF9800);
  static const Color educationSecondary = Color(0xFFFFB74D);
  static const Color educationAccent = Color(0xFFFFC107);
  
  // Agriculture colors
  static const Color agriculturePrimary = Color(0xFF4CAF50);
  static const Color agricultureSecondary = Color(0xFF81C784);
  static const Color agricultureAccent = Color(0xFF8BC34A);
  
  static const Color textDisabled = Color(0xFF9CA3AF);
  static const Color backgroundLight = Color(0xFFF8F9FA);
  static const Color accent = Color(0xFF2196F3);
  
  // Text colors
  static const Color textSecondary = Color(0xFF757575);
  static const Color textPrimary = Color(0xFF212121);
  
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF2E7D32,
    <int, Color>{
      50: Color(0xFFE8F5E8),
      100: Color(0xFFC8E6C9),
      200: Color(0xFFA5D6A7),
      300: Color(0xFF81C784),
      400: Color(0xFF66BB6A),
      500: Color(0xFF4CAF50),
      600: Color(0xFF43A047),
      700: Color(0xFF388E3C),
      800: Color(0xFF2E7D32),
      900: Color(0xFF1B5E20),
    },
  );
  
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Colors.white;
  static const Color textOnSecondary = Colors.white;
  
  // Background colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Colors.white;
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);
  
  // Connection status colors
  static const Color connected = Color(0xFF4CAF50);
  static const Color disconnected = Color(0xFFF44336);
  static const Color connecting = Color(0xFFFF9800);
  
  // Card colors
  static const Color cardBackground = Colors.white;
  static const Color cardShadow = Color(0x1F000000);
  
  // Border colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderFocus = Color(0xFF2196F3);
  
  // Overlay colors
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);
  
  // Gradient colors
  static const List<Color> primaryGradient = [
    Color(0xFF2E7D32),
    Color(0xFF4CAF50),
  ];
  
  static const List<Color> emergencyGradient = [
    Color(0xFFD32F2F),
    Color(0xFFFF5722),
  ];
  
  static const List<Color> medicalGradient = [
    Color(0xFF1976D2),
    Color(0xFF42A5F5),
  ];
  
  static const List<Color> educationGradient = [
    Color(0xFFFF9800),
    Color(0xFFFFC107),
  ];
  
  static const List<Color> agricultureGradient = [
    Color(0xFF4CAF50),
    Color(0xFF8BC34A),
  ];
}

