import 'dart:async';

import 'connection_state.dart' as conn_state;
import 'integrated_api_service.dart';
import 'modular_backend_service.dart';

/// Eventos da API
class ApiEvent {

  ApiEvent({
    required this.type,
    required this.message,
    this.data = const {},
  }) : timestamp = DateTime.now();

  factory ApiEvent.healthCheckStarted() => ApiEvent(
      type: 'health_check_started',
      message: 'Iniciando verificação de saúde',
    );

  factory ApiEvent.healthCheckCompleted(bool success, String service) => ApiEvent(
      type: 'health_check_completed',
      message: 'Verificação de saúde concluída: $service',
      data: {'success': success, 'service': service},
    );

  factory ApiEvent.medicalQueryStarted(String question, bool isEmergency) => ApiEvent(
      type: 'medical_query_started',
      message: 'Iniciando consulta médica',
      data: {'question': question, 'is_emergency': isEmergency},
    );

  factory ApiEvent.medicalQueryCompleted(bool success, String service) => ApiEvent(
      type: 'medical_query_completed',
      message: 'Consulta médica concluída: $service',
      data: {'success': success, 'service': service},
    );

  factory ApiEvent.educationQueryStarted(String question, String subject) => ApiEvent(
      type: 'education_query_started',
      message: 'Iniciando consulta educacional',
      data: {'question': question, 'subject': subject},
    );

  factory ApiEvent.educationQueryCompleted(bool success, String service) => ApiEvent(
      type: 'education_query_completed',
      message: 'Consulta educacional concluída: $service',
      data: {'success': success, 'service': service},
    );

  factory ApiEvent.error(String message) => ApiEvent(
      type: 'error',
      message: message,
    );
  final String type;
  final String message;
  final Map<String, dynamic> data;
  final DateTime timestamp;
}

/// Resposta aprimorada da API
class EnhancedApiResponse<T> {

  const EnhancedApiResponse({
    required this.success,
    required this.source, required this.service, this.data,
    this.error,
    this.confidence,
    this.fromCache = false,
    this.responseTime,
  });

  factory EnhancedApiResponse.success({
    required T data,
    required String source,
    required String service,
    double? confidence,
    bool fromCache = false,
    double? responseTime,
  }) => EnhancedApiResponse(
      success: true,
      data: data,
      source: source,
      service: service,
      confidence: confidence,
      fromCache: fromCache,
      responseTime: responseTime,
    );

  factory EnhancedApiResponse.error(String error) => EnhancedApiResponse(
      success: false,
      error: error,
      source: 'Error',
      service: 'none',
    );
  final bool success;
  final T? data;
  final String? error;
  final String source;
  final String service;
  final double? confidence;
  final bool fromCache;
  final double? responseTime;
}

/// Serviço de API Aprimorado que integra o IntegratedApiService com o ModularBackendService
class EnhancedApiService {
  
  EnhancedApiService._() {
    _smartApi = IntegratedApiService();
    _modularService = ModularBackendService.instance;
    _connectionMonitor = conn_state.ConnectionMonitor.instance;
    
    // Monitorar mudanças de estado da conexão
    _connectionMonitor.stateStream.listen(_onConnectionStateChanged);
  }
  static EnhancedApiService? _instance;
  static EnhancedApiService get instance => _instance ??= EnhancedApiService._();
  
  late final IntegratedApiService _smartApi;
  late final ModularBackendService _modularService;
  late final conn_state.ConnectionMonitor _connectionMonitor;
  
  // Stream controllers para eventos
  final StreamController<ApiEvent> _eventController = StreamController<ApiEvent>.broadcast();

  /// Inicializar o serviço
  Future<void> initialize() async {
    await _modularService.initialize();
  }

  /// Iniciar monitoramento
  void startMonitoring() {
    _modularService.startMonitoring();
  }

  /// Parar monitoramento
  void stopMonitoring() {
    _modularService.stopMonitoring();
  }

  /// Stream do estado da conexão
  Stream<conn_state.ConnectionState> get connectionStream => _connectionMonitor.stateStream;
  
  /// Stream de eventos da API
  Stream<ApiEvent> get eventStream => _eventController.stream;
  
  /// Estado atual da conexão
  conn_state.ConnectionState get connectionState => _connectionMonitor.currentState;
  
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
      if (smartResult) {
        _emitEvent(ApiEvent.healthCheckCompleted(true, 'Smart'));
        return EnhancedApiResponse.success(
          data: {'status': 'ok'},
          source: 'Backend Smart',
          service: 'smart',
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
            data: modularResult.data!['answer'] ?? modularResult.data.toString(),
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
        question,
        language: language,
      );
      
      if (smartResult['answer'] != null) {
        _emitEvent(ApiEvent.medicalQueryCompleted(true, 'Smart'));
        return EnhancedApiResponse.success(
          data: smartResult['answer'],
          source: 'Smart API',
          service: 'smart',
          confidence: smartResult['confidence']?.toDouble(),
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
            data: modularResult.data!['answer'] ?? modularResult.data.toString(),
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
        question,
        language: language,
      );
      
      if (smartResult['answer'] != null) {
        _emitEvent(ApiEvent.educationQueryCompleted(true, 'Smart'));
        return EnhancedApiResponse.success(
          data: smartResult['answer'],
          source: 'Smart API',
          service: 'smart',
          confidence: smartResult['confidence']?.toDouble(),
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
    bool preferModular = true,
  }) async {
    try {
      if (preferModular && connectionState.isHealthy) {
        // Tentar serviço modular primeiro
        final modularResult = await _modularService.agricultureQuery(
          question: question,
          language: language,
          cropType: cropType,
        );
        
        if (modularResult.success && modularResult.data != null) {
          return EnhancedApiResponse.success(
            data: modularResult.data!['answer'] ?? modularResult.data.toString(),
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
        question,
        language: language,
      );
      
      if (smartResult['answer'] != null) {
        return EnhancedApiResponse.success(
          data: smartResult['answer'],
          source: 'Smart API',
          service: 'smart',
          confidence: smartResult['confidence']?.toDouble(),
        );
      }
      
      return EnhancedApiResponse.error('Ambos os serviços falharam na consulta agrícola');
    } catch (e) {
      return EnhancedApiResponse.error('Erro na consulta agrícola: $e');
    }
  }
  
  void _onConnectionStateChanged(conn_state.ConnectionState state) {
    // Reagir a mudanças no estado da conexão
    if (!state.isConnected) {
      _emitEvent(ApiEvent.error('Conexão perdida: ${state.lastError}'));
    }
  }
  
  void _emitEvent(ApiEvent event) {
    _eventController.add(event);
  }
  
  /// Limpar recursos
  void dispose() {
    _eventController.close();
    _modularService.dispose();
  }
}