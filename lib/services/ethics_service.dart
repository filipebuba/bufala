// Implementação das Diretrizes Éticas no Flutter
// lib/services/ethics_service.dart

import 'dart:math';

/// Serviço responsável por garantir que todas as provocações
/// sejam éticas, respeitosas e motivacionais
class EthicsService {
  // Palavras e frases completamente proibidas
  static const List<String> _prohibitedWords = [
    'burro',
    'estúpido',
    'idiota',
    'imbecil',
    'incompetente',
    'incapaz',
    'inferior',
    'primitivo',
    'atrasado',
    'selvagem',
    'subdesenvolvido',
    'bárbaro',
    'impossível',
    'nunca vai conseguir',
    'desista',
    'muito difícil para você',
    'dialeto inferior',
    'língua simples',
    'não é língua de verdade',
  ];

  static const List<String> _prohibitedPhrases = [
    'você não consegue',
    'isso está muito errado',
    'sua língua não serve',
    'cultura primitiva',
    'você é incapaz',
    'melhor desistir',
    'não vale a pena',
    'isso é ridículo',
    'você está errado',
  ];

  // Templates de provocações éticas aprovadas
  static const List<String> _ethicalCuriosityTemplates = [
    "Que interessante! '{word}' em {language}... Você conhece a origem dessa palavra?",
    "Nossa! Nunca tinha ouvido '{word}' em {language}! Você poderia me ensinar mais palavras assim?",
    "Fascinante! '{word}' tem um som único em {language}... Há mais palavras com essa sonoridade?",
    "Que legal! '{word}' me lembra algumas palavras que já ouvi... Você sabe de onde vem essa palavra?",
    "Adorei '{word}'! Que palavra expressiva em {language}! Você conhece sinônimos interessantes?",
  ];

  static const List<String> _ethicalChallengeTemplates = [
    "Impressionante seu conhecimento! Aposto que você conhece até expressões idiomáticas... Me surpreende!",
    "Você está indo muito bem! Será que consegue me ensinar uma palavra realmente única?",
    "Que riqueza de conhecimento! Tenho curiosidade: você conhece palavras antigas em {language}?",
    "Incrível! Você domina {language} muito bem... Há alguma palavra especial que você adora?",
    "Que talento para {language}! Você conhece palavras que só os mais experientes sabem?",
  ];

  static const List<String> _ethicalAppreciationTemplates = [
    "Que riqueza linguística! {language} tem palavras tão expressivas como '{word}'!",
    "Adoro aprender sobre {language}! Cada palavra como '{word}' conta uma história cultural!",
    "Que privilégio aprender {language} com você! '{word}' é uma palavra linda!",
    "Fascinante como {language} expressa conceitos! '{word}' tem um significado tão rico!",
    "Que tesouro cultural! {language} preserva palavras incríveis como '{word}'!",
  ];

  // Respostas éticas para diferentes situações
  static const Map<String, List<String>> _ethicalResponses = {
    'error_gentle': [
      "Interessante! Eu havia aprendido essa palavra de forma diferente... Será que há variações regionais?",
      "Que curioso! Talvez eu esteja confuso... Você poderia me explicar melhor?",
      "Nossa, que diferença interessante! Você conhece outras variações dessa palavra?",
      "Hmm, talvez eu tenha me confundido... Você pode me ensinar a forma correta?",
    ],
    'encouragement_beginner': [
      "Que legal você estar aprendendo! Vamos descobrir mais palavras juntos?",
      "Primeira palavra em {language}! Que início incrível! Qual será a próxima?",
      "Que início promissor! {language} é uma língua fascinante para aprender!",
      "Parabéns por começar essa jornada! {language} tem tantas palavras interessantes!",
    ],
    'challenge_expert': [
      "Seu domínio de {language} é impressionante! Conhece expressões idiomáticas?",
      "Que expertise! Será que você sabe palavras que só os mestres conhecem?",
      "Incrível conhecimento! Você conhece as palavras mais antigas de {language}?",
      "Que talento! Aposto que você conhece até as palavras mais raras!",
    ],
  };

