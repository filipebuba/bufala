import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

import 'backend_connection_config.dart';
import 'connection_state.dart' as conn_state;
import 'retry_interceptor.dart';

/// Serviço Modular para conexão com Backend Bu Fala
/// Otimizado para trabalhar com a arquitetura modular do backend
class ModularBackendService {
  
  ModularBackendService._() {
    _initializeDio();
    _startConnectivityMonitoring();
  }
  static ModularBackendService? _instance;
  static ModularBackendService get instance => _instance ??= ModularBackendService._();
  
  late final Dio _dio;
  conn_state.ConnectionState _connectionState = conn_state.ConnectionState(
    isConnected: false,
    lastCheck: DateTime.now(),
  );
  
  final Map<String, dynamic> _responseCache = {};
  Timer? _connectivityTimer;

  /// Inicializar o serviço
  Future<void> initialize() async {
    // Implementação da inicialização
    await _performInitialHealthCheck();
  }

  /// Iniciar monitoramento de conectividade
  void startMonitoring() {
    _startConnectivityMonitoring();
  }

  /// Parar monitoramento
  void stopMonitoring() {
    _connectivityTimer?.cancel();
  }

  /// Stream do estado da conexão
  Stream<conn_state.ConnectionState> get connectionStream => Stream.periodic(const Duration(seconds: 5), (_) => _connectionState);
  
  void _initializeDio() {
    _dio = Dio(BaseOptions(
      baseUrl: BackendConnectionConfig.baseUrl,
      connectTimeout: BackendConnectionConfig.connectTimeout,
      receiveTimeout: BackendConnectionConfig.receiveTimeoutMedium,
      sendTimeout: BackendConnectionConfig.sendTimeout,
      headers: BackendConnectionConfig.defaultHeaders,
    ));
    
    // Configurar interceptors personalizados
    _dio.interceptors.add(RetryInterceptor(
      
    ));
    
    _dio.interceptors.add(LoggingInterceptor(
      
    ));
    
    _dio.interceptors.add(CacheInterceptor(
      
    ));
    
    // Interceptor de métricas de performance
    if (BackendConnectionConfig.enablePerformanceMetrics) {
      _dio.interceptors.add(_createPerformanceInterceptor());
    }
  }
  
