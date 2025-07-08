import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'modular_backend_service.dart';
import 'connection_state.dart';
import 'smart_api_service.dart';

/// Serviço de API Aprimorado que integra o SmartApiService com o ModularBackendService
/// Fornece uma interface unificada com recursos avançados de conexão
class EnhancedApiService {
  static EnhancedApiService? _instance;
  static EnhancedApiService get instance => _instance ??= EnhancedApiService._();
  
  late final SmartApiService _smartApi;
  late final ModularBackendService _modularService;
  late final ConnectionMonitor _connectionMonitor;
  
  // Stream controllers para eventos
  final StreamController<ApiEvent> _eventController = StreamController<ApiEvent>.broadcast();
  
  EnhancedApiService._() {
    _smartApi = SmartApiService();
    _modularService = ModularBackendService.instance;
    _connectionMonitor = ConnectionMonitor.instance;
    
    // Monitorar mudanças de estado da conexão
    _connectionMonitor.stateStream.listen(_onConnectionStateChanged);
  }
  
  /// Stream de eventos da API
  Stream<ApiEvent> get eventStream => _eventController.stream;
  
  /// Estado atual da conexão
  ConnectionState get connectionState => _connectionMonitor.currentState;
  
  /// Verifica conectividade usando ambos os serviços
  Future<bool> hasInternetConnection() async {
    try {
      // Tentar primeiro com o serviço modular (mais rápido)
      final modularResult = await _modularService.healthCheck();
      if (modularResult.success) {
        _connectionMonitor.recordSuccess(responseTime: modularResult.responseTime);
        return true;
      }
      
      // Fallback para o smart service
      final smartResult = await _smartApi.hasInternetConnection();
      if (smartResult) {
        _connectionMonitor.recordSuccess();
        return true;
      }
      
      _connectionMonitor.recordFailure('Ambos os serviços falharam na verificação de conectividade');
      return false;
    } catch (e) {
      _connectionMonitor.recordFailure('Erro na verificação de conectividade: $e');
      return false;
    }
  }
  
  /// Health check unificado
  Future<EnhancedApiResponse<Map<String, dynamic>>> healthCheck() async {
    try {
      _emitEvent(ApiEvent.healthCheckStarted());
      
      // Tentar serviço modular primeiro
      final modularResult = await _modularService.healthCheck();
      if (modularResult.success) {
        _emitEvent(ApiEvent.healthCheckCompleted(true, 'Modular'));
        return EnhancedApiResponse.success(
          data: modularResult.data!,
          source: 'Backend Modular',
          service: 'modular',
          fromCache: modularResult.fromCache,
          responseTime: modularResult.responseTime,
        );
      }
      
      // Fallback para smart service
      final smartResult = await _smartApi.healthCheck();
      if (smartResult.success) {
        _emitEvent(ApiEvent.healthCheckCompleted(true, 'Smart'));
        return EnhancedApiResponse.success(
          data: smartResult.data!,
          source: 'Backend Smart',
          service: 'smart',
          responseTime: smartResult.responseTime,
        );
      }
      
      _emitEvent(ApiEvent.healthCheckCompleted(false, 'Ambos falharam'));
      return EnhancedApiResponse.error('Ambos os serviços falharam no health check');
    } catch (e) {
      _emitEvent(ApiEvent.error('Health check falhou: $e'));
      return EnhancedApiResponse.error('Erro no health check: $e');
    }
  }
  
  /// Consulta médica com estratégia inteligente
  Future<EnhancedApiResponse<String>> askMedicalQuestion({
    required String question,
    String language = 'pt-BR',
    bool isEmergency = false,
    bool preferModular = true,
  }) async {
    try {
      _emitEvent(ApiEvent.medicalQueryStarted(question, isEmergency));
      
      if (preferModular && connectionState.isHealthy) {
        // Tentar serviço modular primeiro
        final modularResult = await _modularService.medicalQuery(
          question: question,
          language: language,
          isEmergency: isEmergency,
        );
        
        if (modularResult.success && modularResult.data != null) {
          _emitEvent(ApiEvent.medicalQueryCompleted(true, 'Modular'));
          return EnhancedApiResponse.success(
            data: modularResult.data!,
            source: modularResult.source,
            service: 'modular',
            confidence: modularResult.confidence,
            fromCache: modularResult.fromCache,
            responseTime: modularResult.responseTime,
          );
        }
      }
      
      // Fallback para smart service
      final smartResult = await _smartApi.askMedicalQuestion(
        question: question,
        language: language,
      );
      
      if (smartResult.success && smartResult.data != null) {
        _emitEvent(ApiEvent.medicalQueryCompleted(true, 'Smart'));
        return EnhancedApiResponse.success(
          data: smartResult.data!,
          source: smartResult.source,
          service: 'smart',
          confidence: smartResult.confidence,
          responseTime: smartResult.responseTime,
        );
      }
      
      _emitEvent(ApiEvent.medicalQueryCompleted(false, 'Ambos falharam'));
      return EnhancedApiResponse.error('Ambos os serviços falharam na consulta médica');
    } catch (e) {
      _emitEvent(ApiEvent.error('Consulta médica falhou: $e'));
      return EnhancedApiResponse.error('Erro na consulta médica: $e');
    }
  }
  
