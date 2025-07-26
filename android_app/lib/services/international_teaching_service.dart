import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/international_teaching_models.dart';
import '../services/gemma3_backend_service.dart';

/// Serviço para sistema de ensino internacional integrado (estilo Duolingo)
class InternationalTeachingService {
  InternationalTeachingService() {
    _initializeSystem();
  }

  final Gemma3BackendService _gemmaService = Gemma3BackendService();

  // Estado do sistema
  late InternationalTeachingSystem _system;
  final List<InternationalTeachingSession> _activeSessions = [];
  final Map<String, InternationalLearningProgress> _userProgress = {};

  void _initializeSystem() {
    _system = InternationalTeachingSystem(
      id: 'android_app_international',
      name: 'Bu Fala - Sistema Internacional',
      description: 'Sistema de ensino multilíngue para ONGs e organizações internacionais',
      supportedLanguages: _supportedLanguages,
      targetAudiences: _getTargetAudiences(),
      teachingMethods: _getTeachingMethods(),
      aiCapabilities: _getAICapabilities(),
    );
  }

  /// Línguas suportadas pelo sistema
  static const List<SupportedLanguage> _supportedLanguages = [
    // Línguas Locais da Guiné-Bissau
    SupportedLanguage(
      code: 'pt-GW',
      name: 'Português (Guiné-Bissau)',
      nativeName: 'Português',
      region: 'África Ocidental',
      isLocal: true,
      proficiency: LanguageProficiency.native,
      status: LanguageStatus.active,
      flag: '🇬🇼',
      culturalNotes: 'Língua oficial com influências crioulas locais',
    ),
    SupportedLanguage(
      code: 'gcr',
      name: 'Crioulo Guineense',
      nativeName: 'Kriol',
      region: 'Guiné-Bissau',
      isLocal: true,
      proficiency: LanguageProficiency.advanced,
      status: LanguageStatus.active,
      flag: '🇬🇼',
      culturalNotes: 'Língua franca amplamente falada',
    ),
    SupportedLanguage(
      code: 'ff',
      name: 'Fula',
      nativeName: 'Fulfulde',
      region: 'África Ocidental',
      isLocal: true,
      proficiency: LanguageProficiency.intermediate,
      status: LanguageStatus.development,
      flag: '🌍',
      culturalNotes: 'Uma das principais línguas étnicas',
    ),
    SupportedLanguage(
      code: 'mnk',
      name: 'Mandinga',
      nativeName: 'Mandinka',
      region: 'África Ocidental',
      isLocal: true,
      proficiency: LanguageProficiency.intermediate,
      status: LanguageStatus.development,
      flag: '🌍',
      culturalNotes: 'Importante língua comercial tradicional',
    ),

    // Línguas Regionais Africanas
    SupportedLanguage(
      code: 'wo',
      name: 'Wolof',
      nativeName: 'Wolof',
      region: 'Senegal',
      isLocal: false,
      proficiency: LanguageProficiency.basic,
      status: LanguageStatus.planned,
      flag: '🇸🇳',
      culturalNotes: 'Língua regional importante no Senegal',
    ),
    SupportedLanguage(
      code: 'sw',
      name: 'Suaíli',
      nativeName: 'Kiswahili',
      region: 'África Oriental',
      isLocal: false,
      proficiency: LanguageProficiency.basic,
      status: LanguageStatus.planned,
      flag: '🌍',
      culturalNotes: 'Língua franca da África Oriental',
    ),

    // Línguas Europeias
    SupportedLanguage(
      code: 'pt',
      name: 'Português (Brasil/Portugal)',
      nativeName: 'Português',
      region: 'Europa/América do Sul',
      isLocal: false,
      proficiency: LanguageProficiency.native,
      status: LanguageStatus.active,
      flag: '🇵🇹',
      culturalNotes: 'Variante padrão internacional',
    ),
    SupportedLanguage(
      code: 'fr',
      name: 'Francês',
      nativeName: 'Français',
      region: 'Europa/África',
      isLocal: false,
      proficiency: LanguageProficiency.advanced,
      status: LanguageStatus.active,
      flag: '🇫🇷',
      culturalNotes: 'Importante na região da África Ocidental',
    ),

    // Línguas Globais
    SupportedLanguage(
      code: 'en',
      name: 'Inglês',
      nativeName: 'English',
      region: 'Global',
      isLocal: false,
      proficiency: LanguageProficiency.advanced,
      status: LanguageStatus.active,
      flag: '🇺🇸',
      culturalNotes: 'Língua global para oportunidades internacionais',
    ),
    SupportedLanguage(
      code: 'es',
      name: 'Espanhol',
      nativeName: 'Español',
      region: 'Europa/América',
      isLocal: false,
      proficiency: LanguageProficiency.intermediate,
      status: LanguageStatus.development,
      flag: '🇪🇸',
      culturalNotes: 'Língua global com grande comunidade',
    ),
    SupportedLanguage(
      code: 'ar',
      name: 'Árabe',
      nativeName: 'العربية',
      region: 'Norte da África/Oriente Médio',
      isLocal: false,
      proficiency: LanguageProficiency.basic,
      status: LanguageStatus.planned,
      flag: '🇸🇦',
      culturalNotes: 'Importante para estudos islâmicos',
    ),
    SupportedLanguage(
      code: 'zh',
      name: 'Chinês (Mandarim)',
      nativeName: '中文',
      region: 'Ásia',
      isLocal: false,
      proficiency: LanguageProficiency.basic,
      status: LanguageStatus.planned,
      flag: '🇨🇳',
      culturalNotes: 'Crescente importância econômica global',
    ),
  ];

  /// Públicos-alvo do sistema
  List<TargetAudience> _getTargetAudiences() => [
      const TargetAudience(
        id: 'ngo_workers',
        name: 'Trabalhadores de ONGs',
        description: 'Profissionais de organizações não-governamentais',
        ageRange: AgeRange.adults,
        educationLevel: EducationLevel.university,
        context: LearningContext.ngo,
        specialNeeds: [SpecialNeed.cultural, SpecialNeed.emergency],
      ),
      const TargetAudience(
        id: 'community_leaders',
        name: 'Líderes Comunitários',
        description: 'Líderes locais e tradicionais',
        ageRange: AgeRange.adults,
        educationLevel: EducationLevel.mixed,
        context: LearningContext.community,
        specialNeeds: [SpecialNeed.cultural, SpecialNeed.health],
      ),
      const TargetAudience(
        id: 'health_workers',
        name: 'Agentes de Saúde',
        description: 'Profissionais de saúde comunitária',
        ageRange: AgeRange.adults,
        educationLevel: EducationLevel.secondary,
        context: LearningContext.hospital,
        specialNeeds: [SpecialNeed.health, SpecialNeed.emergency],
      ),
      const TargetAudience(
        id: 'teachers',
        name: 'Professores',
        description: 'Educadores formais e informais',
        ageRange: AgeRange.adults,
        educationLevel: EducationLevel.secondary,
        context: LearningContext.classroom,
        specialNeeds: [SpecialNeed.literacy, SpecialNeed.cultural],
      ),
      const TargetAudience(
        id: 'farmers',
        name: 'Agricultores',
        description: 'Produtores rurais e familiares',
        ageRange: AgeRange.mixed,
        educationLevel: EducationLevel.primary,
        context: LearningContext.field,
        specialNeeds: [SpecialNeed.agriculture, SpecialNeed.technology],
      ),
      const TargetAudience(
        id: 'youth',
        name: 'Jovens',
        description: 'Adolescentes e jovens adultos',
        ageRange: AgeRange.teenagers,
        educationLevel: EducationLevel.secondary,
        context: LearningContext.community,
        specialNeeds: [SpecialNeed.technology, SpecialNeed.cultural],
      ),
      const TargetAudience(
        id: 'women_groups',
        name: 'Grupos de Mulheres',
        description: 'Associações e cooperativas femininas',
        ageRange: AgeRange.adults,
        educationLevel: EducationLevel.mixed,
        context: LearningContext.community,
        specialNeeds: [SpecialNeed.health, SpecialNeed.literacy],
      ),
      const TargetAudience(
        id: 'refugees',
        name: 'Refugiados e Migrantes',
        description: 'Pessoas em situação de deslocamento',
        ageRange: AgeRange.mixed,
        educationLevel: EducationLevel.mixed,
        context: LearningContext.emergency,
        specialNeeds: [SpecialNeed.emergency, SpecialNeed.cultural],
      ),
    ];

