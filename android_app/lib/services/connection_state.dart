import 'dart:async';

/// Estado da conexão com o backend modular
class ConnectionState {
  
  const ConnectionState({
    required this.isConnected,
    required this.lastCheck, this.lastError,
    this.responseTime,
    this.consecutiveFailures = 0,
    this.metrics = const {},
  });
  final bool isConnected;
  final String? lastError;
  final DateTime lastCheck;
  final double? responseTime;
  final int consecutiveFailures;
  final Map<String, dynamic> metrics;
  
  /// Verifica se a conexão está saudável
  bool get isHealthy {
    if (!isConnected) return false;
    if (consecutiveFailures > 3) return false;
    if (responseTime != null && responseTime! > 10000) return false; // > 10s
    return true;
  }
  
  /// Qualidade da conexão baseada no tempo de resposta
  ConnectionQuality get quality {
    if (!isConnected) return ConnectionQuality.offline;
    if (responseTime == null) return ConnectionQuality.unknown;
    
    if (responseTime! < 1000) return ConnectionQuality.excellent;
    if (responseTime! < 3000) return ConnectionQuality.good;
    if (responseTime! < 6000) return ConnectionQuality.fair;
    return ConnectionQuality.poor;
  }
  
  /// Status textual da conexão
  String get statusText {
    if (!isConnected) {
      return lastError != null ? 'Desconectado: $lastError' : 'Desconectado';
    }
    
    switch (quality) {
      case ConnectionQuality.excellent:
        return 'Conexão excelente (${responseTime?.toInt()}ms)';
      case ConnectionQuality.good:
        return 'Conexão boa (${responseTime?.toInt()}ms)';
      case ConnectionQuality.fair:
        return 'Conexão regular (${responseTime?.toInt()}ms)';
      case ConnectionQuality.poor:
        return 'Conexão lenta (${responseTime?.toInt()}ms)';
      case ConnectionQuality.offline:
        return 'Offline';
      case ConnectionQuality.unknown:
        return 'Conectado';
    }
  }
  
  /// Ícone representativo do estado
  String get statusIcon {
    switch (quality) {
      case ConnectionQuality.excellent:
        return '🟢';
      case ConnectionQuality.good:
        return '🟡';
      case ConnectionQuality.fair:
        return '🟠';
      case ConnectionQuality.poor:
        return '🔴';
      case ConnectionQuality.offline:
        return '⚫';
      case ConnectionQuality.unknown:
        return '⚪';
    }
  }
  
  /// Cria uma nova instância com valores atualizados
  ConnectionState copyWith({
    bool? isConnected,
    String? lastError,
    DateTime? lastCheck,
    double? responseTime,
    int? consecutiveFailures,
    Map<String, dynamic>? metrics,
  }) => ConnectionState(
      isConnected: isConnected ?? this.isConnected,
      lastError: lastError ?? this.lastError,
      lastCheck: lastCheck ?? this.lastCheck,
      responseTime: responseTime ?? this.responseTime,
      consecutiveFailures: consecutiveFailures ?? this.consecutiveFailures,
      metrics: metrics ?? this.metrics,
    );
  
  /// Incrementa falhas consecutivas
  ConnectionState withFailure(String error) => copyWith(
      isConnected: false,
      lastError: error,
      lastCheck: DateTime.now(),
      consecutiveFailures: consecutiveFailures + 1,
    );
  
  /// Reseta para estado de sucesso
  ConnectionState withSuccess({double? responseTime}) => copyWith(
      isConnected: true,
      lastCheck: DateTime.now(),
      responseTime: responseTime,
      consecutiveFailures: 0,
    );
  
  @override
  String toString() => 'ConnectionState(connected: $isConnected, quality: $quality, responseTime: ${responseTime}ms)';
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConnectionState &&
        other.isConnected == isConnected &&
        other.lastError == lastError &&
        other.responseTime == responseTime &&
        other.consecutiveFailures == consecutiveFailures;
  }
  
  @override
  int get hashCode => Object.hash(
      isConnected,
      lastError,
      responseTime,
      consecutiveFailures,
    );
}