  /// Consulta educacional com estratégia inteligente
  Future<EnhancedApiResponse<String>> askEducationQuestion({
    required String question,
    String language = 'pt-BR',
    String subject = 'general',
    String level = 'básico',
    bool preferModular = true,
  }) async {
    try {
      _emitEvent(ApiEvent.educationQueryStarted(question, subject));
      
      if (preferModular && connectionState.isHealthy) {
        // Tentar serviço modular primeiro
        final modularResult = await _modularService.educationQuery(
          question: question,
          language: language,
          subject: subject,
          level: level,
        );
        
        if (modularResult.success && modularResult.data != null) {
          _emitEvent(ApiEvent.educationQueryCompleted(true, 'Modular'));
          return EnhancedApiResponse.success(
            data: modularResult.data!,
            source: modularResult.source,
            service: 'modular',
            confidence: modularResult.confidence,
            fromCache: modularResult.fromCache,
            responseTime: modularResult.responseTime,
          );
        }
      }
      
      // Fallback para smart service
      final smartResult = await _smartApi.askEducationQuestion(
        question: question,
        language: language,
        subject: subject,
        level: level,
      );
      
      if (smartResult.success && smartResult.data != null) {
        _emitEvent(ApiEvent.educationQueryCompleted(true, 'Smart'));
        return EnhancedApiResponse.success(
          data: smartResult.data!,
          source: smartResult.source,
          service: 'smart',
          confidence: smartResult.confidence,
          responseTime: smartResult.responseTime,
        );
      }
      
      _emitEvent(ApiEvent.educationQueryCompleted(false, 'Ambos falharam'));
      return EnhancedApiResponse.error('Ambos os serviços falharam na consulta educacional');
    } catch (e) {
      _emitEvent(ApiEvent.error('Consulta educacional falhou: $e'));
      return EnhancedApiResponse.error('Erro na consulta educacional: $e');
    }
  }
  
  /// Consulta agrícola com estratégia inteligente
  Future<EnhancedApiResponse<String>> askAgricultureQuestion({
    required String question,
    String language = 'pt-BR',
    String cropType = 'general',
    String season = 'current',
    bool preferModular = true,
  }) async {
    try {
      _emitEvent(ApiEvent.agricultureQueryStarted(question, cropType));
      
      if (preferModular && connectionState.isHealthy) {
        // Tentar serviço modular primeiro
        final modularResult = await _modularService.agricultureQuery(
          question: question,
          language: language,
          cropType: cropType,
          season: season,
        );
        
        if (modularResult.success && modularResult.data != null) {
          _emitEvent(ApiEvent.agricultureQueryCompleted(true, 'Modular'));
          return EnhancedApiResponse.success(
            data: modularResult.data!,
            source: modularResult.source,
            service: 'modular',
            confidence: modularResult.confidence,
            fromCache: modularResult.fromCache,
            responseTime: modularResult.responseTime,
          );
        }
      }
      
      // Fallback para smart service
      final smartResult = await _smartApi.askAgricultureQuestion(
        question: question,
        language: language,
        cropType: cropType,
        season: season,
      );
      
      if (smartResult.success && smartResult.data != null) {
        _emitEvent(ApiEvent.agricultureQueryCompleted(true, 'Smart'));
        return EnhancedApiResponse.success(
          data: smartResult.data!,
          source: smartResult.source,
          service: 'smart',
          confidence: smartResult.confidence,
          responseTime: smartResult.responseTime,
        );
      }
      
      _emitEvent(ApiEvent.agricultureQueryCompleted(false, 'Ambos falharam'));
      return EnhancedApiResponse.error('Ambos os serviços falharam na consulta agrícola');
    } catch (e) {
      _emitEvent(ApiEvent.error('Consulta agrícola falhou: $e'));
      return EnhancedApiResponse.error('Erro na consulta agrícola: $e');
    }
  }
  