  InterceptorsWrapper _createLoggingInterceptor() => InterceptorsWrapper(
      onRequest: (options, handler) {
        print('[🔄 MODULAR-API] ${options.method} ${options.path}');
        print('[📋 MODULAR-API] Headers: ${options.headers}');
        if (options.data != null) {
          final dataStr = jsonEncode(options.data).substring(0, 200);
          print('[📦 MODULAR-API] Data: $dataStr...');
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        print('[✅ MODULAR-API] ${response.statusCode} - ${response.requestOptions.path}');
        print('[⏱️ MODULAR-API] Tempo: ${response.extra['response_time'] ?? 'N/A'}ms');
        handler.next(response);
      },
      onError: (error, handler) {
        print('[❌ MODULAR-API] Erro: ${error.type}');
        print('[❌ MODULAR-API] Mensagem: ${error.message}');
        if (error.response != null) {
          print('[❌ MODULAR-API] Status: ${error.response!.statusCode}');
        }
        handler.next(error);
      },
    );
  
  InterceptorsWrapper _createRetryInterceptor() => InterceptorsWrapper(
      onError: (error, handler) async {
        if (_shouldRetry(error)) {
          final retryCount = error.requestOptions.extra['retry_count'] ?? 0;
          if (retryCount < BackendConnectionConfig.maxRetries) {
            print('[🔄 MODULAR-API] Tentativa ${retryCount + 1}/${BackendConnectionConfig.maxRetries}');
            
            await Future.delayed(BackendConnectionConfig.retryInterval);
            
            final newOptions = error.requestOptions.copyWith(
              extra: {...error.requestOptions.extra, 'retry_count': retryCount + 1},
            );
            
            try {
              final response = await _dio.fetch(newOptions);
              handler.resolve(response);
              return;
            } catch (e) {
              // Continue para o próximo retry ou falha final
            }
          }
        }
        handler.next(error);
      },
    );
  
  InterceptorsWrapper _createCacheInterceptor() => InterceptorsWrapper(
      onRequest: (options, handler) {
        if (options.method == 'GET' && _shouldUseCache(options.path)) {
          final cacheKey = _getCacheKey(options);
          final cachedResponse = _responseCache[cacheKey];
          
          if (cachedResponse != null && _isCacheValid(cachedResponse)) {
            print('[💾 MODULAR-API] Cache hit: ${options.path}');
            handler.resolve(Response(
              requestOptions: options,
              data: cachedResponse['data'],
              statusCode: 200,
              extra: {'from_cache': true},
            ));
            return;
          }
        }
        handler.next(options);
      },
      onResponse: (response, handler) {
        if (response.requestOptions.method == 'GET' && 
            _shouldUseCache(response.requestOptions.path)) {
          final cacheKey = _getCacheKey(response.requestOptions);
          _responseCache[cacheKey] = {
            'data': response.data,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          };
          
          // Limpar cache se necessário
          if (_responseCache.length > BackendConnectionConfig.maxCacheSize) {
            _cleanupCache();
          }
        }
        handler.next(response);
      },
    );
  
  InterceptorsWrapper _createPerformanceInterceptor() => InterceptorsWrapper(
      onRequest: (options, handler) {
        options.extra['start_time'] = DateTime.now().millisecondsSinceEpoch;
        handler.next(options);
      },
      onResponse: (response, handler) {
        final startTime = response.requestOptions.extra['start_time'] as int?;
        if (startTime != null) {
          final responseTime = DateTime.now().millisecondsSinceEpoch - startTime;
          response.extra['response_time'] = responseTime;
          
          // Atualizar estado da conexão
          _updateConnectionState(true, responseTime.toDouble());
        }
        handler.next(response);
      },
      onError: (error, handler) {
        _updateConnectionState(false, 0, error.message);
        handler.next(error);
      },
    );
  
  bool _shouldRetry(DioException error) => error.type == DioExceptionType.connectionTimeout ||
           error.type == DioExceptionType.receiveTimeout ||
           error.type == DioExceptionType.connectionError ||
           (error.response?.statusCode ?? 0) >= 500;
  
  bool _shouldUseCache(String path) {
    final nonCacheablePaths = ['/health', '/medical', '/accessibility/voice'];
    return !nonCacheablePaths.any((p) => path.contains(p));
  }
  
  String _getCacheKey(RequestOptions options) => '${options.method}_${options.path}_${jsonEncode(options.queryParameters)}';
  
  bool _isCacheValid(Map<String, dynamic> cachedItem) {
    final timestamp = cachedItem['timestamp'] as int;
    final age = DateTime.now().millisecondsSinceEpoch - timestamp;
    return age < BackendConnectionConfig.cacheTimeout.inMilliseconds;
  }
  
  void _cleanupCache() {
    final now = DateTime.now().millisecondsSinceEpoch;
    _responseCache.removeWhere((key, value) {
      final timestamp = value['timestamp'] as int;
      return now - timestamp > BackendConnectionConfig.cacheTimeout.inMilliseconds;
    });
  }
  
  void _updateConnectionState(bool isConnected, double responseTime, [String? error]) {
    _connectionState = conn_state.ConnectionState(
      isConnected: isConnected,
      lastError: error,
      lastCheck: DateTime.now(),
      responseTime: responseTime,
    );
  }
  
  void _startConnectivityMonitoring() {
    _connectivityTimer?.cancel(); // Cancel previous timer if any
    _connectivityTimer = Timer.periodic(
      BackendConnectionConfig.connectivityCheckInterval,
      (_) => _checkConnectivity(),
    );
  }

  Future<void> _performInitialHealthCheck() async {
    try {
      final result = await healthCheck();
      if (result.success) {
        _updateConnectionState(true, result.responseTime ?? 0.0);
      } else {
        _updateConnectionState(false, 0, result.error);
      }
    } catch (e) {
      _updateConnectionState(false, 0, e.toString());
    }
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await healthCheck();
      if (result.success) {
        _updateConnectionState(true, result.responseTime ?? 0.0);
      } else {
        _updateConnectionState(false, 0, result.error);
      }
    } catch (e) {
      _updateConnectionState(false, 0, e.toString());
    }
  }

