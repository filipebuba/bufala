import 'integrated_api_service.dart';

/// Serviço de API unificado - versão integrada com backend_novo
abstract class IApiService {
  Future<Map<String, dynamic>> getHealthInfo(String query);

  Future<Map<String, dynamic>> getEducationInfo(String query);

  Future<Map<String, dynamic>> getAgricultureInfo(String query);

  Future<Map<String, dynamic>> validatePhrase(Map<String, dynamic> phraseData);
}

class ApiService implements IApiService {
  factory ApiService() => _instance;
  ApiService._internal();
  static final ApiService _instance = ApiService._internal();

  final IntegratedApiService _integratedService = IntegratedApiService();

  /// Verificar conectividade com a internet
  Future<bool> checkConnectivity() async => _integratedService.hasInternetConnection();

  /// Verificar saúde do backend
  Future<bool> healthCheck() async => _integratedService.healthCheck();

  @override
  Future<Map<String, dynamic>> getHealthInfo(String query) async => _integratedService.getHealthInfo(query);

  @override
  Future<Map<String, dynamic>> getEducationInfo(String query) async => _integratedService.getEducationInfo(query);

  @override
  Future<Map<String, dynamic>> getAgricultureInfo(String query) async => _integratedService.getAgricultureInfo(query);

  @override
  Future<Map<String, dynamic>> validatePhrase(Map<String, dynamic> phraseData) async {
    try {
      final String text = phraseData['text'] ?? '';
      final String targetLanguage = phraseData['language'] ?? 'crioulo';
      return await _integratedService.translateText(
        text,
        fromLanguage: 'pt',
        toLanguage: targetLanguage,
      );
    } catch (e) {
      return {
        'success': false,
        'message': 'Funcionalidade de tradução temporariamente indisponível'
      };
    }
  }

  /// Fazer pergunta médica
  Future<Map<String, dynamic>> askMedicalQuestion(
    String question, {
    String language = 'pt-BR',
  }) async => _integratedService.getHealthInfo(question);

  /// Fazer pergunta educacional
  Future<Map<String, dynamic>> askEducationQuestion(
    String question, {
    String language = 'pt-BR',
  }) async => _integratedService.getEducationInfo(question);

  /// Fazer pergunta agrícola
  Future<Map<String, dynamic>> askAgricultureQuestion(
    String question, {
    String language = 'pt-BR',
  }) async => _integratedService.getAgricultureInfo(question);

  /// Descrever ambiente (para deficientes visuais)
  Future<Map<String, dynamic>> describeEnvironment(
    String imageBase64, {
    String language = 'pt-BR',
  }) async {
    final result = await _integratedService.analyzeMultimodal(
      imageBase64: imageBase64,
      text: 'Descreva o ambiente desta imagem para uma pessoa com deficiência visual',
      language: language,
    );
    return result;
  }
  
  /// Traduzir texto
  Future<Map<String, dynamic>> translateText(
    String text, {
    String fromLanguage = 'pt',
    String toLanguage = 'crioulo',
  }) async => _integratedService.translateText(
      text,
      fromLanguage: fromLanguage,
      toLanguage: toLanguage,
    );
}
