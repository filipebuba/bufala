import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'smart_api_service.dart';

/// Modelo para análise de ambiente
class EnvironmentAnalysis {

  EnvironmentAnalysis({
    required this.analysis,
    required this.timestamp,
    required this.language,
    required this.context,
    required this.emergencyDetected,
    required this.navigationSuggestions,
  });

  factory EnvironmentAnalysis.fromJson(Map<String, dynamic> json) => EnvironmentAnalysis(
      analysis: json['analysis'] ?? '',
      timestamp: json['timestamp'] ?? '',
      language: json['language'] ?? 'pt-BR',
      context: json['context'] ?? '',
      emergencyDetected: json['emergency_detected'] ?? false,
      navigationSuggestions: List<String>.from(json['navigation_suggestions'] ?? []),
    );
  final String analysis;
  final String timestamp;
  final String language;
  final String context;
  final bool emergencyDetected;
  final List<String> navigationSuggestions;
}

/// Modelo para instruções de navegação
class NavigationInstructions {

  NavigationInstructions({
    required this.instructions,
    required this.destination,
    required this.timestamp,
    required this.language,
    required this.steps,
    required this.estimatedTime,
    required this.safetyAlerts,
  });

  factory NavigationInstructions.fromJson(Map<String, dynamic> json) => NavigationInstructions(
      instructions: json['instructions'] ?? '',
      destination: json['destination'] ?? '',
      timestamp: json['timestamp'] ?? '',
      language: json['language'] ?? 'pt-BR',
      steps: List<String>.from(json['steps'] ?? []),
      estimatedTime: json['estimated_time'] ?? '',
      safetyAlerts: List<String>.from(json['safety_alerts'] ?? []),
    );
  final String instructions;
  final String destination;
  final String timestamp;
  final String language;
  final List<String> steps;
  final String estimatedTime;
  final List<String> safetyAlerts;
}

/// Modelo para resposta de comando de voz
class VoiceCommandResponse {

  VoiceCommandResponse({
    required this.response,
    required this.type,
    required this.timestamp,
    this.destination,
    this.command,
  });

  factory VoiceCommandResponse.fromJson(Map<String, dynamic> json) => VoiceCommandResponse(
      response: json['response'] ?? '',
      type: json['type'] ?? 'general',
      timestamp: json['timestamp'] ?? '',
      destination: json['destination'],
      command: json['command'],
    );
  final String response;
  final String type;
  final String timestamp;
  final String? destination;
  final String? command;
}

/// Modelo para modo de emergência
class EmergencyResponse {

  EmergencyResponse({
    required this.emergencyInstructions,
    required this.emergencyContacts,
    required this.timestamp,
    required this.context,
    required this.priority,
  });

  factory EmergencyResponse.fromJson(Map<String, dynamic> json) => EmergencyResponse(
      emergencyInstructions: json['emergency_instructions'] ?? '',
      emergencyContacts: Map<String, String>.from(json['emergency_contacts'] ?? {}),
      timestamp: json['timestamp'] ?? '',
      context: json['context'] ?? '',
      priority: json['priority'] ?? 'NORMAL',
    );
  final String emergencyInstructions;
  final Map<String, String> emergencyContacts;
  final String timestamp;
  final String context;
  final String priority;
}

/// Modelo para navegação rápida
class QuickNavigationResult {

  QuickNavigationResult({
    required this.environmentAnalysis,
    required this.navigationInstructions,
    required this.quickSummary,
  });

  factory QuickNavigationResult.fromJson(Map<String, dynamic> json) => QuickNavigationResult(
      environmentAnalysis: EnvironmentAnalysis.fromJson(json['environment_analysis'] ?? {}),
      navigationInstructions: NavigationInstructions.fromJson(json['navigation_instructions'] ?? {}),
      quickSummary: QuickSummary.fromJson(json['quick_summary'] ?? {}),
    );
  final EnvironmentAnalysis environmentAnalysis;
  final NavigationInstructions navigationInstructions;
  final QuickSummary quickSummary;
}

class QuickSummary {

  QuickSummary({
    required this.destination,
    required this.emergencyDetected,
    required this.stepCount,
    required this.estimatedTime,
    required this.safetyAlerts,
  });

  factory QuickSummary.fromJson(Map<String, dynamic> json) => QuickSummary(
      destination: json['destination'] ?? '',
      emergencyDetected: json['emergency_detected'] ?? false,
      stepCount: json['step_count'] ?? 0,
      estimatedTime: json['estimated_time'] ?? '',
      safetyAlerts: List<String>.from(json['safety_alerts'] ?? []),
    );
  final String destination;
  final bool emergencyDetected;
  final int stepCount;
  final String estimatedTime;
  final List<String> safetyAlerts;
}

