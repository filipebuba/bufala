import 'dart:io';

import 'package:dio/dio.dart';

/// Classe de serviço para comunicação com a API
class ApiService {
  factory ApiService() => _instance;
  ApiService._internal();
  static final ApiService _instance = ApiService._internal();

  late final Dio _dio;
  static const Duration longTimeoutDuration = Duration(minutes: 5);

  /// Inicializa o serviço
  void initialize() {
    _dio = Dio(BaseOptions(
      baseUrl: 'http://10.0.2.2:5000',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 2),
      sendTimeout: const Duration(minutes: 2),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: print,
    ));
  }

  /// Verifica conectividade
  Future<bool> hasInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Health check da API
  Future<ApiResponse<Map<String, dynamic>>> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return ApiResponse.success(response.data as Map<String, dynamic>);
    } catch (e) {
      print('Erro no health check: $e');
      return ApiResponse.error('Erro na conexão com o servidor');
    }
  }

  /// Pergunta médica
  Future<ApiResponse<MedicalResponse>> askMedicalQuestion({
    required String question,
    String language = 'pt-BR',
    String? context,
  }) async {
    try {
      print('[API] 🏥 Enviando pergunta médica: $question');

      final response = await _dio.post<Map<String, dynamic>>(
        '/medical',
        data: {
          'question': question,
          'language': language,
          'context': context,
        },
      );

      print('[API] ✅ Resposta médica recebida');

      return ApiResponse.success(
        MedicalResponse.fromJson(response.data!),
      );
    } on DioException catch (e) {
      print('[API] ❌ Erro médico DioException: ${e.message}');
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      print('[API] ❌ Erro médico inesperado: $e');
      return ApiResponse.error('Erro inesperado: $e');
    }
  }

  /// Pergunta educacional
  Future<ApiResponse<EducationResponse>> askEducationQuestion({
    required String question,
    String language = 'pt-BR',
    String subject = 'general',
    String level = 'básico',
    int duration = 30,
  }) async {
    try {
      print('[API] 📚 Enviando pergunta educacional: $question');

      final response = await _dio.post<Map<String, dynamic>>(
        '/education',
        data: {
          'question': question,
          'language': language,
          'subject': subject,
          'level': level,
          'duration': duration,
          'context': 'educacao',
        },
        options: Options(
          receiveTimeout: longTimeoutDuration,
          sendTimeout: longTimeoutDuration,
        ),
      );

      print('[API] ✅ Resposta educacional recebida');

      return ApiResponse.success(
        EducationResponse.fromJson(response.data!),
      );
    } on DioException catch (e) {
      print('[API] ❌ Erro educacional DioException: ${e.message}');
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      print('[API] ❌ Erro educacional inesperado: $e');
      return ApiResponse.error('Erro inesperado: $e');
    }
  }

  /// Pergunta sobre agricultura
  Future<ApiResponse<AgricultureResponse>> askAgricultureQuestion({
    required String question,
    String language = 'pt-BR',
    String? cropType,
  }) async {
    try {
      print('[API] 🌱 Enviando pergunta sobre agricultura: $question');

      final response = await _dio.post<Map<String, dynamic>>(
        '/agriculture',
        data: {
          'question': question,
          'language': language,
          'crop_type': cropType,
          'context': 'agricultura',
        },
      );

      print('[API] ✅ Resposta sobre agricultura recebida');

      return ApiResponse.success(
        AgricultureResponse.fromJson(response.data!),
      );
    } on DioException catch (e) {
      print('[API] ❌ Erro agricultura DioException: ${e.message}');
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      print('[API] ❌ Erro agricultura inesperado: $e');
      return ApiResponse.error('Erro inesperado: $e');
    }
  }

  /// Análise de imagem
  Future<ApiResponse<MultimodalResponse>> analyzeImage({
    required String imagePath,
    String language = 'pt-BR',
    String? prompt,
  }) async {
    try {
      print('[API] 📸 Enviando imagem para análise');

      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(imagePath),
        'language': language,
        'prompt': prompt ?? 'Analise esta imagem',
      });

      final response = await _dio.post<Map<String, dynamic>>(
        '/multimodal/image',
        data: formData,
      );

      print('[API] ✅ Análise de imagem recebida');

      return ApiResponse.success(
        MultimodalResponse.fromJson(response.data!),
      );
    } on DioException catch (e) {
      print('[API] ❌ Erro análise imagem DioException: ${e.message}');
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      print('[API] ❌ Erro análise imagem inesperado: $e');
      return ApiResponse.error('Erro inesperado: $e');
    }
  }

  /// Análise de áudio
  Future<ApiResponse<MultimodalResponse>> analyzeAudio({
    required String audioPath,
    String language = 'pt-BR',
    String? prompt,
  }) async {
    try {
      print('[API] 🎵 Enviando áudio para análise');

      final formData = FormData.fromMap({
        'audio': await MultipartFile.fromFile(audioPath),
        'language': language,
        'prompt': prompt ?? 'Analise este áudio',
      });

      final response = await _dio.post<Map<String, dynamic>>(
        '/multimodal/audio',
        data: formData,
      );

      print('[API] ✅ Análise de áudio recebida');

      return ApiResponse.success(
        MultimodalResponse.fromJson(response.data!),
      );
    } on DioException catch (e) {
      print('[API] ❌ Erro análise áudio DioException: ${e.message}');
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      print('[API] ❌ Erro análise áudio inesperado: $e');
      return ApiResponse.error('Erro inesperado: $e');
    }
  }

  /// Tradução de texto
  Future<ApiResponse<TranslationResponse>> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
  }) async {
    try {
      print('[API] 🔤 Traduzindo texto: $text');

      final response = await _dio.post<Map<String, dynamic>>(
        '/translate',
        data: {
          'text': text,
          'source_language': sourceLanguage,
          'target_language': targetLanguage,
        },
      );

      print('[API] ✅ Tradução recebida');

      return ApiResponse.success(
        TranslationResponse.fromJson(response.data!),
      );
    } on DioException catch (e) {
      print('[API] ❌ Erro tradução DioException: ${e.message}');
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      print('[API] ❌ Erro tradução inesperado: $e');
      return ApiResponse.error('Erro inesperado: $e');
    }
  }

  /// Upload de arquivo
  Future<ApiResponse<Map<String, dynamic>>> uploadFile({
    required String filePath,
    String endpoint = '/upload',
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _dio.post<Map<String, dynamic>>(
        endpoint,
        data: formData,
      );

      return ApiResponse.success(response.data!);
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Erro inesperado: $e');
    }
  }

  /// Manipula erros do Dio
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Tempo limite de conexão excedido';
      case DioExceptionType.sendTimeout:
        return 'Tempo limite de envio excedido';
      case DioExceptionType.receiveTimeout:
        return 'Tempo limite de recebimento excedido';
      case DioExceptionType.badResponse:
        switch (e.response?.statusCode) {
          case 404:
            return 'Endpoint não encontrado';
          case 500:
            return 'Erro interno do servidor';
          default:
            return 'Erro HTTP: ${e.response?.statusCode}';
        }
      case DioExceptionType.cancel:
        return 'Requisição cancelada';
      case DioExceptionType.unknown:
        return 'Erro de rede desconhecido';
      default:
        return 'Erro inesperado: ${e.message}';
    }
  }
}