  /// Métodos de ensino disponíveis (estilo Duolingo)
  List<TeachingMethod> _getTeachingMethods() => [
      const TeachingMethod(
        id: 'ai_conversation',
        name: 'Conversação com IA',
        description: 'Diálogo interativo com assistente AI multilíngue',
        type: MethodType.conversation,
        interactivity: InteractivityLevel.interactive,
        aiAssisted: true,
        icon: Icons.chat,
        color: Colors.blue,
      ),
      const TeachingMethod(
        id: 'real_time_translation',
        name: 'Tradução em Tempo Real',
        description: 'Tradução instantânea entre línguas durante conversas',
        type: MethodType.translation,
        interactivity: InteractivityLevel.immersive,
        aiAssisted: true,
        icon: Icons.translate,
        color: Colors.green,
      ),
      const TeachingMethod(
        id: 'vocabulary_practice',
        name: 'Prática de Vocabulário',
        description: 'Exercícios de vocabulário com repetição espaçada',
        type: MethodType.vocabulary,
        interactivity: InteractivityLevel.interactive,
        aiAssisted: true,
        icon: Icons.book,
        color: Colors.indigo,
      ),
      const TeachingMethod(
        id: 'grammar_exercises',
        name: 'Exercícios de Gramática',
        description: 'Lições estruturadas de gramática com exemplos',
        type: MethodType.grammar,
        interactivity: InteractivityLevel.interactive,
        aiAssisted: true,
        icon: Icons.school,
        color: Colors.deepPurple,
      ),
      const TeachingMethod(
        id: 'listening_comprehension',
        name: 'Compreensão Auditiva',
        description: 'Exercícios de escuta com áudio nativo',
        type: MethodType.listening,
        interactivity: InteractivityLevel.interactive,
        aiAssisted: true,
        icon: Icons.headphones,
        color: Colors.cyan,
      ),
      const TeachingMethod(
        id: 'speaking_practice',
        name: 'Prática de Fala',
        description: 'Exercícios de pronúncia com feedback de IA',
        type: MethodType.speaking,
        interactivity: InteractivityLevel.immersive,
        aiAssisted: true,
        icon: Icons.mic,
        color: Colors.pink,
      ),
      const TeachingMethod(
        id: 'cultural_storytelling',
        name: 'Narrativas Culturais',
        description: 'Histórias tradicionais adaptadas para ensino',
        type: MethodType.storytelling,
        interactivity: InteractivityLevel.interactive,
        aiAssisted: true,
        icon: Icons.auto_stories,
        color: Colors.orange,
      ),
      const TeachingMethod(
        id: 'emergency_scenarios',
        name: 'Cenários de Emergência',
        description: 'Simulações para situações críticas',
        type: MethodType.emergency,
        interactivity: InteractivityLevel.immersive,
        aiAssisted: true,
        icon: Icons.emergency,
        color: Colors.red,
      ),
      const TeachingMethod(
        id: 'collaborative_learning',
        name: 'Aprendizado Colaborativo',
        description: 'Grupos multilíngues com facilitação AI',
        type: MethodType.cultural,
        interactivity: InteractivityLevel.collaborative,
        aiAssisted: true,
        icon: Icons.groups,
        color: Colors.purple,
      ),
      const TeachingMethod(
        id: 'practical_application',
        name: 'Aplicação Prática',
        description: 'Uso da língua em contextos reais de trabalho',
        type: MethodType.practical,
        interactivity: InteractivityLevel.immersive,
        aiAssisted: true,
        icon: Icons.work,
        color: Colors.teal,
      ),
      const TeachingMethod(
        id: 'cultural_games',
        name: 'Jogos Culturais',
        description: 'Atividades lúdicas baseadas em tradições locais',
        type: MethodType.games,
        interactivity: InteractivityLevel.interactive,
        aiAssisted: true,
        icon: Icons.games,
        color: Colors.amber,
      ),
      const TeachingMethod(
        id: 'daily_challenges',
        name: 'Desafios Diários',
        description: 'Exercícios diários para manter o progresso',
        type: MethodType.challenge,
        interactivity: InteractivityLevel.interactive,
        aiAssisted: true,
        icon: Icons.today,
        color: Colors.lightGreen,
      ),
      const TeachingMethod(
        id: 'streak_maintenance',
        name: 'Manutenção de Sequência',
        description: 'Sistema de sequências para motivar o aprendizado',
        type: MethodType.gamification,
        interactivity: InteractivityLevel.passive,
        aiAssisted: false,
        icon: Icons.local_fire_department,
        color: Colors.deepOrange,
      ),
    ];

  /// Capacidades da IA
  AICapabilities _getAICapabilities() => const AICapabilities(
      canTranslate: true,
      canGenerateContent: true,
      canAdaptToContext: true,
      canLearnFromInteraction: true,
      supportedFeatures: [
        AIFeature.realTimeTranslation,
        AIFeature.contextualLearning,
        AIFeature.culturalAdaptation,
        AIFeature.voiceGeneration,
        AIFeature.emergencyResponse,
        AIFeature.progressTracking,
        AIFeature.personalizedContent,
        AIFeature.speechRecognition,
        AIFeature.pronunciationFeedback,
        AIFeature.adaptiveDifficulty,
      ],
      limitations: [
        'Algumas línguas locais ainda em desenvolvimento',
        'Nuances culturais complexas podem ser perdidas',
        'Requer conectividade para funcionalidades avançadas',
        'Reconhecimento de voz pode variar com sotaques locais',
      ],
    );

  // Métodos públicos do serviço

  /// Obter sistema de ensino
  InternationalTeachingSystem get system => _system;

  /// Obter línguas suportadas
  List<SupportedLanguage> get supportedLanguages => _supportedLanguages;

  /// Obter línguas locais apenas
  List<SupportedLanguage> get localLanguages =>
      _supportedLanguages.where((lang) => lang.isLocal).toList();

  /// Obter línguas por região
  List<SupportedLanguage> getLanguagesByRegion(String region) =>
      _supportedLanguages.where((lang) => lang.region == region).toList();

  /// Obter línguas por proficiência
  List<SupportedLanguage> getLanguagesByProficiency(
          LanguageProficiency proficiency) =>
      _supportedLanguages
          .where((lang) => lang.proficiency == proficiency)
          .toList();

  /// Criar nova sessão de ensino
  Future<InternationalTeachingSession> createTeachingSession({
    required String teacherId,
    required TargetAudience audience,
    required List<SupportedLanguage> languages,
    required TeachingMethod method,
    required String topic,
    CulturalContext? culturalContext,
  }) async {
    final session = InternationalTeachingSession(
      id: 'session_${DateTime.now().millisecondsSinceEpoch}',
      teacherId: teacherId,
      targetAudience: audience,
      languages: languages,
      method: method,
      topic: topic,
      startTime: DateTime.now(),
      culturalContext: culturalContext,
      aiAssistant: _createAIAssistant(languages),
      exercises: [],
      currentExerciseIndex: 0,
      score: 0,
      streak: 0,
      hearts: 5, // Sistema de vidas como no Duolingo
    );

    _activeSessions.add(session);
    return session;
  }

