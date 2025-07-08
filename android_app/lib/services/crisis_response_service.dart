import 'package:dio/dio.dart';

import '../models/crisis_response_models.dart';
import 'gemma3_multimodal_service.dart';

/// Serviço de resposta a crises - versão simplificada para build
class CrisisResponseService {
  factory CrisisResponseService() => _instance;
  CrisisResponseService._internal();
  static final CrisisResponseService _instance =
      CrisisResponseService._internal();

  final Gemma3MultimodalService _gemmaService = Gemma3MultimodalService();
  final Dio _dio = Dio();
  static const String _backendUrl =
      'http://127.0.0.1:5000'; // Backend localhost
  final Map<String, CrisisResponseData> _emergencyDatabase = {};
  bool _isInitialized = false;

  /// Inicializar serviço
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // Removido método initialize inexistente
      await _loadEmergencyDatabase();
      _isInitialized = true;
      return true;
    } catch (e) {
      print('Erro ao inicializar CrisisResponseService: $e');
      return false;
    }
  }

  /// Carregar base de dados de emergências
  Future<void> _loadEmergencyDatabase() async {
    _emergencyDatabase['medical'] = CrisisResponseData(
      id: 'medical',
      title: 'Emergência Médica',
      description: 'Emergência médica geral',
      severity: 'high',
      emergencyType: 'medical',
      immediateActions: [
        'Manter calma',
        'Avaliar a situação',
        'Buscar ajuda médica',
        'Verificar sinais vitais',
        'Manter pessoa aquecida',
      ],
      resources: [
        'Kit de primeiros socorros',
        'Telefone de emergência',
        'Água limpa',
        'Cobertores',
      ],
      contacts: {
        'emergência': '113',
        'hospital': 'local',
        'cruz_vermelha': '199',
      },
      descriptionCreole: 'Emerjénsia médiku jeral',
      immediateActionsCreole: [
        'Mantén kalma',
        'Odja situason',
        'Buska djuda médiku',
        'Odja sinal di vida',
        'Mantén pesoa kenti',
      ],
      resourcesCreole: [
        'Kit di primeiru sokoru',
        'Telefoni di emerjénsia',
        'Agu limpu',
        'Kobertor',
      ],
    );

    _emergencyDatabase['fire'] = CrisisResponseData(
      id: 'fire',
      title: 'Incêndio',
      description: 'Incêndio - procedimentos de evacuação e combate',
      severity: 'critical',
      emergencyType: 'fire',
      immediateActions: [
        'Ligar para bombeiros (115)',
        'Evacuar área imediatamente',
        'Não usar elevadores',
        'Rastejar sob fumaça',
        'Fechar portas atrás de si',
      ],
      resources: [
        'Extintor de incêndio',
        'Água',
        'Areia',
        'Cobertores molhados',
      ],
      contacts: {'bombeiros': '115', 'emergência': '113'},
      descriptionCreole: 'Fugu - prosedimentu di evakuason i kombati',
      immediateActionsCreole: [
        'Xama bumberu (115)',
        'Sai di lokal imediatamenti',
        'Ka uza elevador',
        'Anda na txon',
        'Fecha porta dipus di pasa',
      ],
    );

    _emergencyDatabase['accident'] = CrisisResponseData(
      id: 'accident',
      title: 'Acidente',
      description: 'Acidente - trauma e ferimentos',
      severity: 'high',
      emergencyType: 'accident',
      immediateActions: [
        'Não mover a vítima',
        'Verificar respiração',
        'Controlar sangramento',
        'Manter vítima aquecida',
        'Chamar ajuda médica',
      ],
      resources: [
        'Bandagens',
        'Gaze esterilizada',
        'Kit primeiros socorros',
        'Tábua para imobilização',
      ],
      contacts: {'emergência': '113', 'ambulância': '192'},
      descriptionCreole: 'Asidenti - trauma i firidamentu',
      immediateActionsCreole: [
        'Ka mexe vítima',
        'Odja respirason',
        'Kontrola sangramentu',
        'Mantén vítima kenti',
        'Xama djuda médiku',
      ],
    );

    _emergencyDatabase['childbirth'] = CrisisResponseData(
      id: 'childbirth',
      title: 'Parto de Emergência',
      description: 'Parto de emergência em área remota',
      severity: 'critical',
      emergencyType: 'childbirth',
      immediateActions: [
        'Lavar mãos com sabão',
        'Preparar local limpo',
        'Não puxar o bebê',
        'Cortar cordão com instrumento esterilizado',
        'Manter bebê aquecido',
      ],
      resources: [
        'Água limpa',
        'Sabão ou álcool',
        'Toalhas limpas',
        'Tesoura esterilizada',
        'Fio limpo',
      ],
      contacts: {'emergência': '113', 'parteira': 'local'},
      descriptionCreole: 'Partu di emerjénsia na lokal longi',
      immediateActionsCreole: [
        'Laba mon ku sabon',
        'Prepara lokal limpu',
        'Ka puxa mininu',
        'Korta kordon ku ferramenta esterilizadu',
        'Mantén mininu kenti',
      ],
    );

    _emergencyDatabase['natural_disaster'] = CrisisResponseData(
      id: 'natural_disaster',
      title: 'Desastre Natural',
      description: 'Desastre natural - inundações, tempestades',
      severity: 'critical',
      emergencyType: 'natural_disaster',
      immediateActions: [
        'Buscar abrigo seguro',
        'Evitar áreas baixas (inundação)',
        'Afastar-se de árvores grandes',
        'Guardar água potável',
        'Seguir orientações das autoridades',
      ],
      resources: [
        'Água potável',
        'Alimentos não perecíveis',
        'Lanternas',
        'Pilhas',
        'Rádio',
      ],
      contacts: {'emergência': '113', 'proteção_civil': 'local'},
      descriptionCreole: 'Dizastri natural - inundasion, timpestad',
      immediateActionsCreole: [
        'Buska abrigo siguru',
        'Evita lokal baxu (inundasion)',
        'Sai di pé di pau grandi',
        'Garda agu potável',
        'Sigui orientason di autoridad',
      ],
    );
  }

  /// Processar emergência
  Future<CrisisResponseData> processEmergency({
    required String emergencyType,
    String? description,
    String? imagePath,
    String language = 'pt-BR',
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Buscar na base de dados
      final crisis = _emergencyDatabase[emergencyType] ??
          _getDefaultCrisisData(emergencyType);

      // Para esta versão simplificada, retornamos dados básicos
      return crisis;
    } catch (e) {
      print('Erro ao processar emergência: $e');
      return _getDefaultCrisisData(emergencyType);
    }
  }

  /// Processar emergência com IA Gemma-3
  Future<CrisisResponseData> processEmergencyWithAI({
    required String emergencyType,
    String? description,
    String? imagePath,
    String? audioPath,
    String language = 'pt-BR',
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      // Preparar dados multimodais para Gemma-3
      final requestData = {
        'emergency_type': emergencyType,
        'description': description,
        'language': language,
        'multimodal': {
          'has_image': imagePath != null,
          'has_audio': audioPath != null,
        },
      };

      // Chamar backend Gemma-3
      final response = await _dio.post<Map<String, dynamic>>(
        '$_backendUrl/medical',
        data: requestData,
        options: Options(
          sendTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        return _buildCrisisResponseFromAI(data, emergencyType);
      } else {
        print('Erro no backend Gemma-3: ${response.statusCode}');
        return _getFallbackResponse(emergencyType, language);
      }
    } catch (e) {
      print('Erro ao conectar com backend Gemma-3: $e');
      return _getFallbackResponse(emergencyType, language);
    }
  }

  /// Construir resposta de crise baseada na IA
  CrisisResponseData _buildCrisisResponseFromAI(
    Map<String, dynamic> aiData,
    String emergencyType,
  ) =>
      CrisisResponseData(
        id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Emergência AI - $emergencyType',
        emergencyType: emergencyType,
        severity: (aiData['severity'] as String?) ?? 'medium',
        location: '',
        description: (aiData['description'] as String?) ??
            'Emergência identificada pela IA',
        immediateActions:
            (aiData['immediate_actions'] as List<dynamic>?)?.cast<String>() ??
                [],
        resources:
            (aiData['resources'] as List<dynamic>?)?.cast<String>() ?? [],
        contacts: (aiData['contacts'] as Map<String, dynamic>?)
                ?.cast<String, String>() ??
            {},
        descriptionCreole: aiData['description_creole'] as String?,
        immediateActionsCreole:
            (aiData['immediate_actions_creole'] as List<dynamic>?)
                ?.cast<String>(),
        resourcesCreole:
            (aiData['resources_creole'] as List<dynamic>?)?.cast<String>(),
        aiAnalysis: aiData['ai_analysis'] as Map<String, dynamic>?,
      );

  /// Resposta de fallback quando IA não está disponível
  CrisisResponseData _getFallbackResponse(
    String emergencyType,
    String language,
  ) {
    final isCreole = language == 'crioulo-gb';

    return CrisisResponseData(
      title: 'Fallback Emergency Response',
      id: 'fallback_${DateTime.now().millisecondsSinceEpoch}',
      emergencyType: emergencyType,
      severity: 'medium',
      location: '',
      description: isCreole
          ? 'Emerjénsia identificadu. IA ka ta disponível agora.'
          : 'Emergência identificada. IA não disponível no momento.',
      immediateActions: isCreole
          ? ['Mantén kalma', 'Buska djuda lokal', 'Telefona 113']
          : ['Manter calma', 'Buscar ajuda local', 'Ligar 113'],
      resources: isCreole
          ? ['Kit di primeiru sokoru', 'Telefoni']
          : ['Kit de primeiros socorros', 'Telefone'],
      contacts: {'emergência': '113'},
    );
  }

  /// Dados padrão para emergências não catalogadas
  CrisisResponseData _getDefaultCrisisData(String emergencyType) =>
      CrisisResponseData(
        title: 'Default Crisis Response',
        id: 'unknown',
        emergencyType: emergencyType,
        severity: 'medium',
        location: '',
        description: 'Emergência não identificada. Procure ajuda local.',
        immediateActions: ['Manter calma', 'Avaliar situação', 'Buscar ajuda'],
        resources: ['Kit de primeiros socorros'],
        contacts: {'emergência': '113'},
        descriptionCreole: 'Emerjénsia ka konhisidu. Buska djuda lokal.',
      );

  /// Verificar se está inicializado
  bool get isInitialized => _isInitialized;

  /// Analisar crise (método simplificado)
  Future<CrisisResponseData> analyzeCrisis({
    String? audioPath,
    String? imagePath,
    String? textInput,
    String language = 'pt-BR',
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Para esta versão simplificada, retornamos uma resposta básica
    return _getDefaultCrisisData('analysis');
  }

  /// Gerar mensagem de emergência
  Future<String> generateEmergencyMessage({
    required String emergencyType,
    required String location,
    String? additionalInfo,
    String language = 'pt-BR',
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final isCreole = language == 'crioulo-gb';

    // Template básico de mensagem
    final template = isCreole
        ? 'EMERJÉNSIA: [TIPU] na [LOKAL]. [INFO]. Djuda nesesáriu!'
        : 'EMERGÊNCIA: [TIPO] em [LOCAL]. [INFO]. Ajuda necessária!';

    final emergencyName = isCreole
        ? _getEmergencyNameCreole(emergencyType)
        : _getEmergencyNamePortuguese(emergencyType);

    return template
        .replaceAll('[TIPO]', emergencyName)
        .replaceAll('[TIPU]', emergencyName)
        .replaceAll('[LOCAL]', location)
        .replaceAll('[LOKAL]', location)
        .replaceAll('[INFO]', additionalInfo ?? '');
  }

  String _getEmergencyNamePortuguese(String type) {
    switch (type) {
      case 'medical':
        return 'Emergência Médica';
      case 'fire':
        return 'Incêndio';
      case 'accident':
        return 'Acidente';
      case 'natural_disaster':
        return 'Desastre Natural';
      default:
        return 'Emergência';
    }
  }

  String _getEmergencyNameCreole(String type) {
    switch (type) {
      case 'medical':
        return 'Emerjénsia Médiku';
      case 'fire':
        return 'Fugu';
      case 'accident':
        return 'Asidenti';
      case 'natural_disaster':
        return 'Dizastri Natural';
      default:
        return 'Emerjénsia';
    }
  }
}
