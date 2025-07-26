/// Configurações de Conexão Backend-Flutter
/// Otimizado para o backend modular Bu Fala
library;

class BackendConnectionConfig {
  // URLs base para diferentes ambientes
  static const String _localUrl = 'http://10.0.2.2:5000';
  static const String _productionUrl = 'https://bufala-api.herokuapp.com';
  static const String _developmentUrl = 'http://localhost:5000';
  
  // URL ativa (pode ser alterada dinamicamente)
  static String get baseUrl => _localUrl;
  
  // Timeouts otimizados para diferentes tipos de requisição
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeoutShort = Duration(minutes: 2);
  static const Duration receiveTimeoutMedium = Duration(minutes: 5);
  static const Duration receiveTimeoutLong = Duration(minutes: 8);
  static const Duration sendTimeout = Duration(minutes: 2);
  
  // Headers padrão
  static const Map<String, String> defaultHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'User-Agent': 'Bu-Fala-Flutter/2.0',
    'Keep-Alive': 'timeout=120, max=100',
    'X-Client-Version': '2.0.0',
    'X-Platform': 'flutter',
  };
  
  // Configurações de retry
  static const int maxRetries = 3;
  static const Duration retryInterval = Duration(seconds: 2);
  
  // Endpoints disponíveis no backend modular
  static const Map<String, String> endpoints = {
    // Endpoints principais
    'health': '/health',
    'medical': '/medical',
    'education': '/education',
    'agriculture': '/agriculture',
    'translate': '/translate',
    'multimodal': '/multimodal',
    
    // Novos endpoints do backend modular
    'wellness': '/wellness',
    'accessibility': '/accessibility',
    'environmental': '/environmental',
    'collaborative': '/collaborative',
    'international': '/international',
    
    // Endpoints específicos
    'medical_emergency': '/medical/emergency',
    'education_lesson': '/education/lesson',
    'agriculture_diagnosis': '/agriculture/diagnosis',
    'wellness_plan': '/wellness/plan',
    'accessibility_voice': '/accessibility/voice',
    'environmental_tips': '/environmental/tips',
  };
  
  // Configurações específicas por endpoint
  static Duration getTimeoutForEndpoint(String endpoint) {
    switch (endpoint) {
      case '/health':
        return receiveTimeoutShort;
      case '/medical':
      case '/education':
      case '/agriculture':
        return receiveTimeoutMedium;
      case '/multimodal':
      case '/accessibility/voice':
        return receiveTimeoutLong;
      default:
        return receiveTimeoutMedium;
    }
  }
  
  // Configurações de cache
  static const Duration cacheTimeout = Duration(minutes: 5);
  static const int maxCacheSize = 50;
  
  // Configurações de logging
  static const bool enableDetailedLogging = true;
  static const bool enablePerformanceMetrics = true;
  
  // Configurações de fallback
  static const bool enableFallbackResponses = true;
  static const Duration fallbackTimeout = Duration(seconds: 10);
  
  // Configurações multimodais
  static const int maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int maxAudioDurationSeconds = 60;
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> supportedAudioFormats = ['wav', 'mp3', 'm4a'];
  
  // Configurações de conectividade
  static const Duration connectivityCheckInterval = Duration(seconds: 30);
  static const int maxConnectionAttempts = 5;
  
  // Configurações de qualidade de resposta
  static const int minResponseLength = 50;
  static const double minConfidenceScore = 0.6;
  
  // Configurações de idioma
  static const String defaultLanguage = 'pt-BR';
  static const List<String> supportedLanguages = [
    'pt-BR',
    'crioulo-gb',
    'en-US',
    'fr-FR',
    'es-ES'
  ];
  
  // Configurações de contexto
  static const Map<String, Map<String, dynamic>> contextConfigs = {
    'medical': {
      'priority': 'high',
      'timeout_preference': 'balanced',
      'fallback_enabled': true,
      'cache_enabled': false,
    },
    'education': {
      'priority': 'medium',
      'timeout_preference': 'fast',
      'fallback_enabled': true,
      'cache_enabled': true,
    },
    'agriculture': {
      'priority': 'medium',
      'timeout_preference': 'balanced',
      'fallback_enabled': true,
      'cache_enabled': true,
    },
    'wellness': {
      'priority': 'low',
      'timeout_preference': 'fast',
      'fallback_enabled': true,
      'cache_enabled': true,
    },
    'accessibility': {
      'priority': 'high',
      'timeout_preference': 'balanced',
      'fallback_enabled': false,
      'cache_enabled': false,
    },
  };
  
  // Método para obter configuração específica de contexto
  static Map<String, dynamic> getContextConfig(String context) => contextConfigs[context] ?? {
      'priority': 'medium',
      'timeout_preference': 'balanced',
      'fallback_enabled': true,
      'cache_enabled': true,
    };
  
  // Método para verificar se endpoint está disponível
  static bool isEndpointAvailable(String endpoint) => endpoints.containsValue(endpoint) || endpoints.containsKey(endpoint);
  
  // Método para obter URL completa do endpoint
  static String getFullUrl(String endpoint) {
    final endpointPath = endpoints[endpoint] ?? endpoint;
    return '$baseUrl$endpointPath';
  }
  
  // Configurações de desenvolvimento
  static const bool isDevelopment = true;
  static const bool enableMockResponses = false;
  static const bool enableOfflineMode = true;
}

/// Classe para gerenciar estado da conexão
class ConnectionState {
  
  const ConnectionState({
    required this.isConnected,
    required this.lastCheck, this.lastError,
    this.responseTime = 0.0,
  });
  final bool isConnected;
  final String? lastError;
  final DateTime lastCheck;
  final double responseTime;
  
  bool get isHealthy => isConnected && responseTime < 5.0;
  bool get needsCheck => DateTime.now().difference(lastCheck) > 
      BackendConnectionConfig.connectivityCheckInterval;
}

/// Enums para melhor tipagem
enum RequestPriority { low, medium, high, critical }
enum TimeoutPreference { fast, balanced, thorough }
enum CacheStrategy { none, short, medium, long }