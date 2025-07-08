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
    return await _smartService.healthCheck();
  }

  /// Fazer pergunta médica
  Future<Map<String, dynamic>?> askMedicalQuestion(
    String question, {
    String language = 'pt-BR',
  }) async {
    return await _smartService.askMedicalQuestion(
      question,
      language: language,
    );
  }

  /// Fazer pergunta educacional
  Future<Map<String, dynamic>?> askEducationQuestion(
    String question, {
    String language = 'pt-BR',
  }) async {
    return await _smartService.askEducationQuestion(
      question,
      language: language,
    );
  }

  /// Fazer pergunta agrícola
  Future<Map<String, dynamic>?> askAgricultureQuestion(
    String question, {
    String language = 'pt-BR',
  }) async {
    return await _smartService.askAgricultureQuestion(
      question,
      language: language,
    );
  }

  /// Descrever ambiente (para deficientes visuais)
  Future<Map<String, dynamic>?> describeEnvironment(
    String imagePath, {
    String language = 'pt-BR',
  }) async {
    return await _smartService.describeEnvironment(
      imagePath,
      language: language,
    );
  }
}
