import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/accessibility_models.dart';

class AccessibilityService {
  // Instâncias
  // final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  // Estados
  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';

  // Configurações
  double _speechRate = 0.5;
  double _speechPitch = 1;
  double _speechVolume = 1;
  String _currentLanguage = 'pt-BR';

  // Inicializar serviços de acessibilidade
  Future<bool> initialize() async {
    try {
      // Configurar TTS
      await _flutterTts.setLanguage(_currentLanguage);
      await _flutterTts.setSpeechRate(_speechRate);
      await _flutterTts.setVolume(_speechVolume);
      await _flutterTts.setPitch(_speechPitch);

      _speechEnabled = true;
      return true;
    } catch (e) {
      print('Erro ao inicializar acessibilidade: $e');
      return false;
    }
  }

  // Conversão de voz para texto (para deficientes auditivos)
  Future<VoiceToTextResult> startListening({
    String language = 'pt-BR',
    Function(String)? onResult,
  }) async {
    if (!_speechEnabled) {
      return VoiceToTextResult(
        success: false,
        text: '',
        error: 'Reconhecimento de voz não disponível',
      );
    }

    try {
      if (_isListening) {
        // await _speechToText.stop();
        _isListening = false;
      }

      // Simulação do reconhecimento de voz
      _isListening = true;
      _lastWords = 'Reconhecimento simulado';
      onResult?.call(_lastWords);

      return VoiceToTextResult(
        success: true,
        text: _lastWords,
        isListening: _isListening,
      );
    } catch (e) {
      return VoiceToTextResult(
        success: false,
        text: '',
        error: e.toString(),
      );
    }
  }

  // Parar reconhecimento de voz
  Future<void> stopListening() async {
    if (_isListening) {
      // await _speechToText.stop();
      _isListening = false;
    }
  }

  // Conversão de texto para voz (para deficientes visuais)
  Future<TextToSpeechResult> speak(
    String text, {
    String? language,
    double? rate,
    double? pitch,
    double? volume,
  }) async {
    try {
      if (language != null) await _flutterTts.setLanguage(language);
      if (rate != null) await _flutterTts.setSpeechRate(rate);
      if (pitch != null) await _flutterTts.setPitch(pitch);
      if (volume != null) await _flutterTts.setVolume(volume);

      await _flutterTts.speak(text);

      return TextToSpeechResult(
        success: true,
        text: text,
      );
    } catch (e) {
      return TextToSpeechResult(
        success: false,
        text: text,
        error: e.toString(),
      );
    }
  }

  // Parar reprodução de voz
  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }

  // Configurar velocidade da fala
  Future<void> setSpeechRate(double rate) async {
    _speechRate = rate.clamp(0.0, 1.0);
    await _flutterTts.setSpeechRate(_speechRate);
  }

  // Configurar tom da voz
  Future<void> setSpeechPitch(double pitch) async {
    _speechPitch = pitch.clamp(0.5, 2.0);
    await _flutterTts.setPitch(_speechPitch);
  }

  // Configurar volume
  Future<void> setSpeechVolume(double volume) async {
    _speechVolume = volume.clamp(0.0, 1.0);
    await _flutterTts.setVolume(_speechVolume);
  }

  // Configurar idioma
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
  Future<void> vibrateFeedback({
    VibrationPattern pattern = VibrationPattern.light,
  }) async {
    try {
      switch (pattern) {
        case VibrationPattern.light:
          await HapticFeedback.lightImpact();
          break;
        case VibrationPattern.medium:
          await HapticFeedback.mediumImpact();
          break;
        case VibrationPattern.heavy:
          await HapticFeedback.heavyImpact();
          break;
        case VibrationPattern.selection:
          await HapticFeedback.selectionClick();
          break;
      }
    } catch (e) {
      print('Erro ao gerar vibração: $e');
    }
  }

  // Análise de acessibilidade de texto simplificada
  Map<String, dynamic> analyzeTextAccessibility(String text) {
    final issues = <String>[];

    // Verificar comprimento do texto
    if (text.length > 160) {
      issues.add('Texto muito longo para leitura de tela');
    }

    // Verificar uso de maiúsculas
    if (text == text.toUpperCase() && text.length > 10) {
      issues.add('Texto todo em maiúsculas dificulta leitura');
    }

    return {
      'isAccessible': issues.isEmpty,
      'issues': issues,
      'score': _calculateAccessibilityScore(issues),
    };
  }

  double _calculateAccessibilityScore(List<String> issues) {
    if (issues.isEmpty) return 100;
    return (100.0 - (issues.length * 15.0)).clamp(0.0, 100.0);
  }

  // Getters para estado atual
  bool get isListening => _isListening;
  String get lastWords => _lastWords;
  double get speechRate => _speechRate;
  double get speechPitch => _speechPitch;
  double get speechVolume => _speechVolume;
  String get currentLanguage => _currentLanguage;

  // Limpar recursos
  void dispose() {
    stopListening();
    stopSpeaking();
  }
}

// Enums para vibração
enum VibrationPattern {
  light,
  medium,
  heavy,
  selection,
}