  /// Criar assistente AI para a sessão
  AITeachingAssistant _createAIAssistant(List<SupportedLanguage> languages) => AITeachingAssistant(
      name: 'Bu Fala AI Teacher',
      capabilities: _system.aiCapabilities,
      activeLanguages: languages,
      adaptationLevel: 0.8,
      personality: 'encorajador',
      voiceSettings: const VoiceSettings(
        speed: 1,
        pitch: 1,
        accent: 'neutral',
        gender: 'neutro',
      ),
    );

  /// Gerar exercício estilo Duolingo
  Future<LearningExercise> generateExercise({
    required String userId,
    required SupportedLanguage targetLanguage,
    required SupportedLanguage sourceLanguage,
    required ExerciseType type,
    required DifficultyLevel difficulty,
    String? topic,
  }) async {
    try {
      final userProgress = getUserProgress(userId);
      final exerciseContent = await _generateExerciseContent(
        type: type,
        targetLanguage: targetLanguage,
        sourceLanguage: sourceLanguage,
        difficulty: difficulty,
        userProgress: userProgress,
        topic: topic,
      );

      return LearningExercise(
        id: 'exercise_${DateTime.now().millisecondsSinceEpoch}',
        type: type,
        difficulty: difficulty,
        targetLanguage: targetLanguage,
        sourceLanguage: sourceLanguage,
        question: exerciseContent.question,
        options: exerciseContent.options,
        correctAnswer: exerciseContent.correctAnswer,
        explanation: exerciseContent.explanation,
        audioUrl: exerciseContent.audioUrl,
        imageUrl: exerciseContent.imageUrl,
        hints: exerciseContent.hints,
        points: _calculateExercisePoints(type, difficulty),
        timeLimit: _getExerciseTimeLimit(type),
        culturalContext: exerciseContent.culturalContext,
      );
    } catch (e) {
      print('Erro ao gerar exercício: $e');
      return _createFallbackExercise(type, targetLanguage, sourceLanguage);
    }
  }

  /// Gerar conteúdo do exercício
  Future<ExerciseContent> _generateExerciseContent({
    required ExerciseType type,
    required SupportedLanguage targetLanguage,
    required SupportedLanguage sourceLanguage,
    required DifficultyLevel difficulty,
    InternationalLearningProgress? userProgress,
    String? topic,
  }) async {
    final prompt = _buildExercisePrompt(
      type: type,
      targetLanguage: targetLanguage,
      sourceLanguage: sourceLanguage,
      difficulty: difficulty,
      topic: topic,
    );

    try {
      final response = await _gemmaService.askQuestion(prompt);
      return _parseExerciseResponse(response, type);
    } catch (e) {
      return _createFallbackExerciseContent(type, targetLanguage, sourceLanguage);
    }
  }

