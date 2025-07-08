import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mental_health_models.dart';
import 'voice_analysis_service.dart';

/// Serviço completo de coaching de bem-estar pessoal
class WellnessCoachingService {
  factory WellnessCoachingService() => _instance;
  WellnessCoachingService._internal() {
    // Configurar Dio com timeouts mais generosos para o backend Gemma-3n
    _dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
  }
  static final WellnessCoachingService _instance =
      WellnessCoachingService._internal();

  final VoiceAnalysisService _voiceService = VoiceAnalysisService();
  late final Dio _dio;

  // Configuração do backend
  static const String _backendUrl =
      'http://10.0.2.2:5000'; // CORRIGIDO: emulador Android
  bool _backendAvailable = false;

  WellnessProfile? _currentProfile;
  List<CoachingSession> _sessions = [];
  List<DailyWellnessMetrics> _dailyMetrics = [];
  bool _isInitialized = false;

  /// Inicializa o serviço de coaching
  Future<bool> initialize() async {
    try {
      // Verificar backend com retry
      await _checkBackendHealthWithRetry();

      await _loadUserProfile();
      await _loadSessions();
      await _loadDailyMetrics();

      _setupDailyReminders();
      _isInitialized = true;

      debugPrint(
          '✅ Serviço de coaching inicializado (Backend: $_backendAvailable)');
      return true;
    } on Exception catch (e) {
      debugPrint('❌ Erro ao inicializar coaching: $e');
      return false;
    }
  }

  /// Verificar saúde do backend com retry
  Future<void> _checkBackendHealthWithRetry() async {
    var attempts = 0;
    const maxAttempts = 3;

    while (attempts < maxAttempts && !_backendAvailable) {
      attempts++;
      debugPrint(
          '🔄 Tentativa $attempts/$maxAttempts de conectar ao backend...');

      await _checkBackendHealth();

      if (!_backendAvailable && attempts < maxAttempts) {
        await Future<void>.delayed(const Duration(seconds: 2));
      }
    }

    if (_backendAvailable) {
      debugPrint('🎉 Conectado ao backend com sucesso!');
    } else {
      debugPrint(
          '⚠️ Funcionando em modo offline - Backend indisponível após $maxAttempts tentativas');
    }
  }

  /// Verificar saúde do backend
  Future<void> _checkBackendHealth() async {
    try {
      debugPrint('🔍 Verificando saúde do backend em $_backendUrl...');

      final response = await _dio.get<Map<String, dynamic>>(
        '$_backendUrl/health',
      );

      _backendAvailable = response.statusCode == 200;
      debugPrint('✅ Backend disponível: $_backendAvailable');

      if (_backendAvailable) {
        debugPrint('📊 Resposta do backend: ${response.data}');
      }
    } on DioException catch (e) {
      _backendAvailable = false;
      if (e.type == DioExceptionType.receiveTimeout) {
        debugPrint(
            '❌ Backend timeout: O servidor demorou mais que 60s para responder');
        debugPrint(
            '💡 Dica: Verifique se o modelo Gemma-3n está carregado no backend');
      } else if (e.type == DioExceptionType.connectionTimeout) {
        debugPrint(
            '❌ Backend connection timeout: Não foi possível conectar em 30s');
      } else if (e.type == DioExceptionType.connectionError) {
        debugPrint(
            '❌ Backend connection error: Verifique se o servidor está rodando em $_backendUrl');
      } else {
        debugPrint('❌ Backend indisponível: ${e.type} - ${e.message}');
      }
    } catch (e) {
      _backendAvailable = false;
      debugPrint('❌ Erro inesperado ao verificar backend: $e');
    }
  }