/// Qualidade da conexão
enum ConnectionQuality {
  excellent,  // < 1s
  good,       // 1-3s
  fair,       // 3-6s
  poor,       // > 6s
  offline,    // Sem conexão
  unknown,    // Estado desconhecido
}

/// Monitor de conexão em tempo real
class ConnectionMonitor {
  
  ConnectionMonitor._();
  static ConnectionMonitor? _instance;
  static ConnectionMonitor get instance => _instance ??= ConnectionMonitor._();
  
  final StreamController<ConnectionState> _stateController = 
      StreamController<ConnectionState>.broadcast();
  
  ConnectionState _currentState = ConnectionState(
    isConnected: false,
    lastCheck: DateTime.now(),
  );
  
  /// Stream do estado da conexão
  Stream<ConnectionState> get stateStream => _stateController.stream;
  
  /// Estado atual da conexão
  ConnectionState get currentState => _currentState;
  
  /// Atualiza o estado da conexão
  void updateState(ConnectionState newState) {
    if (_currentState != newState) {
      _currentState = newState;
      _stateController.add(newState);
    }
  }
  
  /// Registra uma falha de conexão
  void recordFailure(String error) {
    updateState(_currentState.withFailure(error));
  }
  
  /// Registra um sucesso de conexão
  void recordSuccess({double? responseTime}) {
    updateState(_currentState.withSuccess(responseTime: responseTime));
  }
  
  /// Limpa recursos
  void dispose() {
    _stateController.close();
  }
}

/// Métricas de performance da conexão
class ConnectionMetrics {
  final List<double> _responseTimes = [];
  final List<DateTime> _requestTimes = [];
  final Map<String, int> _errorCounts = {};
  
  static const int _maxSamples = 100;
  
  /// Adiciona uma medição de tempo de resposta
  void addResponseTime(double responseTime) {
    _responseTimes.add(responseTime);
    _requestTimes.add(DateTime.now());
    
    // Manter apenas as últimas medições
    if (_responseTimes.length > _maxSamples) {
      _responseTimes.removeAt(0);
      _requestTimes.removeAt(0);
    }
  }
  
  /// Adiciona um erro
  void addError(String errorType) {
    _errorCounts[errorType] = (_errorCounts[errorType] ?? 0) + 1;
  }
  
  /// Tempo médio de resposta
  double get averageResponseTime {
    if (_responseTimes.isEmpty) return 0;
    return _responseTimes.reduce((a, b) => a + b) / _responseTimes.length;
  }
  
  /// Tempo mínimo de resposta
  double get minResponseTime {
    if (_responseTimes.isEmpty) return 0;
    return _responseTimes.reduce((a, b) => a < b ? a : b);
  }
  
  /// Tempo máximo de resposta
  double get maxResponseTime {
    if (_responseTimes.isEmpty) return 0;
    return _responseTimes.reduce((a, b) => a > b ? a : b);
  }
  
  /// Taxa de sucesso (últimas 24h)
  double get successRate {
    final now = DateTime.now();
    final last24h = now.subtract(const Duration(hours: 24));
    
    final recentRequests = _requestTimes.where((time) => time.isAfter(last24h)).length;
    final totalErrors = _errorCounts.values.fold(0, (sum, count) => sum + count);
    
    if (recentRequests == 0) return 1;
    return (recentRequests - totalErrors) / recentRequests;
  }
  
  /// Estatísticas resumidas
  Map<String, dynamic> get summary => {
    'average_response_time': averageResponseTime,
    'min_response_time': minResponseTime,
    'max_response_time': maxResponseTime,
    'success_rate': successRate,
    'total_requests': _responseTimes.length,
    'error_counts': Map.from(_errorCounts),
  };
  
  /// Limpa todas as métricas
  void clear() {
    _responseTimes.clear();
    _requestTimes.clear();
    _errorCounts.clear();
  }
}