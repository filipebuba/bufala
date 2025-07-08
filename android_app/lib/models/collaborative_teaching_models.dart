/// Modelos de dados para o sistema de ensino colaborativo
/// "Ensine o Bu Fala" - Usuários ensinando idiomas ao app
library;

/// Idioma que pode ser ensinado na plataforma
class TeachableLanguage {

  const TeachableLanguage({
    required this.id,
    required this.name,
    required this.nativeName,
    required this.region,
    this.totalPhrases = 0,
    this.activeProfessors = 0,
    this.specialties = const [],
    this.completionPercentage = 0.0,
  });

  factory TeachableLanguage.fromJson(Map<String, dynamic> json) => TeachableLanguage(
      id: json['id'] as String,
      name: json['name'] as String,
      nativeName: json['native_name'] as String,
      region: json['region'] as String,
      totalPhrases: json['total_phrases'] as int? ?? 0,
      activeProfessors: json['active_professors'] as int? ?? 0,
      specialties: List<String>.from(json['specialties'] as List? ?? []),
      completionPercentage:
          (json['completion_percentage'] as num?)?.toDouble() ?? 0.0,
    );
  final String id;
  final String name;
  final String nativeName;
  final String region;
  final int totalPhrases;
  final int activeProfessors;
  final List<String> specialties; // 'medical', 'agriculture', 'daily', etc.
  final double completionPercentage;

  Map<String, dynamic> toJson() => {
      'id': id,
      'name': name,
      'native_name': nativeName,
      'region': region,
      'total_phrases': totalPhrases,
      'active_professors': activeProfessors,
      'specialties': specialties,
      'completion_percentage': completionPercentage,
    };
}

/// Perfil de professor/usuário que ensina idiomas
class LanguageProfessor { // 'medical': 150, 'agriculture': 200

  const LanguageProfessor({
    required this.id,
    required this.name,
    required this.joinDate, required this.lastActive, this.avatarUrl,
    this.totalPoints = 0,
    this.level = 1,
    this.languagesTeaching = const [],
    this.badges = const [],
    this.accuracyRate = 0.0,
    this.specialtyPoints = const {},
  });