  /// Cria um novo perfil de bem-estar
  Future<bool> createWellnessProfile({
    required String name,
    required int age,
    required List<String> concerns,
    required List<String> goals,
  }) async {
    try {
      _currentProfile = WellnessProfile(
        userId: 'user_${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        age: age,
        concerns: concerns,
        goals: goals,
        baselineMetrics: await _calculateBaselineMetrics(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _saveUserProfile();
      print('✅ Perfil de bem-estar criado para $name');
      return true;
    } catch (e) {
      print('❌ Erro ao criar perfil: $e');
      return false;
    }
  }

  Future<Map<String, double>> _calculateBaselineMetrics() async => {
        'mood': 5.0,
        'stress': 0.5,
        'energy': 0.5,
      };

  /// Inicia uma sessão de coaching personalizada
  Future<CoachingSession?> startCoachingSession(String type) async {
    if (_currentProfile == null) {
      print('❌ Perfil não encontrado. Crie um perfil primeiro.');
      return null;
    }

    try {
      // Usar backend se disponível
      if (_backendAvailable) {
        return await _startBackendCoachingSession(type);
      }

      // Fallback para implementação offline
      final session = CoachingSession(
        sessionId: 'session_${DateTime.now().millisecondsSinceEpoch}',
        userId: _currentProfile!.userId,
        type: type,
        startTime: DateTime.now(),
        sessionData: {},
        recommendations: [],
        progressScore: 0,
      );

      switch (type) {
        case 'breathing':
          return await _startBreathingSession(session);
        case 'meditation':
          return await _startMeditationSession(session);
        case 'voice_check':
          return await _startVoiceCheckSession(session);
        case 'mood_tracking':
          return await _startMoodTrackingSession(session);
        case 'stress_relief':
          return await _startStressReliefSession(session);
        default:
          print('❌ Tipo de sessão não reconhecido: $type');
          return null;
      }
    } catch (e) {
      print('❌ Erro ao iniciar sessão: $e');
      return null;
    }
  }

  /// Registra métricas diárias de bem-estar
  Future<bool> recordDailyMetrics({
    required double moodRating,
    required double stressLevel,
    required double energyLevel,
    required int sleepHours,
    required List<String> activities,
    String notes = '',
    VoiceAnalysisResult? voiceAnalysis,
  }) async {
    try {
      final metrics = DailyWellnessMetrics(
        date: DateTime.now(),
        moodRating: moodRating,
        stressLevel: stressLevel,
        energyLevel: energyLevel,
        sleepHours: sleepHours,
        activities: activities,
        notes: notes,
        voiceAnalysis: voiceAnalysis,
      );

      _dailyMetrics.add(metrics);

      // Manter apenas os últimos 30 dias
      if (_dailyMetrics.length > 30) {
        _dailyMetrics.removeAt(0);
      }

      await _saveDailyMetrics();

      // Tentar enviar métricas para o backend Gemma-3n
      await _sendMetricsToBackend(metrics);

      // Gerar recomendações baseadas nas métricas
      final recommendations = _generateDailyRecommendations(metrics);
      if (recommendations.isNotEmpty) {
        _showWellnessRecommendations(recommendations);
      }

      print('✅ Métricas diárias registradas');
      return true;
    } catch (e) {
      print('❌ Erro ao registrar métricas: $e');
      return false;
    }
  }

  /// Enviar métricas diárias para o backend Gemma-3n
  Future<void> _sendMetricsToBackend(DailyWellnessMetrics metrics) async {
    if (!_backendAvailable) return;

    try {
      print('📊 Enviando métricas diárias para backend Gemma-3n');

      final response = await _dio.post<Map<String, dynamic>>(
        '$_backendUrl/wellness/daily-metrics',
        data: {
          'metrics': {
            'mood_rating': metrics.moodRating,
            'stress_level': metrics.stressLevel,
            'energy_level': metrics.energyLevel,
            'sleep_hours': metrics.sleepHours,
            'activities': metrics.activities,
            'notes': metrics.notes,
            'voice_analysis': metrics.voiceAnalysis != null
                ? {
                    'stress_level': metrics.voiceAnalysis!.stressLevel,
                    'energy_level': metrics.voiceAnalysis!.energyLevel,
                    'mood_state': metrics.voiceAnalysis!.moodState,
                  }
                : null,
          },
          'language': 'pt-BR',
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        final analysis = data['wellness_analysis'];

        print('✅ Análise recebida do backend: ${analysis['summary']}');

        // Salvar recomendações do backend
        final backendRecommendations =
            (data['recommendations'] as List<dynamic>?)
                    ?.map((e) => e.toString())
                    .toList() ??
                [];

        if (backendRecommendations.isNotEmpty) {
          _showWellnessRecommendations(backendRecommendations);
        }
      }
    } on DioException catch (e) {
      print('⚠️ Erro ao enviar métricas para backend: ${e.message}');
    } catch (e) {
      print('⚠️ Erro inesperado ao enviar métricas: $e');
    }
  }

  /// Executa análise completa de bem-estar
  Future<Map<String, dynamic>> performWellnessAnalysis() async {
    if (_currentProfile == null || _dailyMetrics.isEmpty) {
      return {'error': 'Dados insuficientes para análise'};
    }

    try {
      final recentMetrics = _dailyMetrics.take(7).toList();

      // Análise de tendências
      final trends = _analyzeTrends(recentMetrics);

      // Pontuação de bem-estar
      final wellnessScore = _calculateOverallWellnessScore(recentMetrics);

      // Identificar padrões
      final patterns = _identifyWellnessPatterns(recentMetrics);

      // Recomendações personalizadas
      final recommendations =
          _generatePersonalizedRecommendations(recentMetrics, trends);

      // Metas de progresso
      final progress = _calculateGoalProgress();

      return {
        'wellness_score': wellnessScore,
        'trends': trends,
        'patterns': patterns,
        'recommendations': recommendations,
        'goal_progress': progress,
        'risk_factors': _identifyRiskFactors(recentMetrics),
        'positive_indicators': _identifyPositiveIndicators(recentMetrics),
        'next_steps': _getNextSteps(wellnessScore, trends),
      };
    } catch (e) {
      print('❌ Erro na análise de bem-estar: $e');
      return {'error': 'Erro durante análise: $e'};
    }
  }

  /// Gera plano de bem-estar personalizado
  Map<String, dynamic> generateWellnessPlan({int durationDays = 30}) {
    if (_currentProfile == null) {
      return {'error': 'Perfil não encontrado'};
    }

    final plan = <String, dynamic>{
      'duration_days': durationDays,
      'profile': _currentProfile!.toJson(),
      'daily_activities': _generateDailyActivities(),
      'weekly_goals': _generateWeeklyGoals(),
      'monitoring_schedule': _generateMonitoringSchedule(),
      'emergency_strategies': _generateEmergencyStrategies(),
      'progress_milestones': _generateProgressMilestones(durationDays),
    };

    return plan;
  }

  /// Obtém estatísticas de progresso
  Map<String, dynamic> getProgressStats({int days = 30}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final relevantMetrics =
        _dailyMetrics.where((m) => m.date.isAfter(cutoffDate)).toList();

    if (relevantMetrics.isEmpty) {
      return {'error': 'Dados insuficientes'};
    }

    final moodAvg =
        relevantMetrics.map((m) => m.moodRating).reduce((a, b) => a + b) /
            relevantMetrics.length;

    final stressAvg =
        relevantMetrics.map((m) => m.stressLevel).reduce((a, b) => a + b) /
            relevantMetrics.length;

    final energyAvg =
        relevantMetrics.map((m) => m.energyLevel).reduce((a, b) => a + b) /
            relevantMetrics.length;

    return {
      'period_days': days,
      'entries_count': relevantMetrics.length,
      'averages': {
        'mood': moodAvg,
        'stress': stressAvg,
        'energy': energyAvg,
      },
      'trends': _calculateTrends(relevantMetrics),
      'consistency_score': _calculateConsistencyScore(relevantMetrics),
      'improvement_areas': _identifyImprovementAreas(relevantMetrics),
      'achievements': _identifyAchievements(relevantMetrics),
    };
  }

  // ================= SESSÕES ESPECÍFICAS =================

  /// Sessão de exercícios de respiração
  Future<CoachingSession> _startBreathingSession(
      CoachingSession session) async {
    print('🌬️ Iniciando sessão de respiração...');

    final breathingPatterns = [
      {'name': '4-7-8', 'inhale': 4, 'hold': 7, 'exhale': 8, 'cycles': 4},
      {
        'name': 'Box Breathing',
        'inhale': 4,
        'hold': 4,
        'exhale': 4,
        'hold2': 4,
        'cycles': 6
      },
      {'name': 'Relaxamento', 'inhale': 3, 'hold': 2, 'exhale': 6, 'cycles': 8},
    ];

    final selectedPattern =
        breathingPatterns[Random().nextInt(breathingPatterns.length)];

    session.sessionData['pattern'] = selectedPattern;
    session.sessionData['start_stress'] = await _getCurrentStressLevel();

    // Simular sessão de respiração
    await _runBreathingExercise(selectedPattern);

    session.sessionData['end_stress'] = await _getCurrentStressLevel();
    session.sessionData['duration_minutes'] = 5;
    session.endTime = DateTime.now();
    session.progressScore = _calculateBreathingProgress(session.sessionData);

    session.recommendations.addAll([
      'Pratique respiração profunda 2-3 vezes ao dia',
      'Use técnicas de respiração quando sentir estresse',
      'Mantenha ambiente calmo durante os exercícios',
    ]);

    _sessions.add(session);
    await _saveSessions();

    return session;
  }

  /// Sessão de meditação guiada
  Future<CoachingSession> _startMeditationSession(
      CoachingSession session) async {
    print('🧘 Iniciando sessão de meditação...');

    final meditationTypes = [
      'Mindfulness básico',
      'Body scan',
      'Meditação da gratidão',
      'Visualização relaxante',
      'Meditação para ansiedade',
    ];

    final selectedType =
        meditationTypes[Random().nextInt(meditationTypes.length)];
    final duration = [5, 10, 15, 20][Random().nextInt(4)];

    session.sessionData['meditation_type'] = selectedType;
    session.sessionData['duration_minutes'] = duration;
    session.sessionData['start_mood'] = await _getCurrentMoodLevel();

    // Simular sessão de meditação
    await _runMeditationSession(selectedType, duration);

    session.sessionData['end_mood'] = await _getCurrentMoodLevel();
    session.endTime = DateTime.now();
    session.progressScore = _calculateMeditationProgress(session.sessionData);

    session.recommendations.addAll([
      'Medite regularmente, mesmo que por poucos minutos',
      'Encontre um local tranquilo para prática',
      'Seja paciente consigo mesmo durante o aprendizado',
    ]);

    _sessions.add(session);
    await _saveSessions();

    return session;
  }

  /// Sessão de verificação vocal
  Future<CoachingSession> _startVoiceCheckSession(
      CoachingSession session) async {
    print('🎤 Iniciando verificação vocal...');

    session.sessionData['voice_prompts'] = [
      'Como você está se sentindo hoje?',
      'Descreva seu nível de energia atual',
      'Conte sobre algo positivo que aconteceu recentemente',
    ];

    // Integração com análise de voz
    final voiceResult = await _voiceService.startRealtimeAnalysis(
      duration: const Duration(minutes: 2),
    );

    if (voiceResult != null) {
      session.sessionData['voice_analysis'] = voiceResult.toJson();
      session.progressScore = _calculateVoiceCheckProgress(voiceResult);

      // Recomendações baseadas na análise de voz
      session.recommendations
          .addAll(_getVoiceBasedRecommendations(voiceResult));
    } else {
      session.sessionData['voice_analysis'] = null;
      session.progressScore = 0.5;
      session.recommendations
          .add('Tente realizar verificação vocal em ambiente mais silencioso');
    }

    session.endTime = DateTime.now();
    _sessions.add(session);
    await _saveSessions();

    return session;
  }

  /// Sessão de rastreamento de humor
  Future<CoachingSession> _startMoodTrackingSession(
      CoachingSession session) async {
    print('😊 Iniciando rastreamento de humor...');

    final moodQuestions = [
      'Como você avaliaria seu humor geral hoje? (1-10)',
      'Quão estressado você se sente? (1-10)',
      'Qual seu nível de energia? (1-10)',
      'Quão bem você dormiu na noite passada? (1-10)',
    ];

    session.sessionData['mood_questions'] = moodQuestions;
    session.sessionData['responses'] =
        _simulateMoodResponses(); // Simular respostas

    final moodScore = _calculateMoodScore(
        session.sessionData['responses'] as Map<String, double>);
    session.sessionData['mood_score'] = moodScore;
    session.progressScore = moodScore / 10.0;

    session.recommendations.addAll(_getMoodBasedRecommendations(moodScore));
    session.endTime = DateTime.now();

    _sessions.add(session);
    await _saveSessions();

    return session;
  }

  /// Sessão de alívio de estresse
  Future<CoachingSession> _startStressReliefSession(
      CoachingSession session) async {
    print('😌 Iniciando sessão de alívio de estresse...');

    final stressReliefTechniques = [
      'Relaxamento muscular progressivo',
      'Exercícios de grounding 5-4-3-2-1',
      'Caminhada mindful',
      'Journaling de gratidão',
      'Música relaxante',
    ];

    final selectedTechnique =
        stressReliefTechniques[Random().nextInt(stressReliefTechniques.length)];

    session.sessionData['technique'] = selectedTechnique;
    session.sessionData['start_stress'] = await _getCurrentStressLevel();

    // Simular aplicação da técnica
    await _applyStressReliefTechnique(selectedTechnique);

    session.sessionData['end_stress'] = await _getCurrentStressLevel();
    session.sessionData['duration_minutes'] = 10;
    session.endTime = DateTime.now();
    session.progressScore = _calculateStressReliefProgress(session.sessionData);

    session.recommendations.addAll([
      'Pratique técnicas de alívio regularmente',
      'Identifique gatilhos de estresse pessoais',
      'Mantenha técnicas de emergência sempre acessíveis',
    ]);

    _sessions.add(session);
    await _saveSessions();

    return session;
  }

  // ================= MÉTODOS AUXILIARES =================

  Future<double> _getCurrentStressLevel() async {
    return 0.3 + (Random().nextDouble() * 0.4); // Simular
  }

  Future<double> _getCurrentMoodLevel() async {
    return 5.0 + (Random().nextDouble() * 4.0); // Simular
  }

  Future<void> _runBreathingExercise(Map<String, dynamic> pattern) async {
    await Future<void>.delayed(const Duration(seconds: 2)); // Simular
  }

  Future<void> _runMeditationSession(String type, int duration) async {
    await Future<void>.delayed(Duration(seconds: duration)); // Simular
  }

  Future<void> _applyStressReliefTechnique(String technique) async {
    await Future<void>.delayed(const Duration(seconds: 3)); // Simular
  }

  double _calculateBreathingProgress(Map<String, dynamic> data) {
    final startStress = (data['start_stress'] ?? 0.5) as double;
    final endStress = (data['end_stress'] ?? 0.4) as double;
    return (1.0 - (endStress / startStress)).clamp(0.0, 1.0);
  }

  double _calculateMeditationProgress(Map<String, dynamic> data) {
    final startMood = (data['start_mood'] ?? 5.0) as double;
    final endMood = (data['end_mood'] ?? 6.0) as double;
    final duration = (data['duration_minutes'] ?? 5) as int;
    final moodImprovement = (endMood - startMood) / 10.0;
    final durationBonus = (duration / 20.0).clamp(0.0, 0.3);
    return (0.5 + moodImprovement + durationBonus).clamp(0.0, 1.0);
  }

  double _calculateVoiceCheckProgress(VoiceAnalysisResult result) {
    final stressScore = 1.0 - result.stressLevel;
    final stabilityScore = result.emotionalStability;
    return (stressScore + stabilityScore) / 2.0;
  }

  double _calculateStressReliefProgress(Map<String, dynamic> data) {
    final startStress = (data['start_stress'] ?? 0.5) as double;
    final endStress = (data['end_stress'] ?? 0.4) as double;
    return (1.0 - (endStress / startStress)).clamp(0.0, 1.0);
  }

  List<String> _getVoiceBasedRecommendations(VoiceAnalysisResult result) {
    final recommendations = <String>[];

    if (result.stressLevel > 0.7) {
      recommendations.addAll([
        'Considere técnicas de respiração para reduzir estresse',
        'Faça pausas regulares durante atividades estressantes',
      ]);
    }

    if (result.energyLevel < 0.3) {
      recommendations.addAll([
        'Avalie qualidade do sono e descanso',
        'Considere atividades energizantes leves',
      ]);
    }

    return recommendations;
  }

  List<String> _getMoodBasedRecommendations(double moodScore) {
    if (moodScore < 4.0) {
      return [
        'Pratique atividades que trazem alegria',
        'Mantenha conexões sociais positivas',
        'Considere buscar apoio profissional se necessário',
      ];
    } else if (moodScore < 6.0) {
      return [
        'Mantenha rotinas que promovem bem-estar',
        'Pratique gratidão diariamente',
      ];
    } else {
      return [
        'Continue mantendo hábitos positivos',
        'Compartilhe energia positiva com outros',
      ];
    }
  }

  Map<String, double> _simulateMoodResponses() {
    final random = Random();
    return {
      'humor_geral': 5.0 + (random.nextDouble() * 4.0),
      'nivel_estresse': 2.0 + (random.nextDouble() * 6.0),
      'nivel_energia': 4.0 + (random.nextDouble() * 5.0),
      'qualidade_sono': 5.0 + (random.nextDouble() * 4.0),
    };
  }

  double _calculateMoodScore(Map<String, double> responses) =>
      responses.values.reduce((a, b) => a + b) / responses.length;

  // ================= ANÁLISES E TENDÊNCIAS =================

  Map<String, dynamic> _analyzeTrends(List<DailyWellnessMetrics> metrics) {
    if (metrics.length < 3) return {'insufficient_data': true};

    final moodTrend =
        _calculateTrendDirection(metrics.map((m) => m.moodRating).toList());
    final stressTrend =
        _calculateTrendDirection(metrics.map((m) => m.stressLevel).toList());
    final energyTrend =
        _calculateTrendDirection(metrics.map((m) => m.energyLevel).toList());

    return {
      'mood_trend': moodTrend,
      'stress_trend': stressTrend,
      'energy_trend': energyTrend,
      'overall_direction':
          _getOverallTrend([moodTrend, stressTrend, energyTrend]),
    };
  }

  String _calculateTrendDirection(List<double> values) {
    if (values.length < 3) return 'stable';

    final first = values.take(values.length ~/ 2).reduce((a, b) => a + b) /
        (values.length ~/ 2);
    final last = values.skip(values.length ~/ 2).reduce((a, b) => a + b) /
        (values.length - values.length ~/ 2);

    final difference = last - first;
    if (difference > 0.2) return 'improving';
    if (difference < -0.2) return 'declining';
    return 'stable';
  }

  String _getOverallTrend(List<String> trends) {
    final improving = trends.where((t) => t == 'improving').length;
    final declining = trends.where((t) => t == 'declining').length;

    if (improving > declining) return 'positive';
    if (declining > improving) return 'concerning';
    return 'stable';
  }

  double _calculateOverallWellnessScore(List<DailyWellnessMetrics> metrics) {
    if (metrics.isEmpty) return 0;

    final avgMood = metrics.map((m) => m.moodRating).reduce((a, b) => a + b) /
        metrics.length;
    final avgStress =
        metrics.map((m) => 1.0 - m.stressLevel).reduce((a, b) => a + b) /
            metrics.length;
    final avgEnergy =
        metrics.map((m) => m.energyLevel).reduce((a, b) => a + b) /
            metrics.length;

    return ((avgMood / 10.0 * 0.4) + (avgStress * 0.3) + (avgEnergy * 0.3)) *
        100;
  }

  Map<String, dynamic> _identifyWellnessPatterns(
      List<DailyWellnessMetrics> metrics) {
    // Análise de padrões semanais, correlações, etc.
    return {
      'weekly_patterns': _analyzeWeeklyPatterns(metrics),
      'activity_correlations': _analyzeActivityCorrelations(metrics),
      'sleep_impact': _analyzeSleepImpact(metrics),
    };
  }

  List<String> _generatePersonalizedRecommendations(
      List<DailyWellnessMetrics> metrics, Map<String, dynamic> trends) {
    final recommendations = <String>[];

    // Baseado nas tendências
    if (trends['stress_trend'] == 'declining') {
      recommendations
          .add('Continue práticas atuais de gerenciamento de estresse');
    } else if (trends['stress_trend'] == 'increasing') {
      recommendations.add('Intensifique técnicas de redução de estresse');
    }

    // Baseado nas métricas médias
    final avgMood = metrics.map((m) => m.moodRating).reduce((a, b) => a + b) /
        metrics.length;
    if (avgMood < 5.0) {
      recommendations.add('Foque em atividades que elevam o humor');
    }

    return recommendations;
  }

  Map<String, dynamic> _calculateGoalProgress() {
    if (_currentProfile == null) return {};

    // Simular progresso nas metas
    return {
      'goals_total': _currentProfile!.goals.length,
      'goals_achieved': (_currentProfile!.goals.length * 0.6).round(),
      'progress_percentage': 60.0,
      'next_milestone': 'Manter consistência por mais 1 semana',
    };
  }

  // ================= PERSISTÊNCIA =================

  Future<void> _loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final profileJson = prefs.getString('wellness_profile');
      if (profileJson != null) {
        _currentProfile = WellnessProfile.fromJson(
            jsonDecode(profileJson) as Map<String, dynamic>);
      }
    } catch (e) {
      print('❌ Erro ao carregar perfil: $e');
    }
  }

  Future<void> _saveUserProfile() async {
    if (_currentProfile == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
          'wellness_profile', jsonEncode(_currentProfile!.toJson()));
    } catch (e) {
      print('❌ Erro ao salvar perfil: $e');
    }
  }

