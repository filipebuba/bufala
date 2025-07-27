import 'package:dio/dio.dart';
import '../models/crisis_response_models.dart';
import '../models/offline_learning_models.dart';
import '../config/app_config.dart';

/// Serviço simplificado para conectar ao backend Gemma-3
class Gemma3BackendService {
  factory Gemma3BackendService() => _instance;
  Gemma3BackendService._internal();
  static final Gemma3BackendService _instance =
      Gemma3BackendService._internal();

  final Dio _dio = Dio();

  bool _isInitialized = false;

  /// Inicializar serviço
  Future<bool> initialize() async {
    try {
      _dio.options.baseUrl = AppConfig.apiBaseUrl.replaceAll('/api', '');
      _dio.options.connectTimeout = const Duration(seconds: 10);
      _dio.options.receiveTimeout = const Duration(seconds: 30);

      // Testar conexão
      final response = await _dio.get(AppConfig.buildUrl('health'));
      if (response.statusCode == 200) {
        _isInitialized = true;
        print('✅ Conectado ao backend Gemma-3');
        return true;
      }
    } catch (e) {
      print('❌ Backend não disponível, usando modo offline');
      // Em modo offline, ainda consideramos inicializado
      _isInitialized = true;
      return true;
    }
    return false;
  }

  /// Processar emergência
  Future<CrisisResponseData> processEmergency({
    required String emergencyType,
    String? description,
    String? imagePath,
    String language = 'pt-BR',
    String? location,
  }) async {
    try {
      if (_isInitialized && await _isBackendAvailable()) {
        // Tentar usar backend real
        final response = await _dio.post(
          AppConfig.buildUrl('medical'),
          data: {
            'emergency_type': emergencyType,
            'description': description,
            'language': language,
            'location': location,
          },
        );

        if (response.statusCode == 200) {
          final data = response.data as Map<String, dynamic>;
          return _createCrisisFromBackend(data, emergencyType, location);
        }
      }
    } catch (e) {
      print('Backend indisponível, usando resposta local: $e');
    }

    // Fallback para resposta local
    return _createLocalCrisisResponse(
      emergencyType,
      description,
      location,
      language,
    );
  }

  /// Gerar conteúdo educativo
  Future<OfflineLearningContent> generateEducationalContent({
    required String subject,
    required String language,
    String level = 'beginner',
  }) async {
    try {
      if (_isInitialized && await _isBackendAvailable()) {
        final response = await _dio.post(
          AppConfig.buildUrl('education'),
          data: {'subject': subject, 'language': language, 'level': level},
        );

        if (response.statusCode == 200) {
          final data = response.data as Map<String, dynamic>;
          return _createContentFromBackend(data, subject, language, level);
        }
      }
    } catch (e) {
      print('Backend indisponível, usando conteúdo local: $e');
    }

    // Fallback para conteúdo local
    return _createLocalEducationalContent(subject, language, level);
  }

