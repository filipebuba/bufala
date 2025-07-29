import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';

import '../models/crisis_response_models.dart';
import '../models/offline_learning_models.dart';
import '../config/app_config.dart';
// import 'tflite_gemma_service.dart';

/// Serviço para conectar ao backend Gemma-3
class Gemma3BackendService {
  factory Gemma3BackendService() => _instance;
  Gemma3BackendService._internal();
  static final Gemma3BackendService _instance =
      Gemma3BackendService._internal();

  final Dio _dio = Dio();
  static String get _baseUrl => AppConfig.apiBaseUrl; // URL dinâmica do backend
  bool _isInitialized = false;

  // TensorFlow Lite para funcionamento offline
  // final TFLiteGemmaService _tfliteService = TFLiteGemmaService();
  bool _isOfflineMode = false;

  /// Inicializar serviço
  Future<bool> initialize() async {
    // Sempre inicializar TensorFlow Lite para funcionamento offline
    // await _tfliteService.initialize();

    try {
      _dio.options.baseUrl = _baseUrl;
      _dio.options.connectTimeout = const Duration(seconds: 30);
      _dio.options.receiveTimeout = const Duration(seconds: 60);

      // Testar conexão com o backend
      final response = await _dio.get<Map<String, dynamic>>(AppConfig.buildUrl('health'));
      if (response.statusCode == 200) {
        _isInitialized = true;
        _isOfflineMode = false;
        print('✅ Conectado ao backend Gemma-3 em $_baseUrl');
        return true;
      }
    } catch (e) {
      print('❌ Erro ao conectar ao backend Gemma-3: $e');
      print('💡 Mudando para modo offline com TensorFlow Lite');
      _isOfflineMode = true;
      _isInitialized = true;
      return true;
    }
    return false;
  }