  /// Consulta de bem-estar (apenas modular)
  Future<EnhancedApiResponse<String>> askWellnessQuestion({
    required String question,
    String language = 'pt-BR',
    String category = 'general',
  }) async {
    try {
      _emitEvent(ApiEvent.wellnessQueryStarted(question, category));
      
      final result = await _modularService.wellnessQuery(
        question: question,
        language: language,
        category: category,
      );
      
      if (result.success && result.data != null) {
        _emitEvent(ApiEvent.wellnessQueryCompleted(true, 'Modular'));
        return EnhancedApiResponse.success(
          data: result.data!,
          source: result.source,
          service: 'modular',
          confidence: result.confidence,
          fromCache: result.fromCache,
          responseTime: result.responseTime,
        );
      }
      
      _emitEvent(ApiEvent.wellnessQueryCompleted(false, 'Falhou'));
      return EnhancedApiResponse.error(result.error ?? 'Erro na consulta de bem-estar');
    } catch (e) {
      _emitEvent(ApiEvent.error('Consulta de bem-estar falhou: $e'));
      return EnhancedApiResponse.error('Erro na consulta de bem-estar: $e');
    }
  }
  
  /// Serviço de acessibilidade (apenas modular)
  Future<EnhancedApiResponse<String>> accessibilityQuery({
    required String text,
    String language = 'pt-BR',
    String mode = 'voice',
  }) async {
    try {
      _emitEvent(ApiEvent.accessibilityQueryStarted(text, mode));
      
      final result = await _modularService.accessibilityQuery(
        text: text,
        language: language,
        mode: mode,
      );
      
      if (result.success && result.data != null) {
        _emitEvent(ApiEvent.accessibilityQueryCompleted(true, 'Modular'));
        return EnhancedApiResponse.success(
          data: result.data!,
          source: result.source,
          service: 'modular',
          confidence: result.confidence,
          fromCache: result.fromCache,
          responseTime: result.responseTime,
        );
      }
      
      _emitEvent(ApiEvent.accessibilityQueryCompleted(false, 'Falhou'));
      return EnhancedApiResponse.error(result.error ?? 'Erro no serviço de acessibilidade');
    } catch (e) {
      _emitEvent(ApiEvent.error('Serviço de acessibilidade falhou: $e'));
      return EnhancedApiResponse.error('Erro no serviço de acessibilidade: $e');
    }
  }
  
  /// Métodos de acessibilidade do SmartApiService
  Future<EnhancedApiResponse<String>> describeEnvironment({
    required String imageBase64,
    String language = 'pt-BR',
    String detailLevel = 'detailed',
  }) async {
    try {
      final result = await _smartApi.describeEnvironment(
        imageBase64: imageBase64,
        language: language,
        detailLevel: detailLevel,
      );
      
      if (result.success && result.data != null) {
        return EnhancedApiResponse.success(
          data: result.data!,
          source: result.source,
          service: 'smart',
          confidence: result.confidence,
          responseTime: result.responseTime,
        );
      }
      
      return EnhancedApiResponse.error(result.error ?? 'Erro na descrição do ambiente');
    } catch (e) {
      return EnhancedApiResponse.error('Erro na descrição do ambiente: $e');
    }
  }
  
  void _onConnectionStateChanged(ConnectionState state) {
    _emitEvent(ApiEvent.connectionStateChanged(state));
  }
  
  void _emitEvent(ApiEvent event) {
    _eventController.add(event);
  }
  
  /// Limpar recursos
  void dispose() {
    _eventController.close();
    _modularService.dispose();
    _connectionMonitor.dispose();
  }
}

/// Resposta aprimorada da API
class EnhancedApiResponse<T> {
  final bool success;
  final T? data;
  final String? error;
  final String source;
  final String service; // 'modular' ou 'smart'
  final double confidence;
  final bool fromCache;
  final double? responseTime;
  
  const EnhancedApiResponse._({
    required this.success,
    this.data,
    this.error,
    required this.source,
    required this.service,
    this.confidence = 1.0,
    this.fromCache = false,
    this.responseTime,
  });
  
  factory EnhancedApiResponse.success({
    required T data,
    required String source,
    required String service,
    double confidence = 1.0,
    bool fromCache = false,
    double? responseTime,
  }) {
    return EnhancedApiResponse._(
      success: true,
      data: data,
      source: source,
      service: service,
      confidence: confidence,
      fromCache: fromCache,
      responseTime: responseTime,
    );
  }
  
