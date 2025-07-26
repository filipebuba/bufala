import 'dart:math' as math;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

/// Serviço de API Inteligente para o Bu Fala
/// Otimizado para trabalhar com o DocsGemmaService
class SmartApiService {

  SmartApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 45),
      receiveTimeout:
          const Duration(minutes: 8), // Tempo estendido para Gemma-3n
      sendTimeout: const Duration(minutes: 2),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Bu-Fala-Flutter/1.0',
        'Keep-Alive': 'timeout=120, max=100',
      },
    ));

    // Interceptor para logging detalhado
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('[🔄 SMART-API] Enviando: ${options.method} ${options.path}');
          if (options.data != null) {
            final dataStr = options.data.toString();
            final maxLength = math.min(200, dataStr.length);
            print(
                '[📋 SMART-API] Dados: ${dataStr.substring(0, maxLength)}${dataStr.length > 200 ? '...' : ''}');
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('[✅ SMART-API] Resposta recebida: ${response.statusCode}');
          if (response.data != null) {
            final dataStr = response.data.toString();
            print('[📦 SMART-API] Tamanho resposta: ${dataStr.length} chars');
          }
          handler.next(response);
        },
        onError: (error, handler) {
          print('[❌ SMART-API] Erro: ${error.type} - ${error.message}');
          if (error.response != null) {
            print('[❌ SMART-API] Status: ${error.response!.statusCode}');
          }
          handler.next(error);
        },
      ),
    );

    // Interceptor para retry automático
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        options: const RetryOptions(
          retries: 2,
          retryInterval: Duration(seconds: 3),
        ),
      ),
    );
  }
  static const String baseUrl = 'http://10.0.2.2:5000';

  late final Dio _dio;

  /// Verifica conectividade de rede
  Future<bool> hasInternetConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      print('[❌ SMART-API] Erro verificando conectividade: $e');
      return false;
    }
  }
  
  /// Alias para compatibilidade
  Future<bool> checkConnectivity() async {
    return await hasInternetConnection();
  }

  /// Health check otimizado
  Future<SmartApiResponse<Map<String, dynamic>>> healthCheck() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/health');

      if (response.statusCode == 200 && response.data != null) {
        return SmartApiResponse.success(
          data: response.data as Map<String, dynamic>,
          source: 'Backend Ativo',
        );
      }

      return SmartApiResponse.error('Servidor indisponível');
    } catch (e) {
      print('[❌ SMART-API] Health check falhou: $e');
      return SmartApiResponse.error('Erro de conectividade: $e');
    }
  }

  /// Pergunta médica com tratamento inteligente
  Future<SmartApiResponse<String>> askMedicalQuestion({
    required String question,
    String language = 'pt-BR',
  }) async {
    try {
      print('[🏥 SMART-API] Enviando pergunta médica...');
      print(
          '[🏥 SMART-API] Pergunta: ${question.substring(0, math.min(100, question.length))}...');

      final stopwatch = Stopwatch()..start();

      // Usar o _dio principal com timeout otimizado
      final response = await _dio.post<Map<String, dynamic>>(
        '/medical',
        data: {
          'question': question,
          'language': language,
          'context': 'medico',
          'timestamp': DateTime.now().toIso8601String(),
          'timeout_preference': 'balanced',
        },
        options: Options(
          receiveTimeout: const Duration(minutes: 5), // Timeout balanceado
        ),
      );

      stopwatch.stop();
      final responseTime = stopwatch.elapsedMilliseconds / 1000.0;

      print('[🏥 SMART-API] Resposta recebida em ${responseTime}s');

      if (response.statusCode == 200 && response.data != null) {
        final processedResponse = _processGemmaResponse(
          response.data!,
          'Consulta Médica',
          responseTime,
        );

        // Verificar se realmente há conteúdo útil
        if (processedResponse.answer.isEmpty ||
            processedResponse.answer.length < 50) {
          print('[⚠️ SMART-API] Resposta muito curta, tentando fallback...');
          return _getMedicalFallback(question, language);
        }

        return SmartApiResponse.success(
          data: processedResponse.answer,
          source: processedResponse.source,
          responseTime: responseTime,
          confidence: processedResponse.confidence,
        );
      }

      return SmartApiResponse.error('Resposta inválida do servidor');
    } on DioException catch (e) {
      print('[❌ SMART-API] Erro Dio: ${e.type} - ${e.message}');

      // Se for timeout ou erro de conexão, tentar fallback médico
      if (e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        print(
            '[🔄 SMART-API] Timeout/Conexão detectado, usando fallback médico...');
        return _getMedicalFallback(question, language);
      }

      return SmartApiResponse.error(_handleDioError(e));
    } catch (e) {
      print('[❌ SMART-API] Erro geral: $e');
      return _getMedicalFallback(question, language);
    }
  }

  /// Pergunta educacional com tratamento inteligente
  Future<SmartApiResponse<String>> askEducationQuestion({
    required String question,
    String language = 'pt-BR',
    String subject = 'general',
    String level = 'básico',
  }) async {
    try {
      print('[📚 SMART-API] Enviando pergunta educacional...');

      final stopwatch = Stopwatch()..start();

      final response = await _dio.post<Map<String, dynamic>>(
        '/education',
        data: {
          'question': question,
          'language': language,
          'subject': subject,
          'level': level,
          'context': 'educacao',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      stopwatch.stop();
      final responseTime = stopwatch.elapsedMilliseconds / 1000.0;

      if (response.statusCode == 200 && response.data != null) {
        final processedResponse = _processGemmaResponse(
          response.data!,
          'Consulta Educacional',
          responseTime,
        );

        return SmartApiResponse.success(
          data: processedResponse.answer,
          source: processedResponse.source,
          responseTime: responseTime,
          confidence: processedResponse.confidence,
        );
      }

      return SmartApiResponse.error('Resposta inválida do servidor');
    } on DioException catch (e) {
      return SmartApiResponse.error(_handleDioError(e));
    } catch (e) {
      return SmartApiResponse.error('Erro inesperado: $e');
    }
  }

  /// Pergunta agrícola com tratamento inteligente
  Future<SmartApiResponse<String>> askAgricultureQuestion({
    required String question,
    String language = 'pt-BR',
    String cropType = 'general',
    String season = 'current',
  }) async {
    try {
      print('[🌱 SMART-API] Enviando pergunta agrícola...');

      final stopwatch = Stopwatch()..start();

      final response = await _dio.post<Map<String, dynamic>>(
        '/agriculture',
        data: {
          'question': question,
          'language': language,
          'crop_type': cropType,
          'season': season,
          'context': 'agricultura',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      stopwatch.stop();
      final responseTime = stopwatch.elapsedMilliseconds / 1000.0;

      if (response.statusCode == 200 && response.data != null) {
        final processedResponse = _processGemmaResponse(
          response.data!,
          'Consulta Agrícola',
          responseTime,
        );

        return SmartApiResponse.success(
          data: processedResponse.answer,
          source: processedResponse.source,
          responseTime: responseTime,
          confidence: processedResponse.confidence,
        );
      }

      return SmartApiResponse.error('Resposta inválida do servidor');
    } on DioException catch (e) {
      return SmartApiResponse.error(_handleDioError(e));
    } catch (e) {
      return SmartApiResponse.error('Erro inesperado: $e');
    }
  }

  // ========================================
  // 🎯 MÉTODOS DE ACESSIBILIDADE
  // ========================================

  /// 1️⃣ PARA DEFICIÊNCIA VISUAL
  /// Descrição de ambiente via câmera usando Gemma-3n
  Future<SmartApiResponse<String>> describeEnvironment({
    required String imageBase64,
    String language = 'pt-BR',
    String detailLevel = 'detailed', // basic, detailed, navigation
  }) async {
    try {
      print('[👁️ SMART-API] Analisando ambiente via câmera...');

      final stopwatch = Stopwatch()..start();

      final response = await _dio.post<Map<String, dynamic>>(
        '/accessibility/visual/describe',
        data: {
          'image_base64': imageBase64,
          'language': language,
          'detail_level': detailLevel,
          'context': 'visual_accessibility',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      stopwatch.stop();
      final responseTime = stopwatch.elapsedMilliseconds / 1000.0;

      if (response.statusCode == 200 && response.data != null) {
        final processedResponse = _processGemmaResponse(
          response.data!,
          'Descrição Visual',
          responseTime,
        );

        return SmartApiResponse.success(
          data: processedResponse.answer,
          source: processedResponse.source,
          responseTime: responseTime,
          confidence: processedResponse.confidence,
        );
      }

      return SmartApiResponse.error('Erro ao processar imagem');
    } on DioException catch (e) {
      return SmartApiResponse.error(_handleDioError(e));
    } catch (e) {
      return SmartApiResponse.error('Erro inesperado na análise visual: $e');
    }
  }

  /// Navegação por voz para deficientes visuais
  Future<SmartApiResponse<String>> getVoiceNavigation({
    required String audioText,
    String currentLocation = '',
    String destination = '',
    String language = 'pt-BR',
  }) async {
    try {
      print('[🗣️ SMART-API] Processando navegação por voz...');

      final stopwatch = Stopwatch()..start();

      final response = await _dio.post<Map<String, dynamic>>(
        '/accessibility/navigation/voice',
        data: {
          'audio_text': audioText,
          'current_location': currentLocation,
          'destination': destination,
          'language': language,
          'context': 'voice_navigation',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      stopwatch.stop();
      final responseTime = stopwatch.elapsedMilliseconds / 1000.0;

      if (response.statusCode == 200 && response.data != null) {
        final processedResponse = _processGemmaResponse(
          response.data!,
          'Navegação por Voz',
          responseTime,
        );

        return SmartApiResponse.success(
          data: processedResponse.answer,
          source: processedResponse.source,
          responseTime: responseTime,
          confidence: processedResponse.confidence,
        );
      }

      return SmartApiResponse.error('Erro ao processar comando de navegação');
    } on DioException catch (e) {
      return SmartApiResponse.error(_handleDioError(e));
    } catch (e) {
      return SmartApiResponse.error('Erro inesperado na navegação: $e');
    }
  }

  /// 2️⃣ PARA SEU PRIMO SURDO E MUDO
  /// Iniciar transcrição contínua
  Future<SmartApiResponse<String>> startTranscription({
    String language = 'pt-BR',
    String sessionId = '',
  }) async {
    try {
      print('[🎤 SMART-API] Iniciando transcrição contínua...');

      final response = await _dio.post<Map<String, dynamic>>(
        '/accessibility/transcription/start',
        data: {
          'language': language,
          'session_id': sessionId.isEmpty
              ? DateTime.now().millisecondsSinceEpoch.toString()
              : sessionId,
          'context': 'deaf_accessibility',
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final sessionInfo = response.data!['session_id'] as String? ?? 'Ativa';

        return SmartApiResponse.success(
          data: 'Transcrição iniciada com sucesso',
          source: 'Sessão: $sessionInfo',
        );
      }

      return SmartApiResponse.error('Erro ao iniciar transcrição');
    } on DioException catch (e) {
      return SmartApiResponse.error(_handleDioError(e));
    } catch (e) {
      return SmartApiResponse.error('Erro inesperado na transcrição: $e');
    }
  }

  /// Parar transcrição
  Future<SmartApiResponse<String>> stopTranscription({
    String sessionId = '',
  }) async {
    try {
      print('[⏹️ SMART-API] Parando transcrição...');

      final response = await _dio.post<Map<String, dynamic>>(
        '/accessibility/transcription/stop',
        data: {
          'session_id': sessionId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return SmartApiResponse.success(
          data: 'Transcrição finalizada com sucesso',
          source: 'Sistema de Transcrição',
        );
      }

      return SmartApiResponse.error('Erro ao parar transcrição');
    } on DioException catch (e) {
      return SmartApiResponse.error(_handleDioError(e));
    } catch (e) {
      return SmartApiResponse.error('Erro inesperado ao parar transcrição: $e');
    }
  }

  /// Buscar transcrições recentes
  Future<SmartApiResponse<List<TranscriptionHistory>>> getRecentTranscriptions({
    int limit = 10,
    String sessionId = '',
  }) async {
    try {
      print('[📜 SMART-API] Buscando transcrições recentes...');

      final response = await _dio.get<Map<String, dynamic>>(
        '/accessibility/transcription/recent',
        queryParameters: {
          'limit': limit,
          'session_id': sessionId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final transcriptionsData =
            response.data!['transcriptions'] as List? ?? [];

        final transcriptions = transcriptionsData
            .map((item) =>
                TranscriptionHistory.fromJson(item as Map<String, dynamic>))
            .toList();

        return SmartApiResponse.success(
          data: transcriptions,
          source: 'Histórico de Transcrições',
        );
      }
      return SmartApiResponse.error('Erro ao buscar transcrições');
    } on DioException catch (e) {
      return SmartApiResponse.error(_handleDioError(e));
    } catch (e) {
      return SmartApiResponse.error('Erro inesperado ao buscar histórico: $e');
    }
  }

  /// Tradução simultânea OFFLINE (PT-BR ↔ Crioulo ↔ Inglês)
  Future<SmartApiResponse<String>> translateText({
    required String text,
    required String sourceLanguage,
    required String targetLanguage,
    String context = 'general',
  }) async {
    try {
      print('[🌐 SMART-API] Traduzindo: $sourceLanguage → $targetLanguage');

      final stopwatch = Stopwatch()..start();

      final response = await _dio.post<Map<String, dynamic>>(
        '/accessibility/translation/translate',
        data: {
          'text': text,
          'source_language': sourceLanguage,
          'target_language': targetLanguage,
          'context': context,
          'offline_mode': true, // Força processamento offline
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      stopwatch.stop();
      final responseTime = stopwatch.elapsedMilliseconds / 1000.0;

      if (response.statusCode == 200 && response.data != null) {
        final translatedText =
            response.data!['translated_text'] as String? ?? '';
        final confidence = response.data!['confidence'] as double? ?? 0.8;

        return SmartApiResponse.success(
          data: translatedText,
          source: 'Gemma-3n Offline ($responseTime s)',
          responseTime: responseTime,
          confidence: confidence,
        );
      }

      return SmartApiResponse.error('Erro na tradução');
    } on DioException catch (e) {
      return SmartApiResponse.error(_handleDioError(e));
    } catch (e) {
      return SmartApiResponse.error('Erro inesperado na tradução: $e');
    }
  }

  /// Obter idiomas suportados para tradução
  Future<SmartApiResponse<List<SupportedLanguage>>>
      getSupportedLanguages() async {
    try {
      print('[🗣️ SMART-API] Buscando idiomas suportados...');

      final response = await _dio.get<Map<String, dynamic>>(
        '/accessibility/translation/languages',
      );

      if (response.statusCode == 200 && response.data != null) {
        final languagesData = response.data!['languages'] as List? ?? [];

        final languages = languagesData
            .map((item) =>
                SupportedLanguage.fromJson(item as Map<String, dynamic>))
            .toList();

        return SmartApiResponse.success(
          data: languages,
          source: 'Sistema de Idiomas',
        );
      }

      return SmartApiResponse.error('Erro ao buscar idiomas');
    } on DioException catch (e) {
      return SmartApiResponse.error(_handleDioError(e));
    } catch (e) {
      return SmartApiResponse.error('Erro inesperado ao buscar idiomas: $e');
    }
  }

  /// Transcrição em tempo real (streaming)
  Future<SmartApiResponse<String>> getRealtimeTranscription({
    required String audioBase64,
    String language = 'pt-BR',
    String sessionId = '',
  }) async {
    try {
      print('[⚡ SMART-API] Processando áudio em tempo real...');

      final response = await _dio.post<Map<String, dynamic>>(
        '/accessibility/transcription/realtime',
        data: {
          'audio_base64': audioBase64,
          'language': language,
          'session_id': sessionId,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final transcribedText =
            response.data!['transcribed_text'] as String? ?? '';
        final confidence = response.data!['confidence'] as double? ?? 0.8;
        final isComplete = response.data!['is_complete'] as bool? ?? false;

        return SmartApiResponse.success(
          data: transcribedText,
          source: isComplete ? 'Transcrição Completa' : 'Transcrição Parcial',
          confidence: confidence,
        );
      }

      return SmartApiResponse.error('Erro na transcrição em tempo real');
    } on DioException catch (e) {
      return SmartApiResponse.error(_handleDioError(e));
    } catch (e) {
      return SmartApiResponse.error('Erro inesperado na transcrição: $e');
    }
  }

  /// 3️⃣ MÉTODO HELPER DE ACESSIBILIDADE
  /// Obter informações de ajuda sobre funcionalidades de acessibilidade
  Future<SmartApiResponse<AccessibilityHelp>> getAccessibilityHelp({
    String language = 'pt-BR',
  }) async {
    try {
      print('[ℹ️ SMART-API] Buscando informações de acessibilidade...');

      final response = await _dio.get<Map<String, dynamic>>(
        '/accessibility/help',
        queryParameters: {
          'language': language,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final helpInfo = AccessibilityHelp.fromJson(response.data!);

        return SmartApiResponse.success(
          data: helpInfo,
          source: 'Sistema de Ajuda',
        );
      }

      return SmartApiResponse.error('Erro ao buscar informações de ajuda');
    } on DioException catch (e) {
      return SmartApiResponse.error(_handleDioError(e));
    } catch (e) {
      return SmartApiResponse.error('Erro inesperado na ajuda: $e');
    }
  }

  /// Verificar status dos serviços de acessibilidade
  Future<SmartApiResponse<AccessibilityStatus>> getAccessibilityStatus() async {
    try {
      print('[📊 SMART-API] Verificando status de acessibilidade...');

      final response = await _dio.get<Map<String, dynamic>>(
        '/accessibility/status',
      );

      if (response.statusCode == 200 && response.data != null) {
        final status = AccessibilityStatus.fromJson(response.data!);

        return SmartApiResponse.success(
          data: status,
          source: 'Monitor de Sistema',
        );
      }

      return SmartApiResponse.error('Erro ao verificar status');
    } on DioException catch (e) {
      return SmartApiResponse.error(_handleDioError(e));
    } catch (e) {
      return SmartApiResponse.error('Erro inesperado no status: $e');
    }
  }

  /// Salvar configurações de acessibilidade do usuário
  Future<SmartApiResponse<String>> saveAccessibilitySettings({
    required AccessibilitySettings settings,
  }) async {
    try {
      print('[⚙️ SMART-API] Salvando configurações de acessibilidade...');

      final response = await _dio.post<Map<String, dynamic>>(
        '/accessibility/settings/save',
        data: settings.toJson(),
      );

      if (response.statusCode == 200 && response.data != null) {
        return SmartApiResponse.success(
          data: 'Configurações salvas com sucesso',
          source: 'Sistema de Configurações',
        );
      }

      return SmartApiResponse.error('Erro ao salvar configurações');
    } on DioException catch (e) {
      return SmartApiResponse.error(_handleDioError(e));
    } catch (e) {
      return SmartApiResponse.error('Erro inesperado ao salvar: $e');
    }
  }

  /// Carregar configurações de acessibilidade do usuário
  Future<SmartApiResponse<AccessibilitySettings>> loadAccessibilitySettings({
    String userId = 'default',
  }) async {
    try {
      print('[📥 SMART-API] Carregando configurações de acessibilidade...');

      final response = await _dio.get<Map<String, dynamic>>(
        '/accessibility/settings/load',
        queryParameters: {
          'user_id': userId,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final settings = AccessibilitySettings.fromJson(response.data!);

        return SmartApiResponse.success(
          data: settings,
          source: 'Configurações do Usuário',
        );
      }

      return SmartApiResponse.error('Erro ao carregar configurações');
    } on DioException catch (e) {
      return SmartApiResponse.error(_handleDioError(e));
    } catch (e) {
      return SmartApiResponse.error('Erro inesperado ao carregar: $e');
    }
  }

  // ========================================
  // 🎯 MÉTODOS GENÉRICOS EXISTENTES
  // ========================================

  /// Método POST genérico
  Future<SmartApiResponse<Map<String, dynamic>>> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final response =
          await _dio.post<Map<String, dynamic>>(endpoint, data: data);

      if (response.statusCode == 200 && response.data != null) {
        return SmartApiResponse.success(data: response.data!);
      }

      return SmartApiResponse.error(
          'Erro na requisição: ${response.statusCode}');
    } on DioException catch (e) {
      return SmartApiResponse.error(_handleDioError(e));
    } catch (e) {
      return SmartApiResponse.error('Erro inesperado: $e');
    }
  }

  /// Método GET genérico
  Future<SmartApiResponse<Map<String, dynamic>>> get(String endpoint) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(endpoint);

      if (response.statusCode == 200 && response.data != null) {
        return SmartApiResponse.success(data: response.data!);
      }

      return SmartApiResponse.error(
          'Erro na requisição: ${response.statusCode}');
    } on DioException catch (e) {
      return SmartApiResponse.error(_handleDioError(e));
    } catch (e) {
      return SmartApiResponse.error('Erro inesperado: $e');
    }
  }

  /// Processa resposta do DocsGemmaService
  ProcessedGemmaResponse _processGemmaResponse(
    Map<String, dynamic> responseData,
    String context,
    double responseTime,
  ) {
    try {
      // Tentar diferentes campos para compatibilidade com diferentes backends
      final answer = responseData['answer'] as String? ??
          responseData['response'] as String? ??
          '';

      // Se não há resposta, retornar erro
      if (answer.isEmpty) {
        print('[⚠️ SMART-API] Resposta vazia recebida do backend');
        return const ProcessedGemmaResponse(
          answer: 'Resposta vazia recebida do servidor.',
          source: 'Erro do Backend',
          confidence: 0,
        );
      }

      // Detectar tipo de resposta
      if (answer.contains('[Docs Gemma •')) {
        return _processDocsGemmaResponse(answer, responseTime);
      } else if (answer.contains('[Fallback Response')) {
        return _processFallbackResponse(answer);
      } else if (answer.contains('[Improved Gemma •')) {
        return _processImprovedGemmaResponse(answer, responseTime);
      } else {
        return _processStandardResponse(answer, context);
      }
    } catch (e) {
      print('[❌ SMART-API] Erro processando resposta: $e');
      return ProcessedGemmaResponse(
        answer: 'Erro processando resposta: $e',
        source: 'Erro do Sistema',
        confidence: 0,
      );
    }
  }

  /// Processa resposta do Docs Gemma Service
  ProcessedGemmaResponse _processDocsGemmaResponse(
      String rawAnswer, double responseTime) {
    final parts = rawAnswer.split('[Docs Gemma •');
    final cleanAnswer = parts[0].trim();

    var timePart = 'Tempo não detectado';
    if (parts.length > 1) {
      final timeMatch = RegExp(r'(\d+\.?\d*)s').firstMatch(parts[1]);
      if (timeMatch != null) {
        timePart = timeMatch.group(0)!;
      }
    }

    final confidence = _calculateConfidence(cleanAnswer, responseTime);

    return ProcessedGemmaResponse(
      answer: _cleanTextResponse(cleanAnswer),
      source: 'Docs Gemma ($timePart)',
      confidence: confidence,
    );
  }

  /// Processa resposta de fallback
  ProcessedGemmaResponse _processFallbackResponse(String rawAnswer) {
    final parts = rawAnswer.split('[Fallback Response');
    final cleanAnswer = parts[0].trim();

    return ProcessedGemmaResponse(
      answer: _cleanTextResponse(cleanAnswer),
      source: 'Resposta de Emergência',
      confidence: 0.3, // Baixa confiança para fallback
    );
  }

  /// Processa resposta do Improved Gemma Service
  ProcessedGemmaResponse _processImprovedGemmaResponse(
      String rawAnswer, double responseTime) {
    final parts = rawAnswer.split('[Improved Gemma •');
    final cleanAnswer = parts[0].trim();

    var timePart = 'Tempo não detectado';
    if (parts.length > 1) {
      final timeMatch = RegExp(r'(\d+\.?\d*)s').firstMatch(parts[1]);
      if (timeMatch != null) {
        timePart = timeMatch.group(0)!;
      }
    }

    final confidence = _calculateConfidence(cleanAnswer, responseTime);

    return ProcessedGemmaResponse(
      answer: _cleanTextResponse(cleanAnswer),
      source: 'Improved Gemma ($timePart)',
      confidence: confidence,
    );
  }

  /// Processa resposta padrão
  ProcessedGemmaResponse _processStandardResponse(
          String rawAnswer, String context) =>
      ProcessedGemmaResponse(
        answer: _cleanTextResponse(rawAnswer),
        source: 'Bu Fala AI - $context',
        confidence: 0.8,
      );

  /// Limpa e formata texto da resposta
  String _cleanTextResponse(String text) {
    var cleaned = text;

    // Remover código RTF se presente
    if (cleaned.contains(r'{\rtf1')) {
      final rtfStart = cleaned.indexOf(r'{\rtf1');
      cleaned = cleaned.substring(0, rtfStart).trim();
    }

    // Remover quebras de linha excessivas
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    // Remover espaços excessivos
    cleaned = cleaned.replaceAll(RegExp(r' {2,}'), ' ');

    // Remover caracteres de controle
    cleaned = cleaned.replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '');

    return cleaned.trim();
  }

  /// Calcula confiança da resposta baseada em heurísticas
  double _calculateConfidence(String answer, double responseTime) {
    var confidence = 0.5; // Base

    // Fator comprimento
    if (answer.length > 100) confidence += 0.2;
    if (answer.length > 300) confidence += 0.1;

    // Fator tempo de resposta
    if (responseTime < 30) confidence += 0.1;
    if (responseTime > 120) confidence -= 0.2;

    // Fator conteúdo
    if (answer.contains('agricultura') || answer.contains('cultivo')) {
      confidence += 0.1;
    }
    if (answer.contains('saúde') || answer.contains('médico')) {
      confidence += 0.1;
    }
    if (answer.contains('educação') || answer.contains('ensino')) {
      confidence += 0.1;
    }

    // Fator qualidade
    if (answer.contains('?') && answer.contains('.')) confidence += 0.1;
    if (answer.split(' ').length > 20) confidence += 0.1;

    return confidence.clamp(0.0, 1.0);
  }

  /// Trata erros do Dio
  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return 'Tempo de conexão esgotado. Verifique sua internet.';
      case DioExceptionType.sendTimeout:
        return 'Tempo de envio esgotado. Tente novamente.';
      case DioExceptionType.receiveTimeout:
        return 'Tempo de resposta esgotado. O servidor pode estar sobrecarregado.';
      case DioExceptionType.badResponse:
        return 'Erro do servidor: ${e.response?.statusCode}';
      case DioExceptionType.cancel:
        return 'Requisição cancelada.';
      case DioExceptionType.connectionError:
        return 'Erro de conexão. Verifique sua internet.';
      default:
        return 'Erro de rede: ${e.message}';
    }
  }

  /// Fallback médico para casos de timeout ou erro
  Future<SmartApiResponse<String>> _getMedicalFallback(
    String question,
    String language,
  ) async {
    print('[🏥 SMART-API] Gerando resposta médica de fallback...');

    try {
      // Tentar o endpoint principal com timeout mais curto e parâmetros simplificados
      final response = await _dio.post<Map<String, dynamic>>(
        '/medical',
        data: {
          'question': question,
          'language': language,
          'context': 'medico_simple',
          'timeout_preference': 'fast',
          'fallback_mode': true,
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 60), // Timeout mais curto
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final answer = response.data!['answer'] as String? ??
            response.data!['response'] as String? ??
            '';
        if (answer.isNotEmpty) {
          print(
              '[✅ SMART-API] Fallback médico funcionou: ${answer.length} chars');
          return SmartApiResponse.success(
            data: answer,
            source: 'Fallback Médico (${answer.length} chars)',
            confidence: 0.6,
          );
        } else {
          print('[⚠️ SMART-API] Fallback retornou resposta vazia');
        }
      }
    } catch (e) {
      print('[⚠️ SMART-API] Fallback também falhou: $e');
    }

    // Última tentativa: resposta offline básica
    print('[📱 SMART-API] Usando resposta médica offline...');
    return _getOfflineMedicalResponse(question, language);
  }

  /// Resposta médica offline básica
  SmartApiResponse<String> _getOfflineMedicalResponse(
    String question,
    String language,
  ) {
    print('[📱 SMART-API] Gerando resposta médica offline...');

    final questionLower = question.toLowerCase();
    var response = '';

    // Respostas básicas baseadas em palavras-chave
    if (questionLower.contains('febre') ||
        questionLower.contains('temperatura')) {
      response = '''
🌡️ **Sobre Febre:**

• **O que fazer:**
  - Medir a temperatura regularmente
  - Manter hidratação adequada
  - Descansar bastante
  - Usar roupas leves

• **Quando procurar ajuda:**
  - Febre acima de 39°C
  - Febre persistente por mais de 3 dias
  - Dificuldade para respirar
  - Vômitos frequentes

⚠️ **Importante:** Consulte sempre um médico para diagnóstico adequado.
''';
    } else if (questionLower.contains('dor de cabeça') ||
        questionLower.contains('cefaleia')) {
      response = '''
🧠 **Sobre Dor de Cabeça:**

• **Medidas gerais:**
  - Descansar em ambiente escuro e silencioso
  - Aplicar compressa fria na testa
  - Manter hidratação
  - Evitar estresse

• **Quando se preocupar:**
  - Dor súbita e intensa
  - Acompanhada de febre alta
  - Visão turva ou dupla
  - Rigidez no pescoço

⚠️ **Importante:** Dores de cabeça frequentes devem ser avaliadas por um médico.
''';
    } else if (questionLower.contains('pressão') ||
        questionLower.contains('hipertensão')) {
      response = '''
❤️ **Sobre Pressão Arterial:**

• **Cuidados gerais:**
  - Reduzir o consumo de sal
  - Praticar exercícios regulares
  - Manter peso adequado
  - Evitar estresse

• **Monitoramento:**
  - Medir pressão regularmente
  - Anotar os valores
  - Seguir prescrição médica

⚠️ **Importante:** Hipertensão requer acompanhamento médico contínuo.
''';
    } else {
      response = '''
🏥 **Orientação Médica Geral:**

• **Para qualquer sintoma:**
  - Observe a evolução
  - Mantenha-se hidratado
  - Descanse adequadamente
  - Anote os sintomas

• **Procure ajuda médica se:**
  - Sintomas persistirem
  - Houver piora do quadro
  - Surgirem novos sintomas
  - Tiver dúvidas

⚠️ **Importante:** Esta é uma orientação geral. Sempre consulte um profissional de saúde para diagnóstico e tratamento adequados.

📞 **Emergências:** Em caso de emergência, ligue 192 (SAMU) ou dirija-se ao hospital mais próximo.
''';
    }

    return SmartApiResponse.success(
      data: response,
      source: 'Resposta Offline - Bu Fala',
      confidence: 0.4,
    );
  }
}

// ========================================
// 🎯 CLASSES DE MODELO PARA ACESSIBILIDADE
// ========================================

/// Histórico de transcrições
class TranscriptionHistory {
  const TranscriptionHistory({
    required this.id,
    required this.text,
    required this.timestamp,
    required this.language,
    required this.confidence,
    this.translation,
  });

  factory TranscriptionHistory.fromJson(Map<String, dynamic> json) => TranscriptionHistory(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ??
          DateTime.now(),
      language: json['language'] as String? ?? 'pt-BR',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      translation: json['translation'] as String?,
    );

  final String id;
  final String text;
  final DateTime timestamp;
  final String language;
  final double confidence;
  final String? translation;

  Map<String, dynamic> toJson() => {
      'id': id,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'language': language,
      'confidence': confidence,
      'translation': translation,
    };
}

/// Idiomas suportados
class SupportedLanguage {
  const SupportedLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.isOfflineSupported,
    this.flag,
  });

  factory SupportedLanguage.fromJson(Map<String, dynamic> json) => SupportedLanguage(
      code: json['code'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nativeName: json['native_name'] as String? ?? '',
      isOfflineSupported: json['is_offline_supported'] as bool? ?? false,
      flag: json['flag'] as String?,
    );

  final String code;
  final String name;
  final String nativeName;
  final bool isOfflineSupported;
  final String? flag;

  Map<String, dynamic> toJson() => {
      'code': code,
      'name': name,
      'native_name': nativeName,
      'is_offline_supported': isOfflineSupported,
      'flag': flag,
    };
}

/// Informações de ajuda de acessibilidade
class AccessibilityHelp {
  const AccessibilityHelp({
    required this.visualFeatures,
    required this.hearingFeatures,
    required this.generalFeatures,
    required this.supportedLanguages,
    required this.offlineCapabilities,
  });

  factory AccessibilityHelp.fromJson(Map<String, dynamic> json) => AccessibilityHelp(
      visualFeatures: List<String>.from(json['visual_features'] as List? ?? []),
      hearingFeatures:
          List<String>.from(json['hearing_features'] as List? ?? []),
      generalFeatures:
          List<String>.from(json['general_features'] as List? ?? []),
      supportedLanguages:
          List<String>.from(json['supported_languages'] as List? ?? []),
      offlineCapabilities:
          List<String>.from(json['offline_capabilities'] as List? ?? []),
    );

  final List<String> visualFeatures;
  final List<String> hearingFeatures;
  final List<String> generalFeatures;
  final List<String> supportedLanguages;
  final List<String> offlineCapabilities;

  Map<String, dynamic> toJson() => {
      'visual_features': visualFeatures,
      'hearing_features': hearingFeatures,
      'general_features': generalFeatures,
      'supported_languages': supportedLanguages,
      'offline_capabilities': offlineCapabilities,
    };
}

/// Status dos serviços de acessibilidade
class AccessibilityStatus {
  const AccessibilityStatus({
    required this.transcriptionActive,
    required this.translationActive,
    required this.visualAnalysisActive,
    required this.offlineMode,
    required this.gemmaModelLoaded,
    required this.systemHealth,
  });

  factory AccessibilityStatus.fromJson(Map<String, dynamic> json) => AccessibilityStatus(
      transcriptionActive: json['transcription_active'] as bool? ?? false,
      translationActive: json['translation_active'] as bool? ?? false,
      visualAnalysisActive: json['visual_analysis_active'] as bool? ?? false,
      offlineMode: json['offline_mode'] as bool? ?? false,
      gemmaModelLoaded: json['gemma_model_loaded'] as bool? ?? false,
      systemHealth: json['system_health'] as String? ?? 'unknown',
    );

  final bool transcriptionActive;
  final bool translationActive;
  final bool visualAnalysisActive;
  final bool offlineMode;
  final bool gemmaModelLoaded;
  final String systemHealth;

  Map<String, dynamic> toJson() => {
      'transcription_active': transcriptionActive,
      'translation_active': translationActive,
      'visual_analysis_active': visualAnalysisActive,
      'offline_mode': offlineMode,
      'gemma_model_loaded': gemmaModelLoaded,
      'system_health': systemHealth,
    };
}

/// Configurações de acessibilidade do usuário
class AccessibilitySettings {
  const AccessibilitySettings({
    required this.userId,
    required this.preferredLanguage,
    required this.enableVoiceFeedback,
    required this.enableVisualDescriptions,
    required this.enableContinuousTranscription,
    required this.transcriptionLanguage,
    required this.translationTargetLanguage,
    required this.fontSize,
    required this.highContrast,
    required this.autoTranslate,
    required this.saveTranscriptionHistory,
  });

  factory AccessibilitySettings.fromJson(Map<String, dynamic> json) => AccessibilitySettings(
      userId: json['user_id'] as String? ?? 'default',
      preferredLanguage: json['preferred_language'] as String? ?? 'pt-BR',
      enableVoiceFeedback: json['enable_voice_feedback'] as bool? ?? true,
      enableVisualDescriptions:
          json['enable_visual_descriptions'] as bool? ?? true,
      enableContinuousTranscription:
          json['enable_continuous_transcription'] as bool? ?? false,
      transcriptionLanguage:
          json['transcription_language'] as String? ?? 'pt-BR',
      translationTargetLanguage:
          json['translation_target_language'] as String? ?? 'en',
      fontSize: (json['font_size'] as num?)?.toDouble() ?? 16.0,
      highContrast: json['high_contrast'] as bool? ?? false,
      autoTranslate: json['auto_translate'] as bool? ?? false,
      saveTranscriptionHistory:
          json['save_transcription_history'] as bool? ?? true,
    );

  final String userId;
  final String preferredLanguage;
  final bool enableVoiceFeedback;
  final bool enableVisualDescriptions;
  final bool enableContinuousTranscription;
  final String transcriptionLanguage;
  final String translationTargetLanguage;
  final double fontSize;
  final bool highContrast;
  final bool autoTranslate;
  final bool saveTranscriptionHistory;

  Map<String, dynamic> toJson() => {
      'user_id': userId,
      'preferred_language': preferredLanguage,
      'enable_voice_feedback': enableVoiceFeedback,
      'enable_visual_descriptions': enableVisualDescriptions,
      'enable_continuous_transcription': enableContinuousTranscription,
      'transcription_language': transcriptionLanguage,
      'translation_target_language': translationTargetLanguage,
      'font_size': fontSize,
      'high_contrast': highContrast,
      'auto_translate': autoTranslate,
      'save_transcription_history': saveTranscriptionHistory,
    };

  AccessibilitySettings copyWith({
    String? userId,
    String? preferredLanguage,
    bool? enableVoiceFeedback,
    bool? enableVisualDescriptions,
    bool? enableContinuousTranscription,
    String? transcriptionLanguage,
    String? translationTargetLanguage,
    double? fontSize,
    bool? highContrast,
    bool? autoTranslate,
    bool? saveTranscriptionHistory,
  }) => AccessibilitySettings(
      userId: userId ?? this.userId,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      enableVoiceFeedback: enableVoiceFeedback ?? this.enableVoiceFeedback,
      enableVisualDescriptions:
          enableVisualDescriptions ?? this.enableVisualDescriptions,
      enableContinuousTranscription:
          enableContinuousTranscription ?? this.enableContinuousTranscription,
      transcriptionLanguage:
          transcriptionLanguage ?? this.transcriptionLanguage,
      translationTargetLanguage:
          translationTargetLanguage ?? this.translationTargetLanguage,
      fontSize: fontSize ?? this.fontSize,
      highContrast: highContrast ?? this.highContrast,
      autoTranslate: autoTranslate ?? this.autoTranslate,
      saveTranscriptionHistory:
          saveTranscriptionHistory ?? this.saveTranscriptionHistory,
    );
}

// ========================================
// 🎯 CLASSES EXISTENTES
// ========================================

/// Resposta inteligente da API
class SmartApiResponse<T> {
  const SmartApiResponse._({
    required this.success,
    this.data,
    this.error,
    this.source = 'Sistema',
    this.responseTime = 0.0,
    this.confidence = 0.0,
  });

  factory SmartApiResponse.success({
    required T data,
    String source = 'Sistema',
    double responseTime = 0.0,
    double confidence = 1.0,
  }) => SmartApiResponse._(
      success: true,
      data: data,
      source: source,
      responseTime: responseTime,
      confidence: confidence,
    );

  factory SmartApiResponse.error(String error) => SmartApiResponse._(
      success: false,
      error: error,
    );
  final bool success;
  final T? data;
  final String? error;
  final String source;
  final double responseTime;
  final double confidence;
}

/// Resposta processada do Gemma
class ProcessedGemmaResponse {
  const ProcessedGemmaResponse({
    required this.answer,
    required this.source,
    required this.confidence,
  });
  final String answer;
  final String source;
  final double confidence;
}

/// Interceptor para retry automático
class RetryInterceptor extends Interceptor {
  RetryInterceptor({required this.dio, required this.options});
  final Dio dio;
  final RetryOptions options;

  @override
  Future<void> onError(
      DioException err, ErrorInterceptorHandler handler) async {
    if (options.shouldRetry(err)) {
      await Future<void>.delayed(options.retryInterval);

      try {
        final response = await dio.request<Map<String, dynamic>>(
          err.requestOptions.path,
          data: err.requestOptions.data,
          queryParameters: err.requestOptions.queryParameters,
          options: Options(
            method: err.requestOptions.method,
            headers: err.requestOptions.headers,
          ),
        );
        handler.resolve(response);
        return;
      } catch (e) {
        // Continue with original error
      }
    }

    handler.next(err);
  }
}

/// Opções de retry
class RetryOptions {
  const RetryOptions({
    this.retries = 3,
    this.retryInterval = const Duration(seconds: 1),
  });
  final int retries;
  final Duration retryInterval;

  bool shouldRetry(DioException error) =>
      error.type == DioExceptionType.connectionTimeout ||
      error.type == DioExceptionType.receiveTimeout ||
      error.type == DioExceptionType.connectionError;
}
