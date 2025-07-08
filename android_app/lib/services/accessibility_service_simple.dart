import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/accessibility_models.dart';

class AccessibilityService {
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();
  static final AccessibilityService _instance =
      AccessibilityService._internal();

  final FlutterTts _flutterTts = FlutterTts();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';

  Future<bool> initialize() async {
    try {
      await _flutterTts.setLanguage('pt-BR');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1);
      await _flutterTts.setPitch(1);
      _speechEnabled = true;
      return true;
    } catch (e) {
      print('Erro ao inicializar acessibilidade: $e');
      return false;
    }
  }

  Future<VoiceToTextResult> startListening({
    String language = 'pt-BR',
    Function(String)? onResult,
  }) async {
    try {
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

  Future<void> stopListening() async {
    _isListening = false;
  }

  Future<TextToSpeechResult> speak(
    String text, {
    String language = 'pt-BR',
    double rate = 0.5,
    double volume = 1.0,
    double pitch = 1.0,
  }) async {
    try {
      await _flutterTts.setLanguage(language);
      await _flutterTts.setSpeechRate(rate);
      await _flutterTts.setVolume(volume);
      await _flutterTts.setPitch(pitch);
      await _flutterTts.speak(text);

      return TextToSpeechResult(
        success: true,
        text: text,
      );
    } catch (e) {
      return TextToSpeechResult(
        success: false,
        text: '',
        error: e.toString(),
      );
    }
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }

  bool get isListening => _isListening;
  String get lastWords => _lastWords;
  bool get speechEnabled => _speechEnabled;

  // Configurações de acessibilidade
  ThemeData getHighContrastTheme() => ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.yellow,
    );

  ThemeData getLowContrastTheme() => ThemeData(
      brightness: Brightness.light,
      primarySwatch: Colors.blue,
    );

  Future<AccessibilityAnalysisResult> analyzeAccessibility(
      BuildContext context) async {
    try {
      final issues = <AccessibilityIssue>[];

      final textScaleFactor = MediaQuery.of(context).textScaleFactor;
      if (textScaleFactor < 1.2) {
        issues.add(AccessibilityIssue(
          type: 'font_size',
          severity: 'medium',
          description: 'Fonte pode estar muito pequena',
        ));
      }

      return AccessibilityAnalysisResult(issues: issues);
    } catch (e) {
      print('Erro na análise de acessibilidade: $e');
      return AccessibilityAnalysisResult(issues: []);
    }
  }

  List<AccessibilityIssue> checkContrast(
      double backgroundLuminance, double foregroundLuminance) {
    final ratio = backgroundLuminance > foregroundLuminance
        ? backgroundLuminance / foregroundLuminance
        : foregroundLuminance / backgroundLuminance;

    if (ratio < 4.5) {
      return [
        AccessibilityIssue(
          type: 'contrast',
          severity: 'high',
          description: 'Contraste insuficiente',
        )
      ];
    }
    return [];
  }
}

class AccessibilityIssue {

  AccessibilityIssue({
    required this.type,
    required this.severity,
    required this.description,
  });
  final String type;
  final String severity;
  final String description;
}

class AccessibilityAnalysisResult {

  AccessibilityAnalysisResult({required this.issues});
  final List<AccessibilityIssue> issues;
}
