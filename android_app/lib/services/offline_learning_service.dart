import '../models/offline_learning_models.dart';

/// Serviço de aprendizado offline simplificado
abstract class IOfflineLearningService {
  Future<List<OfflineLearningContent>> getContent(String subject);
  Future<List<OfflineLearningContent>> getContentBySubject(String subject);
  Future<List<OfflineLearningContent>> getContentByLanguage(String language);
  Future<void> saveProgress(String contentId, double progress);
  Future<double> getProgress(String contentId);
}

class OfflineLearningService implements IOfflineLearningService {
  /// Gera conteúdo de aprendizado
  @override
  Future<List<OfflineLearningContent>> getContent(String subject) async {
    try {
      // Simula carregamento assíncrono
      await Future<void>.delayed(const Duration(milliseconds: 100));
      return _getOfflineContent(subject);
    } catch (e) {
      print('Erro ao gerar conteúdo: $e');
      return _getOfflineContent(subject);
    }
  }

  /// Obtém conteúdo por assunto específico
  @override
  Future<List<OfflineLearningContent>> getContentBySubject(
      String subject) async => getContent(subject);

  /// Obtém conteúdo por idioma
  @override
  Future<List<OfflineLearningContent>> getContentByLanguage(
      String language) async {
    try {
      final allContent = await getContent('todos');
      return allContent
          .where((content) => content.languages.contains(language))
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// Salva progresso do usuário
  @override
  Future<void> saveProgress(String contentId, double progress) async {
    // Implementação simplificada para salvar progresso
    print('Progresso salvo para $contentId: $progress%');
  }

  /// Obtém progresso do usuário
  @override
  Future<double> getProgress(String contentId) async {
    // Implementação simplificada - retorna 0 por padrão
    return 0.0;
  }

  /// Conteúdo offline padrão com todos os campos obrigatórios
  List<OfflineLearningContent> _getOfflineContent(String subject) {
    final now = DateTime.now();

    switch (subject.toLowerCase()) {
      case 'agricultura':
        return [
          OfflineLearningContent(
            id: 'agri_001',
            title: 'Técnicas de Plantio Sustentável',
            content:
                'Técnicas básicas de plantio sustentável incluem rotação de culturas, uso de compostagem e controle natural de pragas. A rotação de culturas ajuda a manter a fertilidade do solo e quebra o ciclo de pragas e doenças.',
            description:
                'Aprenda técnicas básicas para agricultura sustentável',
            subject: 'Agricultura',
            languages: ['pt-BR'],
            level: 'básico',
            type: 'text',
            metadata: {'category': 'plantio', 'difficulty': 'basic'},
            createdAt: now,
          ),
          OfflineLearningContent(
            id: 'agri_002',
            title: 'Controle de Pragas Natural',
            content:
                'Métodos naturais para controle de pragas incluem uso de plantas repelentes, controle biológico e armadilhas. Plantas como manjericão, hortelã e alecrim ajudam a repelir insetos.',
            description:
                'Métodos ecológicos para controlar pragas na agricultura',
            subject: 'Agricultura',
            languages: ['pt-BR'],
            level: 'intermediário',
            type: 'text',
            metadata: {'category': 'pragas', 'difficulty': 'intermediate'},
            createdAt: now,
          ),
          OfflineLearningContent(
            id: 'agri_003',
            title: 'Irrigação Eficiente',
            content:
                'Sistemas de irrigação eficientes economizam água e melhoram a produtividade através de gotejamento e aspersão. O sistema por gotejamento é ideal para hortas e economiza até 50% de água.',
            description:
                'Como economizar água com sistemas de irrigação inteligentes',
            subject: 'Agricultura',
            languages: ['pt-BR'],
            level: 'avançado',
            type: 'text',
            metadata: {'category': 'irrigacao', 'difficulty': 'advanced'},
            createdAt: now,
          ),
          OfflineLearningContent(
            id: 'agri_004',
            title: 'Compostagem Caseira',
            content:
                'A compostagem transforma restos orgânicos em adubo natural rico em nutrientes para as plantas. Misture restos de vegetais com folhas secas em proporção 3:1.',
            description:
                'Como fazer compostagem em casa para fertilizar suas plantas',
            subject: 'Agricultura',
            languages: ['pt-BR'],
            level: 'básico',
            type: 'text',
            metadata: {'category': 'compostagem', 'difficulty': 'basic'},
            createdAt: now,
          ),
          OfflineLearningContent(
            id: 'agri_005',
            title: 'Cultivo Orgânico',
            content:
                'O cultivo orgânico utiliza apenas fertilizantes naturais e métodos ecológicos de manejo. Evita o uso de pesticidas sintéticos e promove a biodiversidade.',
            description: 'Fundamentos do cultivo orgânico sem pesticidas',
            subject: 'Agricultura',
            languages: ['pt-BR'],
            level: 'intermediário',
            type: 'text',
            metadata: {'category': 'organico', 'difficulty': 'intermediate'},
            createdAt: now,
          ),
        ];

      case 'saúde':
        return [
          OfflineLearningContent(
            id: 'health_001',
            title: 'Primeiros Socorros Básicos',
            content:
                'Primeiros socorros incluem avaliação da vítima, controle de sangramento, ressuscitação e imobilização. Sempre verifique a consciência e respiração antes de qualquer procedimento.',
            description:
                'Conhecimentos essenciais de primeiros socorros para emergências',
            subject: 'Saúde',
            languages: ['pt-BR'],
            level: 'essencial',
            type: 'emergency',
            metadata: {'category': 'emergencia', 'priority': 'high'},
            createdAt: now,
          ),
          OfflineLearningContent(
            id: 'health_002',
            title: 'Higiene e Saneamento',
            content:
                'A higiene adequada previne doenças transmissíveis. Lave as mãos frequentemente com sabão e água limpa por pelo menos 20 segundos.',
            description: 'Práticas de higiene para prevenção de doenças',
            subject: 'Saúde',
            languages: ['pt-BR'],
            level: 'básico',
            type: 'text',
            metadata: {'category': 'prevencao', 'priority': 'medium'},
            createdAt: now,
          ),
        ];

      case 'educação':
        return [
          OfflineLearningContent(
            id: 'edu_001',
            title: 'Alfabetização de Adultos',
            content:
                'Métodos de alfabetização adaptados para adultos focam na aplicação prática e experiências de vida. Use palavras do cotidiano como ponto de partida.',
            description:
                'Estratégias para ensinar leitura e escrita para adultos',
            subject: 'Educação',
            languages: ['pt-BR'],
            level: 'básico',
            type: 'text',
            metadata: {'category': 'alfabetizacao', 'target': 'adults'},
            createdAt: now,
          ),
        ];

      case 'todos':
      case 'geral':
        // Retorna todo o conteúdo disponível
        return [
          ..._getOfflineContent('agricultura'),
          ..._getOfflineContent('saúde'),
          ..._getOfflineContent('educação'),
        ];

      default:
        return [
          OfflineLearningContent(
            id: 'default_001',
            title: 'Bem-vindo ao Bu Fala',
            content:
                'Bu Fala é uma plataforma de aprendizado offline que oferece conteúdo educacional sobre agricultura, saúde e educação. Explore os diferentes tópicos disponíveis.',
            description: 'Introdução à plataforma Bu Fala',
            subject: 'Geral',
            languages: ['pt-BR'],
            level: 'básico',
            type: 'intro',
            metadata: {'category': 'welcome'},
            createdAt: now,
          ),
        ];
    }
  }
}