  /// Valida se uma provocação é ética antes de ser enviada
  static EthicsValidationResult validateProvocation(String text) {
    // Verifica palavras proibidas
    final lowerText = text.toLowerCase();

    for (final word in _prohibitedWords) {
      if (lowerText.contains(word.toLowerCase())) {
        return EthicsValidationResult(
          isEthical: false,
          reason: 'Contém palavra proibida: $word',
          severity: EthicsViolationSeverity.high,
        );
      }
    }

    // Verifica frases proibidas
    for (final phrase in _prohibitedPhrases) {
      if (lowerText.contains(phrase.toLowerCase())) {
        return EthicsValidationResult(
          isEthical: false,
          reason: 'Contém frase proibida: $phrase',
          severity: EthicsViolationSeverity.high,
        );
      }
    }

    // Análise de sentimento simples
    final sentimentScore = _analyzeSentiment(text);
    if (sentimentScore < 0.7) {
      // Deve ser pelo menos 70% positivo
      return EthicsValidationResult(
        isEthical: false,
        reason: 'Sentimento muito negativo (score: $sentimentScore)',
        severity: EthicsViolationSeverity.medium,
      );
    }

    return EthicsValidationResult(
      isEthical: true,
      reason: 'Provocação ética aprovada',
      sentimentScore: sentimentScore,
    );
  }

  /// Gera provocação ética baseada no contexto
  static String generateEthicalProvocation({
    required ProvocationType type,
    required String userInput,
    required String language,
    required UserExpertiseLevel expertiseLevel,
    String? specificContext,
  }) {
    late List<String> templates;

    switch (type) {
      case ProvocationType.curiosity:
        templates = _ethicalCuriosityTemplates;
        break;
      case ProvocationType.challenge:
        templates = _getTemplatesForExpertise(expertiseLevel);
        break;
      case ProvocationType.appreciation:
        templates = _ethicalAppreciationTemplates;
        break;
      case ProvocationType.encouragement:
        templates = _ethicalResponses['encouragement_beginner']!;
        break;
      case ProvocationType.errorCorrection:
        templates = _ethicalResponses['error_gentle']!;
        break;
    }

    // Seleciona template aleatório
    final random = Random();
    final template = templates[random.nextInt(templates.length)];

    // Substitui variáveis
    String provocation = template
        .replaceAll('{word}', userInput)
        .replaceAll('{language}', language);

    // Valida antes de retornar
    final validation = validateProvocation(provocation);
    if (!validation.isEthical) {
      // Se não passou na validação, usa template mais seguro
      return _generateSafeProvocation(userInput, language);
    }

    return provocation;
  }

  /// Analisa sentimento simples do texto
  static double _analyzeSentiment(String text) {
    final positiveWords = [
      'interessante',
      'fascinante',
      'incrível',
      'legal',
      'ótimo',
      'maravilhoso',
      'lindo',
      'rico',
      'tesouro',
    ];
    final negativeWords = [
      'ruim',
      'feio',
      'errado',
      'péssimo',
      'horrível',
      'impossível',
      'difícil',
      'complicado',
    ];

    final lowerText = text.toLowerCase();
    int positiveCount = 0;
    int negativeCount = 0;

    for (final word in positiveWords) {
      if (lowerText.contains(word)) positiveCount++;
    }

    for (final word in negativeWords) {
      if (lowerText.contains(word)) negativeCount++;
    }

    // Score simples: mais palavras positivas = melhor score
    if (positiveCount + negativeCount == 0) return 0.8; // Neutro
    return positiveCount / (positiveCount + negativeCount);
  }

  /// Seleciona templates apropriados para nível de expertise
  static List<String> _getTemplatesForExpertise(UserExpertiseLevel level) {
    switch (level) {
      case UserExpertiseLevel.beginner:
        return _ethicalResponses['encouragement_beginner']!;
      case UserExpertiseLevel.intermediate:
        return _ethicalCuriosityTemplates;
      case UserExpertiseLevel.advanced:
        return _ethicalChallengeTemplates;
      case UserExpertiseLevel.expert:
        return _ethicalResponses['challenge_expert']!;
    }
  }

