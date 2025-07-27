import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../services/gemma3_backend_service.dart';
import '../services/integrated_api_service.dart';
import '../utils/app_colors.dart';

class InteractiveEducationScreen extends StatefulWidget {
  const InteractiveEducationScreen({super.key});

  @override
  State<InteractiveEducationScreen> createState() =>
      _InteractiveEducationScreenState();
}

class _InteractiveEducationScreenState extends State<InteractiveEducationScreen>
    with TickerProviderStateMixin {
  final IntegratedApiService _apiService = IntegratedApiService();
  final Gemma3BackendService _gemmaService = Gemma3BackendService();
  final FlutterTts _flutterTts = FlutterTts();

  // Controllers e Animações
  late AnimationController _progressController;
  late AnimationController _cardController;
  late Animation<double> _progressAnimation;
  late Animation<double> _cardAnimation;

  // Estado da aplicação
  bool _isLoading = false;
  bool _useCreole = false;
  String _currentLanguage = 'portuguese';
  String _selectedSubject = '';
  final String _currentLevel = 'beginner';
  int _currentLessonIndex = 0;
  double _userProgress = 0;

  // Conteúdo e interações
  List<InteractiveLessonContent> _lessons = [];
  InteractiveLessonContent? _currentLesson;
  final Map<String, dynamic> _userResponses = {};
  final List<String> _completedLessons = [];

  // Configurações offline
  Map<String, dynamic> _offlineContent = {};
  bool _isOfflineMode = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeServices();
    _loadOfflineContent();
  }

  void _initializeControllers() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
    _cardAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _cardController, curve: Curves.elasticOut),
    );
  }

  Future<void> _initializeServices() async {
    try {
      await _gemmaService.initialize();
      await _setupTTS();
    } catch (e) {
      print('Erro ao inicializar serviços: $e');
      setState(() => _isOfflineMode = true);
    }
  }

  Future<void> _setupTTS() async {
    await _flutterTts.setLanguage(_useCreole ? 'pt-PT' : 'pt-BR');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(0.8);
  }

  Future<void> _loadOfflineContent() async {
    try {
      final jsonString = await rootBundle
          .loadString('assets/learning/educational_content.json');
      setState(() {
        _offlineContent = json.decode(jsonString) as Map<String, dynamic>;
      });
    } catch (e) {
      print('Erro ao carregar conteúdo offline: $e');
    }
  }

  // Subjects disponíveis com melhor UX
  List<Map<String, dynamic>> get subjects => [
        {
          'id': 'literacy',
          'title': _useCreole ? 'Alfabetizason' : 'Alfabetização',
          'description': _useCreole
              ? 'Aprende lei i skirbi na portugés i kriolu'
              : 'Aprenda a ler e escrever em português e crioulo',
          'icon': Icons.abc,
          'color': Colors.blue[600]!,
          'difficulty': 'Básico',
          'lessons': 8,
          'isInteractive': true,
        },
        {
          'id': 'mathematics',
          'title': _useCreole ? 'Matemátika' : 'Matemática',
          'description': _useCreole
              ? 'Númeru, konta i kalkulason básiku'
              : 'Números, contas e cálculos básicos',
          'icon': Icons.calculate,
          'color': Colors.green[600]!,
          'difficulty': 'Básico a Avançado',
          'lessons': 12,
          'isInteractive': true,
        },
        {
          'id': 'science',
          'title': _useCreole ? 'Siénsia' : 'Ciências',
          'description': _useCreole
              ? 'Natura, korpu umanu i mundu'
              : 'Natureza, corpo humano e mundo',
          'icon': Icons.science,
          'color': Colors.purple[600]!,
          'difficulty': 'Intermediário',
          'lessons': 10,
          'isInteractive': true,
        },
        {
          'id': 'history',
          'title': _useCreole ? 'Istória' : 'História',
          'description': _useCreole
              ? 'Istória di Guiné-Bissau i mundu'
              : 'História da Guiné-Bissau e do mundo',
          'icon': Icons.history_edu,
          'color': Colors.brown[600]!,
          'difficulty': 'Intermediário',
          'lessons': 6,
          'isInteractive': false,
        },
      ];

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title:
              Text(_useCreole ? 'Sikolansa Interativa' : 'Educação Interativa'),
          backgroundColor: AppColors.education,
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(_isOfflineMode ? Icons.wifi_off : Icons.wifi),
              onPressed: _showConnectionInfo,
            ),
            IconButton(
              icon: Icon(_useCreole ? Icons.language : Icons.translate),
              onPressed: _toggleLanguage,
            ),
            IconButton(
              icon: const Icon(Icons.volume_up),
              onPressed: _speakCurrentContent,
            ),
          ],
        ),
        body: Column(
          children: [
            // Barra de progresso animada
            if (_selectedSubject.isNotEmpty) _buildProgressBar(),

            // Conteúdo principal
            Expanded(
              child: _selectedSubject.isEmpty
                  ? _buildSubjectGrid()
                  : _buildInteractiveLearning(),
            ),
          ],
        ),
        floatingActionButton: _selectedSubject.isNotEmpty
            ? FloatingActionButton(
                onPressed: _resetToSubjects,
                backgroundColor: AppColors.education,
                child: const Icon(Icons.home, color: Colors.white),
              )
            : null,
      );

  Widget _buildProgressBar() => Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _useCreole ? 'Progresu:' : 'Progresso:',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${(_userProgress * 100).toInt()}%',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.education,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) => LinearProgressIndicator(
                value: _progressAnimation.value * _userProgress,
                backgroundColor: Colors.grey[300],
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.education),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _useCreole
                  ? 'Lison ${_currentLessonIndex + 1} di ${_lessons.length}'
                  : 'Lição ${_currentLessonIndex + 1} de ${_lessons.length}',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      );

  Widget _buildSubjectGrid() => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header inspirador
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.education,
                    AppColors.education.withValues(alpha: 0.7)
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.school, size: 60, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    _useCreole
                        ? 'Revolusaun na Edukason'
                        : 'Revolução na Educação',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _useCreole
                        ? 'Aprende ku interason, sin internet!'
                        : 'Aprenda com interação, mesmo sem internet!',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              _useCreole ? 'Skoji bu matéria:' : 'Escolha sua matéria:',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Grid de matérias
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  return _buildSubjectCard(subject);
                },
              ),
            ),
          ],
        ),
      );

  Widget _buildSubjectCard(Map<String, dynamic> subject) => AnimatedBuilder(
        animation: _cardAnimation,
        builder: (context, child) => Transform.scale(
          scale: 0.9 + (_cardAnimation.value * 0.1),
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () => _selectSubject(subject['id'] as String),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: [
                      (subject['color'] as Color).withValues(alpha: 0.1),
                      (subject['color'] as Color).withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: subject['color'] as Color,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            subject['icon'] as IconData,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const Spacer(),
                        if (subject['isInteractive'] as bool)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _useCreole ? 'Interativu' : 'Interativo',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      subject['title'] as String,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subject['description'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(Icons.book, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          '${subject['lessons']} ${_useCreole ? 'lison' : 'lições'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subject['difficulty'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: subject['color'] as Color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

  Widget _buildInteractiveLearning() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.education),
            const SizedBox(height: 16),
            Text(
              _useCreole
                  ? 'Krega konteúdu edukativu...'
                  : 'Carregando conteúdo educativo...',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_lessons.isEmpty) {
      return _buildEmptyState();
    }

    return PageView.builder(
      itemCount: _lessons.length,
      onPageChanged: (index) {
        setState(() {
          _currentLessonIndex = index;
          _currentLesson = _lessons[index];
        });
        _updateProgress();
      },
      itemBuilder: (context, index) {
        final lesson = _lessons[index];
        return _buildLessonPage(lesson, index);
      },
    );
  }

  Widget _buildLessonPage(InteractiveLessonContent lesson, int index) =>
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho da lição
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.education,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          lesson.title,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _speakText(lesson.content),
                        icon: const Icon(Icons.volume_up,
                            color: AppColors.education),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    lesson.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Conteúdo da lição
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.content,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                        ),
                      ),
                      if (lesson.exercises.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          _useCreole ? 'Exersísiu:' : 'Exercícios:',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...lesson.exercises.map(_buildExercise),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Botões de navegação
            Row(
              children: [
                if (index > 0)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _previousLesson,
                      icon: const Icon(Icons.arrow_back),
                      label: Text(_useCreole ? 'Anterior' : 'Anterior'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                if (index > 0) const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: index < _lessons.length - 1
                        ? _nextLesson
                        : _completeSubject,
                    icon: Icon(index < _lessons.length - 1
                        ? Icons.arrow_forward
                        : Icons.check),
                    label: Text(
                      index < _lessons.length - 1
                          ? (_useCreole ? 'Prósimu' : 'Próximo')
                          : (_useCreole ? 'Kompletu' : 'Concluir'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.education,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildExercise(Map<String, dynamic> exercise) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.education.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.education.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              exercise['question'] as String? ?? '',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            if ((exercise['type'] as String?) == 'multiple_choice')
              ...((exercise['options'] as List<dynamic>?)?.cast<String>() ?? [])
                  .map(
                (option) => RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue:
                      _userResponses[exercise['id'] as String] as String?,
                  onChanged: (value) {
                    setState(() {
                      _userResponses[exercise['id'] as String] = value;
                    });
                  },
                ),
              ),
            if (exercise['type'] == 'text_input')
              TextField(
                decoration: InputDecoration(
                  hintText: _useCreole
                      ? 'Skribi bu risposta...'
                      : 'Digite sua resposta...',
                  border: const OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _userResponses[exercise['id'] as String] = value;
                },
              ),
          ],
        ),
      );

  Widget _buildEmptyState() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 100,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _useCreole
                  ? 'Nenhum konteúdu disponível'
                  : 'Nenhum conteúdo disponível',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _useCreole
                  ? 'Verifica konekson i tenta otru vez'
                  : 'Verifique a conexão e tente novamente',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );

  Future<void> _selectSubject(String subjectId) async {
    setState(() {
      _selectedSubject = subjectId;
      _isLoading = true;
    });

    _cardController.forward();

    try {
      // Gerar conteúdo com Gemma-3n ou usar offline
      if (!_isOfflineMode && await _gemmaService.initialize()) {
        await _generateOnlineContent(subjectId);
      } else {
        _loadOfflineSubjectContent(subjectId);
      }
    } catch (e) {
      print('Erro ao carregar conteúdo: $e');
      _loadOfflineSubjectContent(subjectId);
    }

    setState(() => _isLoading = false);
    _progressController.forward();
  }

  Future<void> _generateOnlineContent(String subjectId) async {
    final questions = [
      'Introdução básica sobre $subjectId',
      'Conceitos fundamentais de $subjectId',
      'Exercícios práticos de $subjectId',
      'Aplicações do dia-a-dia de $subjectId',
    ];

    final lessons = <InteractiveLessonContent>[];

    for (var i = 0; i < questions.length; i++) {
      try {
        final response = await _apiService.askEducationQuestion(
          question: questions[i],
          subject: subjectId,
          level: _currentLevel,
          language: _currentLanguage,
        );

        if (response.success && response.data != null) {
          lessons.add(InteractiveLessonContent(
            id: 'online_${subjectId}_$i',
            title: 'Lição ${i + 1}: ${_getLessonTitle(subjectId, i)}',
            content: response.data!,
            description: 'Conteúdo gerado por IA',
            exercises: _generateExercises(subjectId, i),
          ));
        }
      } catch (e) {
        print('Erro ao gerar lição $i: $e');
      }
    }

    setState(() => _lessons = lessons);
  }

  void _loadOfflineSubjectContent(String subjectId) {
    final offlineSubjects =
        _offlineContent['subjects'] as Map<String, dynamic>?;
    if (offlineSubjects == null || !offlineSubjects.containsKey(subjectId)) {
      setState(() => _lessons = []);
      return;
    }

    final subjectData = offlineSubjects[subjectId] as Map<String, dynamic>;
    final lessonsData = subjectData['lessons'] as List<dynamic>? ?? [];

    final lessons = lessonsData.map((lessonData) {
      final lesson = lessonData as Map<String, dynamic>;
      return InteractiveLessonContent(
        id: lesson['id'] as String? ?? '',
        title: _useCreole
            ? (lesson['title_creole'] as String? ??
                lesson['title'] as String? ??
                '')
            : (lesson['title'] as String? ?? ''),
        content: _useCreole
            ? (lesson['content_creole'] as String? ??
                lesson['content'] as String? ??
                '')
            : (lesson['content'] as String? ?? ''),
        description: 'Conteúdo offline',
        exercises: (lesson['exercises'] as List<dynamic>?)
                ?.map((e) => e as Map<String, dynamic>)
                .toList() ??
            [],
      );
    }).toList();

    setState(() => _lessons = lessons);
  }

  String _getLessonTitle(String subject, int index) {
    final titles = {
      'literacy': ['Alfabeto', 'Palavras', 'Frases', 'Leitura'],
      'mathematics': ['Números', 'Adição', 'Subtração', 'Multiplicação'],
      'science': ['Natureza', 'Água', 'Ar', 'Plantas'],
      'history': ['Origens', 'Colonização', 'Independência', 'Atualidade'],
    };

    return titles[subject]?[index] ?? 'Lição ${index + 1}';
  }

  List<Map<String, dynamic>> _generateExercises(
      String subject, int lessonIndex) {
    final random = Random();
    final exercises = <Map<String, dynamic>>[];

    // Exercício simples baseado no assunto
    if (subject == 'mathematics') {
      exercises.add({
        'id': 'math_${lessonIndex}_1',
        'type': 'multiple_choice',
        'question': 'Quanto é 2 + 3?',
        'options': ['4', '5', '6', '7'],
        'answer': '5',
      });
    } else if (subject == 'literacy') {
      exercises.add({
        'id': 'literacy_${lessonIndex}_1',
        'type': 'text_input',
        'question': 'Complete a palavra: A_C',
        'answer': 'ABC',
      });
    }

    return exercises;
  }

  void _nextLesson() {
    if (_currentLessonIndex < _lessons.length - 1) {
      setState(() {
        _currentLessonIndex++;
        _currentLesson = _lessons[_currentLessonIndex];
      });
      _updateProgress();
    }
  }

  void _previousLesson() {
    if (_currentLessonIndex > 0) {
      setState(() {
        _currentLessonIndex--;
        _currentLesson = _lessons[_currentLessonIndex];
      });
      _updateProgress();
    }
  }

  void _updateProgress() {
    final newProgress = (_currentLessonIndex + 1) / _lessons.length;
    setState(() => _userProgress = newProgress);
    _progressController.animateTo(newProgress);
  }

  void _completeSubject() {
    setState(() {
      _completedLessons.add(_selectedSubject);
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_useCreole ? 'Parabéns!' : 'Parabéns!'),
        content: Text(
          _useCreole
              ? 'Bu kompleta matéria ku suksesu!'
              : 'Você completou a matéria com sucesso!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetToSubjects();
            },
            child: Text(_useCreole ? 'Kontinua' : 'Continuar'),
          ),
        ],
      ),
    );
  }

  void _resetToSubjects() {
    setState(() {
      _selectedSubject = '';
      _lessons.clear();
      _currentLessonIndex = 0;
      _userProgress = 0.0;
      _userResponses.clear();
    });
    _progressController.reset();
    _cardController.reset();
  }

  void _toggleLanguage() {
    setState(() {
      _useCreole = !_useCreole;
      _currentLanguage = _useCreole ? 'crioulo-gb' : 'portuguese';
    });
    _setupTTS();
  }

  Future<void> _speakText(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> _speakCurrentContent() async {
    if (_currentLesson != null) {
      await _speakText(_currentLesson!.content);
    }
  }

  void _showConnectionInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_useCreole ? 'Konekson' : 'Conexão'),
        content: Text(
          _isOfflineMode
              ? (_useCreole
                  ? 'Bu ta uza konteúdu offline. Alguns funsionalidadi limitadu.'
                  : 'Você está usando conteúdo offline. Algumas funcionalidades limitadas.')
              : (_useCreole
                  ? 'Bu ta konektadu i pode uza konteúdu IA.'
                  : 'Você está conectado e pode usar conteúdo com IA.'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _cardController.dispose();
    _flutterTts.stop();
    super.dispose();
  }
}

// Modelo para conteúdo de lição interativa
class InteractiveLessonContent {
  InteractiveLessonContent({
    required this.id,
    required this.title,
    required this.content,
    required this.description,
    required this.exercises,
  });
  final String id;
  final String title;
  final String content;
  final String description;
  final List<Map<String, dynamic>> exercises;
}
