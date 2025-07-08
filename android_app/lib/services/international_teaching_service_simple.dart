import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/international_teaching_models.dart';
import '../models/collaborative_learning_models.dart';
import '../services/gemma3_backend_service.dart';

/// Serviço simplificado para sistema de ensino internacional
class InternationalTeachingServiceSimple {
  InternationalTeachingServiceSimple() {
    _initializeSystem();
  }

  final Gemma3BackendService _gemmaService = Gemma3BackendService();

  // Estado do sistema
  late InternationalTeachingSystem _system;
  final List<InternationalTeachingSession> _activeSessions = [];
  final Map<String, InternationalLearningProgress> _userProgress = {};

  // Idiomas suportados simplificados
  final List<SupportedLanguage> _supportedLanguages = [
    const SupportedLanguage(
      code: 'pt',
      name: 'Português',
      nativeName: 'Português',
      flag: '🇵🇹',
      isLocal: false,
      culturalNotes: 'Língua oficial da Guiné-Bissau',
    ),
    const SupportedLanguage(
      code: 'crioulo',
      name: 'Crioulo',
      nativeName: 'Kriol',
      flag: '🇬🇼',
      isLocal: true,
      culturalNotes: 'Língua crioula da Guiné-Bissau',
    ),
    const SupportedLanguage(
      code: 'fr',
      name: 'Francês',
      nativeName: 'Français',
      flag: '🇫🇷',
      isLocal: false,
      culturalNotes: 'Língua regional importante',
    ),
  ];

  List<SupportedLanguage> get supportedLanguages => _supportedLanguages;
  List<SupportedLanguage> get localLanguages =>
      _supportedLanguages.where((lang) => lang.isLocal).toList();

  void _initializeSystem() {
    _system = InternationalTeachingSystem(
      supportedLanguages: _supportedLanguages,
      teachingMethods: _getAvailableTeachingMethods(),
      culturalContexts: _getAvailableCulturalContexts(),
      targetAudiences: _getAvailableTargetAudiences(),
      aiCapabilities: InternationalAICapabilities(
        supportedFeatures: [
          'translation',
          'cultural_adaptation',
          'difficulty_adjustment',
        ],
        maxLanguages: _supportedLanguages.length,
        offlineCapable: true,
      ),
    );
  }

  List<TeachingMethod> _getAvailableTeachingMethods() => [
        const TeachingMethod(
          id: 'vocab',
          name: 'Vocabulário',
          description: 'Aprendizado de palavras e expressões',
        ),
        const TeachingMethod(
          id: 'grammar',
          name: 'Gramática',
          description: 'Estruturas e regras da língua',
        ),
        const TeachingMethod(
          id: 'conversation',
          name: 'Conversação',
          description: 'Prática de diálogo e comunicação',
        ),
      ];

  List<CulturalContext> _getAvailableCulturalContexts() => [
        const CulturalContext(
          id: 'gb_rural',
          name: 'Rural Guiné-Bissau',
          description: 'Contexto rural da Guiné-Bissau',
          region: 'Guiné-Bissau',
        ),
        const CulturalContext(
          id: 'gb_urban',
          name: 'Urbano Guiné-Bissau',
          description: 'Contexto urbano da Guiné-Bissau',
          region: 'Guiné-Bissau',
        ),
      ];

  List<TargetAudience> _getAvailableTargetAudiences() => [
        const TargetAudience(
          id: 'adults',
          description: 'Adultos trabalhadores',
          ageRange: AgeRange.adults,
          educationLevel: EducationLevel.primary,
          context: LearningContext.community,
          specialNeeds: [],
        ),
        const TargetAudience(
          id: 'students',
          description: 'Estudantes jovens',
          ageRange: AgeRange.teenagers,
          educationLevel: EducationLevel.secondary,
          context: LearningContext.classroom,
          specialNeeds: [],
        ),
      ];

  /// Iniciar sessão de ensino
  Future<String> startTeachingSession({
    required String userId,
    required SupportedLanguage targetLanguage,
    required SupportedLanguage sourceLanguage,
    String? topic,
    DifficultyLevel? difficulty,
  }) async {
    final sessionId =
        'session_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}';

    final session = InternationalTeachingSession(
      id: sessionId,
      teacherId: userId,
      targetLanguage: targetLanguage,
      sourceLanguage: sourceLanguage,
      startTime: DateTime.now(),
      topic: topic ?? 'Conversação básica',
      difficulty: difficulty ?? DifficultyLevel.beginner,
    );

    _activeSessions.add(session);
    return sessionId;
  }

