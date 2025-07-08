import '../models/crisis_response_models.dart';
import 'gemma3_multimodal_service.dart';

/// Serviço de resposta a crises - versão simplificada para build
class CrisisResponseService {
  factory CrisisResponseService() => _instance;
  CrisisResponseService._internal();
  static final CrisisResponseService _instance =
      CrisisResponseService._internal();

  final Gemma3MultimodalService _gemmaService = Gemma3MultimodalService();
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
      title: 'Emergência Médica',
      description: 'Emergência médica geral',
      id: 'medical',
      emergencyType: 'medical',
      severity: 'high',
      location: '',
      immediateActions: [
        'Manter calma',
        'Avaliar a situação',
        'Buscar ajuda médica',
      ],
      resources: [
        'Kit de primeiros socorros',
        'Telefone de emergência',
      ],
      contacts: {
        'emergência': '113',
        'hospital': 'local',
      },
      descriptionCreole: 'Emerjénsia médiku jeral',
      immediateActionsCreole: [
        'Mantén kalma',
        'Odja situason',
        'Buska djuda médiku',
      ],
      resourcesCreole: [
        'Kit di primeiru sokoru',
        'Telefoni di emerjénsia',
      ],
    );

    _emergencyDatabase['natural'] = CrisisResponseData(
      title: 'Desastre Natural',
      description: 'Desastre natural',
      id: 'natural',
      emergencyType: 'natural',
      severity: 'medium',
      location: '',
      immediateActions: [
        'Procurar abrigo seguro',
        'Evitar áreas de risco',
        'Seguir orientações locais',
      ],
      resources: [
        'Água potável',
        'Alimentos não perecíveis',
        'Lanternas',
      ],
      contacts: {
        'emergência': '113',
        'proteção civil': 'local',
      },
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

  /// Dados padrão para emergências não catalogadas
  CrisisResponseData _getDefaultCrisisData(String emergencyType) =>
      CrisisResponseData(
        title: 'Emergência Desconhecida',
        description: 'Emergência não identificada. Procure ajuda local.',
        id: 'unknown',
        emergencyType: emergencyType,
        severity: 'medium',
        location: '',
        immediateActions: [
          'Manter calma',
          'Avaliar situação',
          'Buscar ajuda',
        ],
        resources: [
          'Kit de primeiros socorros',
        ],
        contacts: {
          'emergência': '113',
        },
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
}
