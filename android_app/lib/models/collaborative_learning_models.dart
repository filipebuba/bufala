/// Modelos para o Sistema de Aprendizado Colaborativo - "Ensine o Bu Fala"
library;

/// Nível de dificuldade das frases
enum DifficultyLevel {
  basic,
  intermediate,
  advanced,
  expert,
}

/// Tipo de validação
enum ValidationType {
  translation,
  pronunciation,
  grammar,
  cultural,
}

/// Status de validação
enum ValidationStatus {
  pending,
  approved,
  rejected,
  needsReview,
}

/// Período de ranking
enum RankingPeriod {
  weekly,
  monthly,
  allTime,
}

/// Tipo de provocação
enum ProvocationType {
  curiosity,
  challenge,
  motivation,
  cultural,
}

/// Tipo de duelo
enum DuelType {
  translation,
  pronunciation,
  speed,
  accuracy,
}

/// Duelo entre usuários
class Duel {
  const Duel({
    required this.id,
    required this.challengerId,
    required this.challengerName,
    required this.type, required this.targetLanguage, required this.category, required this.createdDate, this.opponentId,
    this.opponentName,
    this.rounds = 5,
    this.currentRound = 0,
    this.scores = const {},
    this.completedDate,
    this.status = 'pending',
  });

  factory Duel.fromJson(Map<String, dynamic> json) => Duel(
      id: json['id'] as String? ?? '',
      challengerId: json['challenger_id'] as String? ?? '',
      challengerName: json['challenger_name'] as String? ?? '',
      opponentId: json['opponent_id'] as String?,
      opponentName: json['opponent_name'] as String?,
      type: DuelType.values.firstWhere(
        (t) => t.toString() == 'DuelType.${json['type']}',
        orElse: () => DuelType.translation,
      ),
      targetLanguage: json['target_language'] as String? ?? '',
      category: json['category'] as String? ?? '',
      rounds: json['rounds'] as int? ?? 5,
      currentRound: json['current_round'] as int? ?? 0,
      scores: json['scores'] as Map<String, dynamic>? ?? {},
      createdDate: DateTime.tryParse(json['created_date'] as String? ?? '') ??
          DateTime.now(),
      completedDate: json['completed_date'] != null
          ? DateTime.tryParse(json['completed_date'])
          : null,
      status: json['status'] as String? ?? 'pending',
    );
  final String id;
  final String challengerId;
  final String challengerName;
  final String? opponentId;
  final String? opponentName;
  final DuelType type;
  final String targetLanguage;
  final String category;
  final int rounds;
  final int currentRound;
  final Map<String, dynamic> scores;
  final DateTime createdDate;
  final DateTime? completedDate;
  final String status;

  Map<String, dynamic> toJson() => {
        'id': id,
        'challenger_id': challengerId,
        'challenger_name': challengerName,
        'opponent_id': opponentId,
        'opponent_name': opponentName,
        'type': type.toString().split('.').last,
        'target_language': targetLanguage,
        'category': category,
        'rounds': rounds,
        'current_round': currentRound,
        'scores': scores,
        'created_date': createdDate.toIso8601String(),
        'completed_date': completedDate?.toIso8601String(),
        'status': status,
      };
}

/// Usuário Professor no sistema colaborativo
class TeacherProfile {
  const TeacherProfile({
    required this.id,
    required this.name,
    required this.points,
    required this.level,
    required this.languagesTeaching,
    required this.specializations,
    required this.accuracyRate,
    required this.totalPhrasesTaught,
    required this.badges,
    required this.joinedDate,
    this.profileImageUrl = '',
  });

  factory TeacherProfile.fromJson(Map<String, dynamic> json) => TeacherProfile(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      points: json['points'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      languagesTeaching: (json['languages_taught'] as List?)?.cast<String>() ??
          [], // CORRIGIDO: era languages_teaching
      specializations: (json['specializations'] as Map<String, dynamic>?)
              ?.cast<String, int>() ??
          {},
      accuracyRate: (json['accuracy_rate'] as num?)?.toDouble() ?? 0.0,
      totalPhrasesTaught: json['total_teachings'] as int? ??
          0, // CORRIGIDO: era total_phrases_taught
      badges: (json['badges'] as List?)
              ?.map((b) => Badge.fromJson(b as Map<String, dynamic>))
              .toList() ??
          [],
      joinedDate: DateTime.tryParse(json['created_at'] as String? ??
              '') ?? // CORRIGIDO: era joined_date
          DateTime.now(),
      profileImageUrl: json['profile_image_url'] as String? ?? '',
    );
  final String id;
  final String name;
  final int points;
  final int level;
  final List<String> languagesTeaching;
  final Map<String, int>
      specializations; // especialidade -> quantidade ensinada
  final double accuracyRate;
  final int totalPhrasesTaught;
  final List<Badge> badges;
  final DateTime joinedDate;
  final String profileImageUrl;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'points': points,
        'level': level,
        'languages_teaching': languagesTeaching,
        'specializations': specializations,
        'accuracy_rate': accuracyRate,
        'total_phrases_taught': totalPhrasesTaught,
        'badges': badges.map((b) => b.toJson()).toList(),
        'joined_date': joinedDate.toIso8601String(),
        'profile_image_url': profileImageUrl,
      };
}

