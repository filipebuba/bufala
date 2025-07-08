import 'dart:async';
import '../models/offline_learning_models.dart';

/// Serviço de aprendizagem offline simplificado para build
class OfflineLearningService {
  factory OfflineLearningService() => _instance;
  OfflineLearningService._internal();
  static final OfflineLearningService _instance =
      OfflineLearningService._internal();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Simular inicialização
      await Future.delayed(const Duration(milliseconds: 100));
      _isInitialized = true;
    } catch (e) {
      print('Erro na inicialização do serviço de aprendizagem: $e');
    }
  }

  Future<List<OfflineLearningContent>> getContentBySubject(
      String subject) async {
    if (!_isInitialized) await initialize();

    // Gerar conteúdo baseado no assunto
    switch (subject.toLowerCase()) {
      case 'alfabetização':
      case 'literacy':
        return [
          OfflineLearningContent(
            id: 'literacy_pt_001',
            title: 'Alfabetização em Português - Básico',
            content: 'Letras: A, E, I, O, U\nPalavras: AVO, EVA, IVO, OVO, UVA',
            description: 'Curso básico de alfabetização em português',
            subject: 'Alfabetização',
            languages: ['pt'],
            level: 'Básico',
            type: 'lesson',
            metadata: {'difficulty': 1, 'duration': '30min'},
            createdAt: DateTime.now(),
          ),
          OfflineLearningContent(
            id: 'literacy_creole_001',
            title: 'Alfabetização em Crioulo - Básico',
            content: 'Letra: A, E, I, O, U\nPalavra: AVO, EVA, IVO, OVO, UVA',
            description: 'Curso básico de alfabetização em crioulo',
            subject: 'Alfabetização',
            languages: ['ht'],
            level: 'Básico',
            type: 'lesson',
            metadata: {'difficulty': 1, 'duration': '30min'},
            createdAt: DateTime.now(),
          ),
        ];

      case 'matemática':
      case 'math':
        return [
          OfflineLearningContent(
            id: 'math_numbers_001',
            title: 'Números - Básico',
            content: 'Números de 1 a 10:\n1, 2, 3, 4, 5, 6, 7, 8, 9, 10',
            description: 'Conceitos básicos de números para iniciantes',
            subject: 'Matemática',
            level: 'Básico',
            languages: ['pt', 'ht'],
            type: 'text',
            metadata: {'category': 'Educação'},
            createdAt: DateTime.now(),
          ),
          OfflineLearningContent(
            id: 'math_operations_001',
            title: 'Operações Básicas',
            content: 'Adição: 1+1=2, 2+2=4\nSubtração: 4-2=2, 3-1=2',
            description: 'Operações matemáticas básicas: adição e subtração',
            subject: 'Matemática',
            level: 'Básico',
            languages: ['pt', 'ht'],
            type: 'text',
            metadata: {'category': 'Educação'},
            createdAt: DateTime.now(),
          ),
        ];

      case 'saúde':
      case 'health':
        return [
          OfflineLearningContent(
            id: 'health_hygiene_001',
            title: 'Higiene Básica',
            content: 'Lave as mãos com sabão\nEscove os dentes 2x ao dia',
            description:
                'Princípios básicos de higiene pessoal para manter a saúde',
            subject: 'Saúde',
            level: 'Básico',
            languages: ['pt', 'ht'],
            type: 'lesson',
            metadata: {'category': 'Saúde', 'duration': '15min'},
            createdAt: DateTime.now(),
          ),
          OfflineLearningContent(
            id: 'health_nutrition_001',
            title: 'Nutrição Básica',
            content: 'Coma frutas e vegetais\nBeba água limpa',
            description:
                'Conceitos fundamentais de nutrição e alimentação saudável',
            subject: 'Saúde',
            level: 'Básico',
            languages: ['pt', 'ht'],
            type: 'lesson',
            metadata: {'category': 'Saúde', 'duration': '20min'},
            createdAt: DateTime.now(),
          ),
        ];

      case 'agricultura':
      case 'agriculture':
        return [
          OfflineLearningContent(
            id: 'agri_basic_001',
            title: 'Cultivo Básico',
            content: 'Prepare o solo\nPlante as sementes\nRegue diariamente',
            description:
                'Técnicas básicas de cultivo para iniciantes na agricultura',
            subject: 'Agricultura',
            level: 'Básico',
            languages: ['pt', 'ht'],
            type: 'lesson',
            metadata: {'category': 'Agricultura', 'duration': '25min'},
            createdAt: DateTime.now(),
          ),
        ];

      default:
        return _getAllContent();
    }
  }

  Future<List<OfflineLearningContent>> _getAllContent() async => [
      OfflineLearningContent(
        id: 'general_001',
        title: 'Conteúdo Geral',
        content: 'Conteúdo educativo básico',
        description:
            'Material educativo geral para introdução aos temas básicos',
        subject: 'Geral',
        level: 'Básico',
        languages: ['pt', 'ht'],
        type: 'lesson',
        metadata: {'category': 'Geral', 'duration': '10min'},
        createdAt: DateTime.now(),
      ),
    ];

  Future<List<OfflineLearningContent>> searchContent(String query) async {
    if (!_isInitialized) await initialize();

    final allContent = await _getAllContent();
    return allContent
        .where((content) =>
            content.title.toLowerCase().contains(query.toLowerCase()) ||
            content.subject.toLowerCase().contains(query.toLowerCase()) ||
            content.content.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  Future<OfflineLearningContent?> getContentById(String id) async {
    if (!_isInitialized) await initialize();

    final allContent = await _getAllContent();
    try {
      return allContent.firstWhere((content) => content.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> isContentAvailable(String id) async =>
      (await getContentById(id)) != null;

  Future<void> cacheContent(OfflineLearningContent content) async {
    // Simular cache
    print('Conteúdo ${content.id} armazenado em cache');
  }
}
