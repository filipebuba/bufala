import 'dart:typed_data';

/// Resultado da análise de voz para saúde mental
class VoiceAnalysisResult {

  VoiceAnalysisResult({
    required this.stressLevel,
    required this.energyLevel,
    required this.emotionalStability,
    required this.moodState,
    required this.confidence,
    required this.emotionalIndicators,
    required this.voiceFeatures,
    required this.timestamp,
  });

  factory VoiceAnalysisResult.fromJson(Map<String, dynamic> json) => VoiceAnalysisResult(
      stressLevel: ((json['stress_level'] ?? 0.0) as num).toDouble(),
      energyLevel: ((json['energy_level'] ?? 0.0) as num).toDouble(),
      emotionalStability:
          ((json['emotional_stability'] ?? 0.0) as num).toDouble(),
      moodState: (json['mood_state'] ?? 'neutral') as String,
      confidence: ((json['confidence'] ?? 0.0) as num).toDouble(),
      emotionalIndicators: List<String>.from(
          (json['emotional_indicators'] ?? <String>[]) as List<dynamic>),
      voiceFeatures: Map<String, double>.from((json['voice_features'] ??
          <String, double>{}) as Map<String, dynamic>),
      timestamp: DateTime.parse(
          (json['timestamp'] ?? DateTime.now().toIso8601String()) as String),
    );
  final double stressLevel;
  final double energyLevel;
  final double emotionalStability;
  final String moodState;
  final double confidence;
  final List<String> emotionalIndicators;
  final Map<String, double> voiceFeatures;
  final DateTime timestamp;

  Map<String, dynamic> toJson() => {
      'stress_level': stressLevel,
      'energy_level': energyLevel,
      'emotional_stability': emotionalStability,
      'mood_state': moodState,
      'confidence': confidence,
      'emotional_indicators': emotionalIndicators,
      'voice_features': voiceFeatures,
      'timestamp': timestamp.toIso8601String(),
    };
}

/// Dados de áudio para análise
class AudioData {

  AudioData({
    required this.audioBytes,
    required this.sampleRate,
    required this.duration,
    required this.format,
  });
  final Uint8List audioBytes;
  final int sampleRate;
  final int duration; // em milissegundos
  final String format;

  Map<String, dynamic> toJson() => {
      'audio_data': audioBytes.toString(),
      'sample_rate': sampleRate,
      'duration': duration,
      'format': format,
    };
}

/// Perfil de bem-estar do usuário
class WellnessProfile {

  WellnessProfile({
    required this.userId,
    required this.name,
    required this.age,
    required this.concerns,
    required this.goals,
    required this.baselineMetrics,
    required this.createdAt,
    required this.updatedAt,
  });

  factory WellnessProfile.fromJson(Map<String, dynamic> json) => WellnessProfile(
      userId: (json['user_id'] ?? '') as String,
      name: (json['name'] ?? '') as String,
      age: (json['age'] ?? 0) as int,
      concerns:
          List<String>.from((json['concerns'] ?? <String>[]) as List<dynamic>),
      goals: List<String>.from((json['goals'] ?? <String>[]) as List<dynamic>),
      baselineMetrics: Map<String, double>.from((json['baseline_metrics'] ??
          <String, double>{}) as Map<String, dynamic>),
      createdAt: DateTime.parse(
          (json['created_at'] ?? DateTime.now().toIso8601String()) as String),
      updatedAt: DateTime.parse(
          (json['updated_at'] ?? DateTime.now().toIso8601String()) as String),
    );
  final String userId;
  final String name;
  final int age;
  final List<String> concerns;
  final List<String> goals;
  final Map<String, double> baselineMetrics;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() => {
      'user_id': userId,
      'name': name,
      'age': age,
      'concerns': concerns,
      'goals': goals,
      'baseline_metrics': baselineMetrics,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
}

/// Sessão de coaching
class CoachingSession {

  CoachingSession({
    required this.sessionId,
    required this.userId,
    required this.type,
    required this.startTime,
    required this.sessionData, required this.recommendations, required this.progressScore, this.endTime,
  });

  factory CoachingSession.fromJson(Map<String, dynamic> json) => CoachingSession(
      sessionId: (json['session_id'] ?? '') as String,
      userId: (json['user_id'] ?? '') as String,
      type: (json['type'] ?? '') as String,
      startTime: DateTime.parse(
          (json['start_time'] ?? DateTime.now().toIso8601String()) as String),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      sessionData: Map<String, dynamic>.from((json['session_data'] ??
          <String, dynamic>{}) as Map<String, dynamic>),
      recommendations: List<String>.from(
          (json['recommendations'] ?? <String>[]) as List<dynamic>),
      progressScore: ((json['progress_score'] ?? 0.0) as num).toDouble(),
    );
  final String sessionId;
  final String userId;
  final String
      type; // 'breathing', 'meditation', 'voice_check', 'mood_tracking'
  final DateTime startTime;
  DateTime? endTime;
  final Map<String, dynamic> sessionData;
  final List<String> recommendations;
  double progressScore;

  Map<String, dynamic> toJson() => {
      'session_id': sessionId,
      'user_id': userId,
      'type': type,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'session_data': sessionData,
      'recommendations': recommendations,
      'progress_score': progressScore,
    };
}

/// Métricas diárias de bem-estar
class DailyWellnessMetrics {

  DailyWellnessMetrics({
    required this.date,
    required this.moodRating,
    required this.stressLevel,
    required this.energyLevel,
    required this.sleepHours,
    required this.activities,
    required this.notes,
    this.voiceAnalysis,
  });

  factory DailyWellnessMetrics.fromJson(Map<String, dynamic> json) => DailyWellnessMetrics(
      date: DateTime.parse(json['date'] as String),
      moodRating: ((json['mood_rating'] ?? 5.0) as num).toDouble(),
      stressLevel: ((json['stress_level'] ?? 0.5) as num).toDouble(),
      energyLevel: ((json['energy_level'] ?? 0.5) as num).toDouble(),
      sleepHours: (json['sleep_hours'] ?? 8) as int,
      activities: List<String>.from(
          (json['activities'] ?? <String>[]) as List<dynamic>),
      notes: (json['notes'] ?? '') as String,
      voiceAnalysis: json['voice_analysis'] != null
          ? VoiceAnalysisResult.fromJson(
              json['voice_analysis'] as Map<String, dynamic>)
          : null,
    );
  final DateTime date;
  final double moodRating; // 1-10
  final double stressLevel; // 0-1
  final double energyLevel; // 0-1
  final int sleepHours;
  final List<String> activities;
  final String notes;
  final VoiceAnalysisResult? voiceAnalysis;

  Map<String, dynamic> toJson() => {
      'date': date.toIso8601String(),
      'mood_rating': moodRating,
      'stress_level': stressLevel,
      'energy_level': energyLevel,
      'sleep_hours': sleepHours,
      'activities': activities,
      'notes': notes,
      'voice_analysis': voiceAnalysis?.toJson(),
    };
}