/// Badge/Conquista do usuário
class Badge {
  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.category,
    required this.earnedDate,
    this.metadata = const {},
  });

  factory Badge.fromJson(Map<String, dynamic> json) => Badge(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      iconUrl: json['icon_url'] as String? ?? '',
      category: json['category'] as String? ?? '',
      earnedDate: DateTime.tryParse(json['earned_date'] as String? ?? '') ??
          DateTime.now(),
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final String category; // 'first_teacher', 'polyglot', 'medical_expert', etc.
  final DateTime earnedDate;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'icon_url': iconUrl,
        'category': category,
        'earned_date': earnedDate.toIso8601String(),
        'metadata': metadata,
      };
}

/// Frase para ser ensinada pelo usuário
class TeachingPhrase {
  const TeachingPhrase({
    required this.id,
    required this.sourceText,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.category,
    this.context = '',
    this.priority = 1,
    this.isRequired = false,
  });

  factory TeachingPhrase.fromJson(Map<String, dynamic> json) => TeachingPhrase(
      id: json['id'] as String? ?? '',
      sourceText: json['source_text'] as String? ?? '',
      sourceLanguage: json['source_language'] as String? ?? '',
      targetLanguage: json['target_language'] as String? ?? '',
      category: json['category'] as String? ?? '',
      context: json['context'] as String? ?? '',
      priority: json['priority'] as int? ?? 1,
      isRequired: json['is_required'] as bool? ?? false,
    );
  final String id;
  final String sourceText;
  final String sourceLanguage;
  final String targetLanguage;
  final String category; // 'medical', 'agriculture', 'daily', etc.
  final String context;
  final int priority;
  final bool isRequired;

  Map<String, dynamic> toJson() => {
        'id': id,
        'source_text': sourceText,
        'source_language': sourceLanguage,
        'target_language': targetLanguage,
        'category': category,
        'context': context,
        'priority': priority,
        'is_required': isRequired,
      };
}

/// Tradução ensinada por um usuário
class UserTranslation {
  const UserTranslation({
    required this.id,
    required this.phraseId,
    required this.teacherId,
    required this.teacherName,
    required this.translatedText,
    required this.createdDate, required this.status, required this.validations, this.audioUrl = '',
    this.pronunciationGuide = '',
    this.confidenceScore = 0.0,
    this.metadata = const {},
  });

  factory UserTranslation.fromJson(Map<String, dynamic> json) => UserTranslation(
      id: json['id'] as String? ?? '',
      phraseId: json['phrase_id'] as String? ?? '',
      teacherId: json['teacher_id'] as String? ?? '',
      teacherName: json['teacher_name'] as String? ?? '',
      translatedText: json['translated_text'] as String? ?? '',
      audioUrl: json['audio_url'] as String? ?? '',
      pronunciationGuide: json['pronunciation_guide'] as String? ?? '',
      createdDate: DateTime.tryParse(json['created_date'] as String? ?? '') ??
          DateTime.now(),
      status: TranslationStatus.values.firstWhere(
        (s) => s.toString() == 'TranslationStatus.${json['status']}',
        orElse: () => TranslationStatus.pending,
      ),
      validations: (json['validations'] as List?)
              ?.map((v) => Validation.fromJson(v as Map<String, dynamic>))
              .toList() ??
          [],
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.0,
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  final String id;
  final String phraseId;
  final String teacherId;
  final String teacherName;
  final String translatedText;
  final String audioUrl;
  final String pronunciationGuide;
  final DateTime createdDate;
  final TranslationStatus status;
  final List<Validation> validations;
  final double confidenceScore;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() => {
        'id': id,
        'phrase_id': phraseId,
        'teacher_id': teacherId,
        'teacher_name': teacherName,
        'translated_text': translatedText,
        'audio_url': audioUrl,
        'pronunciation_guide': pronunciationGuide,
        'created_date': createdDate.toIso8601String(),
        'status': status.toString().split('.').last,
        'validations': validations.map((v) => v.toJson()).toList(),
        'confidence_score': confidenceScore,
        'metadata': metadata,
      };
}

/// Status da tradução no processo de validação
enum TranslationStatus {
  pending, // Aguardando validação
  approved, // Aprovada por consenso
  rejected, // Rejeitada por consenso
  disputed, // Em disputa (opiniões divididas)
  archived, // Arquivada
}

/// Validação de uma tradução por outros usuários
class Validation {
  const Validation({
    required this.id,
    required this.translationId,
    required this.validatorId,
    required this.validatorName,
    required this.isCorrect,
    required this.validatedDate, this.comment = '',
    this.validatorLevel = 1,
    this.validatorLanguageExpertise = '',
  });

