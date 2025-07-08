import 'dart:math' as math;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

/// Serviço de API Inteligente para o Bu Fala - Versão Corrigida
/// Otimizado para trabalhar com timeouts e fallbacks
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

  /// Health check otimizado
  Future<SmartApiResponse<Map<String, dynamic>>> healthCheck() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/health',
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

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

  /// Pergunta médica com tratamento inteligente e fallback
  Future<SmartApiResponse<String>> askMedicalQuestion({
    required String question,
    String language = 'pt-BR',
  }) async {
    try {
      print('[🏥 SMART-API] Enviando pergunta médica...');
      print(
          '[🏥 SMART-API] Pergunta: ${question.substring(0, math.min(100, question.length))}...');

      final stopwatch = Stopwatch()..start();

      // Primeiro, tentativa com timeout padrão
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

  /// Fallback médico para casos de timeout ou erro
  Future<SmartApiResponse<String>> _getMedicalFallback(
    String question,
    String language,
  ) async {
    print('[🏥 SMART-API] Gerando resposta médica de fallback...');

    try {
      // Tentar um endpoint mais simples se disponível
      final response = await _dio.post<Map<String, dynamic>>(
        '/medical/simple',
        data: {
          'question': question,
          'language': language,
          'fallback_mode': true,
          'timeout': 30,
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 45),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final answer = response.data!['answer'] as String? ?? '';
        if (answer.isNotEmpty) {
          return SmartApiResponse.success(
            data: answer,
            source: 'Fallback Médico',
            confidence: 0.6,
          );
        }
      }
    } catch (e) {
      print('[⚠️ SMART-API] Fallback também falhou: $e');
    }

    // Última tentativa: resposta offline básica
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

**Devido a problemas técnicos temporários, aqui está uma orientação geral:**

• **Para qualquer sintoma:**
  - Observe a evolução dos sintomas
  - Mantenha-se bem hidratado
  - Descanse adequadamente
  - Anote todos os sintomas e sua evolução

• **Procure ajuda médica imediatamente se:**
  - Sintomas persistirem ou piorarem
  - Houver febre alta persistente
  - Dificuldade para respirar
  - Dor no peito
  - Vômitos excessivos
  - Tonturas intensas

⚠️ **IMPORTANTE:** Esta é apenas uma orientação geral. 
**SEMPRE consulte um profissional de saúde qualificado** para:
- Diagnóstico adequado
- Tratamento específico
- Prescrição de medicamentos
- Acompanhamento médico

📞 **Emergências:** 
- SAMU: 192
- Bombeiros: 193  
- Hospital mais próximo em casos graves

🔄 **Tente novamente:** O sistema pode estar temporariamente sobrecarregado. Tente sua pergunta novamente em alguns minutos.
''';
    }

    return SmartApiResponse.success(
      data: response,
      source: 'Bu Fala - Resposta Offline',
      confidence: 0.4,
    );
  }

  /// Processa resposta do DocsGemmaService
  ProcessedGemmaResponse _processGemmaResponse(
    Map<String, dynamic> responseData,
    String context,
    double responseTime,
  ) {
    try {
      final answer = responseData['answer'] as String? ?? '';

      if (answer.isEmpty) {
        return const ProcessedGemmaResponse(
          answer: 'Resposta vazia recebida do servidor.',
          source: 'Erro do Sistema',
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
      confidence: 0.3,
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
        return 'Tempo de resposta esgotado. O Gemma-3n pode estar sobrecarregado. Usando resposta de emergência.';
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
}

// ========================================
// 🎯 CLASSES DE MODELO
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
