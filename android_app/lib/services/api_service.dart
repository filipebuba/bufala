import 'smart_api_service.dart';
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
  final SmartApiService _smartService = SmartApiService(); // Mantido para compatibilidade

  /// Verificar conectividade com a internet
  @override
  Future<bool> checkConnectivity() async {
    return await _smartService.checkConnectivity();
  }

  /// Verificar saúde do backend
  Future<bool> healthCheck() async {
    try {
      return await _integratedService.healthCheck();
    } catch (e) {
      // Fallback para o serviço antigo
      final result = await _smartService.healthCheck();
      return result.success;
    }
  }

  @override
  Future<Map<String, dynamic>> getHealthInfo(String query) async {
    try {
      return await _integratedService.getHealthInfo(query);
    } catch (e) {
      // Fallback para o serviço antigo
      final result = await _smartService.askMedicalQuestion(question: query);
      return {
        'success': result.success,
        'data': result.data,
        'error': result.error,
        'source': 'smart_api_fallback'
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getEducationInfo(String query) async {
    try {
      return await _integratedService.getEducationInfo(query);
    } catch (e) {
      // Fallback para o serviço antigo
      final result = await _smartService.askEducationQuestion(question: query);
      return {
        'success': result.success,
        'data': result.data,
        'error': result.error,
        'source': 'smart_api_fallback'
      };
    }
  }

  @override
  Future<Map<String, dynamic>> getAgricultureInfo(String query) async {
    try {
      return await _integratedService.getAgricultureInfo(query);
    } catch (e) {
      // Fallback para o serviço antigo
      final result = await _smartService.askAgricultureQuestion(question: query);
      return {
        'success': result.success,
        'data': result.data,
        'error': result.error,
        'source': 'smart_api_fallback'
      };
    }
  }

  @override
  Future<Map<String, dynamic>> validatePhrase(Map<String, dynamic> phraseData) async {
    try {
      String text = phraseData['text'] ?? '';
      String targetLanguage = phraseData['language'] ?? 'crioulo';
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
  Future<Map<String, dynamic>?> askMedicalQuestion(
    String question, {
    String language = 'pt-BR',
  }) async {
    try {
      final result = await _integratedService.askMedicalQuestion(question);
      return result;
    } catch (e) {
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
  }

  /// Fazer pergunta educacional
  Future<Map<String, dynamic>?> askEducationQuestion(
    String question, {
    String language = 'pt-BR',
  }) async {
    try {
      final result = await _integratedService.askEducationQuestion(question);
      return result;
    } catch (e) {
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
  }

  /// Fazer pergunta agrícola
  Future<Map<String, dynamic>?> askAgricultureQuestion(
    String question, {
    String language = 'pt-BR',
  }) async {
    try {
      final result = await _integratedService.askAgricultureQuestion(question);
      return result;
    } catch (e) {
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
  }

  /// Descrever ambiente (para deficientes visuais)
  Future<Map<String, dynamic>?> describeEnvironment(
    String imageBase64, {
    String language = 'pt-BR',
  }) async {
    try {
      final result = await _integratedService.analyzeMultimodal(
        imageBase64: imageBase64,
        text: 'Descreva o ambiente desta imagem para uma pessoa com deficiência visual',
        language: language,
      );
      return result;
    } catch (e) {
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
}
