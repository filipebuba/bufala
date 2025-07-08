import 'package:flutter/material.dart';

/// Modelo para sistema de ensino internacional integrado na educação
class InternationalTeachingSystem {
  const InternationalTeachingSystem({
    required this.id,
    required this.name,
    required this.description,
    required this.supportedLanguages,
    required this.targetAudiences,
    required this.teachingMethods,
    required this.aiCapabilities,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String description;
  final List<SupportedLanguage> supportedLanguages;
  final List<TargetAudience> targetAudiences;
  final List<TeachingMethod> teachingMethods;
  final AICapabilities aiCapabilities;
  final bool isActive;
}

/// Línguas suportadas pelo sistema
class SupportedLanguage {
  const SupportedLanguage({
    required this.code,
    required this.name,
    required this.nativeName,
    required this.region,
    required this.isLocal,
    required this.proficiency,
    required this.status,
    this.flag,
    this.culturalNotes,
  });

  final String code; // ISO 639-1 ou código customizado
  final String name; // Nome em português
  final String nativeName; // Nome na língua nativa
  final String region; // África Ocidental, Europa, etc.
  final bool isLocal; // Língua local da Guiné-Bissau
  final LanguageProficiency proficiency; // Nível de suporte da IA
  final LanguageStatus status; // Ativo, em desenvolvimento, etc.
  final String? flag; // Emoji da bandeira
  final String? culturalNotes; // Notas culturais importantes
}

enum LanguageProficiency {
  native, // Nativo/Fluente
  advanced, // Avançado
  intermediate, // Intermediário
  basic, // Básico
  learning, // Aprendendo
}

enum LanguageStatus {
  active, // Totalmente ativo
  beta, // Em teste
  development, // Em desenvolvimento
  planned, // Planejado
}

/// Públicos-alvo para o ensino
class TargetAudience {
  const TargetAudience({
    required this.id,
    required this.name,
    required this.description,
    required this.ageRange,
    required this.educationLevel,
    required this.context,
    required this.specialNeeds,
  });

  final String id;
  final String name;
  final String description;
  final AgeRange ageRange;
  final EducationLevel educationLevel;
  final LearningContext context;
  final List<SpecialNeed> specialNeeds;
}

enum AgeRange {
  children, // 5-12 anos
  teenagers, // 13-17 anos
  adults, // 18-65 anos
  elderly, // 65+ anos
  mixed, // Misto
}

enum EducationLevel {
  none, // Sem educação formal
  primary, // Primário
  secondary, // Secundário
  university, // Universitário
  mixed, // Misto
}

enum LearningContext {
  classroom, // Sala de aula
  community, // Comunidade
  family, // Família
  ngo, // ONG
  hospital, // Hospital
  field, // Campo/Rural
  emergency, // Emergência
}

enum SpecialNeed {
  literacy, // Alfabetização
  numeracy, // Numeracia
  health, // Saúde
  agriculture, // Agricultura
  technology, // Tecnologia
  emergency, // Situações de emergência
  cultural, // Preservação cultural
}

/// Métodos de ensino disponíveis
class TeachingMethod {
  const TeachingMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.interactivity,
    required this.aiAssisted,
    this.icon,
    this.color,
  });

  final String id;
  final String name;
  final String description;
  final MethodType type;
  final InteractivityLevel interactivity;
  final bool aiAssisted;
  final IconData? icon;
  final Color? color;
}

enum MethodType {
  conversation, // Conversação
  translation, // Tradução
  storytelling, // Contação de histórias
  games, // Jogos educativos
  cultural, // Intercâmbio cultural
  practical, // Aplicação prática
  emergency, // Situações de emergência
}

enum InteractivityLevel {
  passive, // Passivo (ouvir/ler)
  interactive, // Interativo (perguntas/respostas)
  collaborative, // Colaborativo (grupos)
  immersive, // Imersivo (simulações)
}

/// Capacidades da IA
class AICapabilities {
  const AICapabilities({
    required this.canTranslate,
    required this.canGenerateContent,
    required this.canAdaptToContext,
    required this.canLearnFromInteraction,
    required this.supportedFeatures,
    required this.limitations,
  });

  final bool canTranslate;
  final bool canGenerateContent;
  final bool canAdaptToContext;
  final bool canLearnFromInteraction;
  final List<AIFeature> supportedFeatures;
  final List<String> limitations;
}

enum AIFeature {
  realTimeTranslation, // Tradução em tempo real
  contextualLearning, // Aprendizado contextual
  culturalAdaptation, // Adaptação cultural
  voiceGeneration, // Geração de voz
  imageDescription, // Descrição de imagens
  emergencyResponse, // Resposta de emergência
  progressTracking, // Acompanhamento de progresso
  personalizedContent, // Conteúdo personalizado
}

/// Sessão de ensino internacional
class InternationalTeachingSession {
  const InternationalTeachingSession({
    required this.id,
    required this.teacherId,
    required this.targetAudience,
    required this.languages,
    required this.method,
    required this.topic,
    required this.startTime,
    this.endTime,
    this.participants = const [],
    this.aiAssistant,
    this.culturalContext,
    this.materials = const [],
    this.feedback = const [],
  });

  final String id;
  final String teacherId;
  final TargetAudience targetAudience;
  final List<SupportedLanguage> languages; // Línguas usadas na sessão
  final TeachingMethod method;
  final String topic;
  final DateTime startTime;
  final DateTime? endTime;
  final List<SessionParticipant> participants;
  final AITeachingAssistant? aiAssistant;
  final CulturalContext? culturalContext;
  final List<TeachingMaterial> materials;
  final List<SessionFeedback> feedback;
}