  /// Construir prompt para exercício
  String _buildExercisePrompt({
    required ExerciseType type,
    required SupportedLanguage targetLanguage,
    required SupportedLanguage sourceLanguage,
    required DifficultyLevel difficulty,
    String? topic,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('Crie um exercício de ${_mapExerciseTypeToString(type)}');
    buffer.writeln('Língua de origem: ${sourceLanguage.name}');
    buffer.writeln('Língua alvo: ${targetLanguage.name}');
    buffer.writeln('Dificuldade: ${_mapDifficultyToString(difficulty)}');
    
    if (topic != null) {
      buffer.writeln('Tópico: $topic');
    }
    
    if (targetLanguage.isLocal) {
      buffer.writeln('IMPORTANTE: Esta é uma língua local da Guiné-Bissau.');
      buffer.writeln('Use contexto cultural apropriado: ${targetLanguage.culturalNotes}');
    }

    switch (type) {
      case ExerciseType.translation:
        buffer.writeln('\nFormato: Forneça uma frase em ${sourceLanguage.name} para traduzir para ${targetLanguage.name}');
        buffer.writeln('Inclua 4 opções de resposta (1 correta, 3 incorretas)');
        break;
      case ExerciseType.multipleChoice:
        buffer.writeln('\nFormato: Pergunta sobre vocabulário ou gramática');
        buffer.writeln('Inclua 4 opções de resposta (1 correta, 3 incorretas)');
        break;
      case ExerciseType.fillInTheBlank:
        buffer.writeln('\nFormato: Frase com uma palavra em branco para completar');
        buffer.writeln('Inclua 4 opções de resposta (1 correta, 3 incorretas)');
        break;
      case ExerciseType.listening:
        buffer.writeln('\nFormato: Descrição de áudio para exercício de escuta');
        buffer.writeln('Inclua transcrição e 4 opções de resposta');
        break;
      case ExerciseType.speaking:
        buffer.writeln('\nFormato: Frase para o usuário repetir/pronunciar');
        buffer.writeln('Inclua dicas de pronúncia');
        break;
      case ExerciseType.matching:
        buffer.writeln('\nFormato: Pares de palavras/frases para combinar');
        buffer.writeln('Inclua 4 pares para combinar');
        break;
    }

    buffer.writeln('\nResposta em formato JSON com:');
    buffer.writeln('- question: pergunta/instrução');
    buffer.writeln('- options: array com opções de resposta');
    buffer.writeln('- correctAnswer: resposta correta');
    buffer.writeln('- explanation: explicação da resposta');
    buffer.writeln('- hints: dicas para ajudar');

    return buffer.toString();
  }

  /// Analisar resposta do exercício
  ExerciseContent _parseExerciseResponse(String response, ExerciseType type) {
    try {
      final jsonData = jsonDecode(response);
      return ExerciseContent(
        question: jsonData['question'] ?? '',
        options: List<String>.from(jsonData['options'] ?? []),
        correctAnswer: jsonData['correctAnswer'] ?? '',
        explanation: jsonData['explanation'] ?? '',
        hints: List<String>.from(jsonData['hints'] ?? []),
        audioUrl: jsonData['audioUrl'],
        imageUrl: jsonData['imageUrl'],
        culturalContext: jsonData['culturalContext'],
      );
    } catch (e) {
      return _createFallbackExerciseContent(type, _supportedLanguages.first, _supportedLanguages[1]);
    }
  }

  /// Criar conteúdo de exercício de fallback
  ExerciseContent _createFallbackExerciseContent(
    ExerciseType type,
    SupportedLanguage targetLanguage,
    SupportedLanguage sourceLanguage,
  ) {
    switch (type) {
      case ExerciseType.translation:
        return const ExerciseContent(
          question: 'Traduza: "Olá, como está?"',
          options: ['Kumusta', 'Obrigado', 'Tchau', 'Por favor'],
          correctAnswer: 'Kumusta',
          explanation: 'Kumusta é a forma de cumprimentar em Crioulo Guineense',
          hints: ['É uma saudação comum', 'Usado no dia a dia'],
        );
      case ExerciseType.multipleChoice:
        return ExerciseContent(
          question: 'Qual é a palavra para "água" em ${targetLanguage.name}?',
          options: ['Omi', 'Pan', 'Karne', 'Leite'],
          correctAnswer: 'Omi',
          explanation: 'Omi significa água em Crioulo Guineense',
          hints: ['É essencial para a vida', 'Bebemos todos os dias'],
        );
      default:
        return ExerciseContent(
          question: 'Exercício básico de ${targetLanguage.name}',
          options: ['Opção 1', 'Opção 2', 'Opção 3', 'Opção 4'],
          correctAnswer: 'Opção 1',
          explanation: 'Explicação básica',
          hints: ['Dica básica'],
        );
    }
  }

  /// Criar exercício de fallback
  LearningExercise _createFallbackExercise(
    ExerciseType type,
    SupportedLanguage targetLanguage,
    SupportedLanguage sourceLanguage,
  ) {
    final content = _createFallbackExerciseContent(type, targetLanguage, sourceLanguage);
    
    return LearningExercise(
      id: 'fallback_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      difficulty: DifficultyLevel.beginner,
      targetLanguage: targetLanguage,
      sourceLanguage: sourceLanguage,
      question: content.question,
      options: content.options,
      correctAnswer: content.correctAnswer,
      explanation: content.explanation,
      hints: content.hints,
      points: 10,
      timeLimit: 30,
    );
  }

  /// Calcular pontos do exercício
  int _calculateExercisePoints(ExerciseType type, DifficultyLevel difficulty) {
    final basePoints = switch (type) {
      ExerciseType.translation => 15,
      ExerciseType.multipleChoice => 10,
      ExerciseType.fillInTheBlank => 12,
      ExerciseType.listening => 18,
      ExerciseType.speaking => 20,
      ExerciseType.matching => 14,
    };

    final multiplier = switch (difficulty) {
      DifficultyLevel.beginner => 1.0,
      DifficultyLevel.intermediate => 1.5,
      DifficultyLevel.advanced => 2.0,
      DifficultyLevel.expert => 2.5,
    };

    return (basePoints * multiplier).round();
  }

  /// Obter limite de tempo do exercício
  int _getExerciseTimeLimit(ExerciseType type) => switch (type) {
      ExerciseType.translation => 45,
      ExerciseType.multipleChoice => 30,
      ExerciseType.fillInTheBlank => 35,
      ExerciseType.listening => 60,
      ExerciseType.speaking => 30,
      ExerciseType.matching => 40,
    };

  /// Verificar resposta do exercício
  ExerciseResult checkExerciseAnswer({
    required String exerciseId,
    required String userAnswer,
    required String userId,
  }) {
    // Encontrar o exercício
    final session = _activeSessions.firstWhere(
      (s) => s.exercises.any((e) => e.id == exerciseId),
      orElse: () => throw Exception('Exercício não encontrado'),
    );

    final exercise = session.exercises.firstWhere((e) => e.id == exerciseId);
    final isCorrect = userAnswer.toLowerCase().trim() == 
                     exercise.correctAnswer.toLowerCase().trim();

    // Calcular pontos
    var pointsEarned = 0;
    if (isCorrect) {
      pointsEarned = exercise.points;
      session.score += pointsEarned;
      session.streak += 1;
    } else {
      session.hearts = (session.hearts - 1).clamp(0, 5);
      session.streak = 0;
    }

    // Atualizar progresso do usuário
    if (isCorrect) {
      updateUserProgress(
        userId: userId,
        targetLanguage: exercise.targetLanguage,
        progressDelta: 0.1,
        skillArea: _mapExerciseTypeToSkill(exercise.type),
      );
    }

    return ExerciseResult(
      exerciseId: exerciseId,
      isCorrect: isCorrect,
      userAnswer: userAnswer,
      correctAnswer: exercise.correctAnswer,
      explanation: exercise.explanation,
      pointsEarned: pointsEarned,
      streakCount: session.streak,
      heartsRemaining: session.hearts,
      nextExerciseId: _getNextExerciseId(session),
    );
  }

  /// Mapear tipo de exercício para habilidade
  String _mapExerciseTypeToSkill(ExerciseType type) => switch (type) {
      ExerciseType.translation => 'translation',
      ExerciseType.multipleChoice => 'vocabulary',
      ExerciseType.fillInTheBlank => 'grammar',
      ExerciseType.listening => 'listening',
      ExerciseType.speaking => 'speaking',
      ExerciseType.matching => 'vocabulary',
    };

  /// Obter próximo exercício
  String? _getNextExerciseId(InternationalTeachingSession session) {
    final nextIndex = session.currentExerciseIndex + 1;
    if (nextIndex < session.exercises.length) {
      return session.exercises[nextIndex].id;
    }
    return null;
  }

  /// Traduzir texto usando IA
  Future<Map<String, String>> translateText({
    required String text,
    required SupportedLanguage sourceLanguage,
    required List<SupportedLanguage> targetLanguages,
    String? context,
  }) async {
    try {
      final translations = <String, String>{};

      for (final targetLang in targetLanguages) {
        String response;
        try {
          final prompt = _buildTranslationPrompt(
            text: text,
            sourceLanguage: sourceLanguage,
            targetLanguage: targetLang,
            context: context,
          );
          response = await _gemmaService.askQuestion(prompt);
        } catch (e) {
          response = _getFallbackTranslation(text, targetLang);
        }

        if (response.isNotEmpty) {
          translations[targetLang.code] = response;
        } else {
          translations[targetLang.code] = _getFallbackTranslation(text, targetLang);
        }
      }

      return translations;
    } catch (e) {
      print('Erro na tradução: $e');
      return {};
    }
  }

  /// Construir prompt de tradução
  String _buildTranslationPrompt({
    required String text,
    required SupportedLanguage sourceLanguage,
    required SupportedLanguage targetLanguage,
    String? context,
  }) {
    final buffer = StringBuffer();
    
    buffer.writeln('Traduza o seguinte texto:');
    buffer.writeln('Texto: "$text"');
    buffer.writeln('De: ${sourceLanguage.name} (${sourceLanguage.nativeName})');
    buffer.writeln('Para: ${targetLanguage.name} (${targetLanguage.nativeName})');
    
    if (context != null) {
      buffer.writeln('Contexto: $context');
    }
    
    if (sourceLanguage.isLocal || targetLanguage.isLocal) {
      buffer.writeln('\nIMPORTANTE: Esta tradução envolve línguas locais da Guiné-Bissau.');
      if (sourceLanguage.isLocal) {
        buffer.writeln('Língua de origem: ${sourceLanguage.culturalNotes}');
      }
      if (targetLanguage.isLocal) {
        buffer.writeln('Língua de destino: ${targetLanguage.culturalNotes}');
      }
    }
    
    buffer.writeln('\nForneça apenas a tradução, sem explicações adicionais.');
    
    return buffer.toString();
  }

  /// Tradução de fallback básica
  String _getFallbackTranslation(String text, SupportedLanguage targetLang) {
    // Traduções básicas de fallback expandidas
    final basicTranslations = <String, Map<String, String>>{
      'Olá': {
        'pt-GW': 'Olá',
        'gcr': 'Kumusta',
        'en': 'Hello',
        'fr': 'Bonjour',
        'es': 'Hola',
        'ff': 'Jam',
        'mnk': 'Salaam',
      },
      'Como está?': {
        'pt-GW': 'Como está?',
        'gcr': 'Kuma ku sta?',
        'en': 'How are you?',
        'fr': 'Comment allez-vous?',
        'es': '¿Cómo está?',
        'ff': 'No waali?',
        'mnk': 'I be di?',
      },
      'Obrigado': {
        'pt-GW': 'Obrigado',
        'gcr': 'Obrigadu',
        'en': 'Thank you',
        'fr': 'Merci',
        'es': 'Gracias',
        'ff': 'Jaraama',
        'mnk': 'Abaraka',
      },
      'Água': {
        'pt-GW': 'Água',
        'gcr': 'Omi',
        'en': 'Water',
        'fr': 'Eau',
        'es': 'Agua',
        'ff': 'Ndiyam',
        'mnk': 'Ji',
      },
      'Comida': {
        'pt-GW': 'Comida',
        'gcr': 'Kumida',
        'en': 'Food',
        'fr': 'Nourriture',
        'es': 'Comida',
        'ff': 'Nyaami',
        'mnk': 'Dumuni',
      },
    };

    return basicTranslations[text]?[targetLang.code] ??
        '[Tradução para ${targetLang.name}: $text]';
  }

  /// Gerar conteúdo educacional adaptado culturalmente
  Future<TeachingMaterial> generateCulturalContent({
    required String topic,
    required SupportedLanguage primaryLanguage,
    required List<SupportedLanguage> additionalLanguages,
    required TargetAudience audience,
    CulturalContext? culturalContext,
  }) async {
    try {
      final prompt = _buildCulturalContentPrompt(
        topic: topic,
        primaryLanguage: primaryLanguage,
        audience: audience,
        culturalContext: culturalContext,
      );

      String response;
      try {
        response = await _gemmaService.askQuestion(prompt);
      } catch (e) {
        response = _createFallbackContent(topic, primaryLanguage);
      }

      if (response.isNotEmpty) {
        final translations = await translateText(
          text: response,
          sourceLanguage: primaryLanguage,
          targetLanguages: additionalLanguages,
          context: 'cultural_content',
        );

        return TeachingMaterial(
          id: 'material_${DateTime.now().millisecondsSinceEpoch}',
          title: topic,
          type: 'text',
          languages: [primaryLanguage, ...additionalLanguages],
          content: MaterialContent(
            primary: response,
            translations: translations,
          ),
          culturalNotes: culturalContext?.traditions.join(', '),
          ageAppropriate: audience.ageRange,
          difficulty: _mapEducationLevelToProficiency(audience.educationLevel),
        );
      }
    } catch (e) {
      print('Erro ao gerar conteúdo cultural: $e');
    }

    return _createFallbackMaterial(topic, primaryLanguage, audience);
  }

  /// Criar conteúdo de fallback
  String _createFallbackContent(String topic, SupportedLanguage language) => 'Conteúdo básico sobre $topic em ${language.name}. '
        'Este é um exemplo de material educativo que pode ser '
        'adaptado para diferentes contextos culturais.';

  /// Mapear nível educacional para proficiência
  LanguageProficiency _mapEducationLevelToProficiency(EducationLevel level) => switch (level) {
      EducationLevel.none || EducationLevel.primary => LanguageProficiency.basic,
      EducationLevel.secondary || EducationLevel.mixed => LanguageProficiency.intermediate,
      EducationLevel.university => LanguageProficiency.advanced,
    };

  /// Criar material de fallback
  TeachingMaterial _createFallbackMaterial(
      String topic, SupportedLanguage language, TargetAudience audience) => TeachingMaterial(
      id: 'fallback_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Material Básico: $topic',
      type: 'text',
      languages: [language],
      content: MaterialContent(
        primary: _createFallbackContent(topic, language),
        translations: <String, String>{},
      ),
      culturalNotes: language.culturalNotes,
      ageAppropriate: audience.ageRange,
      difficulty: LanguageProficiency.basic,
    );

  /// Construir prompt contextualizado
  String _buildCulturalContentPrompt({
    required String topic,
    required SupportedLanguage primaryLanguage,
    required TargetAudience audience,
    CulturalContext? culturalContext,
  }) {
    final buffer = StringBuffer();

    buffer.writeln('Crie conteúdo educacional sobre "$topic" para ${audience.description}.');
    buffer.writeln('Língua principal: ${primaryLanguage.nativeName} (${primaryLanguage.name}).');

    if (primaryLanguage.isLocal) {
      buffer.writeln('Esta é uma língua local da Guiné-Bissau, adapte o conteúdo culturalmente.');
    }

    if (culturalContext != null) {
      buffer.writeln('Contexto cultural: ${culturalContext.region}');
      if (culturalContext.traditions.isNotEmpty) {
        buffer.writeln('Tradições relevantes: ${culturalContext.traditions.join(", ")}');
      }
    }

    buffer.writeln('Faixa etária: ${_mapAgeRangeToString(audience.ageRange)}');
    buffer.writeln('Nível educacional: ${_mapEducationLevelToString(audience.educationLevel)}');
    buffer.writeln('Contexto de aprendizado: ${_mapLearningContextToString(audience.context)}');

    if (audience.specialNeeds.isNotEmpty) {
      buffer.writeln('Necessidades especiais: ${audience.specialNeeds.map<String>(_mapSpecialNeedToString).join(", ")}');
    }

    buffer.writeln('\nO conteúdo deve ser:');
    buffer.writeln('- Culturalmente apropriado e respeitoso');
    buffer.writeln('- Prático e aplicável ao dia a dia');
    buffer.writeln('- Adaptado ao nível educacional do público');
    buffer.writeln('- Incluir exemplos locais quando possível');
    buffer.writeln('- Estruturado para facilitar o aprendizado');

    return buffer.toString();
  }

  /// Gerar lição completa estilo Duolingo
  Future<LearningLesson> generateLesson({
    required String userId,
    required SupportedLanguage targetLanguage,
    required SupportedLanguage sourceLanguage,
    required String topic,
    required DifficultyLevel difficulty,
  }) async {
    final exercises = <LearningExercise>[];
    
    // Gerar diferentes tipos de exercícios para a lição
    final exerciseTypes = [
      ExerciseType.multipleChoice,
      ExerciseType.translation,
      ExerciseType.fillInTheBlank,
      ExerciseType.matching,
    ];

    for (final type in exerciseTypes) {
      try {
        final exercise = await generateExercise(
          userId: userId,
          targetLanguage: targetLanguage,
          sourceLanguage: sourceLanguage,
          type: type,
          difficulty: difficulty,
          topic: topic,
        );
        exercises.add(exercise);
      } catch (e) {
        print('Erro ao gerar exercício $type: $e');
      }
    }

    // Se não conseguiu gerar exercícios, criar fallbacks
    if (exercises.isEmpty) {
      exercises.addAll(_createFallbackExercises(targetLanguage, sourceLanguage, topic));
    }

    return LearningLesson(
      id: 'lesson_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Lição: $topic',
      description: 'Aprenda $topic em ${targetLanguage.name}',
      targetLanguage: targetLanguage,
      sourceLanguage: sourceLanguage,
      difficulty: difficulty,
      exercises: exercises,
      totalPoints: exercises.fold(0, (sum, ex) => sum + ex.points),
      estimatedDuration: exercises.length * 2, // 2 minutos por exercício
      topic: topic,
      prerequisites: [],
      learningObjectives: [
        'Vocabulário básico de $topic',
        'Estruturas gramaticais relacionadas',
        'Aplicação prática em contextos reais',
      ],
    );
  }

  /// Criar exercícios de fallback
  List<LearningExercise> _createFallbackExercises(
    SupportedLanguage targetLanguage,
    SupportedLanguage sourceLanguage,
    String topic,
  ) => [
      _createFallbackExercise(ExerciseType.multipleChoice, targetLanguage, sourceLanguage),
      _createFallbackExercise(ExerciseType.translation, targetLanguage, sourceLanguage),
    ];

  // Métodos auxiliares de mapeamento
  String _mapAgeRangeToString(AgeRange range) => switch (range) {
      AgeRange.children => 'Crianças (5-12 anos)',
      AgeRange.teenagers => 'Adolescentes (13-17 anos)',
      AgeRange.adults => 'Adultos (18-65 anos)',
      AgeRange.elderly => 'Idosos (65+ anos)',
      AgeRange.mixed => 'Idade mista',
    };

  String _mapEducationLevelToString(EducationLevel level) => switch (level) {
      EducationLevel.none => 'Sem educação formal',
      EducationLevel.primary => 'Ensino primário',
      EducationLevel.secondary => 'Ensino secundário',
      EducationLevel.university => 'Ensino universitário',
      EducationLevel.mixed => 'Níveis mistos',
    };

  String _mapLearningContextToString(LearningContext context) => switch (context) {
      LearningContext.classroom => 'Sala de aula',
      LearningContext.community => 'Comunidade',
      LearningContext.family => 'Família',
      LearningContext.ngo => 'ONG',
      LearningContext.hospital => 'Hospital',
      LearningContext.field => 'Campo/Rural',
      LearningContext.emergency => 'Emergência',
    };

  String _mapSpecialNeedToString(SpecialNeed need) => switch (need) {
      SpecialNeed.literacy => 'Alfabetização',
      SpecialNeed.numeracy => 'Numeracia',
      SpecialNeed.health => 'Saúde',
      SpecialNeed.agriculture => 'Agricultura',
      SpecialNeed.technology => 'Tecnologia',
      SpecialNeed.emergency => 'Emergências',
      SpecialNeed.cultural => 'Cultural',
    };

  String _mapExerciseTypeToString(ExerciseType type) => switch (type) {
      ExerciseType.translation => 'tradução',
      ExerciseType.multipleChoice => 'múltipla escolha',
      ExerciseType.fillInTheBlank => 'preencher lacunas',
      ExerciseType.listening => 'compreensão auditiva',
      ExerciseType.speaking => 'prática de fala',
      ExerciseType.matching => 'correspondência',
    };

  String _mapDifficultyToString(DifficultyLevel difficulty) => switch (difficulty) {
      DifficultyLevel.beginner => 'iniciante',
      DifficultyLevel.intermediate => 'intermediário',
      DifficultyLevel.advanced => 'avançado',
      DifficultyLevel.expert => 'especialista',
    };

  /// Obter progresso do usuário
  InternationalLearningProgress? getUserProgress(String userId) => _userProgress[userId];

  /// Criar progresso inicial do usuário
  InternationalLearningProgress _createInitialProgress(String userId) => InternationalLearningProgress(
      userId: userId,
      nativeLanguage: _supportedLanguages.first,
      targetLanguages: <String, LanguageProgress>{},
      overallProgress: 0,
      sessionHistory: <String>[],
      achievements: <Achievement>[],
      currentStreak: 0,
      longestStreak: 0,
      totalXP: 0,
      level: 1,
      hearts: 5,
      gems: 0,
      lastActiveDate: DateTime.now(),
    );

  /// Atualizar progresso do usuário
  Future<void> updateUserProgress({
    required String userId,
    required SupportedLanguage targetLanguage,
    required double progressDelta,
    String? skillArea,
    int? xpGained,
  }) async {
    var progress = _userProgress[userId];

    if (progress == null) {
      progress = _createInitialProgress(userId);
      _userProgress[userId] = progress;
    }

    final languageProgress = progress.targetLanguages[targetLanguage.code] ??
        LanguageProgress(
          language: targetLanguage,
          proficiency: 0,
          vocabulary: 0,
          grammar: 0,
          pronunciation: 0,
          culturalKnowledge: 0,
          practicalUsage: 0,
        );

    // Atualizar progresso específico da habilidade
    final updatedProgress = _updateLanguageProgressBySkill(
      languageProgress,
      skillArea,
      progressDelta,
    );

    progress.targetLanguages[targetLanguage.code] = updatedProgress;

    // Atualizar XP e nível
    if (xpGained != null) {
      progress.totalXP += xpGained;
      progress.level = _calculateLevel(progress.totalXP);
    }

    // Atualizar streak
    _updateStreak(progress);

    // Verificar conquistas
    _checkAchievements(userId, progress);

    // Atualizar progresso geral
    progress.overallProgress = _calculateOverallProgress(progress);
  }

  /// Atualizar progresso da língua por habilidade
  LanguageProgress _updateLanguageProgressBySkill(
    LanguageProgress current,
    String? skillArea,
    double delta,
  ) {
    switch (skillArea) {
      case 'vocabulary':
        return current.copyWith(
          vocabulary: (current.vocabulary + delta).clamp(0.0, 1.0),
          lastPracticed: DateTime.now(),
        );
      case 'grammar':
        return current.copyWith(
          grammar: (current.grammar + delta).clamp(0.0, 1.0),
          lastPracticed: DateTime.now(),
        );
      case 'listening':
        return current.copyWith(
          pronunciation: (current.pronunciation + delta).clamp(0.0, 1.0),
          lastPracticed: DateTime.now(),
        );
      case 'speaking':
        return current.copyWith(
          pronunciation: (current.pronunciation + delta).clamp(0.0, 1.0),
          lastPracticed: DateTime.now(),
        );
      case 'cultural':
        return current.copyWith(
          culturalKnowledge: (current.culturalKnowledge + delta).clamp(0.0, 1.0),
          lastPracticed: DateTime.now(),
        );
      case 'practical':
        return current.copyWith(
          practicalUsage: (current.practicalUsage + delta).clamp(0.0, 1.0),
          lastPracticed: DateTime.now(),
        );
      default:
        return current.copyWith(
          proficiency: (current.proficiency + delta).clamp(0.0, 1.0),
          lastPracticed: DateTime.now(),
        );
    }
  }

  /// Calcular nível baseado no XP
  int _calculateLevel(int totalXP) {
    // Fórmula similar ao Duolingo: cada nível requer mais XP
    return (totalXP / 1000).floor() + 1;
  }

  /// Atualizar streak do usuário
  void _updateStreak(InternationalLearningProgress progress) {
    final now = DateTime.now();
    final lastActive = progress.lastActiveDate;
    
    if (lastActive != null) {
      final daysDifference = now.difference(lastActive).inDays;
      
      if (daysDifference == 1) {
        // Continuou a sequência
        progress.currentStreak += 1;
        if (progress.currentStreak > progress.longestStreak) {
          progress.longestStreak = progress.currentStreak;
        }
      } else if (daysDifference > 1) {
        // Quebrou a sequência
        progress.currentStreak = 1;
      }
      // Se daysDifference == 0, mantém a sequência atual
    } else {
      progress.currentStreak = 1;
    }
    
    progress.lastActiveDate = now;
  }

  /// Calcular progresso geral
  double _calculateOverallProgress(InternationalLearningProgress progress) {
    if (progress.targetLanguages.isEmpty) return 0;
    
    var totalProgress = 0;
    for (final langProgress in progress.targetLanguages.values) {
      totalProgress += langProgress.proficiency;
    }
    
    return totalProgress / progress.targetLanguages.length;
  }

  /// Verificar e conceder conquistas
  void _checkAchievements(String userId, InternationalLearningProgress progress) {
    final newAchievements = <Achievement>[];
    final existingIds = progress.achievements.map((a) => a.id).toSet();

    // Primeira tradução
    if (progress.targetLanguages.isNotEmpty && !existingIds.contains('first_translation')) {
      newAchievements.add(Achievement(
        id: 'first_translation',
        name: 'Primeiro Passo',
        description: 'Completou sua primeira tradução',
        icon: '🎯',
        earnedAt: DateTime.now(),
        category: 'linguistic',
        rarity: AchievementRarity.common,
        xpReward: 50,
      ));
    }

    // Sequência de 7 dias
    if (progress.currentStreak >= 7 && !existingIds.contains('week_streak')) {
      newAchievements.add(Achievement(
        id: 'week_streak',
        name: 'Dedicação Semanal',
        description: 'Manteve uma sequência de 7 dias',
        icon: '🔥',
        earnedAt: DateTime.now(),
        category: 'consistency',
        rarity: AchievementRarity.uncommon,
        xpReward: 100,
      ));
    }

    // Sequência de 30 dias
    if (progress.currentStreak >= 30 && !existingIds.contains('month_streak')) {
      newAchievements.add(Achievement(
        id: 'month_streak',
        name: 'Mestre da Consistência',
        description: 'Manteve uma sequência de 30 dias',
        icon: '🏆',
        earnedAt: DateTime.now(),
        category: 'consistency',
        rarity: AchievementRarity.rare,
        xpReward: 500,
      ));
    }

    // Poliglota (3 línguas)
    if (progress.targetLanguages.length >= 3 && !existingIds.contains('polyglot')) {
      newAchievements.add(Achievement(
        id: 'polyglot',
        name: 'Poliglota',
        description: 'Está aprendendo 3 ou mais línguas',
        icon: '🌍',
        earnedAt: DateTime.now(),
        category: 'linguistic',
        rarity: AchievementRarity.rare,
        xpReward: 200,
      ));
    }

    // Especialista em línguas locais
    final localLanguagesCount = progress.targetLanguages.values
        .where((lp) => lp.language.isLocal)
        .length;
    if (localLanguagesCount >= 2 && !existingIds.contains('local_expert')) {
      newAchievements.add(Achievement(
        id: 'local_expert',
        name: 'Especialista Local',
        description: 'Domina línguas locais da Guiné-Bissau',
        icon: '🇬🇼',
        earnedAt: DateTime.now(),
        category: 'cultural',
        rarity: AchievementRarity.epic,
        xpReward: 300,
      ));
    }

    // Nível 10
    if (progress.level >= 10 && !existingIds.contains('level_10')) {
      newAchievements.add(Achievement(
        id: 'level_10',
        name: 'Veterano',
        description: 'Alcançou o nível 10',
        icon: '⭐',
        earnedAt: DateTime.now(),
        category: 'progression',
        rarity: AchievementRarity.uncommon,
        xpReward: 150,
      ));
    }

    // Adicionar conquistas e XP
    for (final achievement in newAchievements) {
      progress.achievements.add(achievement);
      progress.totalXP += achievement.xpReward;
    }

    // Recalcular nível se ganhou XP
    if (newAchievements.isNotEmpty) {
      progress.level = _calculateLevel(progress.totalXP);
    }
  }

  /// Obter lições recomendadas para o usuário
  Future<List<LearningLesson>> getRecommendedLessons({
    required String userId,
    required SupportedLanguage targetLanguage,
    int limit = 5,
  }) async {
    final progress = getUserProgress(userId);
    final userLevel = progress?.level ?? 1;
    final sourceLanguage = progress?.nativeLanguage ?? _supportedLanguages.first;

    final topics = _getTopicsForLevel(userLevel);
    final lessons = <LearningLesson>[];

    for (final topic in topics.take(limit)) {
      try {
        final lesson = await generateLesson(
          userId: userId,
          targetLanguage: targetLanguage,
          sourceLanguage: sourceLanguage,
          topic: topic,
          difficulty: _getDifficultyForLevel(userLevel),
        );
        lessons.add(lesson);
      } catch (e) {
        print('Erro ao gerar lição para $topic: $e');
      }
    }

    return lessons;
  }

  /// Obter tópicos para o nível
  List<String> _getTopicsForLevel(int level) {
    if (level <= 3) {
      return ['Saudações', 'Família', 'Números', 'Cores', 'Comida'];
    } else if (level <= 6) {
      return ['Trabalho', 'Saúde', 'Transporte', 'Tempo', 'Compras'];
    } else if (level <= 10) {
      return ['Educação', 'Cultura', 'História', 'Política', 'Economia'];
    } else {
      return ['Negócios', 'Tecnologia', 'Meio Ambiente', 'Filosofia', 'Arte'];
    }
  }

  /// Obter dificuldade para o nível
  DifficultyLevel _getDifficultyForLevel(int level) {
    if (level <= 3) return DifficultyLevel.beginner;
    if (level <= 7) return DifficultyLevel.intermediate;
    if (level <= 12) return DifficultyLevel.advanced;
    return DifficultyLevel.expert;
  }

  /// Obter estatísticas do usuário
  Map<String, dynamic> getUserStats(String userId) {
    final progress = getUserProgress(userId);
    if (progress == null) return {};

    return {
      'level': progress.level,
      'totalXP': progress.totalXP,
      'currentStreak': progress.currentStreak,
      'longestStreak': progress.longestStreak,
      'hearts': progress.hearts,
      'gems': progress.gems,
      'languagesLearning': progress.targetLanguages.length,
      'achievements': progress.achievements.length,
      'overallProgress': progress.overallProgress,
      'sessionsCompleted': progress.sessionHistory.length,
      'lastActiveDate': progress.lastActiveDate?.toIso8601String(),
      'languageProgress': progress.targetLanguages.map(
        (code, langProgress) => MapEntry(
          code,
          {
            'proficiency': langProgress.proficiency,
            'vocabulary': langProgress.vocabulary,
            'grammar': langProgress.grammar,
            'pronunciation': langProgress.pronunciation,
            'culturalKnowledge': langProgress.culturalKnowledge,
            'practicalUsage': langProgress.practicalUsage,
            'lastPracticed': langProgress.lastPracticed?.toIso8601String(),
          },
        ),
      ),
    };
  }

  /// Obter ranking de usuários (leaderboard)
  List<Map<String, dynamic>> getLeaderboard({int limit = 10}) {
    final users = _userProgress.entries.toList();
    
    // Ordenar por XP total
    users.sort((a, b) => b.value.totalXP.compareTo(a.value.totalXP));
    
    return users.take(limit).map((entry) => {
      'userId': entry.key,
      'level': entry.value.level,
      'totalXP': entry.value.totalXP,
      'currentStreak': entry.value.currentStreak,
      'languagesLearning': entry.value.targetLanguages.length,
      'achievements': entry.value.achievements.length,
    }).toList();
  }

  /// Restaurar corações (vidas)
  void restoreHearts(String userId) {
    final progress = _userProgress[userId];
    if (progress != null) {
      progress.hearts = 5;
    }
  }

  /// Usar gemas para comprar corações
  bool buyHeartsWithGems(String userId, {int heartsCount = 1}) {
    final progress = _userProgress[userId];
    if (progress == null) return false;
    
    final gemCost = heartsCount * 10; // 10 gemas por coração
    
    if (progress.gems >= gemCost) {
      progress.gems -= gemCost;
      progress.hearts = (progress.hearts + heartsCount).clamp(0, 5);
      return true;
    }
    
    return false;
  }

  /// Ganhar gemas por conquistas ou atividades especiais
  void awardGems(String userId, int amount) {
    final progress = _userProgress[userId];
    if (progress != null) {
      progress.gems += amount;
    }
  }

  /// Verificar se o usuário pode fazer um exercício (tem corações)
  bool canDoExercise(String userId) {
    final progress = _userProgress[userId];
    return progress?.hearts ?? 0 > 0;
  }

  /// Obter sessões ativas do usuário
  List<InternationalTeachingSession> getUserActiveSessions(String userId) => _activeSessions.where((session) => session.teacherId == userId).toList();

  /// Finalizar sessão
  void finishSession(String sessionId, String userId) {
    final sessionIndex = _activeSessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex != -1) {
      final session = _activeSessions[sessionIndex];
      
      // Adicionar à história do usuário
      final progress = _userProgress[userId];
      if (progress != null) {
        progress.sessionHistory.add(sessionId);
        
        // Ganhar XP baseado na performance
        final xpGained = _calculateSessionXP(session);
        progress.totalXP += xpGained;
        progress.level = _calculateLevel(progress.totalXP);
        
        // Ganhar gemas se teve boa performance
        if (session.score > session.exercises.length * 0.8) {
          progress.gems += 5;
        }
      }
      
      // Remover da lista de sessões ativas
      _activeSessions.removeAt(sessionIndex);
    }
  }