  /// Verifica conectividade e alterna entre online/offline
  Future<bool> _checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  /// Processar emergência com Gemma-3
  Future<CrisisResponseData> processEmergency({
    required String emergencyType,
    String? description,
    String? imagePath,
    String? audioPath,
    String language = 'pt-BR',
    String? location,
  }) async {
    if (!_isInitialized) {
      throw Exception(
        'Serviço não inicializado. Execute initialize() primeiro.',
      );
    }

    // Verificar conectividade e decidir modo de operação
    final isConnected = await _checkConnectivity();
    if (!isConnected || _isOfflineMode) {
      // Fallback offline: resposta padrão
      return CrisisResponseData(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Emergência: $emergencyType',
        description:
            'Modo offline: backend indisponível. Siga orientações básicas de segurança.',
        emergencyType: emergencyType,
        severity: _determineSeverity(emergencyType),
        instructions: _getEmergencyInstructions(emergencyType, language),
        timestamp: DateTime.now(),
        metadata: {
          'generated_offline': true,
          'language': language,
          'model': 'offline-fallback'
        },
      );
    }

    try {
      final formData = FormData.fromMap({
        'emergency_type': emergencyType,
        'language': language,
        if (description != null) 'description': description,
        if (location != null) 'location': location,
      });

      // Adicionar arquivo de imagem se fornecido
      if (imagePath != null) {
        formData.files.add(
          MapEntry('image', await MultipartFile.fromFile(imagePath)),
        );
      }

      // Adicionar arquivo de áudio se fornecido
      if (audioPath != null) {
        formData.files.add(
          MapEntry('audio', await MultipartFile.fromFile(audioPath)),
        );
      }

      final response = await _dio.post<Map<String, dynamic>>(
        AppConfig.buildUrl('medical'),
        data: formData,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        return CrisisResponseData(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: emergencyType,
          description: (data['description'] as String?) ??
              'Resposta de emergência gerada por IA',
          severity: (data['severity'] as String?) ?? 'medium',
          instructions:
              List<String>.from(data['immediate_actions'] as List? ?? []),
          timestamp: DateTime.now(),
          location: location ?? '',
          contacts: {},
        );
      } else {
        throw Exception('Erro na resposta do servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro ao processar emergência: $e');
      rethrow;
    }
  }

  /// Gerar conteúdo educativo com Gemma-3
  Future<OfflineLearningContent> generateEducationalContent({
    required String subject,
    required String language,
    String level = 'beginner',
    List<String>? topics,
    String? studentProfile,
  }) async {
    if (!_isInitialized) {
      throw Exception(
        'Serviço não inicializado. Execute initialize() primeiro.',
      );
    }

    try {
      // Criar pergunta baseada nos parâmetros
      var question = 'Ensine-me sobre $subject para nível $level';
      if (topics != null && topics.isNotEmpty) {
        question += ', focando em: ${topics.join(', ')}';
      }

      final requestData = {
        'question': question,
        'subject': subject,
        'level': level,
        'language': language,
      };

      final response = await _dio.post<Map<String, dynamic>>(AppConfig.buildUrl('education'),
          data: requestData);

      if (response.statusCode == 200) {
        final data = response.data ?? {};
        return OfflineLearningContent(
          id: 'gemma_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Conteúdo de $subject - Nível $level',
          description: (data['answer'] as String?) ?? 'Conteúdo gerado por IA',
          subject: subject,
          level: level,
          languages: [language],
          content: (data['answer'] as String?) ?? 'Conteúdo não disponível',
          type: 'lesson',
          createdAt: DateTime.now(),
          metadata: {
            'domain': (data['domain'] as String?) ?? 'education',
            'timestamp': DateTime.now().toIso8601String(),
            'question': question,
          },
        );
      } else {
        throw Exception('Erro na resposta do servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro ao gerar conteúdo educativo: $e');
      rethrow;
    }
  }

  /// Processar áudio com Gemma-3 (transcrição e análise)
  Future<Map<String, dynamic>> processAudio({
    required String audioPath,
    String language = 'pt-BR',
    String? context,
  }) async {
    if (!_isInitialized) {
      throw Exception(
        'Serviço não inicializado. Execute initialize() primeiro.',
      );
    }

    try {
      final formData = FormData.fromMap({
        'language': language,
        if (context != null) 'context': context,
      });

      formData.files.add(
        MapEntry('audio', await MultipartFile.fromFile(audioPath)),
      );

      final response =
          await _dio.post<Map<String, dynamic>>(AppConfig.buildUrl('multimodal'), data: formData);

      if (response.statusCode == 200) {
        return response.data ?? {};
      } else {
        throw Exception('Erro na resposta do servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro ao processar áudio: $e');
      rethrow;
    }
  }

  /// Processar imagem com Gemma-3 (análise multimodal)
  Future<Map<String, dynamic>> processImage({
    required String imagePath,
    String? prompt,
    String language = 'pt-BR',
  }) async {
    if (!_isInitialized) {
      throw Exception(
        'Serviço não inicializado. Execute initialize() primeiro.',
      );
    }

    try {
      final formData = FormData.fromMap({
        'language': language,
        if (prompt != null) 'prompt': prompt,
      });

      formData.files.add(
        MapEntry('image', await MultipartFile.fromFile(imagePath)),
      );

      final response =
          await _dio.post<Map<String, dynamic>>(AppConfig.buildUrl('multimodal'), data: formData);

      if (response.statusCode == 200) {
        return response.data ?? {};
      } else {
        throw Exception('Erro na resposta do servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro ao processar imagem: $e');
      rethrow;
    }
  }

  /// Traduzir texto usando Gemma-3
  Future<String> translateText({
    required String text,
    required String fromLanguage,
    required String toLanguage,
  }) async {
    if (!_isInitialized) {
      throw Exception(
        'Serviço não inicializado. Execute initialize() primeiro.',
      );
    }

    try {
      final requestData = {
        'text': text,
        'from_language': fromLanguage,
        'to_language': toLanguage,
      };

      final response = await _dio.post<Map<String, dynamic>>(AppConfig.buildUrl('translate'),
          data: requestData);

      if (response.statusCode == 200) {
        return (response.data?['translated'] as String?) ?? text;
      } else {
        throw Exception('Erro na resposta do servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro ao traduzir texto: $e');
      return text; // Retorna texto original em caso de erro
    }
  }

  /// Verificar status de saúde do backend
  Future<Map<String, dynamic>> getHealthStatus() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(AppConfig.buildUrl('health'));
      return response.data ?? {};
    } catch (e) {
      return {'status': 'error', 'message': e.toString()};
    }
  }

  /// Verificar se está inicializado
  bool get isInitialized => _isInitialized;

  /// Obter URL base
  String get baseUrl => _baseUrl;

  /// Processar emergência offline usando TensorFlow Lite
  // (Removido: _processEmergencyOffline)

  /// Consultar informações agrícolas com Gemma-3
  Future<Map<String, dynamic>> consultAgriculture({
    required String question,
    String language = 'pt-BR',
    String? cropType,
    String? season,
    String? location,
  }) async {
    if (!_isInitialized) {
      throw Exception(
        'Serviço não inicializado. Execute initialize() primeiro.',
      );
    }

    try {
      final requestData = {
        'question': question,
        'language': language,
        if (cropType != null) 'crop_type': cropType,
        if (season != null) 'season': season,
        if (location != null) 'location': location,
      };

      final response = await _dio.post<Map<String, dynamic>>(AppConfig.buildUrl('agriculture'),
          data: requestData);

      if (response.statusCode == 200) {
        return response.data ?? {};
      } else {
        throw Exception('Erro na resposta do servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro ao consultar agricultura: $e');
      rethrow;
    }
  }

  /// Fazer pergunta médica com Gemma-3
  Future<Map<String, dynamic>> consultMedical({
    required String question,
    String language = 'pt-BR',
    String? symptoms,
    String? patientAge,
    String? urgencyLevel,
  }) async {
    if (!_isInitialized) {
      throw Exception(
        'Serviço não inicializado. Execute initialize() primeiro.',
      );
    }

    try {
      final requestData = {
        'question': question,
        'language': language,
        if (symptoms != null) 'symptoms': symptoms,
        if (patientAge != null) 'patient_age': patientAge,
        if (urgencyLevel != null) 'urgency_level': urgencyLevel,
      };

      final response =
          await _dio.post<Map<String, dynamic>>(AppConfig.buildUrl('medical'), data: requestData);

      if (response.statusCode == 200) {
        return response.data ?? {};
      } else {
        throw Exception('Erro na resposta do servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro ao consultar informações médicas: $e');
      rethrow;
    }
  }

  /// Gerar conteúdo de bem-estar com Gemma-3
  Future<Map<String, dynamic>> generateWellnessContent({
    required String prompt,
    String language = 'pt-BR',
    String? sessionType,
    Map<String, dynamic>? userContext,
  }) async {
    if (!_isInitialized) {
      throw Exception(
        'Serviço não inicializado. Execute initialize() primeiro.',
      );
    }

    try {
      final requestData = {
        'prompt': prompt,
        'language': language,
        'context': 'wellness_coaching',
        if (sessionType != null) 'session_type': sessionType,
        if (userContext != null) 'user_context': userContext,
      };

      final response = await _dio.post<Map<String, dynamic>>(
        AppConfig.buildUrl('wellness'),
        data: requestData,
      );

      if (response.statusCode == 200) {
        return response.data ?? {};
      } else {
        throw Exception('Erro na resposta do servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro ao gerar conteúdo de bem-estar: $e');
      rethrow;
    }
  }

  /// Chat genérico com Gemma-3
  Future<Map<String, dynamic>> sendChatMessage({
    required String message,
    String language = 'pt-BR',
    String? context,
    List<Map<String, String>>? conversationHistory,
  }) async {
    if (!_isInitialized) {
      throw Exception(
        'Serviço não inicializado. Execute initialize() primeiro.',
      );
    }

    try {
      final requestData = {
        'message': message,
        'language': language,
        if (context != null) 'context': context,
        if (conversationHistory != null) 'history': conversationHistory,
      };

      final response =
          await _dio.post<Map<String, dynamic>>(AppConfig.buildUrl('chat'), data: requestData);

      if (response.statusCode == 200) {
        return response.data ?? {};
      } else {
        throw Exception('Erro na resposta do servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro ao enviar mensagem de chat: $e');
      rethrow;
    }
  }

  /// Obter resposta de emergência
  Future<Map<String, dynamic>> getEmergencyResponse({
    required String emergencyType,
    String language = 'pt-BR',
    String? description,
    String? location,
    String? severity,
  }) async {
    if (!_isInitialized) {
      throw Exception(
        'Serviço não inicializado. Execute initialize() primeiro.',
      );
    }

    try {
      final requestData = {
        'emergency_type': emergencyType,
        'language': language,
        if (description != null) 'description': description,
        if (location != null) 'location': location,
        if (severity != null) 'severity': severity,
      };

      final response = await _dio.post<Map<String, dynamic>>(AppConfig.buildUrl('emergency'),
          data: requestData);

      if (response.statusCode == 200) {
        return response.data ?? {};
      } else {
        throw Exception('Erro na resposta do servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro ao obter resposta de emergência: $e');
      rethrow;
    }
  }

  /// Obter conteúdo educacional
  Future<Map<String, dynamic>> getEducationalContent({
    required String question,
    String language = 'pt-BR',
    String? subject,
    String? level,
    String? ageGroup,
  }) async {
    if (!_isInitialized) {
      throw Exception(
        'Serviço não inicializado. Execute initialize() primeiro.',
      );
    }

    try {
      final requestData = {
        'question': question,
        'language': language,
        if (subject != null) 'subject': subject,
        if (level != null) 'level': level,
        if (ageGroup != null) 'age_group': ageGroup,
      };

      final response = await _dio.post<Map<String, dynamic>>(AppConfig.buildUrl('education'),
          data: requestData);

      if (response.statusCode == 200) {
        return response.data ?? {};
      } else {
        throw Exception('Erro na resposta do servidor: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Erro ao obter conteúdo educacional: $e');
      rethrow;
    }
  }

  /// Solicitar sessão de meditação guiada com áudio Gemma-3n
  Future<Map<String, dynamic>> requestGuidedMeditationWithAudio({
    required String sessionType,
    required int durationMinutes,
    String language = 'pt-BR',
    String? customPrompt,
    bool useGemmaAudio = true,
  }) async {
    if (!_isInitialized) {
      return {
        'success': false,
        'error': 'Serviço não inicializado',
      };
    }

    try {
      if (_isOfflineMode) {
        // Modo offline - gerar sessão básica
        return _generateOfflineMeditationSession(
          sessionType: sessionType,
          durationMinutes: durationMinutes,
          language: language,
        );
      }

      // Modo online - usar Gemma-3n
      final response = await _dio.post<Map<String, dynamic>>(
        AppConfig.buildUrl('wellness/guided-meditation'),
        data: {
          'session_type': sessionType,
          'duration_minutes': durationMinutes,
          'language': language,
          'personalized_prompt': customPrompt,
          'use_gemma_audio': useGemmaAudio,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        return {
          'success': true,
          'session_data': response.data!['session_data'],
          'audio_capabilities': response.data!['audio_capabilities'] ?? false,
        };
      } else {
        return {
          'success': false,
          'error': 'Resposta inválida do servidor',
        };
      }
    } catch (e) {
      print('❌ Erro na solicitação de meditação: $e');
      
      // Fallback para modo offline
      return _generateOfflineMeditationSession(
        sessionType: sessionType,
        durationMinutes: durationMinutes,
        language: language,
      );
    }
  }

  /// Gerar sessão de meditação offline
  Map<String, dynamic> _generateOfflineMeditationSession({
    required String sessionType,
    required int durationMinutes,
    required String language,
  }) {
    final fallbackSessions = {
      'breathing': {
        'introduction': 'Bem-vindo à sua sessão de respiração guiada. Vamos encontrar calma juntos.',
        'preparation': 'Sente-se confortavelmente e relaxe os ombros.',
        'conclusion': 'Parabéns! Você completou sua sessão de respiração.',
        'pattern': {'name': '4-7-8 Relaxamento', 'inhale_seconds': 4, 'hold_seconds': 7, 'exhale_seconds': 8}
      },
      'meditation': {
        'introduction': 'Bem-vindo à sua sessão de meditação de $durationMinutes minutos.',
        'preparation': 'Encontre uma posição confortável e feche os olhos suavemente.',
        'conclusion': 'Sua sessão de meditação está completa. Carregue essa paz consigo.',
        'pattern': {'name': 'Respiração Natural', 'inhale_seconds': 4, 'hold_seconds': 2, 'exhale_seconds': 6}
      },
      'relaxation': {
        'introduction': 'Hora de relaxar profundamente. Esta sessão é para você.',
        'preparation': 'Deite-se confortavelmente e solte toda a tensão.',
        'conclusion': 'Você está completamente relaxado. Mantenha essa paz.',
        'pattern': {'name': 'Respiração Calmante', 'inhale_seconds': 3, 'hold_seconds': 2, 'exhale_seconds': 6}
      },
    };

    final sessionData = fallbackSessions[sessionType] ?? fallbackSessions['breathing']!;
    
    return {
      'success': true,
      'session_data': {
        'session_id': '${sessionType}_offline_${DateTime.now().millisecondsSinceEpoch}',
        'instructions': {
          'introduction': sessionData['introduction'],
          'preparation': sessionData['preparation'],
          'conclusion': sessionData['conclusion'],
        },
        'audio_content': {
          'has_audio': false,
          'use_tts': true,
          'fallback_text': '${sessionData['introduction']} ${sessionData['preparation']} ${sessionData['conclusion']}'
        },
        'pattern': sessionData['pattern'],
      },
      'audio_capabilities': false,
    };
  }

  /// Construir prompt para emergência
  String _buildEmergencyPrompt(
      String type, String? description, String language) {
    final langCode = language.split('-')[0];

    if (langCode == 'pt') {
      return 'Emergência: $type${description != null ? " - $description" : ""}. '
          'Forneça instruções de primeiros socorros e segurança para Guiné-Bissau:';
    } else {
      return 'Emergency: $type${description != null ? " - $description" : ""}. '
          'Provide first aid and safety instructions for Guinea-Bissau:';
    }
  }

  /// Determinar severidade da emergência
  String _determineSeverity(String emergencyType) {
    final highSeverity = ['medical', 'fire', 'violence', 'drowning'];
    final mediumSeverity = ['accident', 'flood', 'storm'];

    if (highSeverity.contains(emergencyType.toLowerCase())) {
      return 'high';
    } else if (mediumSeverity.contains(emergencyType.toLowerCase())) {
      return 'medium';
    } else {
      return 'low';
    }
  }

  /// Obter instruções básicas de emergência
  List<String> _getEmergencyInstructions(
      String emergencyType, String language) {
    final instructions = {
      'pt': {
        'medical': [
          '1. Mantenha a calma',
          '2. Verifique sinais vitais',
          '3. Procure ajuda médica',
          '4. Não mova a pessoa se houver suspeita de fratura'
        ],
        'fire': [
          '1. Saia do local imediatamente',
          '2. Chame os bombeiros',
          '3. Use escadas, nunca elevadores',
          '4. Se houver fumaça, rasteje'
        ],
        'default': [
          '1. Mantenha a calma',
          '2. Avalie a situação',
          '3. Procure ajuda apropriada',
          '4. Siga as orientações de segurança'
        ]
      },
      'en': {
        'medical': [
          '1. Stay calm',
          '2. Check vital signs',
          '3. Seek medical help',
          '4. Do not move person if fracture suspected'
        ],
        'fire': [
          '1. Leave immediately',
          '2. Call fire department',
          '3. Use stairs, never elevators',
          '4. If smoke, crawl low'
        ],
        'default': [
          '1. Stay calm',
          '2. Assess the situation',
          '3. Seek appropriate help',
          '4. Follow safety guidelines'
        ]
      }
    };

    final langCode = language.split('-')[0];
    final langInstructions = instructions[langCode] ?? instructions['en']!;

    return langInstructions[emergencyType] ?? langInstructions['default']!;
  }
}
