/// Modelos para o Sistema Internacional "Bu Fala Professor para ONGs"
library;

/// Organização Internacional (MSF, UNICEF, etc.)
class InternationalOrganization {

  const InternationalOrganization({
    required this.id,
    required this.name,
    required this.type,
    required this.logoUrl,
    required this.languagesNeeded,
    required this.priorityModules,
    required this.urgencyLevel,
    required this.learningPace,
    this.settings = const {},
  });

  factory InternationalOrganization.fromJson(Map<String, dynamic> json) => InternationalOrganization(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      logoUrl: json['logo_url'] as String? ?? '',
      languagesNeeded: (json['languages_needed'] as List?)?.cast<String>() ?? [],
      priorityModules: (json['priority_modules'] as List?)?.cast<String>() ?? [],
      urgencyLevel: json['urgency_level'] as String? ?? 'medium',
      learningPace: json['learning_pace'] as String? ?? 'normal',
      settings: json['settings'] as Map<String, dynamic>? ?? {},
    );
  final String id;
  final String name;
  final String type; // 'medical', 'education', 'development', etc.
  final String logoUrl;
  final List<String> languagesNeeded;
  final List<String> priorityModules;
  final String urgencyLevel; // 'low', 'medium', 'high', 'critical'
  final String learningPace; // 'slow', 'normal', 'fast', 'intensive'
  final Map<String, dynamic> settings;

  Map<String, dynamic> toJson() => {
      'id': id,
      'name': name,
      'type': type,
      'logo_url': logoUrl,
      'languages_needed': languagesNeeded,
      'priority_modules': priorityModules,
      'urgency_level': urgencyLevel,
      'learning_pace': learningPace,
      'settings': settings,
    };
}

/// Profissional Internacional (médico, engenheiro, professor, etc.)
class InternationalProfessional {

  const InternationalProfessional({
    required this.id,
    required this.name,
    required this.email,
    required this.profession,
    required this.nativeLanguage,
    required this.spokenLanguages,
    required this.organizationId,
    required this.organizationName,
    required this.assignmentLocation,
    required this.arrivalDate,
    required this.targetLanguages, required this.proficiencyLevels, required this.completedModules, this.departureDate,
    this.learningPreferences = const {},
    this.avatarUrl = '',
  });

  factory InternationalProfessional.fromJson(Map<String, dynamic> json) => InternationalProfessional(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profession: json['profession'] as String? ?? '',
      nativeLanguage: json['native_language'] as String? ?? '',
      spokenLanguages: (json['spoken_languages'] as List?)?.cast<String>() ?? [],
      organizationId: json['organization_id'] as String? ?? '',
      organizationName: json['organization_name'] as String? ?? '',
      assignmentLocation: json['assignment_location'] as String? ?? '',
      arrivalDate: DateTime.tryParse(json['arrival_date'] as String? ?? '') ?? DateTime.now(),
      departureDate: json['departure_date'] != null 
          ? DateTime.tryParse(json['departure_date'] as String) 
          : null,
      targetLanguages: (json['target_languages'] as List?)?.cast<String>() ?? [],
      proficiencyLevels: (json['proficiency_levels'] as Map<String, dynamic>?)?.cast<String, int>() ?? {},
      completedModules: (json['completed_modules'] as List?)?.cast<String>() ?? [],
      learningPreferences: json['learning_preferences'] as Map<String, dynamic>? ?? {},
      avatarUrl: json['avatar_url'] as String? ?? '',
    );
  final String id;
  final String name;
  final String email;
  final String profession; // 'doctor', 'engineer', 'teacher', 'diplomat', etc.
  final String nativeLanguage;
  final List<String> spokenLanguages;
  final String organizationId;
  final String organizationName;
  final String assignmentLocation; // região da Guiné-Bissau
  final DateTime arrivalDate;
  final DateTime? departureDate;
  final List<String> targetLanguages; // idiomas que precisa aprender
  final Map<String, int> proficiencyLevels; // idioma -> nível (0-5)
  final List<String> completedModules;
  final Map<String, dynamic> learningPreferences;
  final String avatarUrl;

  Map<String, dynamic> toJson() => {
      'id': id,
      'name': name,
      'email': email,
      'profession': profession,
      'native_language': nativeLanguage,
      'spoken_languages': spokenLanguages,
      'organization_id': organizationId,
      'organization_name': organizationName,
      'assignment_location': assignmentLocation,
      'arrival_date': arrivalDate.toIso8601String(),
      'departure_date': departureDate?.toIso8601String(),
      'target_languages': targetLanguages,
      'proficiency_levels': proficiencyLevels,
      'completed_modules': completedModules,
      'learning_preferences': learningPreferences,
      'avatar_url': avatarUrl,
    };
}

/// Módulo Especializado de Ensino
class SpecializedModule {

  const SpecializedModule({
    required this.id,
    required this.name,
    required this.description,
    required this.profession,
    required this.targetLanguage,
    required this.difficultyLevel,
    required this.estimatedDuration,
    required this.lessons,
    required this.prerequisites,
    this.iconUrl = '',
    this.metadata = const {},
  });

