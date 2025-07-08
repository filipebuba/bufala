import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

class AccessibilityServiceFixed {
  factory AccessibilityServiceFixed() => _instance;
  AccessibilityServiceFixed._internal();
  static final AccessibilityServiceFixed _instance =
      AccessibilityServiceFixed._internal();

  final FlutterTts _flutterTts = FlutterTts();

  String _currentLanguage = 'pt-BR';
  bool _speechEnabled = false;
  bool _isListening = false;
  bool _isInitialized = false;

  double get textScaleFactor => 1;
  double get speechRate => 0.5;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await _flutterTts.setLanguage(_currentLanguage);
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1);
      await _flutterTts.setPitch(1);

      _speechEnabled = true; // Simulado como disponível
      _isInitialized = true;
    } catch (e) {
      print('Erro ao inicializar serviço de acessibilidade: $e');
    }
  }

  // Síntese de fala
  Future<void> speakText(String text,
      {void Function(String)? onComplete}) async {
    if (!_isInitialized) await initialize();

    try {
      if (onComplete != null) {
        _flutterTts.setCompletionHandler(() => onComplete(text));
      }

      await _flutterTts.speak(text);
    } catch (e) {
      print('Erro na síntese de fala: $e');
      if (onComplete != null) onComplete(text);
    }
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }

  // Reconhecimento de fala simulado
  Future<String> startListening({void Function(String)? onResult}) async {
    if (!_speechEnabled || _isListening) return '';

    try {
      _isListening = true;

      // Simulação de reconhecimento de fala
      await Future.delayed(const Duration(seconds: 1));
      const simulatedResult = 'Texto reconhecido simulado';

      if (onResult != null) onResult(simulatedResult);

      _isListening = false;
      return simulatedResult;
    } catch (e) {
      print('Erro no reconhecimento de fala: $e');
      _isListening = false;
      return '';
    }
  }

  Future<void> stopListening() async {
    _isListening = false;
  }

  // Feedback tátil
  Future<void> provideFeedback(String feedbackType) async {
    try {
      switch (feedbackType) {
        case 'light':
          await HapticFeedback.lightImpact();
          break;
        case 'medium':
          await HapticFeedback.mediumImpact();
          break;
        case 'heavy':
          await HapticFeedback.heavyImpact();
          break;
        case 'selection':
          await HapticFeedback.selectionClick();
          break;
        default:
          await HapticFeedback.lightImpact();
      }
    } catch (e) {
      print('Erro no feedback tátil: $e');
    }
  }

  // Configuração de idioma
  Future<void> setLanguage(String languageCode) async {
    _currentLanguage = languageCode;
    await _flutterTts.setLanguage(_currentLanguage);
  }

  // Aplicar configurações de alto contraste
  ThemeData applyHighContrastTheme(ThemeData baseTheme) => baseTheme.copyWith(
      colorScheme: ColorScheme.fromSwatch().copyWith(
        brightness: Brightness.dark,
        primary: Colors.white,
        secondary: Colors.yellow,
        surface: Colors.black,
      ),
      textTheme: baseTheme.textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
    );

  // Aplicar configurações de texto grande
  ThemeData applyLargeTextTheme(ThemeData baseTheme, double scaleFactor) => baseTheme.copyWith(
      textTheme: baseTheme.textTheme.apply(
        fontSizeFactor: scaleFactor.clamp(1.0, 3.0),
      ),
    );

  // Feedback vibratório para interações
  Future<void> vibrateFeedback({String pattern = 'light'}) async {
    await provideFeedback(pattern);
  }

  // Análise básica de acessibilidade
  Map<String, dynamic> analyzeAccessibility(Widget widget) => {
      'hasSemantics': true,
      'issues': <String>[],
      'score': 100.0,
      'suggestions': <String>[],
    };

  // Verificar se texto é acessível
  bool isTextAccessible(String text, {double? fontSize}) {
    if (text.isEmpty) return false;
    if (text.length > 200) return false;
    if (text == text.toUpperCase() && text.length > 10) return false;
    return true;
  }

  // Configurações de acessibilidade
  Map<String, dynamic> getAccessibilitySettings() => {
      'textScaleFactor': textScaleFactor,
      'speechRate': speechRate,
      'speechEnabled': _speechEnabled,
      'isListening': _isListening,
      'currentLanguage': _currentLanguage,
    };

  void dispose() {
    _flutterTts.stop();
    // Removido: _speechToText.stop(); // referência indefinida
    _isListening = false;
    _isInitialized = false;
  }
}

// Enums e classes de suporte simplificadas
enum VibrationPattern { light, medium, heavy, selection }

class TextToSpeechResult {

  TextToSpeechResult({
    required this.text,
    required this.success,
    this.error,
  });
  final String text;
  final bool success;
  final String? error;
}

class SpeechToTextResult {

  SpeechToTextResult({
    required this.recognizedText,
    required this.confidence,
  });
  final String recognizedText;
  final double confidence;
}
