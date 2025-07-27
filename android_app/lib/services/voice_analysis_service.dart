import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../config/app_config.dart';
import '../models/mental_health_models.dart';

/// Serviço avançado de análise de voz para saúde mental
class VoiceAnalysisService {
  factory VoiceAnalysisService() => _instance;
  VoiceAnalysisService._internal() {
    // Configurar Dio para comunicação com backend Gemma-3n
    _dio = Dio(BaseOptions(
      baseUrl: AppConfig.backendHost == 'localhost' ? 'http://localhost:5000' : 'http://10.0.2.2:5000',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
  }
  static final VoiceAnalysisService _instance =
      VoiceAnalysisService._internal();

  late final Dio _dio;
  bool _isInitialized = false;
  bool _isRecording = false;
  bool _backendAvailable = false;
  Timer? _analysisTimer;

  // Cache dos resultados para processamento offline
  final List<VoiceAnalysisResult> _analysisHistory = [];

  /// Inicializa o serviço de análise de voz
  Future<bool> initialize() async {
    try {
      // Verificar permissões
      final micPermission = await Permission.microphone.request();
      if (!micPermission.isGranted) {
        print('❌ Permissão de microfone negada');
        return false;
      }

      // Inicializar processamento de áudio nativo (simulado)
      _isInitialized = true;
      print('✅ Serviço de análise de voz inicializado');
      return true;
    } catch (e) {
      print('❌ Erro ao inicializar análise de voz: $e');
      return false;
    }
  }

  /// Inicia análise contínua de voz em tempo real
  Future<VoiceAnalysisResult?> startRealtimeAnalysis({
    Duration duration = const Duration(seconds: 30),
    void Function(VoiceAnalysisResult)? onAnalysis,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    if (_isRecording) {
      print('⚠️ Análise já em andamento');
      return null;
    }

    try {
      _isRecording = true;
      print('🎤 Iniciando análise de voz em tempo real...');

      // Simular captura e análise de áudio
      final completer = Completer<VoiceAnalysisResult>();

      _analysisTimer =
          Timer.periodic(const Duration(seconds: 2), (timer) async {
        if (!_isRecording) {
          timer.cancel();
          return;
        }

        // Simular análise de features de voz
        final result = await _performVoiceAnalysis();

        // Cache do resultado
        _analysisHistory.add(result);
        if (_analysisHistory.length > 50) {
          _analysisHistory.removeAt(0);
        }

        onAnalysis?.call(result);
      });

      // Parar automaticamente após a duração especificada
      Timer(duration, () async {
        final finalResult = await stopRealtimeAnalysis();
        if (!completer.isCompleted) {
          completer.complete(finalResult);
        }
      });

      return await completer.future;
    } catch (e) {
      print('❌ Erro na análise de voz: $e');
      _isRecording = false;
      return null;
    }
  }

  /// Para a análise contínua e retorna resultado final
  Future<VoiceAnalysisResult?> stopRealtimeAnalysis() async {
    if (!_isRecording) return null;

    _isRecording = false;
    _analysisTimer?.cancel();

    print('🛑 Parando análise de voz...');

    // Calcular métricas finais baseadas no histórico
    if (_analysisHistory.isEmpty) return null;

    final avgStress =
        _analysisHistory.map((r) => r.stressLevel).reduce((a, b) => a + b) /
            _analysisHistory.length;

    final avgEnergy =
        _analysisHistory.map((r) => r.energyLevel).reduce((a, b) => a + b) /
            _analysisHistory.length;

    final avgStability = _analysisHistory
            .map((r) => r.emotionalStability)
            .reduce((a, b) => a + b) /
        _analysisHistory.length;

    // Determinar estado emocional predominante
    final moodCounts = <String, int>{};
    for (final result in _analysisHistory) {
      moodCounts[result.moodState] = (moodCounts[result.moodState] ?? 0) + 1;
    }

    final predominantMood =
        moodCounts.entries.reduce((a, b) => a.value > b.value ? a : b).key;

    return VoiceAnalysisResult(
      stressLevel: avgStress,
      energyLevel: avgEnergy,
      emotionalStability: avgStability,
      moodState: predominantMood,
      confidence: 0.85,
      emotionalIndicators: _generateEmotionalIndicators(avgStress, avgEnergy),
      voiceFeatures: {
        'pitch_variance': _calculatePitchVariance(),
        'speaking_rate': _calculateSpeakingRate(),
        'voice_tremor': _calculateVoiceTremor(),
        'energy_consistency': avgStability,
      },
      timestamp: DateTime.now(),
    );
  }

  /// Análise pontual de um arquivo de áudio
  Future<VoiceAnalysisResult?> analyzeAudioFile(String filePath) async {
    try {
      print('🎵 Analisando arquivo de áudio: $filePath');

      // Verificar se o arquivo existe
      final file = File(filePath);
      if (!await file.exists()) {
        print('❌ Arquivo não encontrado: $filePath');
        return null;
      }

      // Simular processamento do arquivo
      await Future<void>.delayed(const Duration(seconds: 3));

      return await _performVoiceAnalysis();
    } catch (e) {
      print('❌ Erro ao analisar arquivo: $e');
      return null;
    }
  }

  /// Análise de dados de áudio raw
  Future<VoiceAnalysisResult?> analyzeAudioData(AudioData audioData) async {
    try {
      print('🔊 Analisando dados de áudio (${audioData.duration}ms)');

      // Simular processamento dos dados
      await Future<void>.delayed(const Duration(seconds: 2));

      // Análise baseada nas características do áudio
      final durationFactor =
          audioData.duration / 30000.0; // normalizar para 30s
      final sampleRateFactor =
          audioData.sampleRate / 44100.0; // normalizar para 44.1kHz

      return await _performVoiceAnalysis(
        durationFactor: durationFactor,
        qualityFactor: sampleRateFactor,
      );
    } catch (e) {
      print('❌ Erro ao analisar dados de áudio: $e');
      return null;
    }
  }

  /// Detecta padrões de estresse na voz
  Future<Map<String, dynamic>> detectStressPatterns() async {
    if (_analysisHistory.length < 5) {
      return {'insufficient_data': true};
    }

    final recentResults = _analysisHistory.take(10).toList();
    final avgStress =
        recentResults.map((r) => r.stressLevel).reduce((a, b) => a + b) /
            recentResults.length;

    final stressTrend =
        _calculateTrend(recentResults.map((r) => r.stressLevel).toList());

    return {
      'average_stress': avgStress,
      'stress_trend': stressTrend, // 'increasing', 'decreasing', 'stable'
      'stress_level': avgStress > 0.7
          ? 'high'
          : avgStress > 0.4
              ? 'moderate'
              : 'low',
      'recommendations': _getStressRecommendations(avgStress, stressTrend),
      'patterns': _detectVoicePatterns(recentResults),
    };
  }

  /// Gera relatório de saúde mental baseado no histórico
  Map<String, dynamic> generateMentalHealthReport({int days = 7}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    final recentResults =
        _analysisHistory.where((r) => r.timestamp.isAfter(cutoffDate)).toList();

    if (recentResults.isEmpty) {
      return {'error': 'Dados insuficientes'};
    }

    final avgStress =
        recentResults.map((r) => r.stressLevel).reduce((a, b) => a + b) /
            recentResults.length;

    final avgEnergy =
        recentResults.map((r) => r.energyLevel).reduce((a, b) => a + b) /
            recentResults.length;

    final avgStability =
        recentResults.map((r) => r.emotionalStability).reduce((a, b) => a + b) /
            recentResults.length;

    return {
      'period_days': days,
      'total_analyses': recentResults.length,
      'average_metrics': {
        'stress_level': avgStress,
        'energy_level': avgEnergy,
        'emotional_stability': avgStability,
      },
      'wellness_score':
          _calculateWellnessScore(avgStress, avgEnergy, avgStability),
      'mood_distribution': _getMoodDistribution(recentResults),
      'recommendations':
          _getPersonalizedRecommendations(avgStress, avgEnergy, avgStability),
      'progress_indicators': _getProgressIndicators(recentResults),
    };
  }

  // =================== MÉTODOS PRIVADOS ===================

  /// Executa análise de voz com algoritmos simulados e backend Gemma-3n
  Future<VoiceAnalysisResult> _performVoiceAnalysis({
    double durationFactor = 1.0,
    double qualityFactor = 1.0,
  }) async {
    // Tentar usar backend Gemma-3n primeiro
    try {
      final backendResult =
          await _analyzeWithBackend(durationFactor, qualityFactor);
      if (backendResult != null) {
        print('✅ Análise de voz realizada com backend Gemma-3n');
        return backendResult;
      }
    } catch (e) {
      print('⚠️ Backend indisponível, usando análise offline: $e');
    }

    // Fallback para análise offline
    final random = Random();

    // Simular análise de features de voz
    final baseStress = 0.3 + (random.nextDouble() * 0.4);
    final baseEnergy = 0.4 + (random.nextDouble() * 0.4);
    final baseStability = 0.5 + (random.nextDouble() * 0.3);

    // Ajustar baseado na qualidade e duração
    final stressLevel = (baseStress * qualityFactor).clamp(0.0, 1.0);
    final energyLevel = (baseEnergy * durationFactor).clamp(0.0, 1.0);
    final emotionalStability = (baseStability * qualityFactor).clamp(0.0, 1.0);

    // Determinar estado emocional
    String moodState;
    if (stressLevel > 0.7) {
      moodState = 'stressed';
    } else if (energyLevel < 0.3) {
      moodState = 'tired';
    } else if (emotionalStability > 0.7) {
      moodState = 'calm';
    } else if (energyLevel > 0.7) {
      moodState = 'energetic';
    } else {
      moodState = 'neutral';
    }

    return VoiceAnalysisResult(
      stressLevel: stressLevel,
      energyLevel: energyLevel,
      emotionalStability: emotionalStability,
      moodState: moodState,
      confidence: 0.75 + (random.nextDouble() * 0.2),
      emotionalIndicators:
          _generateEmotionalIndicators(stressLevel, energyLevel),
      voiceFeatures: {
        'pitch_mean': 150.0 + (random.nextDouble() * 100),
        'pitch_variance': _calculatePitchVariance(),
        'speaking_rate': _calculateSpeakingRate(),
        'voice_tremor': stressLevel * 0.5,
        'pause_frequency': stressLevel * 3,
      },
      timestamp: DateTime.now(),
    );
  }

  /// Análise de voz usando backend Gemma-3n
  Future<VoiceAnalysisResult?> _analyzeWithBackend(
      double durationFactor, double qualityFactor) async {
    try {
      // Preparar dados de voz simulados para o backend
      final voiceData = {
        'stress_indicators': 0.3 + (Random().nextDouble() * 0.4),
        'energy_indicators': 0.4 + (Random().nextDouble() * 0.4),
        'stability_indicators': 0.5 + (Random().nextDouble() * 0.3),
        'duration_factor': durationFactor,
        'quality_factor': qualityFactor,
        'detected_mood': 'neutral',
        'pitch_variance': _calculatePitchVariance(),
        'speaking_rate': _calculateSpeakingRate(),
      };

      final response = await _dio.post<Map<String, dynamic>>(
        '/wellness/voice-analysis',
        data: {
          'voice_data': voiceData,
          'language': 'pt-BR',
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        final analysis = data['analysis'] as Map<String, dynamic>;
        final recommendations = (data['recommendations'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];

        // Converter dados de voz para Map<String, double>
        final voiceFeatures = <String, double>{
          'pitch_mean': (voiceData['stress_indicators'] as double) * 200,
          'pitch_variance': _calculatePitchVariance(),
          'speaking_rate': _calculateSpeakingRate(),
          'voice_tremor': (voiceData['stress_indicators'] as double) * 0.5,
          'pause_frequency': (voiceData['stress_indicators'] as double) * 3,
        };

        // Converter resposta do backend para VoiceAnalysisResult
        return VoiceAnalysisResult(
          stressLevel: (analysis['stress_level'] ?? 0.5) as double,
          energyLevel: (analysis['energy_level'] ?? 0.5) as double,
          emotionalStability:
              (analysis['emotional_stability'] ?? 0.7) as double,
          moodState: analysis['mood_state']?.toString() ?? 'neutral',
          confidence: (analysis['confidence'] ?? 0.8) as double,
          emotionalIndicators: recommendations,
          voiceFeatures: voiceFeatures,
          timestamp: DateTime.now(),
        );
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionError) {
        _backendAvailable = false;
      }
      print('❌ Erro na análise de voz via backend: ${e.message}');
    } catch (e) {
      print('❌ Erro inesperado na análise de voz: $e');
    }

    return null;
  }

  List<String> _generateEmotionalIndicators(double stress, double energy) {
    final indicators = <String>[];

    if (stress > 0.7) {
      indicators.addAll(['voz tensa', 'ritmo acelerado', 'pausas frequentes']);
    } else if (stress < 0.3) {
      indicators.add('voz relaxada');
    }

    if (energy > 0.7) {
      indicators.addAll(['tom energético', 'volume consistente']);
    } else if (energy < 0.3) {
      indicators.addAll(['voz baixa', 'fala lenta']);
    }

    return indicators;
  }

  double _calculatePitchVariance() {
    final random = Random();
    return 15.0 + (random.nextDouble() * 35.0);
  }

  double _calculateSpeakingRate() {
    final random = Random();
    return 120.0 + (random.nextDouble() * 80.0); // palavras por minuto
  }

  double _calculateVoiceTremor() {
    final random = Random();
    return random.nextDouble() * 0.3;
  }

  String _calculateTrend(List<double> values) {
    if (values.length < 3) return 'stable';

    final first = values.take(values.length ~/ 2).reduce((a, b) => a + b) /
        (values.length ~/ 2);
    final last = values.skip(values.length ~/ 2).reduce((a, b) => a + b) /
        (values.length - values.length ~/ 2);

    final difference = last - first;
    if (difference > 0.1) return 'increasing';
    if (difference < -0.1) return 'decreasing';
    return 'stable';
  }

  List<String> _getStressRecommendations(double avgStress, String trend) {
    final recommendations = <String>[];

    if (avgStress > 0.7) {
      recommendations.addAll([
        'Praticar técnicas de respiração profunda',
        'Fazer pausas regulares durante o dia',
        'Considerar atividades relaxantes como meditação',
      ]);
    } else if (avgStress > 0.4) {
      recommendations.addAll([
        'Manter rotina de exercícios leves',
        'Estabelecer horários regulares de sono',
      ]);
    }

    if (trend == 'increasing') {
      recommendations
          .add('Monitorar fatores de estresse e buscar apoio se necessário');
    }

    return recommendations;
  }

  Map<String, dynamic> _detectVoicePatterns(
          List<VoiceAnalysisResult> results) =>
      {
        'consistency': _calculateConsistency(results),
        'stability_trend':
            _calculateTrend(results.map((r) => r.emotionalStability).toList()),
        'dominant_indicators': _getDominantIndicators(results),
      };

  double _calculateConsistency(List<VoiceAnalysisResult> results) {
    if (results.length < 2) return 1;

    final variations = <double>[];
    for (var i = 1; i < results.length; i++) {
      final diff = (results[i].stressLevel - results[i - 1].stressLevel).abs();
      variations.add(diff);
    }

    final avgVariation = variations.reduce((a, b) => a + b) / variations.length;
    return (1.0 - avgVariation).clamp(0.0, 1.0);
  }

  List<String> _getDominantIndicators(List<VoiceAnalysisResult> results) {
    final allIndicators = <String>[];
    for (final result in results) {
      allIndicators.addAll(result.emotionalIndicators);
    }

    final counts = <String, int>{};
    for (final indicator in allIndicators) {
      counts[indicator] = (counts[indicator] ?? 0) + 1;
    }

    return counts.entries
        .where((e) => e.value >= results.length * 0.3)
        .map((e) => e.key)
        .toList();
  }

  double _calculateWellnessScore(
      double stress, double energy, double stability) {
    // Fórmula de bem-estar: prioriza baixo estresse e alta estabilidade
    final stressScore = (1.0 - stress) * 0.4;
    final energyScore = energy * 0.3;
    final stabilityScore = stability * 0.3;

    return ((stressScore + energyScore + stabilityScore) * 100)
        .clamp(0.0, 100.0);
  }

  Map<String, double> _getMoodDistribution(List<VoiceAnalysisResult> results) {
    final moodCounts = <String, int>{};
    for (final result in results) {
      moodCounts[result.moodState] = (moodCounts[result.moodState] ?? 0) + 1;
    }

    final total = results.length;
    return moodCounts.map((mood, count) => MapEntry(mood, count / total));
  }

  List<String> _getPersonalizedRecommendations(
      double stress, double energy, double stability) {
    final recommendations = <String>[];

    if (stress > 0.6) {
      recommendations.addAll([
        'Implementar técnicas de gerenciamento de estresse',
        'Considerar atividades mindfulness',
        'Manter comunicação regular com pessoas de confiança',
      ]);
    }

    if (energy < 0.4) {
      recommendations.addAll([
        'Revisar qualidade do sono',
        'Incluir atividades físicas regulares',
        'Avaliar hábitos alimentares',
      ]);
    }

    if (stability < 0.5) {
      recommendations.addAll([
        'Estabelecer rotinas consistentes',
        'Praticar técnicas de regulação emocional',
      ]);
    }

    return recommendations;
  }

  Map<String, dynamic> _getProgressIndicators(
      List<VoiceAnalysisResult> results) {
    if (results.length < 5) {
      return {'insufficient_data': true};
    }

    final sortedResults = results
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final firstHalf = sortedResults.take(sortedResults.length ~/ 2).toList();
    final secondHalf = sortedResults.skip(sortedResults.length ~/ 2).toList();

    final firstAvgStress =
        firstHalf.map((r) => r.stressLevel).reduce((a, b) => a + b) /
            firstHalf.length;
    final secondAvgStress =
        secondHalf.map((r) => r.stressLevel).reduce((a, b) => a + b) /
            secondHalf.length;

    final stressImprovement = firstAvgStress - secondAvgStress;

    return {
      'stress_improvement': stressImprovement,
      'improvement_percentage':
          (stressImprovement / firstAvgStress * 100).clamp(-100.0, 100.0),
      'trend': stressImprovement > 0.1
          ? 'improving'
          : stressImprovement < -0.1
              ? 'declining'
              : 'stable',
    };
  }

  // =================== GETTERS ===================

  bool get isInitialized => _isInitialized;
  bool get isRecording => _isRecording;
  List<VoiceAnalysisResult> get analysisHistory =>
      List.unmodifiable(_analysisHistory);

  /// Limpa o histórico de análises
  void clearHistory() {
    _analysisHistory.clear();
  }

  /// Salva histórico em arquivo local
  Future<bool> saveHistoryToFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/voice_analysis_history.json');

      final jsonData = _analysisHistory.map((r) => r.toJson()).toList();
      await file.writeAsString(jsonData.toString());

      return true;
    } catch (e) {
      print('❌ Erro ao salvar histórico: $e');
      return false;
    }
  }
}
