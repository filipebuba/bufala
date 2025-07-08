import 'smart_api_service.dart';

/// Serviço de API unificado - versão simplificada
class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final SmartApiService _smartService = SmartApiService();

  /// Verificar conectividade com a internet
  Future<bool> hasInternetConnection() async {
    return await _smartService.hasInternetConnection();
  }

  /// Health check do backend
  Future<bool> healthCheck() async {
    final result = await _smartService.healthCheck();
    return result.success;
  }

  /// Fazer pergunta médica
  Future<Map<String, dynamic>?> askMedicalQuestion(
    String question, {
    String language = 'pt-BR',
  }) async {
    final result = await _smartService.askMedicalQuestion(
      question: question,
      language: language,
    );
    return {
      'success': result.success,
      'data': result.data,
      'error': result.error
    };
  }

  /// Fazer pergunta educacional
  Future<Map<String, dynamic>?> askEducationQuestion(
    String question, {
    String language = 'pt-BR',
  }) async {
    final result = await _smartService.askEducationQuestion(
      question: question,
      language: language,
    );
    return {
      'success': result.success,
      'data': result.data,
      'error': result.error
    };
  }

  /// Fazer pergunta agrícola
  Future<Map<String, dynamic>?> askAgricultureQuestion(
    String question, {
    String language = 'pt-BR',
  }) async {
    final result = await _smartService.askAgricultureQuestion(
      question: question,
      language: language,
    );
    return {
      'success': result.success,
      'data': result.data,
      'error': result.error
    };
  }

  /// Descrever ambiente (para deficientes visuais)
  Future<Map<String, dynamic>?> describeEnvironment(
    String imageBase64, {
    String language = 'pt-BR',
  }) async {
    final result = await _smartService.describeEnvironment(
      imageBase64: imageBase64,
      language: language,
    );
    return {
      'success': result.success,
      'data': result.data,
      'error': result.error
    };
  }
}