  Future<void> _loadSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsData = prefs.getString('coaching_sessions');

      if (sessionsData != null) {
        final sessionsJson = jsonDecode(sessionsData) as List<dynamic>;
        _sessions = sessionsJson
            .map((json) =>
                CoachingSession.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // Inicializar com algumas sessões de exemplo
        _sessions = _createSampleSessions();
        await _saveSessions();
      }
    } catch (e) {
      print('❌ Erro ao carregar sessões: $e');
      // Fallback para sessões de exemplo
      _sessions = _createSampleSessions();
    }
  }

  Future<void> _saveSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = _sessions.map((s) => s.toJson()).toList();
      await prefs.setString('coaching_sessions', jsonEncode(sessionsJson));
    } catch (e) {
      print('❌ Erro ao salvar sessões: $e');
    }
  }

  Future<void> _loadDailyMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metricsData = prefs.getString('daily_metrics');

      if (metricsData != null) {
        final metricsJson = jsonDecode(metricsData) as List<dynamic>;
        _dailyMetrics = metricsJson
            .map((json) =>
                DailyWellnessMetrics.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // Inicializar com algumas métricas de exemplo
        _dailyMetrics = _createSampleMetrics();
        await _saveDailyMetrics();
      }
    } catch (e) {
      print('❌ Erro ao carregar métricas: $e');
      // Fallback para métricas de exemplo
      _dailyMetrics = _createSampleMetrics();
    }
  }

  Future<void> _saveDailyMetrics() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metricsJson = _dailyMetrics.map((m) => m.toJson()).toList();
      await prefs.setString('daily_metrics', jsonEncode(metricsJson));
    } catch (e) {
      print('❌ Erro ao salvar métricas: $e');
    }
  }

  void _setupDailyReminders() {
    print('💡 Sistema de lembretes será implementado em breve');
  }

  // ================= MÉTODOS AUXILIARES ADICIONAIS =================

  List<String> _generateDailyRecommendations(DailyWellnessMetrics metrics) {
    final recommendations = <String>[];

    if (metrics.stressLevel > 0.7) {
      recommendations.add('Considere técnicas de relaxamento hoje');
    }

    if (metrics.energyLevel < 0.3) {
      recommendations.add('Priorize descanso e atividades revigorantes');
    }

    if (metrics.sleepHours < 6) {
      recommendations.add('Foque em melhorar a qualidade do sono');
    }

    return recommendations;
  }

  void _showWellnessRecommendations(List<String> recommendations) {
    print('💡 Recomendações de bem-estar:');
    for (final rec in recommendations) {
      print('  • $rec');
    }
  }

  Map<String, dynamic> _analyzeWeeklyPatterns(
      List<DailyWellnessMetrics> metrics) {
    // Análise simplificada de padrões semanais
    return {
      'best_day': 'Sábado',
      'challenging_day': 'Segunda-feira',
      'pattern_strength': 0.6,
    };
  }

  Map<String, dynamic> _analyzeActivityCorrelations(
      List<DailyWellnessMetrics> metrics) {
    // Análise de correlação entre atividades e bem-estar
    return {
      'positive_activities': ['exercício', 'meditação', 'tempo na natureza'],
      'negative_activities': ['trabalho excessivo', 'redes sociais'],
      'correlation_strength': 0.7,
    };
  }

  Map<String, dynamic> _analyzeSleepImpact(List<DailyWellnessMetrics> metrics) {
    // Análise do impacto do sono no bem-estar
    return {
      'optimal_sleep_hours': 7.5,
      'sleep_mood_correlation': 0.8,
      'sleep_energy_correlation': 0.9,
    };
  }

  List<String> _identifyRiskFactors(List<DailyWellnessMetrics> metrics) {
    final risks = <String>[];

    final avgStress =
        metrics.map((m) => m.stressLevel).reduce((a, b) => a + b) /
            metrics.length;
    if (avgStress > 0.7) risks.add('Nível de estresse elevado consistente');

    final avgSleep = metrics.map((m) => m.sleepHours).reduce((a, b) => a + b) /
        metrics.length;
    if (avgSleep < 6) risks.add('Padrão de sono insuficiente');

    return risks;
  }

  List<String> _identifyPositiveIndicators(List<DailyWellnessMetrics> metrics) {
    final positives = <String>[];

    final avgMood = metrics.map((m) => m.moodRating).reduce((a, b) => a + b) /
        metrics.length;
    if (avgMood > 7) positives.add('Humor consistentemente positivo');

    final avgEnergy =
        metrics.map((m) => m.energyLevel).reduce((a, b) => a + b) /
            metrics.length;
    if (avgEnergy > 0.7) positives.add('Níveis de energia saudáveis');

    return positives;
  }

  List<String> _getNextSteps(
      double wellnessScore, Map<String, dynamic> trends) {
    final steps = <String>[];

    if (wellnessScore < 60) {
      steps.addAll([
        'Focar em uma área de melhoria por vez',
        'Estabelecer rotinas pequenas e consistentes',
        'Considerar apoio profissional se necessário',
      ]);
    } else if (wellnessScore < 80) {
      steps.addAll([
        'Manter práticas atuais',
        'Expandir gradualmente atividades de bem-estar',
      ]);
    } else {
      steps.addAll([
        'Continuar excelente trabalho',
        'Ser modelo para outros',
        'Explorar práticas avançadas',
      ]);
    }

    return steps;
  }

  List<Map<String, dynamic>> _generateDailyActivities() => [
        {'activity': 'Meditação matinal', 'duration': 10, 'time': '07:00'},
        {'activity': 'Exercício leve', 'duration': 20, 'time': '18:00'},
        {'activity': 'Reflexão diária', 'duration': 5, 'time': '21:00'},
      ];

  List<String> _generateWeeklyGoals() => [
        'Meditar 5 dias na semana',
        'Dormir 7+ horas por noite',
        'Praticar gratidão diariamente',
      ];

  Map<String, dynamic> _generateMonitoringSchedule() => {
        'daily_check_ins': true,
        'weekly_analysis': true,
        'voice_checks': 'twice_weekly',
      };

  List<String> _generateEmergencyStrategies() => [
        'Técnica de respiração 4-7-8',
        'Exercício de grounding 5-4-3-2-1',
        'Contato com pessoa de confiança',
        'Buscar ambiente calmo e seguro',
      ];

  List<Map<String, dynamic>> _generateProgressMilestones(int days) => [
        {
          'week': 1,
          'goal': 'Estabelecer rotina diária',
          'reward': 'Atividade prazerosa'
        },
        {
          'week': 2,
          'goal': 'Consistência em técnicas de bem-estar',
          'reward': 'Tempo para hobby'
        },
        {
          'week': 4,
          'goal': 'Melhoria mensurável em métricas',
          'reward': 'Celebração pessoal'
        },
      ];

  Map<String, dynamic> _calculateTrends(List<DailyWellnessMetrics> metrics) => {
        'mood_trend':
            _calculateTrendDirection(metrics.map((m) => m.moodRating).toList()),
        'stress_trend': _calculateTrendDirection(
            metrics.map((m) => m.stressLevel).toList()),
        'energy_trend': _calculateTrendDirection(
            metrics.map((m) => m.energyLevel).toList()),
      };

  double _calculateConsistencyScore(List<DailyWellnessMetrics> metrics) {
    // Calcular consistência nas práticas de bem-estar
    return 0.75; // Placeholder
  }

  List<String> _identifyImprovementAreas(List<DailyWellnessMetrics> metrics) =>
      [
        'Qualidade do sono',
        'Gerenciamento de estresse',
      ];

  List<String> _identifyAchievements(List<DailyWellnessMetrics> metrics) => [
        'Manutenção de humor estável',
        'Consistência em registros diários',
      ];

  // ================= GETTERS =================

  bool get isInitialized => _isInitialized;
  WellnessProfile? get currentProfile => _currentProfile;
  List<CoachingSession> get sessions => List.unmodifiable(_sessions);
  List<DailyWellnessMetrics> get dailyMetrics =>
      List.unmodifiable(_dailyMetrics);

  /// Cria sessões de exemplo para demonstração
  List<CoachingSession> _createSampleSessions() {
    final now = DateTime.now();
    return [
      CoachingSession(
        sessionId: '1',
        userId: 'demo_user',
        type: 'breathing',
        startTime: now.subtract(const Duration(hours: 2)),
        endTime: now.subtract(const Duration(hours: 2, minutes: -10)),
        sessionData: {
          'duration': 10,
          'exercises_completed': 5,
          'average_breathing_rate': 12,
        },
        progressScore: 0.85,
        recommendations: [
          'Continue praticando diariamente',
          'Tente aumentar para 15 minutos'
        ],
      ),
      CoachingSession(
        sessionId: '2',
        userId: 'demo_user',
        type: 'voice_check',
        startTime: now.subtract(const Duration(days: 1)),
        endTime: now.subtract(const Duration(days: 1, minutes: -5)),
        sessionData: {
          'stress_level': 0.4,
          'energy_level': 0.7,
          'mood_state': 'neutral',
        },
        progressScore: 0.75,
        recommendations: [
          'Pratique exercícios de relaxamento vocal',
          'Hidrate-se mais durante o dia'
        ],
      ),
      CoachingSession(
        sessionId: '3',
        userId: 'demo_user',
        type: 'meditation',
        startTime: now.subtract(const Duration(days: 2)),
        endTime: now.subtract(const Duration(days: 2, minutes: -20)),
        sessionData: {
          'duration': 20,
          'focus_score': 0.9,
          'interruptions': 1,
        },
        progressScore: 0.90,
        recommendations: [
          'Perfeito! Continue assim',
          'Considere sessões mais longas'
        ],
      ),
    ];
  }

  /// Cria métricas de exemplo para demonstração
  List<DailyWellnessMetrics> _createSampleMetrics() {
    final now = DateTime.now();
    return [
      DailyWellnessMetrics(
        date: now.subtract(const Duration(days: 2)),
        moodRating: 7,
        stressLevel: 0.3,
        energyLevel: 0.8,
        sleepHours: 7,
        activities: ['exercício', 'trabalho', 'relaxamento'],
        notes: 'Dia produtivo com boa energia',
      ),
      DailyWellnessMetrics(
        date: now.subtract(const Duration(days: 1)),
        moodRating: 6,
        stressLevel: 0.5,
        energyLevel: 0.6,
        sleepHours: 6,
        activities: ['trabalho', 'estudos'],
        notes: 'Dia um pouco mais estressante',
      ),
      DailyWellnessMetrics(
        date: now,
        moodRating: 8,
        stressLevel: 0.2,
        energyLevel: 0.9,
        sleepHours: 8,
        activities: ['meditação', 'exercício', 'tempo com família'],
        notes: 'Excelente dia de bem-estar!',
      ),
    ];
  }

  /// Cria métricas de exemplo para demonstração
  Future<CoachingSession?> _startBackendCoachingSession(String type) async {
    try {
      print('🚀 Iniciando sessão $type com backend Gemma-3n');

      // Preparar dados para enviar ao backend
      final requestData = {
        'session_type': type,
        'user_data': {
          'mood_rating': 7.0,
          'stress_level': 0.3,
          'energy_level': 0.7,
        },
        'language': 'pt-BR',
      };

      // Enviar requisição para o backend com timeout maior
      final response = await _dio.post<Map<String, dynamic>>(
        '$_backendUrl/wellness/coaching',
        data: requestData,
        options: Options(
          headers: {'Content-Type': 'application/json'},
          receiveTimeout:
              const Duration(seconds: 45), // Tempo maior para Gemma-3n
          sendTimeout: const Duration(seconds: 15),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;

        // Criar sessão com dados do backend
        final session = CoachingSession(
          sessionId: 'backend_${DateTime.now().millisecondsSinceEpoch}',
          userId: _currentProfile!.userId,
          type: type,
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(minutes: 10)),
          sessionData: {
            'backend_response': data['coaching_response'],
            'recommendations_count':
                (data['recommendations'] as List?)?.length ?? 0,
            'source': 'gemma-3n-backend',
            'status': data['status'] ?? 'completed',
          },
          recommendations: (data['recommendations'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              [],
          progressScore: (data['progress_score'] ?? 0.8) as double,
        );

        // Salvar sessão
        _sessions.add(session);
        await _saveSessions();

        print('✅ Sessão $type criada com sucesso usando backend Gemma-3n');
        return session;
      } else {
        print('❌ Resposta inválida do backend: ${response.statusCode}');
        return null;
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.receiveTimeout) {
        print(
            '❌ Backend timeout: Gemma-3n está demorando para processar. Usando fallback offline.');
      } else if (e.type == DioExceptionType.connectionError) {
        print(
            '❌ Erro de conexão: Verifique se o backend está rodando em $_backendUrl');
      } else {
        print('❌ Erro ao usar backend: ${e.type} - ${e.message}');
      }
      // Fallback para sessão offline
      return _createOfflineSession(type);
    } catch (e) {
      print('❌ Erro inesperado ao usar backend: $e');
      // Fallback para sessão offline
      return _createOfflineSession(type);
    }
  }

  /// Criar sessão offline como fallback
  Future<CoachingSession?> _createOfflineSession(String type) async {
    try {
      print('🔄 Criando sessão offline para $type');

      final session = CoachingSession(
        sessionId: 'offline_${DateTime.now().millisecondsSinceEpoch}',
        userId: _currentProfile!.userId,
        type: type,
        startTime: DateTime.now(),
        endTime: DateTime.now().add(const Duration(minutes: 5)),
        sessionData: {
          'source': 'offline-fallback',
          'type': type,
        },
        recommendations: _getOfflineRecommendations(type),
        progressScore: 0.7,
      );

      _sessions.add(session);
      await _saveSessions();

      print('✅ Sessão offline $type criada');
      return session;
    } catch (e) {
      print('❌ Erro ao criar sessão offline: $e');
      return null;
    }
  }

  /// Obter recomendações offline por tipo de sessão
  List<String> _getOfflineRecommendations(String type) {
    switch (type) {
      case 'breathing':
        return [
          'Pratique a respiração 4-7-8: inspire por 4, segure por 7, expire por 8',
          'Repita 5-10 ciclos respiratórios',
          'Encontre um ambiente tranquilo para praticar'
        ];
      case 'meditation':
        return [
          'Comece com 5-10 minutos de meditação',
          'Concentre-se na respiração',
          'Use uma postura confortável e ereta'
        ];
      case 'voice_check':
        return [
          'Fale em voz alta para auto-avaliação',
          'Observe mudanças no tom e ritmo',
          'Pratique exercícios vocais de relaxamento'
        ];
      case 'mood_tracking':
        return [
          'Registre seu humor diariamente',
          'Identifique padrões e gatilhos',
          'Pratique auto-compaixão'
        ];
      case 'stress_relief':
        return [
          'Use técnicas de respiração profunda',
          'Pratique relaxamento muscular progressivo',
          'Mantenha contato com pessoas de apoio'
        ];
      default:
        return [
          'Pratique mindfulness diariamente',
          'Mantenha rotinas saudáveis',
          'Busque apoio quando necessário'
        ];
    }
  }
}