  factory SpecializedModule.fromJson(Map<String, dynamic> json) => SpecializedModule(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      profession: json['profession'] as String? ?? '',
      targetLanguage: json['target_language'] as String? ?? '',
      difficultyLevel: json['difficulty_level'] as String? ?? '',
      estimatedDuration: Duration(
        minutes: json['estimated_duration_minutes'] as int? ?? 60,
      ),
      lessons: (json['lessons'] as List?)
              ?.map((l) => Lesson.fromJson(l as Map<String, dynamic>))
              .toList() ??
          [],
      prerequisites: (json['prerequisites'] as List?)?.cast<String>() ?? [],
      iconUrl: json['icon_url'] as String? ?? '',
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  final String id;
  final String name;
  final String description;
  final String profession; // 'medical', 'education', 'engineering', etc.
  final String targetLanguage;
  final String difficultyLevel; // 'emergency', 'basic', 'intermediate', 'advanced'
  final Duration estimatedDuration;
  final List<Lesson> lessons;
  final List<String> prerequisites;
  final String iconUrl;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() => {
      'id': id,
      'name': name,
      'description': description,
      'profession': profession,
      'target_language': targetLanguage,
      'difficulty_level': difficultyLevel,
      'estimated_duration_minutes': estimatedDuration.inMinutes,
      'lessons': lessons.map((l) => l.toJson()).toList(),
      'prerequisites': prerequisites,
      'icon_url': iconUrl,
      'metadata': metadata,
    };
}

/// Lição Individual
class Lesson {

  const Lesson({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.items,
    required this.culturalContext,
    this.isCompleted = false,
    this.score,
    this.completedAt,
  });

  factory Lesson.fromJson(Map<String, dynamic> json) => Lesson(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      type: json['type'] as String? ?? '',
      items: (json['items'] as List?)
              ?.map((i) => LessonItem.fromJson(i as Map<String, dynamic>))
              .toList() ??
          [],
      culturalContext: (json['cultural_context'] as Map<String, dynamic>?)?.cast<String, String>() ?? {},
      isCompleted: json['is_completed'] as bool? ?? false,
      score: (json['score'] as num?)?.toDouble(),
      completedAt: json['completed_at'] != null 
          ? DateTime.tryParse(json['completed_at'] as String) 
          : null,
    );
  final String id;
  final String title;
  final String description;
  final String type; // 'vocabulary', 'conversation', 'simulation', 'emergency'
  final List<LessonItem> items;
  final Map<String, String> culturalContext;
  final bool isCompleted;
  final double? score;
  final DateTime? completedAt;

  Map<String, dynamic> toJson() => {
      'id': id,
      'title': title,
      'description': description,
      'type': type,
      'items': items.map((i) => i.toJson()).toList(),
      'cultural_context': culturalContext,
      'is_completed': isCompleted,
      'score': score,
      'completed_at': completedAt?.toIso8601String(),
    };
}

/// Item de Lição (frase, diálogo, etc.)
class LessonItem {

  const LessonItem({
    required this.id,
    required this.type,
    required this.sourceText,
    required this.targetText,
    required this.pronunciation,
    required this.context, required this.importance, this.audioUrl,
    this.metadata = const {},
  });

  factory LessonItem.fromJson(Map<String, dynamic> json) => LessonItem(
      id: json['id'] as String? ?? '',
      type: json['type'] as String? ?? '',
      sourceText: json['source_text'] as String? ?? '',
      targetText: json['target_text'] as String? ?? '',
      pronunciation: json['pronunciation'] as String? ?? '',
      audioUrl: json['audio_url'] as String?,
      context: json['context'] as String? ?? '',
      importance: json['importance'] as String? ?? 'useful',
      metadata: json['metadata'] as Map<String, dynamic>? ?? {},
    );
  final String id;
  final String type; // 'phrase', 'dialogue', 'exercise', 'simulation'
  final String sourceText; // texto no idioma de origem
  final String targetText; // texto no idioma alvo
  final String pronunciation; // guia de pronúncia
  final String? audioUrl;
  final String context; // contexto de uso
  final String importance; // 'critical', 'important', 'useful'
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() => {
      'id': id,
      'type': type,
      'source_text': sourceText,
      'target_text': targetText,
      'pronunciation': pronunciation,
      'audio_url': audioUrl,
      'context': context,
      'importance': importance,
      'metadata': metadata,
    };
}

/// Dashboard de Organização
class OrganizationDashboard {

  const OrganizationDashboard({
    required this.organizationId,
    required this.organizationName,
    required this.totalProfessionals,
    required this.activeProfessionals,
    required this.averageProgress,
    required this.completedModules,
    required this.professionals,
    required this.languageStats,
    required this.moduleStats,
    required this.alerts,
    required this.lastUpdated,
  });