  /// Traduzir texto usando IA
  Future<Map<String, String>> translateText({
    required String text,
    required SupportedLanguage sourceLanguage,
    required SupportedLanguage targetLanguage,
    String? context,
  }) async {
    try {
      final response = await _gemmaService.translateText(
        text: text,
        sourceLanguage: sourceLanguage.code,
        targetLanguage: targetLanguage.code,
        context: context,
      );

      return {
        'original': text,
        'translation': response,
        'sourceLanguage': sourceLanguage.name,
        'targetLanguage': targetLanguage.name,
      };
    } catch (e) {
      return {
        'original': text,
        'translation': _getFallbackTranslation(text, targetLanguage),
        'sourceLanguage': sourceLanguage.name,
        'targetLanguage': targetLanguage.name,
        'error': 'Tradução offline básica',
      };
    }
  }

  /// Tradução de fallback básica
  String _getFallbackTranslation(String text, SupportedLanguage targetLang) {
    final basicTranslations = {
      'pt': {
        'hello': 'olá',
        'goodbye': 'tchau',
        'yes': 'sim',
        'no': 'não',
        'thank you': 'obrigado',
        'please': 'por favor',
      },
      'crioulo': {
        'hello': 'ola',
        'goodbye': 'ate logo',
        'yes': 'sin',
        'no': 'nao',
        'thank you': 'obrigadu',
        'please': 'pur favor',
      },
      'fr': {
        'hello': 'bonjour',
        'goodbye': 'au revoir',
        'yes': 'oui',
        'no': 'non',
        'thank you': 'merci',
        'please': 's\'il vous plaît',
      },
    };

    final translations = basicTranslations[targetLang.code];
    if (translations != null) {
      final lowerText = text.toLowerCase();
      for (final entry in translations.entries) {
        if (lowerText.contains(entry.key)) {
          return entry.value;
        }
      }
    }

    return '[Tradução para ${targetLang.name}]: $text';
  }

  /// Gerar conteúdo educacional básico
  Future<Map<String, dynamic>> generateEducationalContent({
    required SupportedLanguage targetLanguage,
    required String topic,
    required DifficultyLevel difficulty,
    CulturalContext? culturalContext,
  }) async {
    try {
      final response = await _gemmaService.getEducationalContent(
        topic: topic,
        language: targetLanguage.code,
        difficulty: difficulty.name,
        culturalContext: culturalContext?.description,
      );

      return response;
    } catch (e) {
      return _createFallbackContent(topic, targetLanguage, difficulty);
    }
  }

  /// Criar conteúdo de fallback
  Map<String, dynamic> _createFallbackContent(
    String topic,
    SupportedLanguage language,
    DifficultyLevel difficulty,
  ) {
    final basicContent = {
      'beginner': {
        'saudacoes': 'Olá, como está? / Ola, kuma ku sta?',
        'familia': 'Minha família / N familia',
        'comida': 'Comida tradicional / Kumida tradisional',
      },
      'intermediate': {
        'trabalho': 'Profissões e trabalho / Profison y trabadju',
        'saude': 'Saúde e medicina / Saudi y medisina',
        'educacao': 'Educação e escola / Edukason y skola',
      },
      'advanced': {
        'economia': 'Economia local / Ekonomia lokal',
        'politica': 'Política e governo / Politika y gobernu',
        'cultura': 'Cultura e tradições / Kultura y tradison',
      },
    };

    final levelContent =
        basicContent[difficulty.name] ?? basicContent['beginner']!;
    final content = levelContent[topic] ?? 'Conteúdo básico sobre $topic';

    return {
      'topic': topic,
      'language': language.name,
      'difficulty': difficulty.name,
      'content': content,
      'cultural_notes': language.culturalNotes,
      'examples': [
        'Exemplo 1: ${content.split('/')[0].trim()}',
        'Exemplo 2: ${content.split('/').length > 1 ? content.split('/')[1].trim() : content}',
      ],
    };
  }

  /// Obter progresso do usuário
  Map<String, dynamic> getUserProgress(String userId) {
    final progress = _userProgress[userId];
    if (progress == null) {
      return {
        'userId': userId,
        'level': 1,
        'totalXP': 0,
        'streak': 0,
        'languagesLearning': 0,
        'achievements': 0,
        'overallProgress': 0.0,
      };
    }

    return {
      'userId': userId,
      'level': 1,
      'totalXP': 0,
      'streak': 0,
      'languagesLearning': progress.targetLanguages.length,
      'achievements': progress.achievements.length,
      'overallProgress': progress.overallProgress,
      'nativeLanguage': progress.nativeLanguage.name,
      'sessionHistory': progress.sessionHistory.length,
    };
  }