  /// Calcular XP da sessão
  int _calculateSessionXP(InternationalTeachingSession session) {
    int baseXP = session.score;
    
    // Bônus por streak
    if (session.streak > 0) {
      baseXP += session.streak * 2;
    }
    
    // Bônus por completar sem perder corações
    if (session.hearts == 5) {
      baseXP += 20;
    }
    
    return baseXP;
  }

  /// Obter desafios diários
  Future<List<DailyChallenge>> getDailyChallenges(String userId) async {
    final progress = getUserProgress(userId);
    final userLevel = progress?.level ?? 1;
    final challenges = <DailyChallenge>[];

    // Desafio de XP
    challenges.add(DailyChallenge(
      id: 'daily_xp',
      title: 'Ganhe XP',
      description: 'Ganhe ${userLevel * 50} XP hoje',
      type: ChallengeType.xp,
      target: userLevel * 50,
      current: 0,
      reward: const ChallengeReward(
        xp: 25,
        gems: 2,
        hearts: 0,
      ),
      expiresAt: DateTime.now().add(const Duration(days: 1)),
    ));

    // Desafio de exercícios
    challenges.add(DailyChallenge(
      id: 'daily_exercises',
      title: 'Complete Exercícios',
      description: 'Complete ${5 + (userLevel ~/ 2)} exercícios',
      type: ChallengeType.exercises,
      target: 5 + (userLevel ~/ 2),
      current: 0,
      reward: const ChallengeReward(
        xp: 50,
        gems: 3,
        hearts: 1,
      ),
      expiresAt: DateTime.now().add(const Duration(days: 1)),
    ));

    // Desafio de streak
    if (progress?.currentStreak ?? 0 > 0) {
      challenges.add(DailyChallenge(
        id: 'maintain_streak',
        title: 'Mantenha a Sequência',
        description: 'Continue sua sequência de ${progress!.currentStreak} dias',
        type: ChallengeType.streak,
        target: 1,
        current: 0,
        reward: ChallengeReward(
          xp: progress.currentStreak * 5,
          gems: 1,
          hearts: 0,
        ),
        expiresAt: DateTime.now().add(const Duration(days: 1)),
      ));
    }

    return challenges;
  }

