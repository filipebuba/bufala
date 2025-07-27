import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'integrated_api_service.dart';
import '../config/app_config.dart';

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
  final IntegratedApiService _apiService = IntegratedApiService();
  static const String _baseEndpoint = 'voice-guide';

  /// Verifica saúde do serviço
  Future<Map<String, dynamic>?> checkHealth() async {
    try {
      final isHealthy = await _apiService.healthCheck();
      return {
        'status': isHealthy ? 'healthy' : 'unhealthy',
        'timestamp': DateTime.now().toIso8601String(),
      };
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

      final response = await _apiService.analyzeMultimodal(
        text: context,
        imageBase64: imageBase64,
        analysisType: 'environment',
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as String;
        return EnvironmentAnalysis(
          analysis: data,
          timestamp: DateTime.now().toIso8601String(),
          language: 'pt-BR',
          context: context,
          emergencyDetected: false,
          navigationSuggestions: [data],
        );
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
      final response = await _apiService.getAccessibilitySupport(
        'Gerar instruções de navegação para $destination. Análise atual: $currentAnalysis',
        accessibilityType: 'navigation',
        userNeeds: 'instruções de navegação',
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as String;
        return NavigationInstructions(
          instructions: data,
          destination: destination,
          timestamp: DateTime.now().toIso8601String(),
          language: 'pt-BR',
          steps: [data],
          estimatedTime: '5-10 minutos',
          safetyAlerts: [],
        );
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
      final response = await _apiService.getAccessibilitySupport(
        'Processar comando de voz: $command',
        accessibilityType: 'voice',
        userNeeds: 'processamento de comando de voz',
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as String;
        return VoiceCommandResponse(
          response: data,
          type: 'voice_command',
          timestamp: DateTime.now().toIso8601String(),
          command: command,
        );
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
      final response = await _apiService.handleMedicalEmergency(
        'Modo de emergência ativado. Contexto: $context',
        location: 'Localização atual',
        emergencyType: 'general',
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as String;
        return EmergencyResponse(
          emergencyInstructions: data,
          emergencyContacts: {
            'emergencia': '192',
            'bombeiros': '193',
            'policia': '190',
          },
          timestamp: DateTime.now().toIso8601String(),
          context: context,
          priority: 'HIGH',
        );
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
      // Simula desativação do modo de emergência
      return true;
    } catch (e) {
      debugPrint('Erro ao desativar emergência: $e');
      return false;
    }
  }

  /// Define idioma do sistema
  Future<bool> setLanguage(String languageCode) async {
    try {
      // Simula configuração de idioma usando os idiomas suportados
      final supportedLanguages = await getSupportedLanguages();
      if (supportedLanguages != null && supportedLanguages.containsKey(languageCode)) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Erro ao definir idioma: $e');
      return false;
    }
  }

  /// Obtém idiomas suportados
  Future<Map<String, String>?> getSupportedLanguages() async {
    try {
      // Retorna idiomas suportados padrão
      return {
        'pt-BR': 'Português (Brasil)',
        'crioulo-gb': 'Crioulo da Guiné-Bissau',
        'en': 'English',
        'fr': 'Français',
      };
    } catch (e) {
      debugPrint('Erro ao obter idiomas: $e');
      return null;
    }
  }

  /// Obtém histórico de navegação
  Future<List<Map<String, dynamic>>?> getNavigationHistory({int limit = 10}) async {
    try {
      // Retorna histórico vazio por enquanto
      return [];
    } catch (e) {
      debugPrint('Erro ao obter histórico: $e');
      return null;
    }
  }

  /// Obtém status do sistema
  Future<Map<String, dynamic>?> getStatus() async {
    try {
      final isHealthy = await _apiService.healthCheck();
      return {
        'status': isHealthy ? 'healthy' : 'unhealthy',
        'timestamp': DateTime.now().toIso8601String(),
      };
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
      final contextText = context.isEmpty ? 'Navegação rápida para $destination' : context;
      
      final response = await _apiService.analyzeMultimodal(
        text: contextText,
        imageBase64: imageBase64,
        analysisType: 'quick_navigation',
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as String;
        
        // Criar análise de ambiente simulada
        final environmentAnalysis = EnvironmentAnalysis(
          analysis: data,
          timestamp: DateTime.now().toIso8601String(),
          language: 'pt-BR',
          context: contextText,
          emergencyDetected: false,
          navigationSuggestions: [data],
        );
        
        // Criar instruções de navegação simuladas
        final navigationInstructions = NavigationInstructions(
          instructions: data,
          destination: destination,
          timestamp: DateTime.now().toIso8601String(),
          language: 'pt-BR',
          steps: [data],
          estimatedTime: '2-5 minutos',
          safetyAlerts: [],
        );
        
        // Criar resumo rápido
        final quickSummary = QuickSummary(
          destination: destination,
          emergencyDetected: false,
          stepCount: 1,
          estimatedTime: '2-5 minutos',
          safetyAlerts: [],
        );
        
        return QuickNavigationResult(
          environmentAnalysis: environmentAnalysis,
          navigationInstructions: navigationInstructions,
          quickSummary: quickSummary,
        );
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