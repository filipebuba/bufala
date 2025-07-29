import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';

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
  final EnvironmentalApiService _environmentalApiService = EnvironmentalApiService(baseUrl: 'http://localhost:5000');
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
  List<Map<String, dynamic>> _educationAlerts = [];
  bool _loadingEducationAlerts = false;

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
        'icon': Icons.book,
        'description': 'Aprender a ler e escrever',
        'description_creole': 'Aprende lei i skrève',
      },
      {
        'id': 'math',
        'title': 'Matemática',
        'title_creole': 'Matemátika',
        'icon': Icons.calculate,
        'description': 'Números e cálculos básicos',
        'description_creole': 'Númeru i kálkulu básiku',
      },
      {
        'id': 'health',
        'title': 'Saúde',
        'title_creole': 'Saúdi',
        'icon': Icons.health_and_safety,
        'description': 'Cuidados com a saúde',
        'description_creole': 'Kuidadu ku saúdi',
      },
      {
        'id': 'agriculture',
        'title': 'Agricultura',
        'title_creole': 'Agrikultura',
        'icon': Icons.eco,
        'description': 'Técnicas de cultivo',
        'description_creole': 'Téknika di kultivo',
      },
      {
        'id': 'teach_language',
        'title': 'Ensine o Bu Fala',
        'title_creole': 'Sina Bu Fala',
        'icon': Icons.school_outlined,
        'description': 'Ensine línguas africanas para a comunidade',
        'description_creole': 'Sina língua afrikanu pa komunidadi',
      },
    ];

    return Column(
      children: [
        _buildEducationAlertsSection(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: subjects.length,
            itemBuilder: (context, index) {
        final subject = subjects[index];
        final title = subject[_useCreole ? 'title_creole' : 'title'] as String;
        final description =
            subject[_useCreole ? 'description_creole' : 'description']
                as String;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: Icon(
              subject['icon'] as IconData,
              size: 40,
              color: AppColors.primaryGreen,
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(description),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _selectSubject(subject['id'] as String),
          ),
        );
      },
    ),
        ),
      ],
    );
  }

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
    // Se for o sistema colaborativo, navegar para a tela específica
    if (subjectId == 'teach_language') {
      // Temporariamente redirecionando para educação até que o sistema colaborativo seja corrigido
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sistema de Ensino Colaborativo em desenvolvimento'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Para outras matérias, comportamento normal
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
        String level = _currentLevel;
        String ageGroup = 'adultos';
        
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
          final parsedContent = _parseBackendResponse(data, _selectedSubject, level, ageGroup);
          
          final backendContent = OfflineLearningContent(
            id: 'backend_${DateTime.now().millisecondsSinceEpoch}',
            title: parsedContent['title'],
            description: parsedContent['description'],
            subject: _getSubjectTitle(),
            level: parsedContent['level'],
            languages: [_useCreole ? 'crioulo-gb' : 'pt-BR'],
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
        final filteredLocal = localContent.where(
          (content) => content.languages.contains(_useCreole ? 'crioulo-gb' : 'pt-BR'),
        ).toList();
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

    final subjectData = contentMap[subject.toLowerCase()] ?? {
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
      'description': 'Conteúdo educacional básico sobre ${_getSubjectTitle()}',
    };

    return OfflineLearningContent(
      id: 'default_${DateTime.now().millisecondsSinceEpoch}',
      title: subjectData['title']!,
      content: subjectData['content']!,
      description: subjectData['description']!,
      subject: _getSubjectTitle(),
      languages: [_useCreole ? 'crioulo-gb' : 'pt-BR'],
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

  Map<String, dynamic> _parseBackendResponse(dynamic data, String subject, String level, String ageGroup) {
     try {
       if (data is Map) {
         // Extrair conteúdo principal
         String mainContent = '';
         String title = '';
         String description = '';
         
         // Verificar se há resposta aninhada
         if (data.containsKey('response') && data['response'] is String) {
           mainContent = data['response'];
         } else if (data.containsKey('content') && data['content'] is String) {
           mainContent = data['content'];
         } else {
           // Tentar extrair texto de qualquer campo string
           for (var value in data.values) {
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
         description = data['description'] ?? 'Conteúdo educacional gerado pela IA';
         
         // Extrair informações educacionais se disponíveis
         Map<String, dynamic> educationalInfo = {};
         if (data.containsKey('educational_info')) {
           educationalInfo = Map<String, dynamic>.from(data['educational_info']);
         }
         
         // Extrair dicas de aprendizagem
         List<String> learningTips = [];
         if (educationalInfo.containsKey('learning_tips')) {
           learningTips = List<String>.from(educationalInfo['learning_tips'] ?? []);
         }
         
         // Extrair recursos adicionais
         List<String> additionalResources = [];
         if (educationalInfo.containsKey('additional_resources')) {
           additionalResources = List<String>.from(educationalInfo['additional_resources'] ?? []);
         }
         
         // Formatar conteúdo final
         String formattedContent = _formatEducationalContent(
           mainContent, 
           learningTips, 
           additionalResources,
           subject
         );
         
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
   
   String _formatEducationalContent(String mainContent, List<String> tips, List<String> resources, String subject) {
     String formatted = mainContent;
     
     // Adicionar dicas de aprendizagem se disponíveis
     if (tips.isNotEmpty) {
       formatted += '\n\n💡 **Dicas de Aprendizagem:**\n';
       for (int i = 0; i < tips.length; i++) {
         formatted += '${i + 1}. ${tips[i]}\n';
       }
     }
     
     // Adicionar recursos adicionais se disponíveis
     if (resources.isNotEmpty) {
       formatted += '\n\n📚 **Recursos Adicionais:**\n';
       for (String resource in resources) {
         formatted += '• $resource\n';
       }
     }
     
     // Adicionar nota sobre o contexto local
     formatted += '\n\n🌍 **Adaptado para a Guiné-Bissau**\nEste conteúdo foi gerado considerando o contexto local e recursos disponíveis.';
     
     return formatted;
   }
   
   String _formatSimpleContent(String content, String subject) {
     return '''📖 **Conteúdo sobre $subject**

$content

💡 **Lembre-se:**
• Pratique regularmente
• Aplique no dia a dia
• Compartilhe com outros

🎯 Continue aprendendo!''';
   }
   
   /// Remove marcadores de formatação Markdown das respostas do Gemma-3
  String _cleanMarkdownFormatting(String text) {
    if (text.isEmpty) return text;
    
    String cleaned = text;
    
    // Remover marcadores de negrito (**texto**)
    cleaned = cleaned.replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1');
    
    // Remover marcadores de cabeçalho (## texto)
    cleaned = cleaned.replaceAll(RegExp(r'^#{1,6}\s*(.*)$', multiLine: true), r'$1');
    
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

  Future<void> _loadEducationAlerts() async {
    if (mounted) {
      setState(() {
        _loadingEducationAlerts = true;
      });
    }

    try {
      final alerts = await _environmentalApiService.getEnvironmentalAlerts();
      
      // Filtrar alertas relevantes para educação
      final educationKeywords = [
        'escola', 'educação', 'ensino', 'criança', 'estudante', 
        'aula', 'material', 'livro', 'professor', 'aprendizagem',
        'alfabetização', 'matemática', 'leitura', 'escrita'
      ];
      
      final filteredAlerts = alerts.where((alert) {
        final message = alert['message']?.toString().toLowerCase() ?? '';
        final category = alert['category']?.toString().toLowerCase() ?? '';
        final type = alert['type']?.toString().toLowerCase() ?? '';
        
        return educationKeywords.any((keyword) => 
          message.contains(keyword) || 
          category.contains(keyword) || 
          type.contains(keyword)
        );
      }).toList();
      
      if (mounted) {
        setState(() {
          _educationAlerts = filteredAlerts.cast<Map<String, dynamic>>();
          _loadingEducationAlerts = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _educationAlerts = [];
          _loadingEducationAlerts = false;
        });
      }
      print('Erro ao carregar alertas educacionais: $e');
    }
  }

  Widget _buildEducationAlertsSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange.shade700,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _useCreole ? 'Alerta Edukasional' : 'Alertas Educacionais',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
              ),
              if (_loadingEducationAlerts)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                )
              else
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadEducationAlerts,
                  color: Colors.orange.shade700,
                  iconSize: 20,
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (_educationAlerts.isEmpty && !_loadingEducationAlerts)
            Text(
              _useCreole
                  ? 'Nada alerta edukasional agora'
                  : 'Nenhum alerta educacional no momento',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            )
          else if (_educationAlerts.isNotEmpty)
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _educationAlerts.length,
                itemBuilder: (context, index) {
                  final alert = _educationAlerts[index];
                  return _buildEducationAlertCard(alert);
                },
              ),
            ),
        ],
      ),
    );
  }

  // Função para limpar caracteres especiais dos textos do Gemma3
  String _cleanGemmaText(String? text) {
    if (text == null || text.isEmpty) return '';
    
    // Remove caracteres especiais comuns que podem aparecer na resposta do Gemma3
    String cleanedText = text
        .replaceAll(RegExp(r'[\*\#\`\~\^\{\}\[\]\|\\]'), '') // Remove markdown e caracteres especiais
        .replaceAll(RegExp(r'\n\s*\n'), '\n') // Remove quebras de linha duplas
        .replaceAll(RegExp(r'^\s*[\-\*\+]\s*'), '') // Remove marcadores de lista no início
        .replaceAll(RegExp(r'\s+'), ' ') // Normaliza espaços múltiplos
        .replaceAll(RegExp(r'["'']'), '"') // Normaliza aspas
        .replaceAll(RegExp(r'[\u2013\u2014]'), '-') // Normaliza travessões
        .replaceAll(RegExp(r'[\u2026]'), '...') // Normaliza reticências
        .replaceAll(RegExp(r'[\u00A0]'), ' ') // Remove espaços não-quebráveis
        .trim();
    
    // Remove caracteres de controle e não-ASCII problemáticos
    cleanedText = cleanedText.replaceAll(RegExp(r'[\x00-\x1F\x7F-\x9F]'), '');
    
    return cleanedText;
  }

  Widget _buildEducationAlertCard(Map<String, dynamic> alert) {
    final type = _cleanGemmaText(alert['type']?.toString()) ?? 'info';
    final message = _cleanGemmaText(alert['message']?.toString());
    final level = _cleanGemmaText(alert['level']?.toString()) ?? 'medium';
    final region = _cleanGemmaText(alert['region']?.toString());

    Color cardColor;
    IconData cardIcon;
    
    switch (level.toLowerCase()) {
      case 'high':
      case 'alto':
        cardColor = Colors.red.shade100;
        cardIcon = Icons.priority_high;
        break;
      case 'medium':
      case 'médio':
        cardColor = Colors.orange.shade100;
        cardIcon = Icons.warning;
        break;
      case 'low':
      case 'baixo':
        cardColor = Colors.yellow.shade100;
        cardIcon = Icons.info;
        break;
      default:
        cardColor = Colors.blue.shade100;
        cardIcon = Icons.notifications;
    }

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cardColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(cardIcon, size: 16, color: Colors.grey.shade700),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  type.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: cardColor.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  level.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                height: 1.3,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (region.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 12, color: Colors.grey.shade600),
                const SizedBox(width: 2),
                Expanded(
                  child: Text(
                    region,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
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