  factory LanguageProfessor.fromJson(Map<String, dynamic> json) => LanguageProfessor(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      totalPoints: json['total_points'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      languagesTeaching: (json['languages_teaching'] as List?)
              ?.map(
                  (e) => ProfessorLanguage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      badges: List<String>.from(json['badges'] as List? ?? []),
      accuracyRate: (json['accuracy_rate'] as num?)?.toDouble() ?? 0.0,
      joinDate: DateTime.parse(json['join_date'] as String),
      lastActive: DateTime.parse(json['last_active'] as String),
      specialtyPoints:
          Map<String, int>.from(json['specialty_points'] as Map? ?? {}),
    );
  final String id;
  final String name;
  final String? avatarUrl;
  final int totalPoints;
  final int level;
  final List<ProfessorLanguage> languagesTeaching;
  final List<String> badges;
  final double accuracyRate;
  final DateTime joinDate;
  final DateTime lastActive;
  final Map<String, int> specialtyPoints;

  Map<String, dynamic> toJson() => {
      'id': id,
      'name': name,
      'avatar_url': avatarUrl,
      'total_points': totalPoints,
      'level': level,
      'languages_teaching': languagesTeaching.map((e) => e.toJson()).toList(),
      'badges': badges,
      'accuracy_rate': accuracyRate,
      'join_date': joinDate.toIso8601String(),
      'last_active': lastActive.toIso8601String(),
      'specialty_points': specialtyPoints,
    };

  /// Calcula o nível baseado nos pontos
  static int calculateLevel(int points) {
    if (points < 100) return 1;
    if (points < 500) return 2;
    if (points < 1000) return 3;
    if (points < 2500) return 4;
    if (points < 5000) return 5;
    if (points < 10000) return 6;
    return 7; // Mestre
  }

  /// Nome do nível baseado na pontuação
  String get levelName {
    switch (level) {
      case 1:
        return 'Iniciante';
      case 2:
        return 'Aprendiz';
      case 3:
        return 'Professor';
      case 4:
        return 'Especialista';
      case 5:
        return 'Expert';
      case 6:
        return 'Mestre';
      case 7:
        return 'Lenda';
      default:
        return 'Professor';
    }
  }
}

/// Idioma que um professor ensina
class ProfessorLanguage {

  const ProfessorLanguage({
    required this.languageId,
    required this.languageName,
    required this.startDate, this.phrasesContributed = 0,
    this.rating = 0,
    this.specialties = const [],
  });

  factory ProfessorLanguage.fromJson(Map<String, dynamic> json) => ProfessorLanguage(
      languageId: json['language_id'] as String,
      languageName: json['language_name'] as String,
      phrasesContributed: json['phrases_contributed'] as int? ?? 0,
      rating: json['rating'] as int? ?? 0,
      specialties: List<String>.from(json['specialties'] as List? ?? []),
      startDate: DateTime.parse(json['start_date'] as String),
    );
  final String languageId;
  final String languageName;
  final int phrasesContributed;
  final int rating; // 1-5 estrelas
  final List<String> specialties;
  final DateTime startDate;

  Map<String, dynamic> toJson() => {
      'language_id': languageId,
      'language_name': languageName,
      'phrases_contributed': phrasesContributed,
      'rating': rating,
      'specialties': specialties,
      'start_date': startDate.toIso8601String(),
    };
}

/// Frase/tradução ensinada por um usuário
class TeachingContribution { // Contexto adicional

  const TeachingContribution({
    required this.id,
    required this.sourceLanguage,
    required this.targetLanguage,
    required this.sourceText,
    required this.targetText,
    required this.professorId, required this.professorName, required this.category, required this.createdAt, this.audioUrl,
    this.status = ContributionStatus.pending,
    this.validationVotes = const [],
    this.confidenceScore = 0.0,
    this.metadata,
  });

  factory TeachingContribution.fromJson(Map<String, dynamic> json) => TeachingContribution(
      id: json['id'] as String,
      sourceLanguage: json['source_language'] as String,
      targetLanguage: json['target_language'] as String,
      sourceText: json['source_text'] as String,
      targetText: json['target_text'] as String,
      audioUrl: json['audio_url'] as String?,
      professorId: json['professor_id'] as String,
      professorName: json['professor_name'] as String,
      category: json['category'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      status: ContributionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ContributionStatus.pending,
      ),
      validationVotes: (json['validation_votes'] as List?)
              ?.map((e) => ValidationVote.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.0,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  final String id;
  final String sourceLanguage;
  final String targetLanguage;
  final String sourceText;
  final String targetText;
  final String? audioUrl;
  final String professorId;
  final String professorName;
  final String category; // 'medical', 'agriculture', 'daily', 'greetings'
  final DateTime createdAt;
  final ContributionStatus status;
  final List<ValidationVote> validationVotes;
  final double confidenceScore;
  final Map<String, dynamic>? metadata;

  Map<String, dynamic> toJson() => {
      'id': id,
      'source_language': sourceLanguage,
      'target_language': targetLanguage,
      'source_text': sourceText,
      'target_text': targetText,
      'audio_url': audioUrl,
      'professor_id': professorId,
      'professor_name': professorName,
      'category': category,
      'created_at': createdAt.toIso8601String(),
      'status': status.name,
      'validation_votes': validationVotes.map((e) => e.toJson()).toList(),
      'confidence_score': confidenceScore,
      'metadata': metadata,
    };

  /// Verifica se a contribuição foi validada positivamente
  bool get isValidated {
    final positiveVotes = validationVotes.where((v) => v.isPositive).length;
    final totalVotes = validationVotes.length;
    return totalVotes >= 3 && positiveVotes >= (totalVotes * 0.7);
  }

  /// Número de votos positivos
  int get positiveVotes => validationVotes.where((v) => v.isPositive).length;

  /// Número de votos negativos
  int get negativeVotes => validationVotes.where((v) => !v.isPositive).length;
}

/// Status de uma contribuição
enum ContributionStatus {
  pending, // Aguardando validação
  validated, // Validada pela comunidade
  rejected, // Rejeitada
  reviewing, // Em revisão
}

/// Voto de validação de uma contribuição
class ValidationVote {

  const ValidationVote({
    required this.id,
    required this.contributionId,
    required this.validatorId,
    required this.validatorName,
    required this.isPositive,
    required this.createdAt, this.comment,
  });

  factory ValidationVote.fromJson(Map<String, dynamic> json) => ValidationVote(
      id: json['id'] as String,
      contributionId: json['contribution_id'] as String,
      validatorId: json['validator_id'] as String,
      validatorName: json['validator_name'] as String,
      isPositive: json['is_positive'] as bool,
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  final String id;
  final String contributionId;
  final String validatorId;
  final String validatorName;
  final bool isPositive;
  final String? comment;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
      'id': id,
      'contribution_id': contributionId,
      'validator_id': validatorId,
      'validator_name': validatorName,
      'is_positive': isPositive,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
}

/// Categoria de ensino com frases sugeridas
class TeachingCategory {

  const TeachingCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.suggestedPhrases = const [],
    this.priority = 0,
    this.color = '#2196F3',
  });

  factory TeachingCategory.fromJson(Map<String, dynamic> json) => TeachingCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      suggestedPhrases:
          List<String>.from(json['suggested_phrases'] as List? ?? []),
      priority: json['priority'] as int? ?? 0,
      color: json['color'] as String? ?? '#2196F3',
    );
  final String id;
  final String name;
  final String description;
  final String icon;
  final List<String> suggestedPhrases;
  final int priority;
  final String color;

  Map<String, dynamic> toJson() => {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'suggested_phrases': suggestedPhrases,
      'priority': priority,
      'color': color,
    };

  /// Categorias pré-definidas
  static List<TeachingCategory> get defaultCategories => [
        const TeachingCategory(
          id: 'greetings',
          name: 'Cumprimentos',
          description: 'Saudações básicas do dia a dia',
          icon: '👋',
          suggestedPhrases: [
            'Olá',
            'Bom dia',
            'Boa tarde',
            'Boa noite',
            'Como está?',
            'Tudo bem?',
            'Até logo',
            'Tchau',
          ],
          priority: 1,
          color: '#4CAF50',
        ),
        const TeachingCategory(
          id: 'medical',
          name: 'Saúde',
          description: 'Termos médicos e de saúde',
          icon: '🏥',
          suggestedPhrases: [
            'Preciso ir ao médico',
            'Estou com dor',
            'Onde fica o hospital?',
            'Tenho febre',
            'Preciso de remédio',
            'Estou doente',
            'Socorro',
            'Emergência',
          ],
          priority: 2,
          color: '#F44336',
        ),
        const TeachingCategory(
          id: 'agriculture',
          name: 'Agricultura',
          description: 'Termos agrícolas e rurais',
          icon: '🌱',
          suggestedPhrases: [
            'Plantar arroz',
            'Época de chuva',
            'Colheita',
            'Sementes',
            'Terra boa',
            'Água para plantas',
            'Ferramentas',
            'Mercado',
          ],
          priority: 3,
          color: '#8BC34A',
        ),
        const TeachingCategory(
          id: 'daily',
          name: 'Cotidiano',
          description: 'Frases do dia a dia',
          icon: '🏠',
          suggestedPhrases: [
            'Minha casa',
            'Família',
            'Comida',
            'Água',
            'Trabalho',
            'Dinheiro',
            'Transporte',
            'Escola',
          ],
          priority: 4,
        ),
        const TeachingCategory(
          id: 'numbers',
          name: 'Números',
          description: 'Números e quantidades',
          icon: '🔢',
          suggestedPhrases: [
            'Um',
            'Dois',
            'Três',
            'Dez',
            'Cem',
            'Muito',
            'Pouco',
            'Nada',
          ],
          priority: 5,
          color: '#9C27B0',
        ),
      ];
}

/// Badge/conquista do sistema de gamificação
class TeachingBadge {

  const TeachingBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    this.color = '#FFD700',
    this.pointsRequired = 0,
    this.requirements = const {},
    this.isUnlocked = false,
    this.unlockedAt,
  });

