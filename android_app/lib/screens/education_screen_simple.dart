import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';

import '../models/offline_learning_models.dart';
import '../services/api_service.dart';
import '../services/gemma3_multimodal_service.dart';
import '../services/offline_learning_service.dart';
import '../utils/app_colors.dart';

class EducationScreen extends StatefulWidget {
  const EducationScreen({super.key});

  @override
  State<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends State<EducationScreen> {
  final ApiService _apiService = ApiService();
  late OfflineLearningService _learningService;
  late Gemma3MultimodalService _gemmaService;

  // Speech and Audio
  // final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';

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
    _gemmaService = Gemma3MultimodalService();

    try {
      // OfflineLearningService não tem método initialize
      // Método initialize não existe no Gemma3MultimodalService - removendo
      print('Serviços inicializados com sucesso');
    } catch (e) {
      print('Erro ao inicializar serviços: $e');
    }
  }

  Future<void> _initSpeech() async {
    try {
      // _speechEnabled = await _speechToText.initialize();
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
    setState(() {
      _selectedSubject = subjectId;
      _isLoading = true;
    });

    _loadContent();
  }

  Future<void> _loadContent() async {
    try {
      final content = await _learningService.getContentBySubject(
        _selectedSubject,
      );

      setState(() {
        _availableContent = content;
        _isLoading = false;
      });
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
      MaterialPageRoute(
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
    setState(() => _isListening = true);
    // Simular reconhecimento de voz
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _lastWords = 'Pergunta de exemplo detectada por voz';
      _isListening = false;
    });
  }

  Future<void> _stopListening() async {
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
class ContentViewScreen extends StatelessWidget {
  const ContentViewScreen({required this.content, super.key});
  final OfflineLearningContent content;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(content.title),
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                content.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                content.description,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.play_circle_outline,
                        size: 100,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Conteúdo em desenvolvimento',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