  /// Atualizar progresso do usuário
  Future<void> updateUserProgress({
    required String userId,
    required SupportedLanguage targetLanguage,
    int xpGained = 10,
    String? skillArea,
  }) async {
    var progress = _userProgress[userId];

    if (progress == null) {
      progress = InternationalLearningProgress(
        userId: userId,
        nativeLanguage: _supportedLanguages.first,
        targetLanguages: {},
        overallProgress: 0.0,
        sessionHistory: [],
        achievements: [],
      );
      _userProgress[userId] = progress;
    }

    // Atualizar progresso básico
    final languageProgress = progress.targetLanguages[targetLanguage.code] ??
        LanguageProgress(
          language: targetLanguage,
          proficiency: 0.0,
          vocabulary: 0.0,
          grammar: 0.0,
          pronunciation: 0.0,
          culturalKnowledge: 0.0,
          practicalUsage: 0.0,
          lastPracticed: DateTime.now(),
        );

    // Incrementar progresso levemente
    final updatedProgress = LanguageProgress(
      language: languageProgress.language,
      proficiency: (languageProgress.proficiency + 0.01).clamp(0.0, 1.0),
      vocabulary: (languageProgress.vocabulary + 0.02).clamp(0.0, 1.0),
      grammar: (languageProgress.grammar + 0.01).clamp(0.0, 1.0),
      pronunciation: (languageProgress.pronunciation + 0.01).clamp(0.0, 1.0),
      culturalKnowledge:
          (languageProgress.culturalKnowledge + 0.01).clamp(0.0, 1.0),
      practicalUsage: (languageProgress.practicalUsage + 0.01).clamp(0.0, 1.0),
      lastPracticed: DateTime.now(),
    );

    progress.targetLanguages[targetLanguage.code] = updatedProgress;
  }

  /// Obter sessões ativas do usuário
  List<Map<String, dynamic>> getUserActiveSessions(String userId) {
    return _activeSessions
        .where((session) => session.teacherId == userId)
        .map((session) => {
              'id': session.id,
              'targetLanguage': session.targetLanguage.name,
              'sourceLanguage': session.sourceLanguage.name,
              'topic': session.topic,
              'difficulty': session.difficulty.name,
              'startTime': session.startTime.toIso8601String(),
            })
        .toList();
  }

  /// Finalizar sessão
  void finishSession(String sessionId, String userId) {
    final sessionIndex = _activeSessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex != -1) {
      _activeSessions.removeAt(sessionIndex);

      // Atualizar progresso básico
      updateUserProgress(
        userId: userId,
        targetLanguage: _supportedLanguages.first,
        xpGained: 20,
      );
    }
  }

  /// Obter estatísticas do sistema
  Map<String, dynamic> getSystemStats() => {
        'total_languages': _supportedLanguages.length,
        'local_languages': localLanguages.length,
        'active_sessions': _activeSessions.length,
        'total_users': _userProgress.length,
        'supported_features': _system.aiCapabilities.supportedFeatures.length,
      };

  /// Obter configurações recomendadas
  Map<String, dynamic> getRecommendedSettings(String userId) => {
        'dailyGoal': 50,
        'reminderTime': '19:00',
        'difficulty': 'beginner',
        'focusAreas': ['vocabulary', 'grammar'],
      };

  /// Verificar se o usuário pode fazer exercícios
  bool canDoExercise(String userId) => true;

  /// Restaurar recursos do usuário
  void restoreHearts(String userId) {
    // Implementação básica
  }

  /// Limpar dados antigos
  void cleanupOldData() {
    final now = DateTime.now();
    _activeSessions.removeWhere((session) {
      final age = now.difference(session.startTime).inHours;
      return age > 24;
    });
  }

  /// Exportar dados do usuário
  Map<String, dynamic> exportUserData(String userId) {
    final progress = _userProgress[userId];
    if (progress == null) return {};

    return {
      'userId': userId,
      'profile': getUserProgress(userId),
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Deletar dados do usuário
  bool deleteUserData(String userId) {
    try {
      _userProgress.remove(userId);
      _activeSessions.removeWhere((session) => session.teacherId == userId);
      return true;
    } catch (e) {
      print('Erro ao deletar dados do usuário: $e');
      return false;
    }
  }

  /// Dispose - limpar recursos
  void dispose() {
    _activeSessions.clear();
    _userProgress.clear();
  }
}