  factory TeachingBadge.fromJson(Map<String, dynamic> json) => TeachingBadge(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String? ?? '#FFD700',
      pointsRequired: json['points_required'] as int? ?? 0,
      requirements:
          Map<String, dynamic>.from(json['requirements'] as Map? ?? {}),
      isUnlocked: json['is_unlocked'] as bool? ?? false,
      unlockedAt: json['unlocked_at'] != null
          ? DateTime.parse(json['unlocked_at'] as String)
          : null,
    );
  final String id;
  final String name;
  final String description;
  final String icon;
  final String color;
  final int pointsRequired;
  final Map<String, dynamic> requirements;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  Map<String, dynamic> toJson() => {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'color': color,
      'points_required': pointsRequired,
      'requirements': requirements,
      'is_unlocked': isUnlocked,
      'unlocked_at': unlockedAt?.toIso8601String(),
    };

  /// Badges pré-definidas
  static List<TeachingBadge> get defaultBadges => [
        const TeachingBadge(
          id: 'first_teacher',
          name: 'Primeiro Professor',
          description: 'Primeira pessoa a ensinar uma nova língua',
          icon: '🥇',
          pointsRequired: 10,
        ),
        const TeachingBadge(
          id: 'polyglot',
          name: 'Poliglota',
          description: 'Ensina 3 ou mais línguas diferentes',
          icon: '🌍',
          color: '#4CAF50',
          pointsRequired: 150,
          requirements: {'languages_count': 3},
        ),
        const TeachingBadge(
          id: 'medical_expert',
          name: 'Especialista Médico',
          description: 'Ensinou 50+ termos de saúde',
          icon: '🩺',
          color: '#F44336',
          pointsRequired: 500,
          requirements: {'medical_phrases': 50},
        ),
        const TeachingBadge(
          id: 'agriculture_guru',
          name: 'Guru da Agricultura',
          description: 'Ensinou 50+ termos agrícolas',
          icon: '🚜',
          color: '#8BC34A',
          pointsRequired: 500,
          requirements: {'agriculture_phrases': 50},
        ),
        const TeachingBadge(
          id: 'community_validator',
          name: 'Validador da Comunidade',
          description: 'Validou 100+ traduções de outros usuários',
          icon: '✅',
          color: '#2196F3',
          pointsRequired: 500,
          requirements: {'validations_count': 100},
        ),
        const TeachingBadge(
          id: 'legend',
          name: 'Lenda Viva',
          description: 'Contribuiu com mais de 500 frases',
          icon: '👑',
          color: '#9C27B0',
          pointsRequired: 5000,
          requirements: {'total_phrases': 500},
        ),
      ];
}