/// Classe de resposta da API
class ApiResponse<T> {
  ApiResponse.success(this.data)
      : success = true,
        error = null;

  ApiResponse.error(this.error)
      : success = false,
        data = null;

  final bool success;
  final T? data;
  final String? error;
}

/// Modelo de resposta médica
class MedicalResponse {
  MedicalResponse({
    required this.domain,
    required this.question,
    required this.answer,
    required this.language,
    required this.timestamp,
  });

  factory MedicalResponse.fromJson(Map<String, dynamic> json) =>
      MedicalResponse(
        domain: json['domain'] as String? ?? '',
        question: json['question'] as String? ?? '',
        answer: json['answer'] as String? ?? '',
        language: json['language'] as String? ?? 'pt-BR',
        timestamp:
            json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      );

  final String domain;
  final String question;
  final String answer;
  final String language;
  final String timestamp;
}

/// Modelo de resposta educacional
class EducationResponse {
  EducationResponse({
    required this.domain,
    required this.question,
    required this.answer,
    required this.language,
    required this.timestamp,
  });

  factory EducationResponse.fromJson(Map<String, dynamic> json) =>
      EducationResponse(
        domain: json['domain'] as String? ?? '',
        question: json['question'] as String? ?? '',
        answer: json['answer'] as String? ?? '',
        language: json['language'] as String? ?? 'pt-BR',
        timestamp:
            json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      );

  final String domain;
  final String question;
  final String answer;
  final String language;
  final String timestamp;
}

/// Modelo de resposta de agricultura
class AgricultureResponse {
  AgricultureResponse({
    required this.domain,
    required this.question,
    required this.answer,
    required this.language,
    required this.timestamp,
  });

  factory AgricultureResponse.fromJson(Map<String, dynamic> json) =>
      AgricultureResponse(
        domain: json['domain'] as String? ?? '',
        question: json['question'] as String? ?? '',
        answer: json['answer'] as String? ?? '',
        language: json['language'] as String? ?? 'pt-BR',
        timestamp:
            json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      );

  final String domain;
  final String question;
  final String answer;
  final String language;
  final String timestamp;
}

/// Modelo de resposta multimodal
class MultimodalResponse {
  MultimodalResponse({
    required this.type,
    required this.input,
    required this.response,
    required this.timestamp,
  });

  factory MultimodalResponse.fromJson(Map<String, dynamic> json) =>
      MultimodalResponse(
        type: json['type'] as String? ?? '',
        input: json['input'] as String? ?? '',
        response: json['response'] as String? ?? '',
        timestamp:
            json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      );

  final String type;
  final String input;
  final String response;
  final String timestamp;
}

/// Modelo de resposta de tradução
class TranslationResponse {
  TranslationResponse({
    required this.original,
    required this.translated,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.timestamp,
  });

  factory TranslationResponse.fromJson(Map<String, dynamic> json) =>
      TranslationResponse(
        original: json['original'] as String? ?? '',
        translated: json['translated'] as String? ?? '',
        sourceLanguage: json['source_language'] as String? ?? '',
        targetLanguage: json['target_language'] as String? ?? '',
        timestamp:
            json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
      );

  final String original;
  final String translated;
  final String sourceLanguage;
  final String targetLanguage;
  final String timestamp;
}
