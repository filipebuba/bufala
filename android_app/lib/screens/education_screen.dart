import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';

import '../config/app_config.dart';
import '../models/offline_learning_models.dart';
import '../screens/content_view_screen.dart';
import '../services/gemma3_backend_service.dart';
import '../services/offline_learning_service.dart';
import '../services/integrated_api_service.dart';
import '../services/environmental_api_service.dart';
import '../utils/app_colors.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final IntegratedApiService _apiService = IntegratedApiService();
  final EnvironmentalApiService _environmentalApiService =
      EnvironmentalApiService(baseUrl: AppConfig.apiBaseUrl);
  late OfflineLearningService _learningService;
  late Gemma3BackendService _gemmaService;

  // Speech and Audio
  // final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _speechEnabled = false; // was: false // _speechEnabled = false;
  bool _isListening = false;
  final String _lastWords = '';

  // Image
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;

  // Learning State
  bool _isLoading = false;
  bool _useCreole = false;
  String _currentLanguage = 'pt-BR';
  String _selectedSubject = '';
  final String _currentLevel = 'beginner';
  List<OfflineLearningContent> _availableContent = [];
  OfflineLearningContent? _currentContent;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _initSpeech();
  }

  Future<void> _initializeServices() async {
    _learningService = OfflineLearningService();
    _gemmaService = Gemma3BackendService();

    try {
      // OfflineLearningService não tem método initialize, não fazer nada
      final gemmaConnected = await _gemmaService.initialize();
      print(gemmaConnected
          ? '✅ Serviços educacionais conectados ao Gemma-3'
          : '🟡 Serviços educacionais em modo offline');
    } catch (e) {
      print('Erro ao inicializar serviços: $e');
    }
  }

  Future<void> _initSpeech() async {
    try {
      _speechEnabled = false; // await _speechToText.initialize();
      setState(() {});
    } catch (e) {
      print('Erro ao inicializar speech: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(_useCreole ? 'Sikolansa' : 'Educação'),
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: Icon(_useCreole ? Icons.language : Icons.translate),
              onPressed: () {
                setState(() {
                  _useCreole = !_useCreole;
                  _currentLanguage = _useCreole ? 'crioulo-gb' : 'pt-BR';
                });
              },
            ),
          ],
        ),
        body: Column(
          children: [
            if (_isLoading) const LinearProgressIndicator(),
            Expanded(
              child: _selectedSubject.isEmpty
                  ? _buildSubjectSelection()
                  : _buildLearningContent(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _isListening ? _stopListening : _startListening,
          backgroundColor: _isListening ? Colors.red : AppColors.primaryGreen,
          child: Icon(_isListening ? Icons.mic_off : Icons.mic),
        ),
      );

  Widget _buildSubjectSelection() {
    final subjects = [
      {
        'id': 'literacy',
        'title': 'Alfabetização',
        'title_creole': 'Alfabetizason',
        'icon': Icons.menu_book_rounded,
        'description': 'Aprender a ler e escrever',
        'description_creole': 'Aprende lei i skrève',
        'color': Colors.blue,
      },
      {
        'id': 'math',
        'title': 'Matemática',
        'title_creole': 'Matemátika',
        'icon': Icons.calculate_rounded,
        'description': 'Números e cálculos básicos',
        'description_creole': 'Númeru i kálkulu básiku',
        'color': Colors.purple,
      },
      {
        'id': 'health',
        'title': 'Saúde',
        'title_creole': 'Saúdi',
        'icon': Icons.health_and_safety_rounded,
        'description': 'Cuidados com a saúde',
        'description_creole': 'Kuidadu ku saúdi',
        'color': Colors.red,
      },
      {
        'id': 'agriculture',
        'title': 'Agricultura',
        'title_creole': 'Agrikultura',
        'icon': Icons.eco_rounded,
        'description': 'Técnicas de cultivo',
        'description_creole': 'Téknika di kultivo',
        'color': Colors.green,
      },
    ];

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.green[50]!, Colors.white],
        ),
      ),
      child: Column(
        children: [
          // Cabeçalho moderno
          Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(
                  Icons.school_rounded,
                  size: 48,
                  color: AppColors.primaryGreen,
                ),
                const SizedBox(height: 16),
                Text(
                  _useCreole
                      ? 'Escolha o Tipo de Educação'
                      : 'Escolha o Tipo de Educação',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _useCreole
                      ? 'Selecione a modalidade que melhor atende suas necessidades'
                      : 'Selecione a modalidade que melhor atende suas necessidades',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Grid de matérias
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: subjects.length,
              itemBuilder: (context, index) {
                final subject = subjects[index];
                final title =
                    subject[_useCreole ? 'title_creole' : 'title'] as String;
                final description =
                    subject[_useCreole ? 'description_creole' : 'description']
                        as String;
                final color = subject['color'] as Color;

                return _buildModernSubjectCard(
                  subject['id'] as String,
                  title,
                  description,
                  subject['icon'] as IconData,
                  color,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernSubjectCard(
    String id,
    String title,
    String description,
    IconData icon,
    Color color,
  ) =>
      GestureDetector(
        onTap: () => _selectSubject(id),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: color.withOpacity(0.2),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 32,
                    color: color,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildLearningContent() => Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _selectedSubject = '';
                      _availableContent.clear();
                    });
                  },
                ),
                Expanded(
                  child: Text(
                    _getSubjectTitle(),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _availableContent.isEmpty
                ? _buildEmptyContent()
                : _buildContentList(),
          ),
        ],
      );

  Widget _buildEmptyContent() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _useCreole ? 'Konteúdu ta karga...' : 'Carregando conteúdo...',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _loadContent,
              icon: const Icon(Icons.refresh),
              label: Text(_useCreole ? 'Karga konteúdu' : 'Carregar conteúdo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );

  Widget _buildContentList() => ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _availableContent.length,
        itemBuilder: (context, index) {
          final content = _availableContent[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryGreen,
                child: Text('${index + 1}'),
              ),
              title: Text(content.title),
              subtitle: Text(content.description),
              trailing: const Icon(Icons.play_arrow),
              onTap: () => _viewContent(content),
            ),
          );
        },
      );

  void _selectSubject(String subjectId) {
    setState(() {
      _selectedSubject = subjectId;
      _isLoading = true;
    });

    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      setState(() => _isLoading = true);

      var content = <OfflineLearningContent>[];

      // Primeiro, tentar usar o backend integrado para conteúdo dinâmico com parâmetros específicos
      try {
        var level = _currentLevel;
        const ageGroup = 'adultos';

        // Determinar nível baseado no assunto
        if (_selectedSubject.toLowerCase().contains('math')) {
          level = 'intermediário';
        }

        final response = await _apiService.askEducationQuestion(
          'Criar lição educacional completa sobre $_selectedSubject com exercícios práticos para nível $level em ${_useCreole ? 'crioulo da Guiné-Bissau' : 'português'}',
        );

        if (response['success'] == true && response['data'] != null) {
          // Processar resposta do backend de forma estruturada
          final data = response['data'];
          final parsedContent =
              _parseBackendResponse(data, _selectedSubject, level, ageGroup);

          final backendContent = OfflineLearningContent(
            id: 'backend_${DateTime.now().millisecondsSinceEpoch}',
            title: parsedContent['title'],
            description: parsedContent['description'],
            subject: _getSubjectTitle(),
            level: parsedContent['level'],
            languages: [if (_useCreole) 'crioulo-gb' else 'pt-BR'],
            content: parsedContent['content'],
            type: 'ai_generated',
            createdAt: DateTime.now(),
            metadata: parsedContent['metadata'],
          );
          content.add(backendContent);
          print('✅ Conteúdo educativo gerado pelo backend');
        }
      } catch (e) {
        print('⚠️ Backend indisponível para conteúdo dinâmico: $e');
      }

      // Sempre adicionar conteúdo local como base (enriquecido)
      try {
        final localContent = await _learningService.getContentBySubject(
          _selectedSubject,
        );
        // Filtrar conteúdo por idioma se possível
        final filteredLocal = localContent
            .where(
              (content) => content.languages
                  .contains(_useCreole ? 'crioulo-gb' : 'pt-BR'),
            )
            .toList();
        content.addAll(filteredLocal.isNotEmpty ? filteredLocal : localContent);
      } catch (e) {
        print('⚠️ Erro ao obter conteúdo local: $e');
      }

      // Se ainda não há conteúdo, tentar Gemma-3 como último recurso com contexto específico
      if (content.isEmpty && _gemmaService.isInitialized) {
        try {
          final generatedContent =
              await _gemmaService.generateEducationalContent(
            subject: _selectedSubject,
            language: _useCreole ? 'crioulo-gb' : 'pt-BR',
            level: _currentLevel,
            studentProfile: _lastWords.isNotEmpty ? _lastWords : null,
          );
          content = [generatedContent];
          print('✅ Conteúdo educativo gerado com Gemma-3 (fallback)');
        } catch (e) {
          print('⚠️ Erro ao gerar com Gemma-3: $e');
        }
      }

      // Se ainda não há conteúdo, criar conteúdo padrão estruturado
      if (content.isEmpty) {
        content = [_createDefaultContent(_selectedSubject)];
        print('🟡 Usando conteúdo padrão (fallback final)');
      }

      setState(() {
        _availableContent = content;
        _isLoading = false;
      });

      print('📚 Total de conteúdos carregados: ${content.length}');
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showErrorDialog('Erro ao carregar conteúdo: $e');
      }
    }
  }

  OfflineLearningContent _createDefaultContent(String subject) {
    final contentMap = {
      'literacy': {
        'title': '📚 Alfabetização - Primeiros Passos',
        'content': '''🔤 **APRENDENDO A LER E ESCREVER**

**📖 Vamos começar com as vogais:**
• A - como em ÁGUA 💧
• E - como em ESCOLA 🏫
• I - como em IGREJA ⛪
• O - como em OLHO 👁️
• U - como em UVA 🍇

**✏️ Exercício prático:**
1. Trace cada letra no ar
2. Escreva cada vogal 5 vezes
3. Encontre 3 objetos que começam com cada vogal

**🎯 Meta diária:** Pratique 15 minutos por dia!

**💡 Dica:** Use objetos do seu dia a dia para associar às letras!''',
        'description': 'Aprenda a reconhecer e escrever as primeiras letras',
      },
      'math': {
        'title': '🔢 Matemática - Números e Contagem',
        'content': '''🧮 **APRENDENDO NÚMEROS**

**📊 Números de 1 a 10:**
1 - UM 🍎
2 - DOIS 🍎🍎
3 - TRÊS 🍎🍎🍎
4 - QUATRO 🍎🍎🍎🍎
5 - CINCO ✋
6 - SEIS
7 - SETE
8 - OITO
9 - NOVE
10 - DEZ

**🎯 Exercícios práticos:**
1. Conte seus dedos
2. Conte objetos em casa
3. Conte moedas

**➕ Soma simples:**
2 + 2 = 4
3 + 1 = 4
5 + 5 = 10

**💰 Exemplo com dinheiro:**
Tenho 3 moedas, ganho 2 = 5 moedas!''',
        'description': 'Aprenda números básicos e operações simples',
      },
      'health': {
        'title': '🏥 Saúde - Cuidados Básicos',
        'content': '''🧼 **CUIDADOS COM A SAÚDE**

**👐 Lavar as mãos:**
1. Use água e sabão
2. Esfregue por 20 segundos
3. Lave entre os dedos
4. Enxágue bem
5. Seque com toalha limpa

**🦷 Cuidar dos dentes:**
• Escove 3 vezes ao dia
• Use pasta de dente
• Escove por 2 minutos
• Não esqueça a língua

**🚿 Banho diário:**
• Use água e sabão
• Lave todo o corpo
• Lave o cabelo
• Use toalha limpa

**⚠️ Importante:** Higiene previne doenças!''',
        'description': 'Aprenda hábitos essenciais de higiene e saúde',
      },
      'agriculture': {
        'title': '🌱 Agricultura - Plantio Básico',
        'content': '''🌾 **APRENDENDO A PLANTAR**

**🌍 Preparação do solo:**
1. Limpe o terreno
2. Cave a terra
3. Misture com adubo
4. Nivele o solo

**🌰 Como plantar:**
1. Faça buracos pequenos
2. Coloque as sementes
3. Cubra com terra
4. Regue com cuidado

**💧 Cuidados diários:**
• Regue de manhã cedo
• Retire ervas daninhas
• Proteja do sol forte
• Observe o crescimento

**🌟 Dica:** Comece com plantas fáceis como feijão!

**📅 Cronograma:**
• Semana 1-2: Plantio
• Semana 3-4: Crescimento
• Semana 5-8: Colheita''',
        'description': 'Aprenda os fundamentos do plantio e cultivo',
      },
    };

    final subjectData = contentMap[subject.toLowerCase()] ??
        {
          'title': '📖 ${_getSubjectTitle()}',
          'content': '''**Conteúdo sobre ${_getSubjectTitle()}**

Este é um conteúdo educacional básico sobre ${_getSubjectTitle()}.

🎯 **Objetivos:**
• Aprender conceitos fundamentais
• Desenvolver habilidades práticas
• Aplicar conhecimentos no dia a dia

📝 **Como estudar:**
1. Leia com atenção
2. Pratique os exercícios
3. Aplique o que aprendeu

💡 Continue estudando para melhorar!''',
          'description':
              'Conteúdo educacional básico sobre ${_getSubjectTitle()}',
        };

    return OfflineLearningContent(
      id: 'default_${DateTime.now().millisecondsSinceEpoch}',
      title: subjectData['title']!,
      content: subjectData['content']!,
      description: subjectData['description']!,
      subject: _getSubjectTitle(),
      languages: [if (_useCreole) 'crioulo-gb' else 'pt-BR'],
      level: _currentLevel,
      type: 'default',
      createdAt: DateTime.now(),
      metadata: {
        'source': 'default',
        'created_at': DateTime.now().toIso8601String(),
        'language': _useCreole ? 'crioulo-gb' : 'pt-BR',
      },
    );
  }

  void _viewContent(OfflineLearningContent content) {
    setState(() {
      _currentContent = content;
    });

    // Navegar para tela de visualização do conteúdo
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ContentViewScreen(content: content),
      ),
    );
  }

  String _getSubjectTitle() {
    switch (_selectedSubject) {
      case 'literacy':
        return _useCreole ? 'Alfabetizason' : 'Alfabetização';
      case 'math':
        return _useCreole ? 'Matemátika' : 'Matemática';
      case 'health':
        return _useCreole ? 'Saúdi' : 'Saúde';
      case 'agriculture':
        return _useCreole ? 'Agrikultura' : 'Agricultura';
      default:
        return _useCreole ? 'Sikolansa' : 'Educação';
    }
  }

  Future<void> _startListening() async {
    if (!_speechEnabled) return;

    // Comentado: await _speechToText.listen(
    //   onResult: (result) {
    //     setState(() {
    //       _lastWords = result.recognizedWords;
    //     });
    //   },
    // );

    setState(() => _isListening = true);
  }

  Future<void> _stopListening() async {
    // await _speechToText.stop();
    setState(() => _isListening = false);
  }

  Map<String, dynamic> _parseBackendResponse(
      dynamic data, String subject, String level, String ageGroup) {
    try {
      if (data is Map) {
        // Extrair conteúdo principal
        var mainContent = '';
        var title = '';
        var description = '';

        // Verificar se há resposta aninhada
        if (data.containsKey('response') && data['response'] is String) {
          mainContent = data['response'];
        } else if (data.containsKey('content') && data['content'] is String) {
          mainContent = data['content'];
        } else {
          // Tentar extrair texto de qualquer campo string
          for (final value in data.values) {
            if (value is String && value.length > 50) {
              mainContent = value;
              break;
            }
          }
        }

        // Se ainda não temos conteúdo, usar o toString do objeto
        if (mainContent.isEmpty) {
          mainContent = data.toString();
        }

        // Limpar marcadores Markdown do conteúdo
        mainContent = _cleanMarkdownFormatting(mainContent);

        // Gerar título baseado no assunto
        title = data['title'] ?? _generateTitleFromSubject(subject);

        // Gerar descrição
        description =
            data['description'] ?? 'Conteúdo educacional gerado pela IA';

        // Extrair informações educacionais se disponíveis
        var educationalInfo = <String, dynamic>{};
        if (data.containsKey('educational_info')) {
          educationalInfo = Map<String, dynamic>.from(data['educational_info']);
        }

        // Extrair dicas de aprendizagem
        var learningTips = <String>[];
        if (educationalInfo.containsKey('learning_tips')) {
          learningTips =
              List<String>.from(educationalInfo['learning_tips'] ?? []);
        }

        // Extrair recursos adicionais
        var additionalResources = <String>[];
        if (educationalInfo.containsKey('additional_resources')) {
          additionalResources =
              List<String>.from(educationalInfo['additional_resources'] ?? []);
        }

        // Formatar conteúdo final
        final formattedContent = _formatEducationalContent(
            mainContent, learningTips, additionalResources, subject);

        return {
          'title': title,
          'description': description,
          'level': educationalInfo['level'] ?? level,
          'content': formattedContent,
          'metadata': {
            'source': 'backend_ai',
            'language': _useCreole ? 'crioulo-gb' : 'pt-BR',
            'generated_at': DateTime.now().toIso8601String(),
            'level': level,
            'age_group': ageGroup,
            'subject': educationalInfo['subject'] ?? subject,
            'has_learning_tips': learningTips.isNotEmpty,
            'has_resources': additionalResources.isNotEmpty,
            'fallback': data['fallback'] ?? false,
          },
        };
      } else {
        // Se não é um Map, tratar como string
        final contentText = _cleanMarkdownFormatting(data.toString());
        return {
          'title': _generateTitleFromSubject(subject),
          'description': 'Conteúdo educacional personalizado',
          'level': level,
          'content': _formatSimpleContent(contentText, subject),
          'metadata': {
            'source': 'backend_ai_simple',
            'language': _useCreole ? 'crioulo-gb' : 'pt-BR',
            'generated_at': DateTime.now().toIso8601String(),
            'level': level,
            'age_group': ageGroup,
            'content_type': 'simple_text',
          },
        };
      }
    } catch (e) {
      print('❌ Erro ao processar resposta do backend: $e');
      return {
        'title': _generateTitleFromSubject(subject),
        'description': 'Conteúdo educacional com erro de processamento',
        'level': level,
        'content': '''⚠️ **Erro no Processamento**

Ocorreu um erro ao processar o conteúdo educacional do servidor.

🔄 **Tente:**
• Recarregar o conteúdo
• Verificar sua conexão
• Selecionar outro tópico

📚 **Conteúdo offline disponível!**
Você pode acessar lições básicas mesmo sem conexão.''',
        'metadata': {
          'source': 'backend_ai_error',
          'error': e.toString(),
          'generated_at': DateTime.now().toIso8601String(),
          'error_type': 'parsing_error',
        },
      };
    }
  }

  String _generateTitleFromSubject(String subject) {
    final titleMap = {
      'literacy': '📚 Alfabetização - Lição Personalizada',
      'math': '🔢 Matemática - Conteúdo IA',
      'health': '🏥 Saúde - Orientações Personalizadas',
      'agriculture': '🌱 Agricultura - Dicas Especializadas',
    };

    return titleMap[subject.toLowerCase()] ?? '📖 $subject - Conteúdo IA';
  }

  String _formatEducationalContent(String mainContent, List<String> tips,
      List<String> resources, String subject) {
    var formatted = mainContent;

    // Adicionar dicas de aprendizagem se disponíveis
    if (tips.isNotEmpty) {
      formatted += '\n\n💡 **Dicas de Aprendizagem:**\n';
      for (var i = 0; i < tips.length; i++) {
        formatted += '${i + 1}. ${tips[i]}\n';
      }
    }

    // Adicionar recursos adicionais se disponíveis
    if (resources.isNotEmpty) {
      formatted += '\n\n📚 **Recursos Adicionais:**\n';
      for (final resource in resources) {
        formatted += '• $resource\n';
      }
    }

    // Adicionar nota sobre o contexto local
    formatted +=
        '\n\n🌍 **Adaptado para a Guiné-Bissau**\nEste conteúdo foi gerado considerando o contexto local e recursos disponíveis.';

    return formatted;
  }

  String _formatSimpleContent(String content, String subject) =>
      '''📖 **Conteúdo sobre $subject**

$content

💡 **Lembre-se:**
• Pratique regularmente
• Aplique no dia a dia
• Compartilhe com outros

🎯 Continue aprendendo!''';

  /// Remove marcadores de formatação Markdown das respostas do Gemma-3
  String _cleanMarkdownFormatting(String text) {
    if (text.isEmpty) return text;

    var cleaned = text;

    // Remover marcadores de negrito (**texto**)
    cleaned = cleaned.replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1');

    // Remover marcadores de cabeçalho (## texto)
    cleaned =
        cleaned.replaceAll(RegExp(r'^#{1,6}\s*(.*)$', multiLine: true), r'$1');

    // Remover marcadores de itálico (*texto*)
    cleaned = cleaned.replaceAll(RegExp(r'\*(.*?)\*'), r'$1');

    // Remover marcadores de código (`código`)
    cleaned = cleaned.replaceAll(RegExp(r'`(.*?)`'), r'$1');

    // Limpar múltiplas quebras de linha
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    // Remover espaços extras no início e fim
    cleaned = cleaned.trim();

    return cleaned;
  }

  // Função para limpar caracteres especiais dos textos do Gemma3
  String _cleanGemmaText(String? text) {
    if (text == null || text.isEmpty) return '';

    // Remove caracteres especiais comuns que podem aparecer na resposta do Gemma3
    var cleanedText = text
        .replaceAll(RegExp(r'[\*\#\`\~\^\{\}\[\]\|\\]'),
            '') // Remove markdown e caracteres especiais
        .replaceAll(RegExp(r'\n\s*\n'), '\n') // Remove quebras de linha duplas
        .replaceAll(RegExp(r'^\s*[\-\*\+]\s*'),
            '') // Remove marcadores de lista no início
        .replaceAll(RegExp(r'\s+'), ' ') // Normaliza espaços múltiplos
        .replaceAll(RegExp(r'["' ']'), '"') // Normaliza aspas
        .replaceAll(RegExp(r'[\u2013\u2014]'), '-') // Normaliza travessões
        .replaceAll(RegExp(r'[\u2026]'), '...') // Normaliza reticências
        .replaceAll(RegExp(r'[\u00A0]'), ' ') // Remove espaços não-quebráveis
        .trim();

    // Remove caracteres de controle e não-ASCII problemáticos
    cleanedText = cleanedText.replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '');

    return cleanedText;
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_useCreole ? 'Erro' : 'Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_useCreole ? 'OK' : 'OK'),
          ),
        ],
      ),
    );
  }
}

// Tela de visualização de conteúdo simplificada
// ...existing code...