/// Estatísticas de ensino do usuário
class TeachingStats {

  const TeachingStats({
    this.totalContributions = 0,
    this.validatedContributions = 0,
    this.pendingContributions = 0,
    this.rejectedContributions = 0,
    this.totalValidations = 0,
    this.accuracyRate = 0.0,
    this.contributionsByCategory = const {},
    this.contributionsByLanguage = const {},
    this.unlockedBadges = const [],
    this.currentStreak = 0,
    this.longestStreak = 0,
  });

  factory TeachingStats.fromJson(Map<String, dynamic> json) => TeachingStats(
      totalContributions: json['total_contributions'] as int? ?? 0,
      validatedContributions: json['validated_contributions'] as int? ?? 0,
      pendingContributions: json['pending_contributions'] as int? ?? 0,
      rejectedContributions: json['rejected_contributions'] as int? ?? 0,
      totalValidations: json['total_validations'] as int? ?? 0,
      accuracyRate: (json['accuracy_rate'] as num?)?.toDouble() ?? 0.0,
      contributionsByCategory: Map<String, int>.from(
          json['contributions_by_category'] as Map? ?? {}),
      contributionsByLanguage: Map<String, int>.from(
          json['contributions_by_language'] as Map? ?? {}),
      unlockedBadges: (json['unlocked_badges'] as List?)
              ?.map((e) => TeachingBadge.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      currentStreak: json['current_streak'] as int? ?? 0,
      longestStreak: json['longest_streak'] as int? ?? 0,
    );
  final int totalContributions;
  final int validatedContributions;
  final int pendingContributions;
  final int rejectedContributions;
  final int totalValidations;
  final double accuracyRate;
  final Map<String, int> contributionsByCategory;
  final Map<String, int> contributionsByLanguage;
  final List<TeachingBadge> unlockedBadges;
  final int currentStreak; // Dias consecutivos ensinando
  final int longestStreak;

  Map<String, dynamic> toJson() => {
      'total_contributions': totalContributions,
      'validated_contributions': validatedContributions,
      'pending_contributions': pendingContributions,
      'rejected_contributions': rejectedContributions,
      'total_validations': totalValidations,
      'accuracy_rate': accuracyRate,
      'contributions_by_category': contributionsByCategory,
      'contributions_by_language': contributionsByLanguage,
      'unlocked_badges': unlockedBadges.map((e) => e.toJson()).toList(),
      'current_streak': currentStreak,
      'longest_streak': longestStreak,
    };
}
