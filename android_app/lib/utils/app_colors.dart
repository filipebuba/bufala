import 'package:flutter/material.dart';

class AppColors {
  // Cores principais baseadas na bandeira da Guiné-Bissau
  static const Color primaryRed = Color(0xFFCE1126);
  static const Color primaryYellow = Color(0xFFFCD116);
  static const Color primaryGreen = Color(0xFF009639);
  static const Color primaryBlack = Color(0xFF000000);
  static const Color primaryWhite = Color(0xFFFFFFFF);

  // Cores funcionais
  static const Color primary = primaryGreen;
  static const Color secondary = primaryYellow;
  static const Color accent = primaryRed;
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = primaryWhite;
  static const Color error = Color(0xFFB00020);

  // Cores de texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textLight = primaryWhite;
  static const Color textDark = primaryBlack;

  // Cores específicas para funcionalidades
  static const Color medical = Color(0xFFE53E3E);
  static const Color education = Color(0xFF3182CE);
  static const Color agriculture = primaryGreen;
  static const Color translation = Color(0xFF805AD5);

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primaryGreen, Color(0xFF00C851)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient medicalGradient = LinearGradient(
    colors: [medical, Color(0xFFFF6B6B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient educationGradient = LinearGradient(
    colors: [education, Color(0xFF4299E1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient agricultureGradient = LinearGradient(
    colors: [agriculture, Color(0xFF48BB78)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // MaterialColorSwatch para o tema
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF009639,
    <int, Color>{
      50: Color(0xFFE8F5E8),
      100: Color(0xFFC8E6C9),
      200: Color(0xFFA5D6A7),
      300: Color(0xFF81C784),
      400: Color(0xFF66BB6A),
      500: Color(0xFF009639),
      600: Color(0xFF43A047),
      700: Color(0xFF388E3C),
      800: Color(0xFF2E7D32),
      900: Color(0xFF1B5E20),
    },
  );

  // Cores para status de conexão
  static const Color connected = primaryGreen;
  static const Color disconnected = error;
  static const Color connecting = primaryYellow;

  // Cores para tipos de mensagem
  static const Color messageUser = Color(0xFFE3F2FD);
  static const Color messageBot = Color(0xFFF1F8E9);
  static const Color messageError = Color(0xFFFFEBEE);
  static const Color messageSuccess = Color(0xFFE8F5E8);
}