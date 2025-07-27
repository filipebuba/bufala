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

      case 'literacy':
      case 'alfabetização':
        return [
          OfflineLearningContent(
            id: 'lit_001',
            title: 'Reconhecendo as Letras',
            content:
                'O alfabeto português tem 26 letras. Vamos começar com as vogais: A, E, I, O, U. Estas são as letras mais importantes porque aparecem em todas as palavras. Pratique escrevendo cada vogal várias vezes.',
            description: 'Aprenda a reconhecer e escrever as letras do alfabeto',
            subject: 'Alfabetização',
            languages: ['pt-BR'],
            level: 'básico',
            type: 'lesson',
            metadata: {'category': 'letras', 'step': 1},
            createdAt: now,
          ),
          OfflineLearningContent(
            id: 'lit_002',
            title: 'Formando Sílabas',
            content:
                'Sílabas são pedaços de palavras. Juntamos consoantes com vogais para formar sílabas. Exemplos: BA, BE, BI, BO, BU. Pratique: BABA, BEBÊ, BIBO, BOBO.',
            description: 'Como juntar letras para formar sílabas',
            subject: 'Alfabetização',
            languages: ['pt-BR'],
            level: 'básico',
            type: 'lesson',
            metadata: {'category': 'silabas', 'step': 2},
            createdAt: now,
          ),
          OfflineLearningContent(
            id: 'lit_003',
            title: 'Primeiras Palavras',
            content:
                'Vamos formar palavras simples do dia a dia: CASA, MESA, PATO, GATO, BOLA, ÁGUA. Leia cada palavra devagar, sílaba por sílaba: CA-SA, ME-SA, PA-TO.',
            description: 'Aprenda a ler suas primeiras palavras',
            subject: 'Alfabetização',
            languages: ['pt-BR'],
            level: 'básico',
            type: 'lesson',
            metadata: {'category': 'palavras', 'step': 3},
            createdAt: now,
          ),
          OfflineLearningContent(
            id: 'lit_004',
            title: 'Frases Simples',
            content:
                'Agora vamos formar frases curtas: "O GATO SUBIU NO TELHADO", "A CASA É BONITA", "EU GOSTO DE ÁGUA". Leia cada frase pausadamente.',
            description: 'Como formar e ler frases simples',
            subject: 'Alfabetização',
            languages: ['pt-BR'],
            level: 'intermediário',
            type: 'lesson',
            metadata: {'category': 'frases', 'step': 4},
            createdAt: now,
          ),
          OfflineLearningContent(
            id: 'lit_005',
            title: 'Escrevendo Seu Nome',
            content:
                'Escrever o próprio nome é muito importante. Pratique escrevendo seu nome completo várias vezes. Comece devagar, letra por letra, depois tente escrever mais rápido.',
            description: 'Aprenda a escrever seu nome corretamente',
            subject: 'Alfabetização',
            languages: ['pt-BR'],
            level: 'básico',
            type: 'practice',
            metadata: {'category': 'nome', 'step': 5},
            createdAt: now,
          ),
        ];

      case 'math':
      case 'matemática':
        return [
          OfflineLearningContent(
            id: 'math_001',
            title: 'Números de 1 a 10',
            content:
                'Vamos aprender os números: 1 (um), 2 (dois), 3 (três), 4 (quatro), 5 (cinco), 6 (seis), 7 (sete), 8 (oito), 9 (nove), 10 (dez). Conte nos dedos: 1, 2, 3, 4, 5.',
            description: 'Reconheça e conte os números básicos',
            subject: 'Matemática',
            languages: ['pt-BR'],
            level: 'básico',
            type: 'lesson',
            metadata: {'category': 'numeros', 'range': '1-10'},
            createdAt: now,
          ),
          OfflineLearningContent(
            id: 'math_002',
            title: 'Somando Números',
            content:
                'Somar é juntar quantidades. 1 + 1 = 2, 2 + 1 = 3, 3 + 2 = 5. Use os dedos para ajudar: mostre 2 dedos, depois mais 3 dedos. Quantos dedos no total? 5!',
            description: 'Aprenda a somar números pequenos',
            subject: 'Matemática',
            languages: ['pt-BR'],
            level: 'básico',
            type: 'lesson',
            metadata: {'category': 'soma', 'operation': 'addition'},
            createdAt: now,
          ),
          OfflineLearningContent(
            id: 'math_003',
            title: 'Subtraindo Números',
            content:
                'Subtrair é tirar quantidades. 5 - 2 = 3, 10 - 3 = 7. Se você tem 5 frutas e come 2, ficam 3 frutas. Pratique com objetos do dia a dia.',
            description: 'Aprenda a subtrair números pequenos',
            subject: 'Matemática',
            languages: ['pt-BR'],
            level: 'básico',
            type: 'lesson',
            metadata: {'category': 'subtracao', 'operation': 'subtraction'},
            createdAt: now,
          ),
          OfflineLearningContent(
            id: 'math_004',
            title: 'Contando Dinheiro',
            content:
                'Vamos aprender sobre dinheiro. 1 real, 2 reais, 5 reais, 10 reais. Se você tem 5 reais e ganha mais 3 reais, terá 8 reais no total. Pratique contando moedas.',
            description: 'Como contar e somar dinheiro',
            subject: 'Matemática',
            languages: ['pt-BR'],
            level: 'intermediário',
            type: 'practical',
            metadata: {'category': 'dinheiro', 'application': 'daily'},
            createdAt: now,
          ),
          OfflineLearningContent(
            id: 'math_005',
            title: 'Medindo Tempo',
            content:
                'O tempo é medido em horas, minutos e segundos. 1 hora = 60 minutos. 1 minuto = 60 segundos. O relógio nos ajuda a saber que horas são. Pratique lendo as horas.',
            description: 'Entenda como medir e ler o tempo',
            subject: 'Matemática',
            languages: ['pt-BR'],
            level: 'intermediário',
            type: 'lesson',
            metadata: {'category': 'tempo', 'unit': 'time'},
            createdAt: now,
          ),
        ];

      case 'health':
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
          OfflineLearningContent(
            id: 'health_003',
            title: 'Cuidados na Gravidez',
            content:
                'Durante a gravidez é importante: fazer consultas regulares, tomar ácido fólico, evitar álcool e cigarro, comer bem e descansar. Procure ajuda médica se sentir dores fortes.',
            description: 'Cuidados essenciais durante a gravidez',
            subject: 'Saúde',
            languages: ['pt-BR'],
            level: 'essencial',
            type: 'health_guide',
            metadata: {'category': 'gravidez', 'priority': 'high', 'target': 'women'},
            createdAt: now,
          ),
          OfflineLearningContent(
            id: 'health_004',
            title: 'Sinais de Emergência',
            content:
                'Procure ajuda médica urgente se houver: dificuldade para respirar, dor no peito, sangramento intenso, perda de consciência, febre muito alta (acima de 39°C).',
            description: 'Reconheça quando buscar ajuda médica urgente',
            subject: 'Saúde',
            languages: ['pt-BR'],
            level: 'essencial',
            type: 'emergency',
            metadata: {'category': 'emergencia', 'priority': 'critical'},
            createdAt: now,
          ),
        ];

      case 'agriculture':
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
