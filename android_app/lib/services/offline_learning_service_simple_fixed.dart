/// Classe para conteúdo de aprendizado offline
class OfflineLearningContent {

  OfflineLearningContent({
    required this.id,
    required this.title,
    required this.subject,
    required this.level,
    required this.languages,
    required this.contentType,
    required this.filePath,
    required this.metadata,
  });

  factory OfflineLearningContent.fromJson(Map<String, dynamic> json) => OfflineLearningContent(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      level: json['level'] as String? ?? '',
      languages: List<String>.from(json['languages'] as List? ?? []),
      contentType: json['contentType'] as String? ?? '',
      filePath: json['filePath'] as String? ?? '',
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  final String id;
  final String title;
  final String subject;
  final String level;
  final List<String> languages;
  final String contentType;
  final String filePath;
  final Map<String, dynamic> metadata;

  Map<String, dynamic> toJson() => {
      'id': id,
      'title': title,
      'subject': subject,
      'level': level,
      'languages': languages,
      'contentType': contentType,
      'filePath': filePath,
      'metadata': metadata,
    };
}

/// Serviço de aprendizado offline - versão simplificada
class OfflineLearningService {
  factory OfflineLearningService() => _instance;
  OfflineLearningService._internal();
  static final OfflineLearningService _instance =
      OfflineLearningService._internal();

  final Map<String, OfflineLearningContent> _learningDatabase = {};
  bool _isInitialized = false;

  /// Inicializar serviço
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      await _loadLearningContent();
      _isInitialized = true;
      return true;
    } catch (e) {
      print('Erro ao inicializar OfflineLearningService: $e');
      return false;
    }
  }

  /// Carregar conteúdo de aprendizado
  Future<void> _loadLearningContent() async {
    // Alfabetização em crioulo
    _learningDatabase['literacy_creole'] = OfflineLearningContent(
      id: 'literacy_creole',
      title: 'Alfabetização em Crioulo',
      subject: 'literacy',
      level: 'beginner',
      languages: ['pt-BR'],
      contentType: 'lesson',
      filePath: 'assets/learning/literacy_pt.json',
      metadata: {'difficulty': 'easy', 'duration': '30min'},
    );

    // Matemática básica
    _learningDatabase['math_basic'] = OfflineLearningContent(
      id: 'math_basic',
      title: 'Matemática Básica',
      subject: 'math',
      level: 'beginner',
      languages: ['pt-BR', 'crioulo-gb'],
      contentType: 'exercise',
      filePath: 'assets/learning/math_basic.json',
      metadata: {
        'difficulty': 'easy',
        'topics': ['counting', 'addition']
      },
    );

    // Educação em saúde
    _learningDatabase['health_basic'] = OfflineLearningContent(
      id: 'health_basic',
      title: 'Educação em Saúde',
      subject: 'health',
      level: 'basic',
      languages: ['pt-BR', 'crioulo-gb'],
      contentType: 'interactive',
      filePath: 'assets/learning/health_basic.json',
      metadata: {'category': 'preventive', 'audience': 'general'},
    );

    // Agricultura
    _learningDatabase['agriculture_basic'] = OfflineLearningContent(
      id: 'agriculture_basic',
      title: 'Técnicas Agrícolas Básicas',
      subject: 'agriculture',
      level: 'beginner',
      languages: ['pt-BR', 'crioulo-gb'],
      contentType: 'guide',
      filePath: 'assets/learning/agriculture_basic.json',
      metadata: {
        'season': 'all',
        'crops': ['rice', 'beans', 'cassava']
      },
    );
  }

  /// Carregar conteúdo por tópico
  Future<List<OfflineLearningContent>> loadSubjectContent(
    String subject, {
    String language = 'pt-BR',
    String level = 'beginner',
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    return _learningDatabase.values
        .where((content) =>
            content.subject == subject &&
            content.languages.contains(language) &&
            content.level == level)
        .toList();
  }

  /// Gerar conteúdo educacional
  Future<OfflineLearningContent> generateEducationalContent({
    required String subject,
    required String level,
    String language = 'pt-BR',
    Map<String, dynamic>? preferences,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Para esta versão simplificada, retorna conteúdo padrão
    return OfflineLearningContent(
      id: '${subject}_$level',
      title: 'Conteúdo de $subject',
      subject: subject,
      level: level,
      languages: [language],
      contentType: 'lesson',
      filePath: 'assets/learning/${subject}_$level.json',
      metadata: preferences ?? {},
    );
  }

  /// Verificar se está inicializado
  bool get isInitialized => _isInitialized;

  /// Obter conteúdo básico
  OfflineLearningContent getBasicContent(String subject) => _learningDatabase.values
            .where((content) => content.subject == subject)
            .firstOrNull ??
        OfflineLearningContent(
          id: '${subject}_default',
          title: 'Conteúdo Padrão de $subject',
          subject: subject,
          level: 'beginner',
          languages: ['pt-BR'],
          contentType: 'lesson',
          filePath: 'assets/learning/default.json',
          metadata: {},
        );

  /// Salvar progresso do usuário
  Future<void> saveProgress(
      String contentId, Map<String, dynamic> progress) async {
    // Implementação simplificada - apenas log
    print('Progresso salvo para conteúdo $contentId: $progress');
  }

  /// Carregar progresso do usuário
  Future<Map<String, dynamic>> loadProgress(String contentId) async {
    // Implementação simplificada - retorna progresso vazio
    return {};
  }
}
