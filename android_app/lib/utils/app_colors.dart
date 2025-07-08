import 'package:flutter/material.dart';

class AppColors {
  // Cores principais baseadas na bandeira da Guiné-Bissau
  static const Color primary = Color(0xFF2E7D32); // Verde
  static const Color primaryGreen = Color(0xFF2E7D32); // Verde (alias)
  static const Color primaryDark = Color(0xFF1B5E20);
  static const Color primaryLight = Color(0xFF4CAF50);

  static const Color secondary = Color(0xFFFFC107); // Amarelo
  static const Color secondaryDark = Color(0xFFF57F17);
  static const Color secondaryLight = Color(0xFFFFEB3B);

  static const Color accent = Color(0xFFD32F2F); // Vermelho
  static const Color accentDark = Color(0xFFB71C1C);
  static const Color accentLight = Color(0xFFEF5350);

  // Cores funcionais
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color error = Color(0xFFD32F2F);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // Cores de texto
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Cores específicas para funcionalidades
  static const Color medical = Color(0xFFE53935); // Vermelho para emergências
  static const Color education = Color(0xFF1976D2); // Azul para educação
  static const Color agriculture = Color(0xFF388E3C); // Verde para agricultura
  static const Color translation = Color(0xFF7B1FA2); // Roxo para tradução

  // Gradientes
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient medicalGradient = LinearGradient(
    colors: [medical, Color(0xFFB71C1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient educationGradient = LinearGradient(
    colors: [education, Color(0xFF0D47A1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient agricultureGradient = LinearGradient(
    colors: [agriculture, Color(0xFF1B5E20)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Material Color Swatch para o tema
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

  // Cores para status de conexão
  static const Color connected = Color(0xFF4CAF50);
  static const Color disconnected = Color(0xFFE53935);
  static const Color connecting = Color(0xFFFF9800);

  // Cores para diferentes tipos de mensagem
  static const Color userMessage = Color(0xFFE3F2FD);
  static const Color aiMessage = Color(0xFFF1F8E9);
  static const Color systemMessage = Color(0xFFFFF3E0);
  static const Color errorMessage = Color(0xFFFFEBEE);
}


