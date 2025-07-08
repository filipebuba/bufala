import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';

class EducationScreenRevolution extends StatefulWidget {
  const EducationScreenRevolution({super.key});

  @override
  State<EducationScreenRevolution> createState() =>
      _EducationScreenRevolutionState();
}

class _EducationScreenRevolutionState extends State<EducationScreenRevolution>
    with TickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final FlutterTts _flutterTts = FlutterTts();

  // Controllers e Animações
  late AnimationController _progressController;
  late Animation<double> _progressAnimation;

  // Estado da aplicação
  bool _isLoading = false;
  bool _useCreole = false;
  String _currentLanguage = 'portuguese';
  String _selectedSubject = '';
  final String _currentLevel = 'beginner';
  int _currentLessonIndex = 0;
  double _userProgress = 0;

  // Conteúdo e interações
  List<LessonContent> _lessons = [];
  final Map<String, String> _userAnswers = {};
  final List<String> _completedSubjects = [];

  // Estado offline
  final bool _isOfflineMode = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupTTS();
  }

  void _initializeControllers() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _progressAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeInOut),
    );
  }

  Future<void> _setupTTS() async {
    try {
      await _flutterTts.setLanguage(_useCreole ? 'pt-PT' : 'pt-BR');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(0.8);
    } catch (e) {
      print('TTS não disponível: $e');
    }
  }

  // Subjects educacionais revolucionários
  List<SubjectData> get subjects => [
        SubjectData(
          id: 'literacy',
          title: _useCreole ? 'Alfabetizason' : 'Alfabetização Digital',
          description: _useCreole
              ? 'Aprende lei, skirbi i uza teknolojia'
              : 'Alfabetização interativa com tecnologia',
          icon: Icons.abc,
          color: Colors.blue[600]!,
          difficulty: 'Básico',
          lessonsCount: 6,
          isInteractive: true,
          offlineCapable: true,
        ),
        SubjectData(
          id: 'mathematics',
          title: _useCreole ? 'Matemátika Práktika' : 'Matemática Prática',
          description: _useCreole
              ? 'Númeru i konta pa vida diária'
              : 'Matemática aplicada ao dia-a-dia',
          icon: Icons.calculate,
          color: Colors.green[600]!,
          difficulty: 'Básico a Avançado',
          lessonsCount: 8,
          isInteractive: true,
          offlineCapable: true,
        ),
        SubjectData(
          id: 'health',
          title: _useCreole ? 'Saúdi Komunidadi' : 'Saúde Comunitária',
          description: _useCreole
              ? 'Kuidadu di saúdi pa família'
              : 'Cuidados de saúde para toda família',
          icon: Icons.healing,
          color: Colors.red[600]!,
          difficulty: 'Essencial',
          lessonsCount: 10,
          isInteractive: true,
          offlineCapable: true,
        ),
        SubjectData(
          id: 'agriculture',
          title: _useCreole
              ? 'Agrikultura Sustentável'
              : 'Agricultura Sustentável',
          description: _useCreole
              ? 'Planta i kria di forma ekolójika'
              : 'Cultivo sustentável e ecológico',
          icon: Icons.eco,
          color: Colors.green[800]!,
          difficulty: 'Intermediário',
          lessonsCount: 12,
          isInteractive: true,
          offlineCapable: true,
        ),
        SubjectData(
          id: 'technology',
          title: _useCreole ? 'Teknolojia pa Vida' : 'Tecnologia para Vida',
          description: _useCreole
              ? 'Uza telefon i komputador pa aprende'
              : 'Uso básico de tecnologia para aprendizado',
          icon: Icons.smartphone,
          color: Colors.purple[600]!,
          difficulty: 'Básico',
          lessonsCount: 5,
          isInteractive: true,
          offlineCapable: false,
        ),
        SubjectData(
          id: 'civics',
          title: _useCreole ? 'Sidadania Ativa' : 'Cidadania Ativa',
          description: _useCreole
              ? 'Diritu i devre di sidadaun'
              : 'Direitos e deveres do cidadão',
          icon: Icons.how_to_vote,
          color: Colors.indigo[600]!,
          difficulty: 'Intermediário',
          lessonsCount: 6,
          isInteractive: true,
          offlineCapable: true,
        ),
      ];

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title:
              Text(_useCreole ? 'Revolusaun Edukativu' : 'Revolução Educativa'),
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
            if (_selectedSubject.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: _speakCurrentContent,
              ),
          ],
        ),
        body: Column(
          children: [
            // Barra de progresso
            if (_selectedSubject.isNotEmpty) _buildProgressBar(),

            // Conteúdo principal
            Expanded(
              child: _selectedSubject.isEmpty
                  ? _buildSubjectGrid()
                  : _buildLearningContent(),
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
            // Header revolucionário
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
                        ? '🌟 Revolusaun na Edukason 🌟'
                        : '🌟 Revolução na Educação 🌟',
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
                        ? 'Experiénsia interativa pa rejaun ku baixu konektividadi'
                        : 'Experiências interativas para regiões de baixa conectividade',
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.offline_bolt,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          _useCreole
                              ? 'Funsiona offline!'
                              : 'Funciona offline!',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Text(
              _useCreole
                  ? 'Skoji bu matéria revolucionária:'
                  : 'Escolha sua matéria revolucionária:',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Grid de matérias revolucionárias
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: subjects.length,
                itemBuilder: (context, index) {
                  final subject = subjects[index];
                  final isCompleted = _completedSubjects.contains(subject.id);
                  return _buildSubjectCard(subject, isCompleted);
                },
              ),
            ),
          ],
        ),
      );

  Widget _buildSubjectCard(SubjectData subject, bool isCompleted) => Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => _selectSubject(subject.id),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                colors: [
                  subject.color.withValues(alpha: 0.1),
                  subject.color.withValues(alpha: 0.05),
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
                        color: subject.color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        subject.icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const Spacer(),
                    if (isCompleted)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    if (subject.isInteractive && !isCompleted)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange,
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
                  subject.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  subject.description,
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
                      '${subject.lessonsCount} ${_useCreole ? 'lison' : 'lições'}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (subject.offlineCapable)
                      Icon(Icons.offline_bolt,
                          size: 16, color: Colors.green[600]),
                    if (subject.offlineCapable) const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        subject.difficulty,
                        style: TextStyle(
                          fontSize: 12,
                          color: subject.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildLearningContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.education),
            const SizedBox(height: 16),
            Text(
              _useCreole
                  ? 'Krega konteúdu educativu revolucionáriu...'
                  : 'Carregando conteúdo educativo revolucionário...',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (_lessons.isEmpty) {
      return _buildEmptyState();
    }

    final currentLesson = _lessons[_currentLessonIndex];
    return _buildLessonContent(currentLesson);
  }

  Widget _buildLessonContent(LessonContent lesson) => Padding(
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
                          '${_currentLessonIndex + 1}',
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
                      if (lesson.questions.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          _useCreole
                              ? 'Pergunta Interativa:'
                              : 'Pergunta Interativa:',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...lesson.questions.map(
                            (question) => _buildQuestion(question, lesson.id)),
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
                if (_currentLessonIndex > 0)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _previousLesson,
                      icon: const Icon(Icons.arrow_back),
                      label: Text(_useCreole ? 'Anterior' : 'Anterior'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                if (_currentLessonIndex > 0) const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _currentLessonIndex < _lessons.length - 1
                        ? _nextLesson
                        : _completeSubject,
                    icon: Icon(_currentLessonIndex < _lessons.length - 1
                        ? Icons.arrow_forward
                        : Icons.check),
                    label: Text(
                      _currentLessonIndex < _lessons.length - 1
                          ? (_useCreole ? 'Prósimu' : 'Próximo')
                          : (_useCreole ? 'Kompletu' : 'Concluir'),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.education,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildQuestion(String question, String lessonId) {
    final answerId = '${lessonId}_answer';
    return Container(
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
            question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: _useCreole
                  ? 'Skribi bu risposta...'
                  : 'Digite sua resposta...',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            onChanged: (value) {
              _userAnswers[answerId] = value;
            },
            maxLines: 2,
          ),
        ],
      ),
    );
  }

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
      _currentLessonIndex = 0;
      _userProgress = 0.0;
    });

    try {
      // Gerar lições online ou usar offline
      await _generateLessons(subjectId);
    } catch (e) {
      print('Erro ao carregar lições: $e');
      _generateOfflineLessons(subjectId);
    }

    setState(() => _isLoading = false);
    _progressController.forward();
  }

  Future<void> _generateLessons(String subjectId) async {
    final lessonTopics = _getLessonTopics(subjectId);
    final lessons = <LessonContent>[];

    for (var i = 0; i < lessonTopics.length; i++) {
      try {
        final response = await _apiService.askEducationQuestion(
          question: lessonTopics[i],
          subject: subjectId,
          level: _currentLevel,
          language: _currentLanguage,
        );

        if (response.success && response.data != null) {
          lessons.add(LessonContent(
            id: '${subjectId}_lesson_$i',
            title: _getLessonTitle(subjectId, i),
            content: response.data!,
            description: 'Lição interativa gerada por IA',
            questions: _generateQuestions(subjectId, i),
          ));
        }
      } catch (e) {
        print('Erro ao gerar lição $i: $e');
      }
    }

    setState(() => _lessons = lessons);
  }

  void _generateOfflineLessons(String subjectId) {
    final lessons = _getOfflineLessons(subjectId);
    setState(() => _lessons = lessons);
  }

  List<String> _getLessonTopics(String subjectId) {
    switch (subjectId) {
      case 'literacy':
        return [
          'Alfabeto e sons das letras',
          'Formação de palavras simples',
          'Leitura de frases básicas',
          'Escrita de palavras',
          'Compreensão de texto simples',
          'Prática de escrita livre',
        ];
      case 'mathematics':
        return [
          'Números de 1 a 10',
          'Adição básica',
          'Subtração básica',
          'Números até 100',
          'Multiplicação simples',
          'Divisão básica',
          'Problemas do dia-a-dia',
          'Medidas e tempo',
        ];
      case 'health':
        return [
          'Higiene pessoal básica',
          'Prevenção de doenças',
          'Primeiros socorros',
          'Alimentação saudável',
          'Saúde da família',
          'Vacinação',
          'Saúde mental',
          'Exercícios físicos',
          'Saúde da mulher',
          'Cuidados com crianças',
        ];
      case 'agriculture':
        return [
          'Preparação do solo',
          'Sementes e plantio',
          'Irrigação inteligente',
          'Controle natural de pragas',
          'Compostagem',
          'Colheita e armazenamento',
          'Criação de animais',
          'Agricultura orgânica',
          'Calendário agrícola',
          'Vendas e mercado',
          'Cooperativas',
          'Sustentabilidade',
        ];
      case 'technology':
        return [
          'Uso básico do celular',
          'Internet e comunicação',
          'Aplicativos úteis',
          'Segurança digital',
          'Aprendizado online',
        ];
      case 'civics':
        return [
          'Direitos fundamentais',
          'Deveres do cidadão',
          'Participação política',
          'Serviços públicos',
          'Documentação civil',
          'Resolução de conflitos',
        ];
      default:
        return ['Introdução ao assunto'];
    }
  }

  String _getLessonTitle(String subject, int index) {
    final topics = _getLessonTopics(subject);
    return topics.length > index ? topics[index] : 'Lição ${index + 1}';
  }

  List<String> _generateQuestions(String subject, int lessonIndex) {
    switch (subject) {
      case 'literacy':
        return [
          'Escreva 3 palavras que começam com a letra A',
          'Como você aplicaria isso na sua vida diária?',
        ];
      case 'mathematics':
        return [
          'Resolva: 5 + 3 = ?',
          'Dê um exemplo de como usar isso no seu trabalho',
        ];
      case 'health':
        return [
          'Liste 3 práticas de higiene que você pode fazer hoje',
          'Como você ensinaria isso para sua família?',
        ];
      case 'agriculture':
        return [
          'Quais ferramentas você precisa para esta atividade?',
          'Em que época do ano isso seria mais eficaz?',
        ];
      default:
        return ['O que você aprendeu nesta lição?'];
    }
  }

  List<LessonContent> _getOfflineLessons(String subjectId) {
    // Conteúdo offline básico
    switch (subjectId) {
      case 'literacy':
        return [
          LessonContent(
            id: 'literacy_offline_1',
            title: 'O Alfabeto',
            content:
                'O alfabeto português tem 26 letras: A, B, C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, T, U, V, W, X, Y, Z.\n\nCada letra tem um som diferente. Vamos praticar!',
            description: 'Aprendendo as letras do alfabeto',
            questions: ['Escreva as primeiras 5 letras do alfabeto'],
          ),
          LessonContent(
            id: 'literacy_offline_2',
            title: 'Palavras Simples',
            content:
                'Agora vamos formar palavras juntando as letras:\n\nMAMA = M + A + M + A\nPAPA = P + A + P + A\nCASA = C + A + S + A',
            description: 'Formando palavras básicas',
            questions: ['Forme uma palavra com as letras: C, A, O'],
          ),
        ];
      case 'mathematics':
        return [
          LessonContent(
            id: 'math_offline_1',
            title: 'Contando até 10',
            content:
                'Vamos aprender a contar:\n\n1 (um)\n2 (dois)\n3 (três)\n4 (quatro)\n5 (cinco)\n6 (seis)\n7 (sete)\n8 (oito)\n9 (nove)\n10 (dez)',
            description: 'Números de 1 a 10',
            questions: ['Conte quantos dedos você tem em uma mão'],
          ),
        ];
      default:
        return [];
    }
  }

  void _nextLesson() {
    if (_currentLessonIndex < _lessons.length - 1) {
      setState(() {
        _currentLessonIndex++;
      });
      _updateProgress();
    }
  }

  void _previousLesson() {
    if (_currentLessonIndex > 0) {
      setState(() {
        _currentLessonIndex--;
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
      _completedSubjects.add(_selectedSubject);
    });

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_useCreole ? '🎉 Parabéns!' : '🎉 Parabéns!'),
        content: Text(
          _useCreole
              ? 'Bu kompleta matéria ku suksesu! Bu agora ten nobu koñesimentu pa aplicar na bu vida.'
              : 'Você completou a matéria com sucesso! Agora você tem novos conhecimentos para aplicar na sua vida.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetToSubjects();
            },
            child: Text(
                _useCreole ? 'Kontinua Aprende!' : 'Continuar Aprendendo!'),
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
      _userAnswers.clear();
    });
    _progressController.reset();
  }

  void _toggleLanguage() {
    setState(() {
      _useCreole = !_useCreole;
      _currentLanguage = _useCreole ? 'crioulo-gb' : 'portuguese';
    });
    _setupTTS();
  }

  Future<void> _speakText(String text) async {
    try {
      await _flutterTts.speak(text);
    } catch (e) {
      print('Erro no TTS: $e');
    }
  }

  Future<void> _speakCurrentContent() async {
    if (_lessons.isNotEmpty) {
      await _speakText(_lessons[_currentLessonIndex].content);
    }
  }

  void _showConnectionInfo() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_useCreole ? 'Estado da Konekson' : 'Estado da Conexão'),
        content: Text(
          _isOfflineMode
              ? (_useCreole
                  ? 'Bu ta na modu offline. Konteúdu básiku disponível sin internet.'
                  : 'Você está no modo offline. Conteúdo básico disponível sem internet.')
              : (_useCreole
                  ? 'Bu ta konektadu! Konteúdu avansadu ku IA disponível.'
                  : 'Você está conectado! Conteúdo avançado com IA disponível.'),
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
    _flutterTts.stop();
    super.dispose();
  }
}

// Modelos de dados
class SubjectData {
  SubjectData({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.difficulty,
    required this.lessonsCount,
    required this.isInteractive,
    required this.offlineCapable,
  });
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final String difficulty;
  final int lessonsCount;
  final bool isInteractive;
  final bool offlineCapable;
}

class LessonContent {
  LessonContent({
    required this.id,
    required this.title,
    required this.content,
    required this.description,
    required this.questions,
  });
  final String id;
  final String title;
  final String content;
  final String description;
  final List<String> questions;
}