  /// Verificar progresso dos desafios
  void updateChallengeProgress(String userId, ChallengeType type, int amount) {
    // Implementar lógica para atualizar progresso dos desafios
    // Esta seria uma funcionalidade mais complexa que requereria
    // armazenamento persistente dos desafios ativos
  }

  /// Obter estatísticas do sistema
  Map<String, dynamic> getSystemStats() => {
      'total_languages': _supportedLanguages.length,
      'local_languages': localLanguages.length,
      'active_sessions': _activeSessions.length,
      'total_users': _userProgress.length,
      'supported_features': _system.aiCapabilities.supportedFeatures.length,
      'total_exercises_generated': _activeSessions.fold(
        0,
        (sum, session) => sum + session.exercises.length,
      ),
      'average_user_level': _userProgress.isEmpty
          ? 0
          : _userProgress.values.fold(0, (sum, p) => sum + p.level) /
              _userProgress.length,
      'total_xp_earned': _userProgress.values.fold(0, (sum, p) => sum + p.totalXP),
      'longest_streak': _userProgress.values.isEmpty
          ? 0
          : _userProgress.values
              .map((p) => p.longestStreak)
              .reduce((a, b) => a > b ? a : b),
    };

  /// Obter configurações recomendadas para um usuário
  Map<String, dynamic> getRecommendedSettings(String userId) {
    final progress = getUserProgress(userId);
    if (progress == null) {
      return {
        'dailyGoal': 50, // XP por dia
        'reminderTime': '19:00',
        'difficulty': 'beginner',
        'focusAreas': ['vocabulary', 'grammar'],
      };
    }

    return {
      'dailyGoal': progress.level * 25,
      'reminderTime': '19:00',
      'difficulty': _getDifficultyForLevel(progress.level).name,
      'focusAreas': _getRecommendedFocusAreas(progress),
    };
  }

