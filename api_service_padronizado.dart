import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Serviço de API padronizado para comunicação com o backend Bu Fala
/// Compatível com a estrutura padronizada de endpoints
class ApiService {
  static const String _baseUrl = 'http://127.0.0.1:5000';
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Interceptor para logging em modo debug
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => debugPrint(obj.toString()),
      ));
    }
  }

  /// Verifica a saúde do backend
  Future<HealthResponse> healthCheck() async {
    try {
      final response = await _dio.get('/health');
      return HealthResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Faz uma pergunta médica
  Future<MedicalResponse> askMedical({
    required String question,
    String language = 'pt-BR',
    String? context,
    String urgency = 'medium',
  }) async {
    try {
      final response = await _dio.post(
        '/medical',
        data: {
          'question': question,
          'language': language,
          if (context != null) 'context': context,
          'urgency': urgency,
        },
        options: Options(
          receiveTimeout: const Duration(minutes: 3), // Timeout maior para Gemma-3n
        ),
      );
      return MedicalResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Faz uma pergunta educacional
  Future<EducationResponse> askEducation({
    required String question,
    String language = 'pt-BR',
    String subject = 'general',
    String level = 'elementary',
  }) async {
    try {
      final response = await _dio.post(
        '/education',
        data: {
          'question': question,
          'language': language,
          'subject': subject,
          'level': level,
        },
        options: Options(
          receiveTimeout: const Duration(minutes: 3),
        ),
      );
      return EducationResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Faz uma pergunta sobre agricultura
  Future<AgricultureResponse> askAgriculture({
    required String question,
    String language = 'pt-BR',
    String cropType = 'general',
    String season = 'current',
    String? location,
  }) async {
    try {
      final response = await _dio.post(
        '/agriculture',
        data: {
          'question': question,
          'language': language,
          'crop_type': cropType,
          'season': season,
          if (location != null) 'location': location,
        },
        options: Options(
          receiveTimeout: const Duration(minutes: 3),
        ),
      );
      return AgricultureResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Traduz texto
  Future<TranslationResponse> translateText({
    required String text,
    required String fromLanguage,
    required String toLanguage,
  }) async {
    try {
      final response = await _dio.post(
        '/translate',
        data: {
          'text': text,
          'from_language': fromLanguage,
          'to_language': toLanguage,
        },
      );
      return TranslationResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Análise multimodal
  Future<MultimodalResponse> analyzeMultimodal({
    String? text,
    String? imageBase64,
    String? audioBase64,
    String type = 'general',
    String language = 'pt-BR',
    String context = 'general',
  }) async {
    try {
      final response = await _dio.post(
        '/multimodal',
        data: {
          if (text != null) 'text': text,
          if (imageBase64 != null) 'image': imageBase64,
          if (audioBase64 != null) 'audio': audioBase64,
          'type': type,
          'language': language,
          'context': context,
        },
        options: Options(
          receiveTimeout: const Duration(minutes: 3),
        ),
      );
      return MultimodalResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Manipula erros do Dio
  ApiException _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          'Timeout na conexão',
          'TIMEOUT',
          'Verifique sua conexão com a internet',
        );
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode ?? 0;
        final data = e.response?.data;
        
        if (data is Map<String, dynamic> && data.containsKey('error')) {
          final error = data['error'];
          return ApiException(
            error['message'] ?? 'Erro do servidor',
            error['code'] ?? 'SERVER_ERROR',
            error['details'] ?? 'Erro não especificado',
            suggestions: List<String>.from(error['suggestions'] ?? []),
          );
        }
        
        return ApiException(
          'Erro HTTP $statusCode',
          'HTTP_ERROR',
          'Erro na comunicação com o servidor',
        );
      case DioExceptionType.cancel:
        return ApiException(
          'Requisição cancelada',
          'CANCELLED',
          'A requisição foi cancelada',
        );
      default:
        return ApiException(
          'Erro de conexão',
          'CONNECTION_ERROR',
          'Não foi possível conectar ao servidor',
        );
    }
  }
}

/// Exceção personalizada para erros da API
class ApiException implements Exception {
  final String message;
  final String code;
  final String details;
  final List<String> suggestions;

  ApiException(
    this.message,
    this.code,
    this.details, {
    this.suggestions = const [],
  });

  @override
  String toString() => 'ApiException: $message ($code)';
}

/// Classe base para respostas da API
abstract class ApiResponse {
  final bool success;
  final String? model;
  final DateTime timestamp;
  final String status;
  final ApiError? error;

  ApiResponse({
    required this.success,
    this.model,
    required this.timestamp,
    required this.status,
    this.error,
  });

  factory ApiResponse.fromJson(Map<String, dynamic> json) {
    throw UnimplementedError('Subclasses must implement fromJson');
  }
}

/// Classe para erros da API
class ApiError {
  final String code;
  final String message;
  final String details;
  final List<String> suggestions;

  ApiError({
    required this.code,
    required this.message,
    required this.details,
    required this.suggestions,
  });

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code'] ?? '',
      message: json['message'] ?? '',
      details: json['details'] ?? '',
      suggestions: List<String>.from(json['suggestions'] ?? []),
    );
  }
}

/// Resposta do endpoint de saúde
class HealthResponse extends ApiResponse {
  final String healthStatus;
  final String modelStatus;
  final List<String> features;
  final String backendVersion;
  final String modelVersion;

  HealthResponse({
    required super.success,
    super.model,
    required super.timestamp,
    required super.status,
    super.error,
    required this.healthStatus,
    required this.modelStatus,
    required this.features,
    required this.backendVersion,
    required this.modelVersion,
  });

  factory HealthResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return HealthResponse(
      success: json['success'] ?? false,
      model: json['model'],
      timestamp: DateTime.parse(json['timestamp']),
      status: json['status'] ?? 'unknown',
      error: json['error'] != null ? ApiError.fromJson(json['error']) : null,
      healthStatus: data['status'] ?? 'unknown',
      modelStatus: data['model_status'] ?? 'unknown',
      features: List<String>.from(data['features'] ?? []),
      backendVersion: data['backend_version'] ?? 'unknown',
      modelVersion: data['model_version'] ?? 'unknown',
    );
  }
}

/// Resposta médica
class MedicalResponse extends ApiResponse {
  final String answer;
  final String question;
  final String domain;
  final String language;
  final MedicalMetadata metadata;

  MedicalResponse({
    required super.success,
    super.model,
    required super.timestamp,
    required super.status,
    super.error,
    required this.answer,
    required this.question,
    required this.domain,
    required this.language,
    required this.metadata,
  });

  factory MedicalResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return MedicalResponse(
      success: json['success'] ?? false,
      model: json['model'],
      timestamp: DateTime.parse(json['timestamp']),
      status: json['status'] ?? 'unknown',
      error: json['error'] != null ? ApiError.fromJson(json['error']) : null,
      answer: data['answer'] ?? '',
      question: data['question'] ?? '',
      domain: data['domain'] ?? 'medical',
      language: data['language'] ?? 'pt-BR',
      metadata: MedicalMetadata.fromJson(data['metadata'] ?? {}),
    );
  }
}

/// Metadados médicos
class MedicalMetadata {
  final String urgency;
  final double confidence;
  final bool emergencyDetected;
  final List<String> recommendations;

  MedicalMetadata({
    required this.urgency,
    required this.confidence,
    required this.emergencyDetected,
    required this.recommendations,
  });

  factory MedicalMetadata.fromJson(Map<String, dynamic> json) {
    return MedicalMetadata(
      urgency: json['urgency'] ?? 'medium',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      emergencyDetected: json['emergency_detected'] ?? false,
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }
}

/// Resposta educacional
class EducationResponse extends ApiResponse {
  final String answer;
  final String question;
  final String domain;
  final String language;
  final EducationMetadata metadata;

  EducationResponse({
    required super.success,
    super.model,
    required super.timestamp,
    required super.status,
    super.error,
    required this.answer,
    required this.question,
    required this.domain,
    required this.language,
    required this.metadata,
  });

  factory EducationResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return EducationResponse(
      success: json['success'] ?? false,
      model: json['model'],
      timestamp: DateTime.parse(json['timestamp']),
      status: json['status'] ?? 'unknown',
      error: json['error'] != null ? ApiError.fromJson(json['error']) : null,
      answer: data['answer'] ?? '',
      question: data['question'] ?? '',
      domain: data['domain'] ?? 'education',
      language: data['language'] ?? 'pt-BR',
      metadata: EducationMetadata.fromJson(data['metadata'] ?? {}),
    );
  }
}

/// Metadados educacionais
class EducationMetadata {
  final String subject;
  final String level;
  final List<String> activities;
  final List<String> resources;

  EducationMetadata({
    required this.subject,
    required this.level,
    required this.activities,
    required this.resources,
  });

  factory EducationMetadata.fromJson(Map<String, dynamic> json) {
    return EducationMetadata(
      subject: json['subject'] ?? 'general',
      level: json['level'] ?? 'elementary',
      activities: List<String>.from(json['activities'] ?? []),
      resources: List<String>.from(json['resources'] ?? []),
    );
  }
}

/// Resposta agrícola
class AgricultureResponse extends ApiResponse {
  final String answer;
  final String question;
  final String domain;
  final String language;
  final AgricultureMetadata metadata;

  AgricultureResponse({
    required super.success,
    super.model,
    required super.timestamp,
    required super.status,
    super.error,
    required this.answer,
    required this.question,
    required this.domain,
    required this.language,
    required this.metadata,
  });

  factory AgricultureResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return AgricultureResponse(
      success: json['success'] ?? false,
      model: json['model'],
      timestamp: DateTime.parse(json['timestamp']),
      status: json['status'] ?? 'unknown',
      error: json['error'] != null ? ApiError.fromJson(json['error']) : null,
      answer: data['answer'] ?? '',
      question: data['question'] ?? '',
      domain: data['domain'] ?? 'agriculture',
      language: data['language'] ?? 'pt-BR',
      metadata: AgricultureMetadata.fromJson(data['metadata'] ?? {}),
    );
  }
}

/// Metadados agrícolas
class AgricultureMetadata {
  final String cropType;
  final String season;
  final String calendarInfo;
  final List<String> pestWarnings;
  final List<String> bestPractices;

  AgricultureMetadata({
    required this.cropType,
    required this.season,
    required this.calendarInfo,
    required this.pestWarnings,
    required this.bestPractices,
  });

  factory AgricultureMetadata.fromJson(Map<String, dynamic> json) {
    return AgricultureMetadata(
      cropType: json['crop_type'] ?? 'general',
      season: json['season'] ?? 'current',
      calendarInfo: json['calendar_info'] ?? '',
      pestWarnings: List<String>.from(json['pest_warnings'] ?? []),
      bestPractices: List<String>.from(json['best_practices'] ?? []),
    );
  }
}

/// Resposta de tradução
class TranslationResponse extends ApiResponse {
  final String translated;
  final String originalText;
  final String fromLanguage;
  final String toLanguage;
  final TranslationMetadata metadata;

  TranslationResponse({
    required super.success,
    super.model,
    required super.timestamp,
    required super.status,
    super.error,
    required this.translated,
    required this.originalText,
    required this.fromLanguage,
    required this.toLanguage,
    required this.metadata,
  });

  factory TranslationResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return TranslationResponse(
      success: json['success'] ?? false,
      model: json['model'],
      timestamp: DateTime.parse(json['timestamp']),
      status: json['status'] ?? 'unknown',
      error: json['error'] != null ? ApiError.fromJson(json['error']) : null,
      translated: data['translated'] ?? '',
      originalText: data['original_text'] ?? '',
      fromLanguage: data['from_language'] ?? '',
      toLanguage: data['to_language'] ?? '',
      metadata: TranslationMetadata.fromJson(data['metadata'] ?? {}),
    );
  }
}

/// Metadados de tradução
class TranslationMetadata {
  final double confidence;
  final String detectedLanguage;
  final List<String> alternativeTranslations;

  TranslationMetadata({
    required this.confidence,
    required this.detectedLanguage,
    required this.alternativeTranslations,
  });

  factory TranslationMetadata.fromJson(Map<String, dynamic> json) {
    return TranslationMetadata(
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      detectedLanguage: json['detected_language'] ?? '',
      alternativeTranslations: List<String>.from(json['alternative_translations'] ?? []),
    );
  }
}

/// Resposta multimodal
class MultimodalResponse extends ApiResponse {
  final String answer;
  final String type;
  final String analysisType;
  final String language;
  final MultimodalMetadata metadata;

  MultimodalResponse({
    required super.success,
    super.model,
    required super.timestamp,
    required super.status,
    super.error,
    required this.answer,
    required this.type,
    required this.analysisType,
    required this.language,
    required this.metadata,
  });

  factory MultimodalResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return MultimodalResponse(
      success: json['success'] ?? false,
      model: json['model'],
      timestamp: DateTime.parse(json['timestamp']),
      status: json['status'] ?? 'unknown',
      error: json['error'] != null ? ApiError.fromJson(json['error']) : null,
      answer: data['answer'] ?? '',
      type: data['type'] ?? 'general',
      analysisType: data['analysis_type'] ?? 'general',
      language: data['language'] ?? 'pt-BR',
      metadata: MultimodalMetadata.fromJson(data['metadata'] ?? {}),
    );
  }
}

/// Metadados multimodais
class MultimodalMetadata {
  final bool hasImage;
  final bool hasAudio;
  final bool hasText;
  final String? imageQuality;
  final List<String> detectedObjects;
  final double confidence;
  final List<String> recommendations;

  MultimodalMetadata({
    required this.hasImage,
    required this.hasAudio,
    required this.hasText,
    this.imageQuality,
    required this.detectedObjects,
    required this.confidence,
    required this.recommendations,
  });

  factory MultimodalMetadata.fromJson(Map<String, dynamic> json) {
    return MultimodalMetadata(
      hasImage: json['has_image'] ?? false,
      hasAudio: json['has_audio'] ?? false,
      hasText: json['has_text'] ?? false,
      imageQuality: json['image_quality'],
      detectedObjects: List<String>.from(json['detected_objects'] ?? []),
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      recommendations: List<String>.from(json['recommendations'] ?? []),
    );
  }
}