  factory OrganizationDashboard.fromJson(Map<String, dynamic> json) => OrganizationDashboard(
      organizationId: json['organization_id'] as String? ?? '',
      organizationName: json['organization_name'] as String? ?? '',
      totalProfessionals: json['total_professionals'] as int? ?? 0,
      activeProfessionals: json['active_professionals'] as int? ?? 0,
      averageProgress: (json['average_progress'] as num?)?.toDouble() ?? 0.0,
      completedModules: json['completed_modules'] as int? ?? 0,
      professionals: (json['professionals'] as List?)
              ?.map((p) => ProfessionalProgress.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      languageStats: (json['language_stats'] as Map<String, dynamic>?)?.cast<String, int>() ?? {},
      moduleStats: (json['module_stats'] as Map<String, dynamic>?)?.cast<String, double>() ?? {},
      alerts: (json['alerts'] as List?)?.cast<String>() ?? [],
      lastUpdated: DateTime.tryParse(json['last_updated'] as String? ?? '') ?? DateTime.now(),
    );
  final String organizationId;
  final String organizationName;
  final int totalProfessionals;
  final int activeProfessionals;
  final double averageProgress;
  final int completedModules;
  final List<ProfessionalProgress> professionals;
  final Map<String, int> languageStats;
  final Map<String, double> moduleStats;
  final List<String> alerts;
  final DateTime lastUpdated;

  Map<String, dynamic> toJson() => {
      'organization_id': organizationId,
      'organization_name': organizationName,
      'total_professionals': totalProfessionals,
      'active_professionals': activeProfessionals,
      'average_progress': averageProgress,
      'completed_modules': completedModules,
      'professionals': professionals.map((p) => p.toJson()).toList(),
      'language_stats': languageStats,
      'module_stats': moduleStats,
      'alerts': alerts,
      'last_updated': lastUpdated.toIso8601String(),
    };
}

/// Progresso de Profissional
class ProfessionalProgress {

  const ProfessionalProgress({
    required this.professionalId,
    required this.name,
    required this.profession,
    required this.languageProgress,
    required this.completedModules,
    required this.currentModule,
    required this.overallProgress,
    required this.status,
    required this.lastActivity,
  });

  factory ProfessionalProgress.fromJson(Map<String, dynamic> json) => ProfessionalProgress(
      professionalId: json['professional_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      profession: json['profession'] as String? ?? '',
      languageProgress: (json['language_progress'] as Map<String, dynamic>?)?.cast<String, double>() ?? {},
      completedModules: (json['completed_modules'] as List?)?.cast<String>() ?? [],
      currentModule: json['current_module'] as String? ?? '',
      overallProgress: (json['overall_progress'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] as String? ?? 'active',
      lastActivity: DateTime.tryParse(json['last_activity'] as String? ?? '') ?? DateTime.now(),
    );
  final String professionalId;
  final String name;
  final String profession;
  final Map<String, double> languageProgress;
  final List<String> completedModules;
  final String currentModule;
  final double overallProgress;
  final String status; // 'active', 'completed', 'on_hold'
  final DateTime lastActivity;

  Map<String, dynamic> toJson() => {
      'professional_id': professionalId,
      'name': name,
      'profession': profession,
      'language_progress': languageProgress,
      'completed_modules': completedModules,
      'current_module': currentModule,
      'overall_progress': overallProgress,
      'status': status,
      'last_activity': lastActivity.toIso8601String(),
    };
}

/// Enums para facilitar uso
enum ProfessionType {
  doctor,
  nurse,
  engineer,
  teacher,
  diplomat,
  agronomist,
  social_worker,
  project_manager,
  translator,
  administrator,
}

enum UrgencyLevel {
  low,
  medium,
  high,
  critical,
}

enum LearningPace {
  slow,
  normal,
  fast,
  intensive,
}

enum ModuleDifficulty {
  emergency,
  basic,
  intermediate,
  advanced,
  expert,
}

extension ProfessionTypeExtension on ProfessionType {
  String get displayName {
    switch (this) {
      case ProfessionType.doctor:
        return 'Médico';
      case ProfessionType.nurse:
        return 'Enfermeiro';
      case ProfessionType.engineer:
        return 'Engenheiro';
      case ProfessionType.teacher:
        return 'Professor';
      case ProfessionType.diplomat:
        return 'Diplomata';
      case ProfessionType.agronomist:
        return 'Agrônomo';
      case ProfessionType.social_worker:
        return 'Assistente Social';
      case ProfessionType.project_manager:
        return 'Gerente de Projeto';
      case ProfessionType.translator:
        return 'Tradutor';
      case ProfessionType.administrator:
        return 'Administrador';
    }
  }

  String get icon {
    switch (this) {
      case ProfessionType.doctor:
        return '👨‍⚕️';
      case ProfessionType.nurse:
        return '👩‍⚕️';
      case ProfessionType.engineer:
        return '👨‍🔧';
      case ProfessionType.teacher:
        return '👨‍🏫';
      case ProfessionType.diplomat:
        return '🤝';
      case ProfessionType.agronomist:
        return '👨‍🌾';
      case ProfessionType.social_worker:
        return '👥';
      case ProfessionType.project_manager:
        return '📊';
      case ProfessionType.translator:
        return '🗣️';
      case ProfessionType.administrator:
        return '💼';
    }
  }
}
