
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';

class ApiService {
  ApiService() {
    // FORÇAR criação de nova instância Dio com configuração para emulador
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.apiBaseUrl.replaceAll('/api', ''),
      connectTimeout: timeoutDuration,
      receiveTimeout: timeoutDuration,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Debug: verificar URL configurada
    print('[API SERVICE] 🔧 FORÇANDO Base URL: ${_dio.options.baseUrl}');
    print('[API SERVICE] ⏱️ Timeout: ${_dio.options.connectTimeout}');

    // Interceptor para logging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) => print('[API] $obj'),
      ),
    );
  }


  static const Duration timeoutDuration = Duration(seconds: 30);
  static const Duration longTimeoutDuration =
      Duration(minutes: 5); // AUMENTADO para Docs Gemma

  late final Dio _dio;

  // Verificar conectividade
  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  // Health check do servidor
  Future<Map<String, dynamic>?> healthCheck() async {
    try {
      final response = await _dio.get(AppConfig.buildUrl('health'));
      return response.data as Map<String, dynamic>?;
    } catch (e) {
      print('Erro no health check: $e');
      return null;
    }
  }

  // Consulta médica (MELHORADO para Docs Gemma Service)
  Future<ApiResponse<MedicalResponse>> askMedicalQuestion({
    required String question,
    String language = 'pt-BR',
  }) async {
    try {
      print('[API] 🏥 Enviando pergunta médica: $question');
      print('[API] 📋 Usando Docs Gemma Service otimizado');

      final response = await _dio.post<Map<String, dynamic>>(
        AppConfig.buildUrl('medical'),
        data: {
          'question': question,
          'language': language,
          'context': 'medico', // NOVO: contexto específico
        },
        options: Options(
          receiveTimeout: longTimeoutDuration, // AUMENTADO para Docs Gemma
          sendTimeout: longTimeoutDuration,
        ),
      );

      print('[API] ✅ Resposta médica recebida do Docs Gemma');

      return ApiResponse.success(
        MedicalResponse.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      print('[API] ❌ Erro médico DioException: ${e.message}');
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      print('[API] ❌ Erro médico inesperado: $e');
      return ApiResponse.error('Erro inesperado: $e');
    }
  }

  // Consulta educacional (MELHORADO para Docs Gemma Service)
  Future<ApiResponse<EducationResponse>> askEducationQuestion({
    required String question,
    String language = 'pt-BR',
    String subject = 'general',
    String level = 'básico',
    int duration = 30,
  }) async {
    try {
      print('[API] 📚 Enviando pergunta educacional: $question');
      print('[API] 📋 Usando Docs Gemma Service otimizado');

      final response = await _dio.post<Map<String, dynamic>>(
        AppConfig.buildUrl('education'),
        data: {
          'question': question,
          'language': language,
          'subject': subject,
          'level': level,
          'duration': duration,
          'context': 'educacao', // NOVO: contexto específico
        },
        options: Options(
          receiveTimeout: longTimeoutDuration, // AUMENTADO para Docs Gemma
          sendTimeout: longTimeoutDuration,
        ),
      );

      print('[API] ✅ Resposta educacional recebida do Docs Gemma');

      return ApiResponse.success(
        EducationResponse.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      print('[API] ❌ Erro educacional DioException: ${e.message}');
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      print('[API] ❌ Erro educacional inesperado: $e');
      return ApiResponse.error('Erro inesperado: $e');
    }
  }

  // Consulta agrícola (MELHORADO para Docs Gemma Service)
  Future<ApiResponse<AgricultureResponse>> askAgricultureQuestion({
    required String question,
    String language = 'pt-BR',
    String cropType = 'general',
    String season = 'current',
  }) async {
    try {
      print('[API] 🌱 Enviando pergunta agrícola: $question');
      print('[API] 📋 Usando Docs Gemma Service otimizado');

      final response = await _dio.post<Map<String, dynamic>>(
        AppConfig.buildUrl('agriculture'),
        data: {
          'question': question,
          'language': language,
          'crop_type': cropType,
          'season': season,
          'context': 'agricultura', // NOVO: contexto específico
        },
        options: Options(
          receiveTimeout: longTimeoutDuration, // AUMENTADO para Docs Gemma
          sendTimeout: longTimeoutDuration,
        ),
      );

      print('[API] ✅ Resposta agrícola recebida do Docs Gemma Service');

      return ApiResponse.success(
        AgricultureResponse.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      print('[API] ❌ Erro agrícola DioException: ${e.message}');
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      print('[API] ❌ Erro agrícola inesperado: $e');
      return ApiResponse.error('Erro inesperado: $e');
    }
  }

  // Análise multimodal (imagem + texto)
  Future<ApiResponse<MultimodalResponse>> analyzeImage({
    required String imageUrl,
    required String text,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        AppConfig.buildUrl('multimodal'),
        data: {
          'image_url': imageUrl,
          'text': text,
        },
        options: Options(
          receiveTimeout: longTimeoutDuration,
        ),
      );

      return ApiResponse.success(
        MultimodalResponse.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Erro inesperado: $e');
    }
  }

  // Tradução de texto
  Future<ApiResponse<TranslationResponse>> translateText({
    required String text,
    required String sourceLang,
    required String targetLang,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/translation',
        data: {
          'text': text,
          'source_lang': sourceLang,
          'target_lang': targetLang,
        },
      );

      return ApiResponse.success(
        TranslationResponse.fromJson(response.data as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      return ApiResponse.error(_handleDioError(e));
    } catch (e) {
      return ApiResponse.error('Erro inesperado: $e');
    }
  }

  // Tratamento de erros DioException
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Timeout de conexão. Verifique sua internet.';
      case DioExceptionType.sendTimeout:
        return 'Timeout ao enviar dados.';
      case DioExceptionType.receiveTimeout:
        return 'Timeout ao receber resposta. O Docs Gemma pode estar processando...';
      case DioExceptionType.badResponse:
        final statusCode = e.response?.statusCode;
        if (statusCode != null) {
          if (statusCode >= 500) {
            return 'Erro interno do servidor ($statusCode). Tente novamente.';
          } else if (statusCode == 404) {
            return 'Endpoint não encontrado. Verifique a configuração.';
          } else {
            return 'Erro HTTP: $statusCode';
          }
        }
        return 'Resposta inválida do servidor.';
      case DioExceptionType.cancel:
        return 'Requisição cancelada.';
      case DioExceptionType.connectionError:
        return 'Erro de conexão. Verifique se o servidor está rodando.';
      default:
        return 'Erro de rede: ${e.message}';
    }
  }
}

// Classes de resposta
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

// Resposta médica
class MedicalResponse {
  MedicalResponse({
    required this.answer,
    required this.confidence,
    this.recommendations,
  });

  factory MedicalResponse.fromJson(Map<String, dynamic> json) => MedicalResponse(
      answer: (json['answer'] ?? json['response'] ?? '') as String,
      confidence: (json['confidence'] ?? 'medium') as String,
      recommendations: json['recommendations'] != null
          ? List<String>.from(json['recommendations'] as List<dynamic>)
          : null,
    );
  final String answer;
  final String confidence;
  final List<String>? recommendations;
}

// Resposta educacional
class EducationResponse {
  EducationResponse({
    required this.answer,
    required this.subject,
    required this.level,
    this.resources,
  });

  factory EducationResponse.fromJson(Map<String, dynamic> json) => EducationResponse(
      answer: (json['answer'] ?? json['response'] ?? '') as String,
      subject: (json['subject'] ?? 'general') as String,
      level: (json['level'] ?? 'básico') as String,
      resources: json['resources'] != null
          ? List<String>.from(json['resources'] as List<dynamic>)
          : null,
    );
  final String answer;
  final String subject;
  final String level;
  final List<String>? resources;
}

// Resposta agrícola
class AgricultureResponse {
  AgricultureResponse({
    required this.answer,
    required this.cropType,
    required this.season,
    this.tips,
  });

  factory AgricultureResponse.fromJson(Map<String, dynamic> json) => AgricultureResponse(
      answer: (json['answer'] ?? json['response'] ?? '') as String,
      cropType: (json['crop_type'] ?? 'general') as String,
      season: (json['season'] ?? 'current') as String,
      tips: json['tips'] != null
          ? List<String>.from(json['tips'] as List<dynamic>)
          : null,
    );
  final String answer;
  final String cropType;
  final String season;
  final List<String>? tips;
}

// Resposta multimodal
class MultimodalResponse {
  MultimodalResponse({
    required this.answer,
    required this.type,
    this.metadata,
  });

  factory MultimodalResponse.fromJson(Map<String, dynamic> json) => MultimodalResponse(
      answer: (json['answer'] ?? json['response'] ?? '') as String,
      type: (json['type'] ?? 'text') as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  final String answer;
  final String type;
  final Map<String, dynamic>? metadata;
}

// Resposta de tradução
class TranslationResponse {
  TranslationResponse({
    required this.translatedText,
    required this.sourceLang,
    required this.targetLang,
    this.confidence,
  });

  factory TranslationResponse.fromJson(Map<String, dynamic> json) => TranslationResponse(
      translatedText: (json['translated_text'] ?? '') as String,
      sourceLang: (json['source_lang'] ?? '') as String,
      targetLang: (json['target_lang'] ?? '') as String,
      confidence: (json['confidence'] as num?)?.toDouble(),
    );
  final String translatedText;
  final String sourceLang;
  final String targetLang;
  final double? confidence;
}