  factory EnhancedApiResponse.error(String error) {
    return EnhancedApiResponse._(
      success: false,
      error: error,
      source: 'Erro',
      service: 'none',
    );
  }
  
  bool get isFromCache => fromCache;
  bool get isHighConfidence => confidence >= 0.8;
  bool get isFastResponse => responseTime != null && responseTime! < 2000;
  bool get isModularService => service == 'modular';
  bool get isSmartService => service == 'smart';
}

/// Eventos da API
class ApiEvent {
  final String type;
  final String message;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  
  const ApiEvent._({
    required this.type,
    required this.message,
    this.data = const {},
  }) : timestamp = DateTime.now();
  
  factory ApiEvent.healthCheckStarted() => ApiEvent._(
    type: 'health_check_started',
    message: 'Health check iniciado',
  );
  
  factory ApiEvent.healthCheckCompleted(bool success, String service) => ApiEvent._(
    type: 'health_check_completed',
    message: 'Health check ${success ? 'bem-sucedido' : 'falhou'} via $service',
    data: {'success': success, 'service': service},
  );
  
  factory ApiEvent.medicalQueryStarted(String question, bool isEmergency) => ApiEvent._(
    type: 'medical_query_started',
    message: 'Consulta médica iniciada${isEmergency ? ' (EMERGÊNCIA)' : ''}',
    data: {'question': question, 'is_emergency': isEmergency},
  );
  
  factory ApiEvent.medicalQueryCompleted(bool success, String service) => ApiEvent._(
    type: 'medical_query_completed',
    message: 'Consulta médica ${success ? 'concluída' : 'falhou'} via $service',
    data: {'success': success, 'service': service},
  );
  
  factory ApiEvent.educationQueryStarted(String question, String subject) => ApiEvent._(
    type: 'education_query_started',
    message: 'Consulta educacional iniciada ($subject)',
    data: {'question': question, 'subject': subject},
  );
  
  factory ApiEvent.educationQueryCompleted(bool success, String service) => ApiEvent._(
    type: 'education_query_completed',
    message: 'Consulta educacional ${success ? 'concluída' : 'falhou'} via $service',
    data: {'success': success, 'service': service},
  );
  
  factory ApiEvent.agricultureQueryStarted(String question, String cropType) => ApiEvent._(
    type: 'agriculture_query_started',
    message: 'Consulta agrícola iniciada ($cropType)',
    data: {'question': question, 'crop_type': cropType},
  );
  
  factory ApiEvent.agricultureQueryCompleted(bool success, String service) => ApiEvent._(
    type: 'agriculture_query_completed',
    message: 'Consulta agrícola ${success ? 'concluída' : 'falhou'} via $service',
    data: {'success': success, 'service': service},
  );
  
  factory ApiEvent.wellnessQueryStarted(String question, String category) => ApiEvent._(
    type: 'wellness_query_started',
    message: 'Consulta de bem-estar iniciada ($category)',
    data: {'question': question, 'category': category},
  );
  
  factory ApiEvent.wellnessQueryCompleted(bool success, String service) => ApiEvent._(
    type: 'wellness_query_completed',
    message: 'Consulta de bem-estar ${success ? 'concluída' : 'falhou'} via $service',
    data: {'success': success, 'service': service},
  );
  
  factory ApiEvent.accessibilityQueryStarted(String text, String mode) => ApiEvent._(
    type: 'accessibility_query_started',
    message: 'Consulta de acessibilidade iniciada ($mode)',
    data: {'text': text, 'mode': mode},
  );
  
  factory ApiEvent.accessibilityQueryCompleted(bool success, String service) => ApiEvent._(
    type: 'accessibility_query_completed',
    message: 'Consulta de acessibilidade ${success ? 'concluída' : 'falhou'} via $service',
    data: {'success': success, 'service': service},
  );
  
  factory ApiEvent.connectionStateChanged(ConnectionState state) => ApiEvent._(
    type: 'connection_state_changed',
    message: 'Estado da conexão alterado: ${state.statusText}',
    data: {
      'is_connected': state.isConnected,
      'is_healthy': state.isHealthy,
      'quality': state.quality.toString(),
      'response_time': state.responseTime,
    },
  );
  
  factory ApiEvent.error(String error) => ApiEvent._(
    type: 'error',
    message: error,
    data: {'error': error},
  );
  
  @override
  String toString() => '[$type] $message';
}