  /// Obter áreas de foco recomendadas
  List<String> _getRecommendedFocusAreas(InternationalLearningProgress progress) {
    final areas = <String>[];
    
    for (final langProgress in progress.targetLanguages.values) {
      if (langProgress.vocabulary < 0.5) areas.add('vocabulary');
      if (langProgress.grammar < 0.5) areas.add('grammar');
      if (langProgress.pronunciation < 0.5) areas.add('pronunciation');
      if (langProgress.culturalKnowledge < 0.3) areas.add('cultural');
    }
    
    return areas.isEmpty ? ['vocabulary', 'grammar'] : areas.take(3).toList();
  }

  /// Limpar dados antigos (manutenção)
  void cleanupOldData() {
    final now = DateTime.now();
    
    // Remover sessões antigas (mais de 24 horas)
    _activeSessions.removeWhere((session) {
      final age = now.difference(session.startTime).inHours;
      return age > 24;
    });
    
    // Limpar histórico muito antigo dos usuários (manter apenas últimos 100)
    for (final progress in _userProgress.values) {
      if (progress.sessionHistory.length > 100) {
        progress.sessionHistory.removeRange(0, progress.sessionHistory.length - 100);
      }
    }
  }

  /// Exportar dados do usuário (GDPR compliance)
  Map<String, dynamic> exportUserData(String userId) {
    final progress = getUserProgress(userId);
    if (progress == null) return {};

    return {
      'userId': userId,
      'profile': getUserStats(userId),
      'achievements': progress.achievements.map((a) => {
        'id': a.id,
        'name': a.name,
        'description': a.description,
        'earnedAt': a.earnedAt.toIso8601String(),
        'category': a.category,
      }).toList(),
      'languageProgress': progress.targetLanguages.map(
        (code, langProgress) => MapEntry(code, {
          'language': langProgress.language.name,
          'proficiency': langProgress.proficiency,
          'vocabulary': langProgress.vocabulary,
          'grammar': langProgress.grammar,
          'pronunciation': langProgress.pronunciation,
          'culturalKnowledge': langProgress.culturalKnowledge,
          'practicalUsage': langProgress.practicalUsage,
          'lastPracticed': langProgress.lastPracticed?.toIso8601String(),
        }),
      ),
      'sessionHistory': progress.sessionHistory,
      'exportedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Deletar dados do usuário
  bool deleteUserData(String userId) {
    try {
      _userProgress.remove(userId);
      
      // Remover sessões do usuário
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

/// Classes auxiliares para estruturas de dados

class ExerciseContent {

  const ExerciseContent({
    required this.question,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    required this.hints,
    this.audioUrl,
    this.imageUrl,
    this.culturalContext,
  });
  final String question;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final List<String> hints;
  final String? audioUrl;
  final String? imageUrl;
  final String? culturalContext;
}

class ExerciseResult {

  const ExerciseResult({
    required this.exerciseId,
    required this.isCorrect,
    required this.userAnswer,
    required this.correctAnswer,
    required this.explanation,
    required this.pointsEarned,
    required this.streakCount,
    required this.heartsRemaining,
    this.nextExerciseId,
  });
  final String exerciseId;
  final bool isCorrect;
  final String userAnswer;
  final String correctAnswer;
  final String explanation;
  final int pointsEarned;
  final int streakCount;
  final int heartsRemaining;
  final String? nextExerciseId;
}

class DailyChallenge {

  const DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    required this.current,
    required this.reward,
    required this.expiresAt,
  });
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final int target;
  final int current;
  final ChallengeReward reward;
  final DateTime expiresAt;

  bool get isCompleted => current >= target;
  bool get isExpired => DateTime.now().isAfter(expiresAt);
  double get progress => current / target;
}

class ChallengeReward {

  const ChallengeReward({
    required this.xp,
    required this.gems,
    required this.hearts,
  });
  final int xp;
  final int gems;
  final int hearts;
}

enum ChallengeType {
  xp,
  exercises,
  streak,
  vocabulary,
  grammar,
  listening,
  speaking,
}

enum ExerciseType {
  translation,
  multipleChoice,
  fillInTheBlank,
  listening,
  speaking,
  matching,
}

enum DifficultyLevel {
  beginner,
  intermediate,
  advanced,
  expert,
}

enum AchievementRarity {
  common,
  uncommon,
  rare,
  epic,
  legendary,
}




