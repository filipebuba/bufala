import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';

import '../models/offline_learning_models.dart';
import '../screens/content_view_screen.dart';
import '../services/gemma3_backend_service.dart';
import '../services/offline_learning_service.dart';
import '../services/integrated_api_service.dart';
import '../utils/app_colors.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final IntegratedApiService _apiService = IntegratedApiService();
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

    return ListView.builder(
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

      // Primeiro, tentar usar o backend integrado para conteúdo dinâmico
      try {
        final response = await _apiService.askEducationQuestion(
          'Gere conteúdo educacional sobre $_selectedSubject para nível $_currentLevel em ${_useCreole ? 'crioulo da Guiné-Bissau' : 'português'}',
        );
        
        if (response['success'] == true && response['data'] != null) {
          // Criar conteúdo a partir da resposta do backend
          final backendContent = OfflineLearningContent(
            id: 'backend_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Conteúdo de $_selectedSubject (IA)',
            description: 'Conteúdo gerado dinamicamente pela IA',
            subject: _getSubjectTitle(),
            level: _currentLevel,
            languages: [_useCreole ? 'crioulo-gb' : 'pt-BR'],
            content: response['data'] as String,
            type: 'ai_generated',
            createdAt: DateTime.now(),
            metadata: {
              'source': 'backend_ai',
              'language': _useCreole ? 'crioulo-gb' : 'pt-BR',
              'generated_at': DateTime.now().toIso8601String(),
            },
          );
          content.add(backendContent);
          print('✅ Conteúdo educativo gerado pelo backend');
        }
      } catch (e) {
        print('⚠️ Backend indisponível para conteúdo dinâmico: $e');
      }

      // Sempre adicionar conteúdo local como base
      final localContent = await _learningService.getContentBySubject(
        _selectedSubject,
      );
      content.addAll(localContent);

      // Se ainda não há conteúdo, tentar Gemma-3 como último recurso
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

      // Se ainda não há conteúdo, criar conteúdo padrão
      if (content.isEmpty) {
        content = [
          OfflineLearningContent(
            id: 'default_${DateTime.now().millisecondsSinceEpoch}',
            title: 'Conteúdo de ${_getSubjectTitle()}',
            description: 'Conteúdo básico disponível offline',
            subject: _getSubjectTitle(),
            level: _currentLevel,
            languages: [_useCreole ? 'crioulo-gb' : 'pt-BR'],
            content: _useCreole 
                ? 'Konteúdu di $_selectedSubject ta karga. Tenta karga di novu.'
                : 'Conteúdo de $_selectedSubject está sendo carregado. Tente carregar novamente.',
            type: 'placeholder',
            createdAt: DateTime.now(),
            metadata: {'type': 'fallback'},
          ),
        ];
        print('🟡 Usando conteúdo padrão (fallback final)');
      }

      setState(() {
        _availableContent = content;
        _isLoading = false;
      });
      
      print('📚 Total de conteúdos carregados: ${content.length}');
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog('Erro ao carregar conteúdo: $e');
    }
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