  void _updateConnectionState(bool isConnected, double responseTime, [String? error]) {
    _connectionState = conn_state.ConnectionState(
      isConnected: isConnected,
      lastCheck: DateTime.now(),
      responseTime: responseTime,
      lastError: error,
      consecutiveFailures: isConnected ? 0 : _connectionState.consecutiveFailures + 1,
    );
  }

  
  Future<void> _checkConnectivity() async {
    try {
      final response = await _dio.get('/health', 
        options: Options(receiveTimeout: const Duration(seconds: 5)));
      _updateConnectionState(true, 0);
    } catch (e) {
      _updateConnectionState(false, 0, e.toString());
    }
  }
  
  // Métodos públicos para diferentes domínios
  
  /// Health Check
  Future<ModularApiResponse<Map<String, dynamic>>> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return ModularApiResponse.success(
        data: response.data,
        source: 'Backend Modular',
        fromCache: response.extra['from_cache'] == true,
      );
    } catch (e) {
      return ModularApiResponse.error('Health check falhou: $e');
    }
  }
  
  /// Consulta Médica
  Future<ModularApiResponse<String>> medicalQuery({
    required String question,
    String language = 'pt-BR',
    bool isEmergency = false,
  }) async {
    try {
      final endpoint = isEmergency ? '/medical/emergency' : '/medical';
      final timeout = BackendConnectionConfig.getTimeoutForEndpoint(endpoint);
      
      final response = await _dio.post(
        endpoint,
        data: {
          'question': question,
          'language': language,
          'context': 'medical',
          'priority': isEmergency ? 'critical' : 'high',
          'timestamp': DateTime.now().toIso8601String(),
        },
        options: Options(receiveTimeout: timeout),
      );
      
      return _processStandardResponse(response, 'Consulta Médica');
    } catch (e) {
      if (BackendConnectionConfig.enableFallbackResponses) {
        return _getMedicalFallback(question, language);
      }
      return ModularApiResponse.error('Erro na consulta médica: $e');
    }
  }
  
  /// Consulta Educacional
  Future<ModularApiResponse<String>> educationQuery({
    required String question,
    String language = 'pt-BR',
    String subject = 'general',
    String level = 'básico',
  }) async {
    try {
      final response = await _dio.post(
        '/education',
        data: {
          'question': question,
          'language': language,
          'subject': subject,
          'level': level,
          'context': 'education',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      return _processStandardResponse(response, 'Consulta Educacional');
    } catch (e) {
      return ModularApiResponse.error('Erro na consulta educacional: $e');
    }
  }
  
  /// Consulta Agrícola
  Future<ModularApiResponse<String>> agricultureQuery({
    required String question,
    String language = 'pt-BR',
    String cropType = 'general',
    String season = 'current',
  }) async {
    try {
      final response = await _dio.post(
        '/agriculture',
        data: {
          'question': question,
          'language': language,
          'crop_type': cropType,
          'season': season,
          'context': 'agriculture',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      return _processStandardResponse(response, 'Consulta Agrícola');
    } catch (e) {
      return ModularApiResponse.error('Erro na consulta agrícola: $e');
    }
  }
  
  /// Consulta de Bem-estar
  Future<ModularApiResponse<String>> wellnessQuery({
    required String question,
    String language = 'pt-BR',
    String category = 'general',
  }) async {
    try {
      final response = await _dio.post(
        '/wellness',
        data: {
          'question': question,
          'language': language,
          'category': category,
          'context': 'wellness',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      
      return _processStandardResponse(response, 'Consulta de Bem-estar');
    } catch (e) {
      return ModularApiResponse.error('Erro na consulta de bem-estar: $e');
    }
  }
  
  /// Serviço de Acessibilidade
  Future<ModularApiResponse<String>> accessibilityQuery({
    required String text,
    String language = 'pt-BR',
    String mode = 'voice',
  }) async {
    try {
      final response = await _dio.post(
        '/accessibility/$mode',
        data: {
          'text': text,
          'language': language,
          'context': 'accessibility',
          'timestamp': DateTime.now().toIso8601String(),
        },
        options: Options(
          receiveTimeout: BackendConnectionConfig.receiveTimeoutLong,
        ),
      );
      
      return _processStandardResponse(response, 'Serviço de Acessibilidade');
    } catch (e) {
      return ModularApiResponse.error('Erro no serviço de acessibilidade: $e');
    }
  }
  
  ModularApiResponse<String> _processStandardResponse(Response response, String source) {
    if (response.statusCode == 200 && response.data != null) {
      final data = response.data as Map<String, dynamic>;
      
      if (data['success'] == true && data['data'] != null) {
        final answer = data['data']['answer'] ?? data['data'].toString();
        final confidence = data['data']['confidence'] ?? 0.8;
        
        return ModularApiResponse.success(
          data: answer,
          source: source,
          confidence: confidence,
          fromCache: response.extra['from_cache'] == true,
          responseTime: response.extra['response_time']?.toDouble(),
        );
      }
    }
    
    return ModularApiResponse.error('Resposta inválida do servidor');
  }
  
  ModularApiResponse<String> _getMedicalFallback(String question, String language) {
    final fallbackResponses = {
      'dor': 'Para dores persistentes, recomendo aplicar gelo por 15-20 minutos e procurar um médico se não melhorar.',
      'febre': 'Para febre, mantenha-se hidratado, descanse e procure atendimento médico se a temperatura passar de 38.5°C.',
      'tosse': 'Para tosse, beba bastante água morna com mel e procure um médico se persistir por mais de uma semana.',
    };
    
    final lowerQuestion = question.toLowerCase();
    for (final key in fallbackResponses.keys) {
      if (lowerQuestion.contains(key)) {
        return ModularApiResponse.success(
          data: fallbackResponses[key]!,
          source: 'Resposta de Emergência',
          confidence: 0.6,
        );
      }
    }
    
    return ModularApiResponse.success(
      data: 'Para qualquer problema de saúde, recomendo procurar atendimento médico adequado. Em emergências, ligue para 192.',
      source: 'Resposta de Emergência Geral',
      confidence: 0.5,
    );
  }
  
  // Getters para estado da conexão
  conn_state.ConnectionState get connectionState => _connectionState;
  bool get isConnected => _connectionState.isConnected;
  bool get isHealthy => _connectionState.isHealthy;
  
  // Cleanup
  void dispose() {
    _connectivityTimer?.cancel();
    _responseCache.clear();
  }
}

/// Classe de resposta padronizada
class ModularApiResponse<T> {
  
  const ModularApiResponse._({
    required this.success,
    required this.source, this.data,
    this.error,
    this.confidence = 1.0,
    this.fromCache = false,
    this.responseTime,
  });
  
  factory ModularApiResponse.success({
    required T data,
    required String source,
    double confidence = 1.0,
    bool fromCache = false,
    double? responseTime,
  }) => ModularApiResponse._(
      success: true,
      data: data,
      source: source,
      confidence: confidence,
      fromCache: fromCache,
      responseTime: responseTime,
    );
  
  factory ModularApiResponse.error(String error) => ModularApiResponse._(
      success: false,
      error: error,
      source: 'Erro',
    );
  final bool success;
  final T? data;
  final String? error;
  final String source;
  final double confidence;
  final bool fromCache;
  final double? responseTime;
  
  bool get isFromCache => fromCache;
  bool get isHighConfidence => confidence >= 0.8;
  bool get isFastResponse => responseTime != null && responseTime! < 2000;
}