import 'package:dio/dio.dart';
import '../models/collaborative_learning_models.dart';
import 'smart_api_service.dart';

/// Serviço para o Sistema de Aprendizado Colaborativo - "Ensine o Bu Fala"
class CollaborativeLearningService {

  CollaborativeLearningService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 3),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Bu-Fala-Collaborative/1.0',
      },
    ));

    // Interceptor para logging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('[🎓 ENSINE-BU-FALA] ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('[✅ ENSINE-BU-FALA] Resposta: ${response.statusCode}');
          handler.next(response);
        },
        onError: (error, handler) {
          print('[❌ ENSINE-BU-FALA] Erro: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }
  /// Submeter tradução colaborativa para uma frase existente
  Future<SmartApiResponse> submitTranslation({
    required String phraseId,
    required String translatedText,
    required String targetLanguage,
    required String userId,
  }) async {
    try {
      final data = {
        'phrase_id': phraseId,
        'translated_text': translatedText,
        'target_language': targetLanguage,
        'user_id': userId,
      };
      final response = await _dio.post(
        '/api/collaborative/translation/submit',
        data: data,
      );
      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          return SmartApiResponse.success();
        }
      }
      return SmartApiResponse.error('Erro ao submeter tradução');
    } catch (e) {
      print('[❌ COLLABORATIVE] Erro ao submeter tradução: $e');
      return SmartApiResponse.error('Falha na comunicação: $e');
    }
  }
  static const String baseUrl = 'http://10.0.2.2:5000';
  late final Dio _dio;
  final SmartApiService _smartApi = SmartApiService();

  // ========================================
  // 🎯 PERFIL DE PROFESSOR
  // ========================================

  /// Obter perfil de professor (cria automaticamente se não existir)
  Future<SmartApiResponse<TeacherProfile>> getTeacherProfile(
      String teacherId) async {
    try {
      final response = await _dio.get(
        '/api/collaborative/teacher/profile',
        queryParameters: {'teacher_id': teacherId},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final profile = TeacherProfile.fromJson(data['data']);
          return SmartApiResponse.success(data: profile);
        }
      }

      return SmartApiResponse.error('Erro ao carregar perfil do professor');
    } catch (e) {
      print('[❌ COLLABORATIVE] Erro no perfil: $e');
      return SmartApiResponse.error('Falha na comunicação: $e');
    }
  }

  /// Criar perfil de professor
  Future<SmartApiResponse<TeacherProfile>> createTeacherProfile({
    required String name,
    required List<String> languagesTeaching,
    String? profileImageUrl,
  }) async {
    try {
      final response = await _dio.post(
        '/api/collaborative/teacher/create',
        data: {
          'name': name,
          'languages_teaching': languagesTeaching,
          'profile_image_url': profileImageUrl,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['success'] == true) {
          final profile = TeacherProfile.fromJson(data['data']);
          return SmartApiResponse.success(data: profile);
        }
      }

      return SmartApiResponse.error('Erro ao criar perfil do professor');
    } catch (e) {
      print('[❌ COLLABORATIVE] Erro ao criar perfil: $e');
      return SmartApiResponse.error('Falha na comunicação: $e');
    }
  }

  /// Atualizar perfil de professor
  Future<SmartApiResponse<TeacherProfile>> updateTeacherProfile({
    required String teacherId,
    String? name,
    List<String>? languagesTeaching,
  }) async {
    try {
      final data = <String, dynamic>{'teacher_id': teacherId};

      if (name != null) data['name'] = name;
      if (languagesTeaching != null) {
        data['languages_taught'] = languagesTeaching;
      }

      final response = await _dio.put(
        '/api/collaborative/teacher/profile',
        data: data,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          final profile = TeacherProfile.fromJson(responseData['data']);
          return SmartApiResponse.success(data: profile);
        }
      }

      return SmartApiResponse.error('Erro ao atualizar perfil');
    } catch (e) {
      print('[❌ COLLABORATIVE] Erro ao atualizar: $e');
      return SmartApiResponse.error('Falha na comunicação: $e');
    }
  }

  // ========================================
  // 📝 ENSINO DE FRASES
  // ========================================

  /// Ensinar nova frase
  Future<SmartApiResponse<TeachingPhrase>> teachPhrase({
    required String teacherId,
    required String portugueseText,
    required String translatedText,
    required String targetLanguage,
    required String category,
    String? audioUrl,
    String? pronunciationGuide,
    String? culturalContext,
    DifficultyLevel? difficultyLevel,
  }) async {
    try {
      final data = {
        'teacher_id': teacherId,
        'portuguese_text': portugueseText,
        'translated_text': translatedText,
        'target_language': targetLanguage,
        'category': category,
        'audio_url': audioUrl,
        'pronunciation_guide': pronunciationGuide,
        'cultural_context': culturalContext,
        'difficulty_level': difficultyLevel?.name ?? 'basic',
      };

      final response = await _dio.post(
        '/api/collaborative/phrase/teach',
        data: data,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          final phrase = TeachingPhrase.fromJson(responseData['data']);
          return SmartApiResponse.success(data: phrase);
        }
      }

      return SmartApiResponse.error('Erro ao ensinar frase');
    } catch (e) {
      print('[❌ COLLABORATIVE] Erro ao ensinar: $e');
      return SmartApiResponse.error('Falha na comunicação: $e');
    }
  }

  /// Validar tradução
  Future<SmartApiResponse<Validation>> validateTranslation({
    required String translationId,
    required String validatorId,
    required ValidationType validationType,
    required bool isCorrect,
    String? comment,
  }) async {
    try {
      final data = {
        'translation_id': translationId,
        'validator_id': validatorId,
        'validation_type': validationType.name,
        'is_correct': isCorrect,
        'comment': comment,
      };

      final response = await _dio.post(
        '/api/collaborative/translation/validate',
        data: data,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          final validation = Validation.fromJson(responseData['data']);
          return SmartApiResponse.success(data: validation);
        }
      }

      return SmartApiResponse.error('Erro ao validar tradução');
    } catch (e) {
      print('[❌ COLLABORATIVE] Erro na validação: $e');
      return SmartApiResponse.error('Falha na comunicação: $e');
    }
  }

  /// Obter traduções pendentes de validação
  Future<SmartApiResponse<List<UserTranslation>>> getPendingValidations({
    required String validatorId,
    String? targetLanguage,
    ValidationStatus? status,
    int? limit,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'validator_id': validatorId,
      };

      if (targetLanguage != null) {
        queryParams['target_language'] = targetLanguage;
      }
      if (status != null) queryParams['status'] = status.name;
      if (limit != null) queryParams['limit'] = limit;

      final response = await _dio.get(
        '/api/collaborative/validation/pending',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final translations = (data['data'] as List)
              .map((t) => UserTranslation.fromJson(t))
              .toList();
          return SmartApiResponse.success(data: translations);
        }
      }

      return SmartApiResponse.error('Erro ao buscar validações pendentes');
    } catch (e) {
      print('[❌ COLLABORATIVE] Erro nas validações: $e');
      return SmartApiResponse.error('Falha na comunicação: $e');
    }
  }

  /// Obter ranking de professores
  Future<SmartApiResponse<TeacherRanking>> getTeacherRanking({
    RankingPeriod period = RankingPeriod.allTime,
    int? limit,
  }) async {
    try {
      final response = await _dio.get(
        '/api/collaborative/ranking',
        queryParameters: {
          'period': period.name,
          if (limit != null) 'limit': limit,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final ranking = TeacherRanking.fromJson(data['data']);
          return SmartApiResponse.success(data: ranking);
        }
      }

      return SmartApiResponse.error('Erro ao buscar ranking');
    } catch (e) {
      print('[❌ COLLABORATIVE] Erro no ranking: $e');
      return SmartApiResponse.error('Falha na comunicação: $e');
    }
  }

  /// Enviar provocação motivacional
  Future<SmartApiResponse<Map<String, dynamic>>> sendProvocation({
    required String teacherId,
    ProvocationType type = ProvocationType.curiosity,
    String? customMessage,
  }) async {
    try {
      final data = {
        'teacher_id': teacherId,
        'type': type.name,
        if (customMessage != null) 'custom_message': customMessage,
      };

      final response = await _dio.post(
        '/api/collaborative/provocation',
        data: data,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          return SmartApiResponse.success(data: responseData['data']);
        }
      }

      return SmartApiResponse.error('Erro ao enviar provocação');
    } catch (e) {
      print('[❌ COLLABORATIVE] Erro na provocação: $e');
      return SmartApiResponse.error('Falha na comunicação: $e');
    }
  }

  /// Criar duelo entre usuários
  Future<SmartApiResponse<Duel>> createDuel({
    required String challengerId,
    required DuelType duelType,
    required String targetLanguage,
    required String category,
    String? opponentId,
    int rounds = 5,
  }) async {
    try {
      final data = {
        'challenger_id': challengerId,
        'duel_type': duelType.name,
        'target_language': targetLanguage,
        'category': category,
        'opponent_id': opponentId,
        'rounds': rounds,
      };

      final response = await _dio.post(
        '/api/collaborative/duel/create',
        data: data,
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData['success'] == true) {
          final duel = Duel.fromJson(responseData['data']);
          return SmartApiResponse.success(data: duel);
        }
      }

      return SmartApiResponse.error('Erro ao criar duelo');
    } catch (e) {
      print('[❌ COLLABORATIVE] Erro no duelo: $e');
      return SmartApiResponse.error('Falha na comunicação: $e');
    }
  }

  /// Participar de duelo
  Future<SmartApiResponse<Duel>> joinDuel({
    required String duelId,
    required String participantId,
  }) async {
    try {
      final response = await _dio.post(
        '/api/collaborative/duel/join',
        data: {
          'duel_id': duelId,
          'participant_id': participantId,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final duel = Duel.fromJson(data['data']);
          return SmartApiResponse.success(data: duel);
        }
      }

      return SmartApiResponse.error('Erro ao participar do duelo');
    } catch (e) {
      print('[❌ COLLABORATIVE] Erro ao participar: $e');
      return SmartApiResponse.error('Falha na comunicação: $e');
    }
  }

  /// Obter duelos disponíveis
  Future<SmartApiResponse<List<Duel>>> getAvailableDuels({
    String? targetLanguage,
    DuelType? type,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (targetLanguage != null) {
        queryParams['target_language'] = targetLanguage;
      }
      if (type != null) queryParams['type'] = type.name;

      final response = await _dio.get(
        '/api/collaborative/duel/available',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final duels =
              (data['data'] as List).map((d) => Duel.fromJson(d)).toList();
          return SmartApiResponse.success(data: duels);
        }
      }

      return SmartApiResponse.error('Erro ao buscar duelos');
    } catch (e) {
      print('[❌ COLLABORATIVE] Erro nos duelos: $e');
      return SmartApiResponse.error('Falha na comunicação: $e');
    }
  }

  /// Obter estatísticas de aprendizado
  Future<SmartApiResponse<LearningStats>> getLearningStats() async {
    try {
      final response = await _dio.get('/api/collaborative/stats');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final stats = LearningStats.fromJson(data['data']);
          return SmartApiResponse.success(data: stats);
        }
      }

      return SmartApiResponse.error('Erro ao buscar estatísticas');
    } catch (e) {
      print('[❌ COLLABORATIVE] Erro nas estatísticas: $e');
      return SmartApiResponse.error('Falha na comunicação: $e');
    }
  }

  /// Obter progresso pessoal do professor
  Future<SmartApiResponse<Map<String, dynamic>>> getPersonalProgress(
      String teacherId) async {
    try {
      final response = await _dio.get(
        '/api/collaborative/progress',
        queryParameters: {'teacher_id': teacherId},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          return SmartApiResponse.success(data: data['data']);
        }
      }

      return SmartApiResponse.error('Erro ao buscar progresso');
    } catch (e) {
      print('[❌ COLLABORATIVE] Erro no progresso: $e');
      return SmartApiResponse.error('Falha na comunicação: $e');
    }
  }

  /// Buscar traduções existentes
  Future<SmartApiResponse<List<UserTranslation>>> searchTranslations({
    required String searchTerm,
    String? targetLanguage,
    String? category,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'search': searchTerm,
      };

      if (targetLanguage != null) {
        queryParams['target_language'] = targetLanguage;
      }
      if (category != null) queryParams['category'] = category;

      final response = await _dio.get(
        '/api/collaborative/search',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true && data['data'] != null) {
          final translations = (data['data'] as List)
              .map((t) => UserTranslation.fromJson(t))
              .toList();
          return SmartApiResponse.success(data: translations);
        }
      }

      return SmartApiResponse.error('Nenhuma tradução encontrada');
    } catch (e) {
      print('[❌ COLLABORATIVE] Erro na busca: $e');
      return SmartApiResponse.error('Erro na busca: $e');
    }
  }

  /// Obter idiomas suportados
  Future<SmartApiResponse<List<Map<String, dynamic>>>>
      getSupportedLanguages() async {
    try {
      final response = await _dio.get('/api/collaborative/languages');

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['success'] == true) {
          final languages = (data['data'] as List).cast<Map<String, dynamic>>();
          return SmartApiResponse.success(data: languages);
        }
      }

      return SmartApiResponse.error('Erro ao buscar idiomas');
    } catch (e) {
      print('[❌ COLLABORATIVE] Erro nos idiomas: $e');
      return SmartApiResponse.error('Erro inesperado: $e');
    }
  }

  // ========================================
  // 🤖 INTEGRAÇÃO COM IA
  // ========================================

  /// Obter contexto cultural para uma frase
  Future<SmartApiResponse<Map<String, dynamic>>> getCulturalContext({
    required String phrase,
    required String targetLanguage,
    required String category,
  }) async {
    try {
      final prompt = '''
      Contexto Cultural - Bu Fala

      Frase em português: "$phrase"
      Idioma alvo: $targetLanguage
      Categoria: $category

      Por favor, forneça:
      1. Contexto cultural relevante
      2. Nuances de uso
      3. Situações apropriadas
      4. Possíveis variações regionais
      ''';

      final response = await _smartApi.askEducationQuestion(
        question: prompt,
      );

      if (response.success && response.data != null) {
        return SmartApiResponse.success(data: {
          'cultural_context': response.data,
          'phrase': phrase,
          'target_language': targetLanguage,
          'category': category,
        });
      }

      return SmartApiResponse.error('Erro ao obter contexto');
    } catch (e) {
      print('[❌ COLLABORATIVE] Erro no contexto: $e');
      return SmartApiResponse.error('Erro inesperado: $e');
    }
  }

  /// Analisar qualidade da tradução usando IA
  Future<SmartApiResponse<Map<String, dynamic>>> analyzeTranslationQuality({
    required String originalText,
    required String translatedText,
    required String targetLanguage,
  }) async {
    try {
      final prompt = '''
      Análise de Tradução - Bu Fala

      Texto original (Português): "$originalText"
      Tradução ($targetLanguage): "$translatedText"

      Analise a qualidade da tradução considerando:
      1. Precisão semântica
      2. Naturalidade na língua alvo
      3. Adequação cultural
      4. Clareza comunicativa

      Forneça uma pontuação de 0-100 e justificativa.
      ''';

      final response = await _smartApi.askEducationQuestion(
        question: prompt,
      );

      if (response.success && response.data != null) {
        return SmartApiResponse.success(data: {
          'analysis': response.data,
          'original_text': originalText,
          'translated_text': translatedText,
          'target_language': targetLanguage,
        });
      }

      return SmartApiResponse.error('Erro na análise');
    } catch (e) {
      print('[❌ COLLABORATIVE] Erro na análise: $e');
      return SmartApiResponse.error('Erro inesperado: $e');
    }
  }

  /// Gerar sugestões de melhoria para tradução
  Future<SmartApiResponse<Map<String, dynamic>>>
      generateImprovementSuggestions({
    required String originalText,
    required String translatedText,
    required String targetLanguage,
    required String category,
  }) async {
    try {
      final prompt = '''
      Sugestões de Melhoria - Bu Fala

      Texto original: "$originalText"
      Tradução atual: "$translatedText"
      Idioma: $targetLanguage
      Categoria: $category

      Gere sugestões específicas para:
      1. Melhorar a tradução
      2. Variações possíveis
      3. Contextos de uso
      4. Dicas culturais
      ''';

      final response = await _smartApi.askEducationQuestion(
        question: prompt,
      );

      if (response.success && response.data != null) {
        return SmartApiResponse.success(data: {
          'suggestions': response.data,
          'original_text': originalText,
          'translated_text': translatedText,
          'target_language': targetLanguage,
          'category': category,
        });
      }

      return SmartApiResponse.error('Erro ao gerar sugestões');
    } catch (e) {
      print('[❌ COLLABORATIVE] Erro nas sugestões: $e');
      return SmartApiResponse.error('Erro inesperado: $e');
    }
  }
}
