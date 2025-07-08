import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// Interceptor personalizado para retry automático de requisições
class RetryInterceptor extends Interceptor {
  final int maxRetries;
  final Duration retryDelay;
  final List<int> retryStatusCodes;
  final Logger _logger = Logger();

  RetryInterceptor({
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 2),
    this.retryStatusCodes = const [500, 502, 503, 504, 408],
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    final retryCount = requestOptions.extra['retry_count'] ?? 0;

    // Verificar se deve tentar novamente
    if (_shouldRetry(err, retryCount)) {
      _logger.w('Tentativa ${retryCount + 1}/$maxRetries para ${requestOptions.path}');
      
      // Aguardar antes de tentar novamente
      await Future.delayed(retryDelay * (retryCount + 1));
      
      // Incrementar contador de tentativas
      requestOptions.extra['retry_count'] = retryCount + 1;
      
      try {
        // Tentar novamente
        final response = await Dio().fetch(requestOptions);
        handler.resolve(response);
        return;
      } catch (e) {
        // Se falhar novamente, continuar com o erro original
        _logger.e('Retry ${retryCount + 1} falhou: $e');
      }
    }

    // Se não deve tentar novamente ou esgotou tentativas
    _logger.e('Falha definitiva após $retryCount tentativas: ${err.message}');
    handler.next(err);
  }

  bool _shouldRetry(DioException err, int retryCount) {
    // Não tentar novamente se já esgotou as tentativas
    if (retryCount >= maxRetries) {
      return false;
    }

    // Tentar novamente para erros de conexão
    if (err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError) {
      return true;
    }

    // Tentar novamente para códigos de status específicos
    if (err.response?.statusCode != null &&
        retryStatusCodes.contains(err.response!.statusCode)) {
      return true;
    }

    return false;
  }
}

/// Interceptor para logging detalhado de requisições
class LoggingInterceptor extends Interceptor {
  final Logger _logger = Logger();
  final bool logRequestBody;
  final bool logResponseBody;

  LoggingInterceptor({
    this.logRequestBody = true,
    this.logResponseBody = true,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.i('🚀 REQUEST: ${options.method} ${options.path}');
    
    if (options.queryParameters.isNotEmpty) {
      _logger.d('Query: ${options.queryParameters}');
    }
    
    if (logRequestBody && options.data != null) {
      _logger.d('Body: ${options.data}');
    }
    
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.i('✅ RESPONSE: ${response.statusCode} ${response.requestOptions.path}');
    
    if (logResponseBody && response.data != null) {
      _logger.d('Response: ${response.data}');
    }
    
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('❌ ERROR: ${err.requestOptions.method} ${err.requestOptions.path}');
    _logger.e('Message: ${err.message}');
    
    if (err.response != null) {
      _logger.e('Status: ${err.response?.statusCode}');
      _logger.e('Data: ${err.response?.data}');
    }
    
    handler.next(err);
  }
}

/// Interceptor para cache simples de requisições
class CacheInterceptor extends Interceptor {
  final Map<String, CacheEntry> _cache = {};
  final Duration cacheDuration;
  final Logger _logger = Logger();

  CacheInterceptor({
    this.cacheDuration = const Duration(minutes: 5),
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Apenas cachear requisições GET
    if (options.method.toUpperCase() != 'GET') {
      handler.next(options);
      return;
    }

    final cacheKey = _generateCacheKey(options);
    final cachedEntry = _cache[cacheKey];

    if (cachedEntry != null && !cachedEntry.isExpired) {
      _logger.d('📦 Cache HIT: ${options.path}');
      handler.resolve(cachedEntry.response);
      return;
    }

    _logger.d('📦 Cache MISS: ${options.path}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Apenas cachear respostas GET bem-sucedidas
    if (response.requestOptions.method.toUpperCase() == 'GET' &&
        response.statusCode == 200) {
      final cacheKey = _generateCacheKey(response.requestOptions);
      _cache[cacheKey] = CacheEntry(
        response: response,
        timestamp: DateTime.now(),
        duration: cacheDuration,
      );
      _logger.d('📦 Cache STORE: ${response.requestOptions.path}');
    }

    handler.next(response);
  }

  String _generateCacheKey(RequestOptions options) {
    return '${options.method}_${options.path}_${options.queryParameters.toString()}';
  }

  void clearCache() {
    _cache.clear();
    _logger.i('📦 Cache cleared');
  }
}

class CacheEntry {
  final Response response;
  final DateTime timestamp;
  final Duration duration;

  CacheEntry({
    required this.response,
    required this.timestamp,
    required this.duration,
  });

  bool get isExpired => DateTime.now().difference(timestamp) > duration;
}