  factory Validation.fromJson(Map<String, dynamic> json) => Validation(
      id: json['id'] as String? ?? '',
      translationId: json['translation_id'] as String? ?? '',
      validatorId: json['validator_id'] as String? ?? '',
      validatorName: json['validator_name'] as String? ?? '',
      isCorrect: json['is_correct'] as bool? ?? false,
      comment: json['comment'] as String? ?? '',
      validatedDate:
          DateTime.tryParse(json['validated_date'] as String? ?? '') ??
              DateTime.now(),
      validatorLevel: json['validator_level'] as int? ?? 1,
      validatorLanguageExpertise:
          json['validator_language_expertise'] as String? ?? '',
    );
  final String id;
  final String translationId;
  final String validatorId;
  final String validatorName;
  final bool isCorrect;
  final String comment;
  final DateTime validatedDate;
  final int validatorLevel;
  final String validatorLanguageExpertise;

  Map<String, dynamic> toJson() => {
        'id': id,
        'translation_id': translationId,
        'validator_id': validatorId,
        'validator_name': validatorName,
        'is_correct': isCorrect,
        'comment': comment,
        'validated_date': validatedDate.toIso8601String(),
        'validator_level': validatorLevel,
        'validator_language_expertise': validatorLanguageExpertise,
      };
}

/// Ranking de professores
class TeacherRanking {
  const TeacherRanking({
    required this.weeklyTop,
    required this.monthlyTop,
    required this.allTimeTop,
    required this.lastUpdated,
  });

  factory TeacherRanking.fromJson(Map<String, dynamic> json) => TeacherRanking(
      weeklyTop: (json['weekly_top'] as List?)
              ?.map((t) => TeacherProfile.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      monthlyTop: (json['monthly_top'] as List?)
              ?.map((t) => TeacherProfile.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      allTimeTop: (json['all_time_top'] as List?)
              ?.map((t) => TeacherProfile.fromJson(t as Map<String, dynamic>))
              .toList() ??
          [],
      lastUpdated: DateTime.tryParse(json['last_updated'] as String? ?? '') ??
          DateTime.now(),
    );
  final List<TeacherProfile> weeklyTop;
  final List<TeacherProfile> monthlyTop;
  final List<TeacherProfile> allTimeTop;
  final DateTime lastUpdated;

  Map<String, dynamic> toJson() => {
        'weekly_top': weeklyTop.map((t) => t.toJson()).toList(),
        'monthly_top': monthlyTop.map((t) => t.toJson()).toList(),
        'all_time_top': allTimeTop.map((t) => t.toJson()).toList(),
        'last_updated': lastUpdated.toIso8601String(),
      };
}

/// Estatísticas de aprendizado colaborativo
class LearningStats {
  const LearningStats({
    required this.totalPhrases,
    required this.validatedPhrases,
    required this.activeTeachers,
    required this.languagesSupported,
    required this.phrasesByCategory,
    required this.phrasesByLanguage,
    required this.averageValidationTime,
  });

  factory LearningStats.fromJson(Map<String, dynamic> json) => LearningStats(
      totalPhrases: json['total_phrases'] as int? ?? 0,
      validatedPhrases: json['validated_phrases'] as int? ?? 0,
      activeTeachers: json['active_teachers'] as int? ?? 0,
      languagesSupported: json['languages_supported'] as int? ?? 0,
      phrasesByCategory: (json['phrases_by_category'] as Map<String, dynamic>?)
              ?.cast<String, int>() ??
          {},
      phrasesByLanguage: (json['phrases_by_language'] as Map<String, dynamic>?)
              ?.cast<String, int>() ??
          {},
      averageValidationTime:
          (json['average_validation_time'] as num?)?.toDouble() ?? 0.0,
    );
  final int totalPhrases;
  final int validatedPhrases;
  final int activeTeachers;
  final int languagesSupported;
  final Map<String, int> phrasesByCategory;
  final Map<String, int> phrasesByLanguage;
  final double averageValidationTime;

  Map<String, dynamic> toJson() => {
        'total_phrases': totalPhrases,
        'validated_phrases': validatedPhrases,
        'active_teachers': activeTeachers,
        'languages_supported': languagesSupported,
        'phrases_by_category': phrasesByCategory,
        'phrases_by_language': phrasesByLanguage,
        'average_validation_time': averageValidationTime,
      };
}