/// Serviço principal do VoiceGuide AI
class VoiceGuideService {
  final SmartApiService _apiService = SmartApiService();
  static const String _baseEndpoint = '/voice-guide';

  /// Verifica saúde do serviço
  Future<Map<String, dynamic>?> checkHealth() async {
    try {
      final response = await _apiService.get('$_baseEndpoint/health');
      if (response.success && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao verificar saúde do VoiceGuide: $e');
      return null;
    }
  }

  /// Analisa ambiente para navegação
  Future<EnvironmentAnalysis?> analyzeEnvironment({
    String? imageBase64,
    String context = '',
  }) async {
    try {
      final requestData = {
        'context': context,
      };
      
      if (imageBase64 != null) {
        requestData['image_data'] = imageBase64;
      }

      final response = await _apiService.post(
        '$_baseEndpoint/analyze-environment',
        requestData,
      );

      if (response.success && response.data != null) {
        return EnvironmentAnalysis.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao analisar ambiente: $e');
      return null;
    }
  }

  /// Gera instruções de navegação
  Future<NavigationInstructions?> generateNavigationInstructions({
    required String destination,
    String currentAnalysis = '',
  }) async {
    try {
      final response = await _apiService.post(
        '$_baseEndpoint/navigation-instructions',
        {
          'destination': destination,
          'current_analysis': currentAnalysis,
        },
      );

      if (response.success && response.data != null) {
        return NavigationInstructions.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao gerar instruções: $e');
      return null;
    }
  }

  /// Processa comando de voz
  Future<VoiceCommandResponse?> processVoiceCommand(String command) async {
    try {
      final response = await _apiService.post(
        '$_baseEndpoint/voice-command',
        {'command': command},
      );

      if (response.success && response.data != null) {
        return VoiceCommandResponse.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao processar comando: $e');
      return null;
    }
  }

  /// Ativa modo de emergência
  Future<EmergencyResponse?> activateEmergencyMode({String context = ''}) async {
    try {
      final response = await _apiService.post(
        '$_baseEndpoint/emergency/activate',
        {'context': context},
      );

      if (response.success && response.data != null) {
        return EmergencyResponse.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao ativar emergência: $e');
      return null;
    }
  }

  /// Desativa modo de emergência
  Future<bool> deactivateEmergencyMode() async {
    try {
      final response = await _apiService.post(
        '$_baseEndpoint/emergency/deactivate',
        {},
      );
      return response.success;
    } catch (e) {
      debugPrint('Erro ao desativar emergência: $e');
      return false;
    }
  }

  /// Define idioma do sistema
  Future<bool> setLanguage(String languageCode) async {
    try {
      final response = await _apiService.post(
        '$_baseEndpoint/settings/language',
        {'language_code': languageCode},
      );
      return response.success;
    } catch (e) {
      debugPrint('Erro ao definir idioma: $e');
      return false;
    }
  }

  /// Obtém idiomas suportados
  Future<Map<String, String>?> getSupportedLanguages() async {
    try {
      final response = await _apiService.get('$_baseEndpoint/settings/languages');
      
      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return Map<String, String>.from(data['supported_languages'] ?? {});
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao obter idiomas: $e');
      return null;
    }
  }

  /// Obtém histórico de navegação
  Future<List<Map<String, dynamic>>?> getNavigationHistory({int limit = 10}) async {
    try {
      final response = await _apiService.get('$_baseEndpoint/history?limit=$limit');
      
      if (response.success && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return List<Map<String, dynamic>>.from(data['history'] ?? []);
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao obter histórico: $e');
      return null;
    }
  }

  /// Obtém status do sistema
  Future<Map<String, dynamic>?> getStatus() async {
    try {
      final response = await _apiService.get('$_baseEndpoint/status');
      
      if (response.success && response.data != null) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      debugPrint('Erro ao obter status: $e');
      return null;
    }
  }

  /// Navegação rápida (análise + instruções)
  Future<QuickNavigationResult?> quickNavigation({
    required String destination,
    String? imageBase64,
    String context = '',
  }) async {
    try {
      final requestData = {
        'destination': destination,
        'context': context.isEmpty ? 'Navegação rápida para $destination' : context,
      };
      
      if (imageBase64 != null) {
        requestData['image_data'] = imageBase64;
      }

      final response = await _apiService.post(
        '$_baseEndpoint/quick-navigation',
        requestData,
      );

      if (response.success && response.data != null) {
        return QuickNavigationResult.fromJson(response.data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('Erro na navegação rápida: $e');
      return null;
    }
  }

  /// Converte imagem para base64
  static String imageToBase64(Uint8List imageBytes) => base64Encode(imageBytes);

  /// Valida se o serviço está disponível
  Future<bool> isServiceAvailable() async {
    final health = await checkHealth();
    return health != null && health['status'] == 'healthy';
  }
}