  /// Verificar se backend está disponível
  Future<bool> _isBackendAvailable() async {
    try {
      final response = await _dio.get(AppConfig.buildUrl('health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  /// Criar resposta de crise do backend
  CrisisResponseData _createCrisisFromBackend(
    Map<String, dynamic> data,
    String emergencyType,
    String? location,
  ) =>
      CrisisResponseData(
        title: data['title']?.toString() ?? 'Resposta de Emergência',
        description:
            data['description']?.toString() ?? 'Resposta gerada por IA',
        id: data['id']?.toString() ??
            'backend_${DateTime.now().millisecondsSinceEpoch}',
        emergencyType: emergencyType,
        severity: data['severity']?.toString() ?? 'medium',
        location: location ?? '',
        immediateActions: _extractStringList(data['immediate_actions']),
        resources: _extractStringList(data['resources']),
        contacts: _extractStringMap(data['contacts']),
        descriptionCreole: data['description_creole']?.toString(),
        immediateActionsCreole: _extractStringList(
          data['immediate_actions_creole'],
        ),
        resourcesCreole: _extractStringList(data['resources_creole']),
      );

  /// Criar conteúdo educativo do backend
  OfflineLearningContent _createContentFromBackend(
    Map<String, dynamic> data,
    String subject,
    String language,
    String level,
  ) =>
      OfflineLearningContent(
        id: data['id']?.toString() ??
            'backend_${DateTime.now().millisecondsSinceEpoch}',
        title: data['title']?.toString() ?? 'Conteúdo Educativo',
        content: data['text_content']?.toString() ?? '',
        description: data['description']?.toString() ?? 'Gerado por IA',
        subject: subject,
        level: level,
        languages: [language],
        type: data['content_type']?.toString() ?? 'lesson',
        metadata: _extractStringDynamicMap(data['metadata']),
        createdAt: DateTime.now(),
      );

  /// Criar resposta local de emergência
  CrisisResponseData _createLocalCrisisResponse(
    String emergencyType,
    String? description,
    String? location,
    String language,
  ) {
    final isCreole = language == 'crioulo-gb';

    final localResponses = {
      'medical': {
        'pt': {
          'description':
              'Emergência médica detectada. Siga as orientações abaixo.',
          'actions': [
            'Manter calma',
            'Avaliar respiração',
            'Buscar ajuda médica',
          ],
          'resources': ['Kit primeiros socorros', 'Telefone emergência'],
        },
        'creole': {
          'description':
              'Emerjénsia médiku detetadu. Sigui orientason na baxu.',
          'actions': ['Mantén kalma', 'Odja respirason', 'Buska djuda médiku'],
          'resources': ['Kit primeiru sokoru', 'Telefoni emerjénsia'],
        },
      },
      'fire': {
        'pt': {
          'description': 'Incêndio detectado. Evacue imediatamente.',
          'actions': ['Sair do local', 'Chamar bombeiros', 'Não usar elevador'],
          'resources': ['Extintor', 'Rota de fuga', 'Telefone bombeiros'],
        },
        'creole': {
          'description': 'Fugu detetadu. Sai di lokal imediatamenti.',
          'actions': ['Sai di lokal', 'Chama bomberu', 'Ka uza elevador'],
          'resources': ['Extintor', 'Rota di fugi', 'Telefoni bomberu'],
        },
      },
    };

    final responseData =
        localResponses[emergencyType] ?? localResponses['medical']!;
    final langData = responseData[isCreole ? 'creole' : 'pt']!;

    return CrisisResponseData(
      title: 'Resposta de Emergência Local',
      description: langData['description'] as String,
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      emergencyType: emergencyType,
      severity: 'high',
      location: location ?? '',
      immediateActions: List<String>.from(langData['actions'] as List),
      resources: List<String>.from(langData['resources'] as List),
      contacts: {'emergência': '113'},
    );
  }

  /// Criar conteúdo educativo local
  OfflineLearningContent _createLocalEducationalContent(
    String subject,
    String language,
    String level,
  ) {
    final isCreole = language == 'crioulo-gb';

    final subjects = {
      'literacy': isCreole ? 'Alfabetizason' : 'Alfabetização',
      'math': isCreole ? 'Matemátika' : 'Matemática',
      'health': isCreole ? 'Saúdi' : 'Saúde',
      'agriculture': isCreole ? 'Agrikultura' : 'Agricultura',
    };

    return OfflineLearningContent(
      id: 'local_${subject}_${DateTime.now().millisecondsSinceEpoch}',
      title: subjects[subject] ?? subject,
      content: isCreole
          ? 'Lison básiku di $subject. Estudi ku atenson.'
          : 'Lição básica de $subject. Estude com atenção.',
      description: isCreole
          ? 'Konteúdu edukativu lokal pa $subject'
          : 'Conteúdo educativo local para $subject',
      subject: subject,
      level: level,
      languages: [language],
      type: 'lesson',
      metadata: {'source': 'local', 'difficulty': level},
      createdAt: DateTime.now(),
    );
  }

  /// Utilitários para extrair dados
  List<String> _extractStringList(dynamic data) {
    if (data is List) {
      return data.map((e) => e?.toString() ?? '').toList();
    }
    return [];
  }

  Map<String, String> _extractStringMap(dynamic data) {
    if (data is Map) {
      return data.map(
        (k, v) => MapEntry(k?.toString() ?? '', v?.toString() ?? ''),
      );
    }
    return {};
  }

  Map<String, dynamic> _extractStringDynamicMap(dynamic data) {
    if (data is Map) {
      return data.map((k, v) => MapEntry(k?.toString() ?? '', v));
    }
    return {};
  }

  bool get isInitialized => _isInitialized;
  String get baseUrl => _baseUrl;
}