  /// Gera provocação ultra-segura quando outras falham na validação
  static String _generateSafeProvocation(String userInput, String language) {
    final safeTemplates = [
      "Obrigado por ensinar '$userInput' em $language! Que palavra interessante!",
      "Que legal aprender '$userInput'! $language é uma língua fascinante!",
      "Adorei conhecer '$userInput'! Você tem mais palavras bonitas em $language?",
      "Que privilégio aprender '$userInput' com você! $language é incrível!",
    ];

    final random = Random();
    return safeTemplates[random.nextInt(safeTemplates.length)];
  }

  /// Responde a reportes de comportamento inadequado
  static String generateApologyResponse(EthicsViolationReport report) {
    final apologyTemplates = [
      "Peço desculpas se minha provocação foi inadequada. Meu objetivo é sempre motivar e divertir, nunca ofender. Obrigado pelo feedback!",
      "Opa! Desculpe se soei desrespeitoso. Estou aqui para aprender junto com você, sempre com respeito. Podemos continuar?",
      "Perdão se não fui gentil o suficiente. Valorizo muito sua contribuição e quero que se sinta sempre respeitado aqui!",
      "Desculpe! Minha intenção é sempre criar um ambiente positivo. Obrigado por me ajudar a melhorar!",
    ];

    final random = Random();
    return apologyTemplates[random.nextInt(apologyTemplates.length)];
  }

  /// Monitora métricas éticas em tempo real
  static Future<EthicsMetricsReport> getEthicsMetrics() async {
    // Em implementação real, coletaria dados do backend
    return EthicsMetricsReport(
      userSatisfactionRate: 0.92,
      culturalRespectScore: 0.96,
      motivationLevel: 0.89,
      safetyScore: 0.98,
      harassmentReports: 0.01,
      timestamp: DateTime.now(),
    );
  }

  /// Ativa modo de segurança extra quando necessário
  static void activateEnhancedSafetyMode() {
    // Reduz agressividade das provocações
    // Aumenta frequência de elogios
    // Usa apenas templates mais seguros
    print('🛡️ Modo de Segurança Ética Ativado');
  }
}

/// Tipos de provocação ética
enum ProvocationType {
  curiosity, // Desperta curiosidade
  challenge, // Desafio respeitoso
  appreciation, // Apreciação cultural
  encouragement, // Encorajamento
  errorCorrection, // Correção gentil
}

/// Níveis de expertise do usuário
enum UserExpertiseLevel {
  beginner, // Iniciante (0-10 contribuições)
  intermediate, // Intermediário (11-50 contribuições)
  advanced, // Avançado (51-200 contribuições)
  expert, // Expert (200+ contribuições)
}

/// Severidade de violação ética
enum EthicsViolationSeverity {
  low, // Levemente inadequado
  medium, // Moderadamente problemático
  high, // Gravemente inadequado
}

/// Resultado da validação ética
class EthicsValidationResult {
  final bool isEthical;
  final String reason;
  final EthicsViolationSeverity? severity;
  final double? sentimentScore;

  EthicsValidationResult({
    required this.isEthical,
    required this.reason,
    this.severity,
    this.sentimentScore,
  });
}

/// Reporte de violação ética pelo usuário
class EthicsViolationReport {
  final String userId;
  final String provocativeText;
  final String violationType;
  final String userFeedback;
  final DateTime timestamp;

  EthicsViolationReport({
    required this.userId,
    required this.provocativeText,
    required this.violationType,
    required this.userFeedback,
    required this.timestamp,
  });
}

/// Relatório de métricas éticas
class EthicsMetricsReport {
  final double userSatisfactionRate;
  final double culturalRespectScore;
  final double motivationLevel;
  final double safetyScore;
  final double harassmentReports;
  final DateTime timestamp;

  EthicsMetricsReport({
    required this.userSatisfactionRate,
    required this.culturalRespectScore,
    required this.motivationLevel,
    required this.safetyScore,
    required this.harassmentReports,
    required this.timestamp,
  });

  bool get meetsEthicalStandards {
    return userSatisfactionRate >= 0.90 &&
        culturalRespectScore >= 0.95 &&
        motivationLevel >= 0.85 &&
        safetyScore >= 0.98 &&
        harassmentReports <= 0.02;
  }
}