/// Participante da sessão
class SessionParticipant {
  const SessionParticipant({
    required this.id,
    required this.name,
    required this.nativeLanguage,
    required this.targetLanguage,
    required this.level,
    this.age,
    this.background,
    this.specialNeeds = const [],
  });

  final String id;
  final String name;
  final SupportedLanguage nativeLanguage;
  final SupportedLanguage targetLanguage;
  final LanguageProficiency level;
  final int? age;
  final String? background;
  final List<SpecialNeed> specialNeeds;
}

/// Assistente de IA para ensino
class AITeachingAssistant {
  const AITeachingAssistant({
    required this.name,
    required this.capabilities,
    required this.activeLanguages,
    required this.adaptationLevel,
    this.personality,
    this.voiceSettings,
  });

  final String name;
  final AICapabilities capabilities;
  final List<SupportedLanguage> activeLanguages;
  final double adaptationLevel; // 0.0 a 1.0
  final String? personality; // formal, amigável, encorajador
  final VoiceSettings? voiceSettings;
}

/// Configurações de voz
class VoiceSettings {
  const VoiceSettings({
    required this.speed,
    required this.pitch,
    required this.accent,
    this.gender,
  });

  final double speed; // 0.5 a 2.0
  final double pitch; // 0.5 a 2.0
  final String accent; // regional, neutral, etc.
  final String? gender; // masculino, feminino, neutro
}

/// Contexto cultural
class CulturalContext {
  const CulturalContext({
    required this.region,
    required this.traditions,
    required this.socialNorms,
    required this.communicationStyle,
    this.religiousConsiderations = const [],
    this.historicalBackground,
  });

  final String region;
  final List<String> traditions;
  final List<String> socialNorms;
  final String communicationStyle;
  final List<String> religiousConsiderations;
  final String? historicalBackground;
}

/// Material de ensino
class TeachingMaterial {
  const TeachingMaterial({
    required this.id,
    required this.title,
    required this.type,
    required this.languages,
    required this.content,
    this.description,
    this.culturalNotes,
    this.ageAppropriate,
    this.difficulty,
  });

  final String id;
  final String title;
  final MaterialType type;
  final List<SupportedLanguage> languages;
  final MaterialContent content;
  final String? description;
  final String? culturalNotes;
  final AgeRange? ageAppropriate;
  final LanguageProficiency? difficulty;
}

enum MaterialType {
  text, // Texto
  audio, // Áudio
  image, // Imagem
  video, // Vídeo
  interactive, // Interativo
  game, // Jogo
  story, // História
  song, // Música
}

/// Conteúdo do material
class MaterialContent {
  const MaterialContent({
    required this.primary,
    this.translations = const {},
    this.audioUrls = const {},
    this.imageUrls = const [],
    this.metadata = const {},
  });

  final String primary; // Conteúdo principal
  final Map<String, String> translations; // Traduções por código de língua
  final Map<String, String> audioUrls; // URLs de áudio por língua
  final List<String> imageUrls; // URLs de imagens
  final Map<String, dynamic> metadata; // Metadados extras
}

/// Feedback da sessão
class SessionFeedback {
  const SessionFeedback({
    required this.participantId,
    required this.rating,
    required this.timestamp,
    this.comments,
    this.suggestions,
    this.difficultyLevel,
    this.engagement,
    this.culturalRelevance,
  });

  final String participantId;
  final double rating; // 1.0 a 5.0
  final DateTime timestamp;
  final String? comments;
  final String? suggestions;
  final double? difficultyLevel; // 1.0 a 5.0
  final double? engagement; // 1.0 a 5.0
  final double? culturalRelevance; // 1.0 a 5.0
}

/// Progresso de aprendizado internacional
class InternationalLearningProgress {
  const InternationalLearningProgress({
    required this.userId,
    required this.nativeLanguage,
    required this.targetLanguages,
    required this.overallProgress,
    required this.sessionHistory,
    required this.achievements,
    this.strengths = const [],
    this.weaknesses = const [],
    this.culturalUnderstanding,
  });

  final String userId;
  final SupportedLanguage nativeLanguage;
  final Map<String, LanguageProgress> targetLanguages;
  final double overallProgress; // 0.0 a 1.0
  final List<InternationalTeachingSession> sessionHistory;
  final List<Achievement> achievements;
  final List<String> strengths;
  final List<String> weaknesses;
  final double? culturalUnderstanding; // 0.0 a 1.0
}

/// Progresso em uma língua específica
class LanguageProgress {
  const LanguageProgress({
    required this.language,
    required this.proficiency,
    required this.vocabulary,
    required this.grammar,
    required this.pronunciation,
    required this.culturalKnowledge,
    required this.practicalUsage,
    this.lastPracticed,
  });

  final SupportedLanguage language;
  final double proficiency; // 0.0 a 1.0
  final double vocabulary; // 0.0 a 1.0
  final double grammar; // 0.0 a 1.0
  final double pronunciation; // 0.0 a 1.0
  final double culturalKnowledge; // 0.0 a 1.0
  final double practicalUsage; // 0.0 a 1.0
  final DateTime? lastPracticed;
}

/// Conquista/Medalha
class Achievement {
  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.earnedAt,
    this.category,
    this.rarity,
  });

  final String id;
  final String name;
  final String description;
  final String icon; // Emoji ou ícone
  final DateTime earnedAt;
  final String? category; // cultural, linguistic, social, etc.
  final AchievementRarity? rarity;
}

enum AchievementRarity {
  common, // Comum
  rare, // Raro
  epic, // Épico
  legendary, // Lendário
}
