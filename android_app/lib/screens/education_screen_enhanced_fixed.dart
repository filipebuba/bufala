import 'package:flutter/material.dart';

import '../models/offline_learning_models.dart';
import '../screens/content_view_screen.dart';
import '../services/gemma3_backend_service.dart';
import '../services/offline_learning_service.dart';
import '../services/smart_api_service.dart';
import '../utils/app_colors.dart';

class EducationScreenEnhanced extends StatefulWidget {
  const EducationScreenEnhanced({super.key});

  @override
  State<EducationScreenEnhanced> createState() => _EducationScreenEnhancedState();
}

class _EducationScreenEnhancedState extends State<EducationScreenEnhanced>
    with TickerProviderStateMixin {
  late OfflineLearningService _learningService;
  late Gemma3BackendService _gemmaService;
  late SmartApiService _smartApiService;

  // Speech and Audio
  bool _speechEnabled = false;
  bool _isListening = false;
  final String _lastWords = '';

  // Learning State
  bool _isLoading = false;
  bool _useCreole = false;
  String _selectedSubject = '';
  String _currentLevel = 'beginner';
  List<OfflineLearningContent> _availableContent = [];

  // Backend Connection Status
  bool _isBackendConnected = false;
  bool _isGemmaConnected = false;
  String _connectionStatus = 'Verificando...';

  // Animation Controllers
  late AnimationController _subjectAnimationController;
  late AnimationController _progressAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  // Progress Tracking
  Map<String, double> _subjectProgress = {};
  int _completedLessons = 0;
  int _totalLessons = 0;
  int _currentStreak = 5;
  int _totalPoints = 150;

  // UI State
  bool _isCompactView = false;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeServices();
    _initSpeech();
    _loadLocalProgress();
  }

  void _initializeAnimations() {
    _subjectAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _progressAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _subjectAnimationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(parent: _subjectAnimationController, curve: Curves.elasticOut),
    );

    _subjectAnimationController.forward();
  }

  Future<void> _initializeServices() async {
    _learningService = OfflineLearningService();
    _gemmaService = Gemma3BackendService();
    _smartApiService = SmartApiService();

    try {
      setState(() {
        _connectionStatus = 'Conectando ao Gemma-3n...';
      });

      // Inicializar Gemma-3
      final gemmaConnected = await _gemmaService.initialize();
      
      setState(() {
        _isGemmaConnected = gemmaConnected;
        _connectionStatus = gemmaConnected 
            ? 'Gemma-3n ativo ✅' 
            : 'Gemma-3n offline 🟡';
      });

      // Testar conexão com backend principal
      try {
        setState(() {
          _connectionStatus = 'Testando backend...';
        });

        final backendConnected = await _testBackendConnection();
        
        setState(() {
          _isBackendConnected = backendConnected;
          if (gemmaConnected && backendConnected) {
            _connectionStatus = 'Todos os serviços conectados ✅';
          } else if (gemmaConnected) {
            _connectionStatus = 'Gemma-3n ativo, backend offline 🟡';
          } else if (backendConnected) {
            _connectionStatus = 'Backend ativo, Gemma-3n offline 🟡';
          } else {
            _connectionStatus = 'Modo offline apenas 🔴';
          }
        });

        print('🔗 Status conexões: Gemma-3n: $gemmaConnected, Backend: $backendConnected');
      } catch (e) {
        setState(() {
          _isBackendConnected = false;
          _connectionStatus = 'Erro de conexão 🔴';
        });
        print('⚠️ Erro de conexão: $e');
      }

      // Carregar progresso do usuário
      await _loadUserProgress();

    } catch (e) {
      setState(() {
        _connectionStatus = 'Erro de inicialização 🔴';
      });
      print('❌ Erro ao inicializar serviços: $e');
    }
  }

  /// Testar conexão simples com backend
  Future<bool> _testBackendConnection() async {
    try {
      final testResponse = await _smartApiService.askHealthQuestion(
        'conexao_teste_educacao',
        language: _useCreole ? 'crioulo-gb' : 'pt-BR',
      );
      return testResponse.success;
    } catch (e) {
      print('❌ Erro teste backend: $e');
      return false;
    }
  }

  /// Carregar progresso do usuário
  Future<void> _loadUserProgress() async {
    try {
      // Se backend conectado, tentar carregar progresso real
      if (_isBackendConnected) {
        final progressResponse = await _smartApiService.askEducationQuestion(
          'Carregar progresso educacional do usuário',
          language: _useCreole ? 'crioulo-gb' : 'pt-BR',
        );

        if (progressResponse.success) {
          print('✅ Progresso carregado do backend');
          // TODO: Parse real progress data
          return;
        }
      }

      // Fallback: usar dados locais
      _loadLocalProgress();
      print('🟡 Usando progresso local');
    } catch (e) {
      print('❌ Erro ao carregar progresso: $e');
      _loadLocalProgress();
    }
  }

  /// Carregar progresso local (simulado)
  void _loadLocalProgress() {
    setState(() {
      _subjectProgress = {
        'literacy': 0.75,
        'math': 0.45,
        'health': 0.89,
        'agriculture': 0.32,
        'science': 0.67,
        'environment': 0.23,
      };
      _completedLessons = 18;
      _totalLessons = 25;
      _currentStreak = 5;
      _totalPoints = 150;
    });
  }

  Future<void> _initSpeech() async {
    try {
      _speechEnabled = false;
      setState(() {});
    } catch (e) {
      print('Erro ao inicializar speech: $e');
    }
  }

  @override
  void dispose() {
    _subjectAnimationController.dispose();
    _progressAnimationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: _buildEnhancedAppBar(),
      body: Column(
        children: [
          _buildProgressHeader(),
          _buildConnectionStatus(),
          if (_isLoading) 
            const LinearProgressIndicator(
              backgroundColor: Colors.grey,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            ),
          Expanded(
            child: _selectedSubject.isEmpty
                ? _buildEnhancedSubjectSelection()
                : _buildEnhancedLearningContent(),
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButtons(),
    );

  PreferredSizeWidget _buildEnhancedAppBar() => AppBar(
      elevation: 0,
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: Colors.white,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _useCreole ? 'Sikolansa Bu Fala' : 'Educação Bu Fala',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          if (_selectedSubject.isNotEmpty)
            Text(
              _getSubjectTitle(),
              style: TextStyle(
                fontSize: 14, 
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(_isCompactView ? Icons.view_comfortable : Icons.view_compact),
          onPressed: () => setState(() => _isCompactView = !_isCompactView),
        ),
        IconButton(
          icon: Icon(_useCreole ? Icons.language : Icons.translate),
          onPressed: () {
            setState(() {
              _useCreole = !_useCreole;
            });
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: _handleMenuSelection,
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'level',
              child: Text(_useCreole ? 'Nível di difisuldadi' : 'Nível de dificuldade'),
            ),
            PopupMenuItem(
              value: 'connection',
              child: Text(_useCreole ? 'Status konexon' : 'Status da conexão'),
            ),
            PopupMenuItem(
              value: 'progress',
              child: Text(_useCreole ? 'Minhu progresu' : 'Meu progresso'),
            ),
          ],
        ),
      ],
    );

  Widget _buildConnectionStatus() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _isGemmaConnected && _isBackendConnected 
                ? Icons.cloud_done 
                : _isGemmaConnected || _isBackendConnected 
                    ? Icons.cloud_queue 
                    : Icons.cloud_off,
            size: 16,
            color: _isGemmaConnected && _isBackendConnected 
                ? Colors.green 
                : _isGemmaConnected || _isBackendConnected 
                    ? Colors.orange 
                    : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            _connectionStatus,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );

  Widget _buildProgressHeader() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primaryGreen, AppColors.primaryGreen.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildProgressCard(
                  '🎯',
                  _useCreole ? 'Lison kompletu' : 'Lições Completas',
                  '$_completedLessons/$_totalLessons',
                  _completedLessons / _totalLessons,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProgressCard(
                  '🔥',
                  _useCreole ? 'Sikwénsia' : 'Sequência',
                  '$_currentStreak ${_useCreole ? "dia" : "dias"}',
                  _currentStreak / 7.0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildProgressCard(
                  '⭐',
                  _useCreole ? 'Pontu' : 'Pontos',
                  '$_totalPoints XP',
                  _totalPoints / 1000.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );

  Widget _buildProgressCard(String emoji, String title, String value, double progress) => Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.white.withValues(alpha: 0.3),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 2,
          ),
        ],
      ),
    );

  Widget _buildEnhancedSubjectSelection() {
    final subjects = _getEnhancedSubjects();
    final filteredSubjects = _searchQuery.isEmpty
        ? subjects
        : subjects.where((subject) {
            final title = subject[_useCreole ? 'title_creole' : 'title'] as String;
            return title.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) => FadeTransition(
                opacity: _fadeAnimation,
                child: Transform.translate(
                  offset: Offset(0, _slideAnimation.value),
                  child: _isCompactView 
                      ? _buildCompactSubjectGrid(filteredSubjects)
                      : _buildExpandedSubjectList(filteredSubjects),
                ),
              ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() => Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: _useCreole ? 'Buska matéria...' : 'Buscar matéria...',
          prefixIcon: const Icon(Icons.search, color: AppColors.primaryGreen),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchQuery = '');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );

  Widget _buildCompactSubjectGrid(List<Map<String, dynamic>> subjects) => GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return _buildCompactSubjectCard(subject, index);
      },
    );

  Widget _buildExpandedSubjectList(List<Map<String, dynamic>> subjects) => ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return _buildExpandedSubjectCard(subject, index);
      },
    );

  Widget _buildCompactSubjectCard(Map<String, dynamic> subject, int index) {
    final title = subject[_useCreole ? 'title_creole' : 'title'] as String;
    final progress = _subjectProgress[subject['id']] ?? 0.0;
    
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 100)),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) => Transform.scale(
          scale: value,
          child: GestureDetector(
            onTap: () => _selectSubject(subject['id'] as String),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.15),
                    spreadRadius: 1,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      subject['icon'] as IconData,
                      size: 32,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                      minHeight: 3,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildExpandedSubjectCard(Map<String, dynamic> subject, int index) {
    final title = subject[_useCreole ? 'title_creole' : 'title'] as String;
    final description = subject[_useCreole ? 'description_creole' : 'description'] as String;
    final progress = _subjectProgress[subject['id']] ?? 0.0;

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 200 + (index * 50)),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) => Transform.translate(
          offset: Offset(50 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    subject['icon'] as IconData,
                    size: 28,
                    color: AppColors.primaryGreen,
                  ),
                ),
                title: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(description),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.grey[300],
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                            minHeight: 4,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: AppColors.primaryGreen,
                    size: 16,
                  ),
                ),
                onTap: () => _selectSubject(subject['id'] as String),
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildEnhancedLearningContent() => Column(
      children: [
        _buildContentHeader(),
        Expanded(
          child: _availableContent.isEmpty
              ? _buildEnhancedEmptyContent()
              : _buildEnhancedContentList(),
        ),
      ],
    );

  Widget _buildContentHeader() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.primaryGreen),
            onPressed: () {
              setState(() {
                _selectedSubject = '';
                _availableContent.clear();
              });
            },
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getSubjectTitle(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_availableContent.isNotEmpty)
                  Text(
                    '${_availableContent.length} ${_useCreole ? "lison disponível" : "lições disponíveis"}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.primaryGreen),
            onPressed: _loadContent,
          ),
        ],
      ),
    );

  Widget _buildEnhancedEmptyContent() => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            duration: const Duration(milliseconds: 1000),
            tween: Tween(begin: 0, end: 1),
            builder: (context, value, child) => Transform.scale(
                scale: value,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.school,
                    size: 64,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
          ),
          const SizedBox(height: 24),
          Text(
            _useCreole ? 'Konteúdu ta karga...' : 'Gerando conteúdo personalizado...',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _isGemmaConnected 
                ? (_useCreole 
                    ? 'Gemma-3n ta prepara matéria pa bo'
                    : 'Gemma-3n está preparando material para você')
                : (_useCreole 
                    ? 'Bu Fala ta karga konteúdu local'
                    : 'Bu Fala está carregando conteúdo local'),
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _loadContent,
            icon: Icon(_isGemmaConnected ? Icons.auto_awesome : Icons.download),
            label: Text(_useCreole ? 'Karga konteúdu' : 'Carregar conteúdo'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );

  Widget _buildEnhancedContentList() => ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _availableContent.length,
      itemBuilder: (context, index) {
        final content = _availableContent[index];
        return _buildEnhancedContentCard(content, index);
      },
    );

  Widget _buildEnhancedContentCard(OfflineLearningContent content, int index) => TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 200 + (index * 100)),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) => Transform.translate(
          offset: Offset(30 * (1 - value), 0),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    spreadRadius: 1,
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Stack(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryGreen,
                      radius: 24,
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    if (index < 3) // Primeiras 3 lições marcadas como concluídas
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.green,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                title: Text(
                  content.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(content.description),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '15-20 ${_useCreole ? "minutu" : "min"}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          _isGemmaConnected ? Icons.auto_awesome : Icons.star,
                          size: 16,
                          color: _isGemmaConnected ? Colors.purple : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _isGemmaConnected ? 'Gemma-3n' : '+10 XP',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    index < 3 ? Icons.replay : Icons.play_arrow,
                    color: AppColors.primaryGreen,
                    size: 20,
                  ),
                ),
                onTap: () => _viewContent(content),
              ),
            ),
          ),
        ),
    );

  Widget _buildFloatingActionButtons() => Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_selectedSubject.isNotEmpty && _isGemmaConnected)
          FloatingActionButton.small(
            heroTag: 'gemma_generate',
            onPressed: _generateWithGemma,
            backgroundColor: Colors.purple,
            child: const Icon(Icons.auto_awesome, color: Colors.white),
          ),
        const SizedBox(height: 8),
        if (_selectedSubject.isNotEmpty)
          FloatingActionButton.small(
            heroTag: 'quiz',
            onPressed: _startQuiz,
            backgroundColor: Colors.orange,
            child: const Icon(Icons.quiz, color: Colors.white),
          ),
        const SizedBox(height: 8),
        FloatingActionButton(
          heroTag: 'mic',
          onPressed: _isListening ? _stopListening : _startListening,
          backgroundColor: _isListening ? Colors.red : AppColors.primaryGreen,
          child: Icon(_isListening ? Icons.mic_off : Icons.mic),
        ),
      ],
    );

  List<Map<String, dynamic>> _getEnhancedSubjects() => [
      {
        'id': 'literacy',
        'title': 'Alfabetização',
        'title_creole': 'Alfabetizason',
        'icon': Icons.menu_book,
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
        'id': 'science',
        'title': 'Ciências',
        'title_creole': 'Siénsia',
        'icon': Icons.science,
        'description': 'Conhecimentos científicos básicos',
        'description_creole': 'Konhesimentu sientífiku básiku',
      },
      {
        'id': 'environment',
        'title': 'Meio Ambiente',
        'title_creole': 'Meiu Ambenti',
        'icon': Icons.nature,
        'description': 'Preservação ambiental',
        'description_creole': 'Preservason ambientál',
      },
    ];

  void _selectSubject(String subjectId) {
    setState(() {
      _selectedSubject = subjectId;
      _isLoading = true;
    });
    _loadContent();
  }

  /// Carregar conteúdo com comunicação real com Gemma-3n
  Future<void> _loadContent() async {
    try {
      setState(() => _isLoading = true);

      var content = <OfflineLearningContent>[];

      // Priorizar Gemma-3n se conectado
      if (_isGemmaConnected) {
        try {
          print('🤖 Gerando conteúdo com Gemma-3n para $_selectedSubject');
          
          final generatedContent = await _gemmaService.generateEducationalContent(
            subject: _selectedSubject,
            language: _useCreole ? 'crioulo-gb' : 'pt-BR',
            level: _currentLevel,
            studentProfile: _lastWords.isNotEmpty ? _lastWords : null,
          );
          
          content = [generatedContent];
          print('✅ Conteúdo gerado pelo Gemma-3n');
          
          // Se backend também conectado, salvar progresso
          if (_isBackendConnected) {
            _saveContentInteraction(generatedContent);
          }
          
        } catch (e) {
          print('⚠️ Erro no Gemma-3n: $e');
          // Fallback para conteúdo local
          content = await _learningService.getContentBySubject(_selectedSubject);
          print('🟡 Usando conteúdo local como fallback');
        }
      } else {
        // Usar conteúdo local se Gemma indisponível
        content = await _learningService.getContentBySubject(_selectedSubject);
        print('📁 Carregando conteúdo local para $_selectedSubject');
      }

      setState(() {
        _availableContent = content;
        _isLoading = false;
      });

      // Mostrar status da geração
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isGemmaConnected 
                  ? (_useCreole ? 'Konteúdu jera ku Gemma-3n!' : 'Conteúdo gerado com Gemma-3n!')
                  : (_useCreole ? 'Konteúdu local karga!' : 'Conteúdo local carregado!'),
            ),
            backgroundColor: _isGemmaConnected ? Colors.purple : Colors.blue,
            duration: const Duration(seconds: 2),
          ),
        );
      }

    } catch (e) {
      setState(() => _isLoading = false);
      print('❌ Erro ao carregar conteúdo: $e');
      _showErrorDialog('Erro ao carregar conteúdo: $e');
    }
  }

  /// Salvar interação de conteúdo no backend
  Future<void> _saveContentInteraction(OfflineLearningContent content) async {
    try {
      if (_isBackendConnected) {
        await _smartApiService.askEducationQuestion(
          'Registrar interação: usuário acessou ${content.title} em $_selectedSubject',
          language: _useCreole ? 'crioulo-gb' : 'pt-BR',
        );
        print('📊 Interação salva no backend');
      }
    } catch (e) {
      print('⚠️ Erro ao salvar interação: $e');
    }
  }

  /// Gerar conteúdo personalizado com Gemma-3n
  Future<void> _generateWithGemma() async {
    if (!_isGemmaConnected) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_useCreole ? 'Gemma-3n ka ta konektadu' : 'Gemma-3n não conectado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() => _isLoading = true);

      // Usar contexto da busca se disponível
      final customPrompt = _searchQuery.isNotEmpty 
          ? 'Criar lição sobre: $_searchQuery'
          : 'Criar lição personalizada avançada sobre $_selectedSubject';

      print('🎯 Gerando conteúdo personalizado: $customPrompt');

      final generatedContent = await _gemmaService.generateEducationalContent(
        subject: _selectedSubject,
        language: _useCreole ? 'crioulo-gb' : 'pt-BR',
        level: 'advanced',
        studentProfile: customPrompt,
      );

      setState(() {
        _availableContent.insert(0, generatedContent); // Adicionar no topo
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_useCreole ? 'Konteúdu personalizadu kriadu!' : 'Conteúdo personalizado criado!'),
          backgroundColor: Colors.purple,
          action: SnackBarAction(
            label: _useCreole ? 'Ver' : 'Ver',
            textColor: Colors.white,
            onPressed: () => _viewContent(generatedContent),
          ),
        ),
      );

    } catch (e) {
      setState(() => _isLoading = false);
      print('❌ Erro na geração personalizada: $e');
      _showErrorDialog('Erro ao gerar conteúdo personalizado: $e');
    }
  }

  void _viewContent(OfflineLearningContent content) {
    // Atualizar progresso quando visualizar conteúdo
    _updateProgress();

    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ContentViewScreen(content: content),
      ),
    );
  }

  /// Atualizar progresso ao visualizar conteúdo
  void _updateProgress() {
    setState(() {
      // Simular progresso incremental
      if (_subjectProgress[_selectedSubject] != null) {
        _subjectProgress[_selectedSubject] = 
            (_subjectProgress[_selectedSubject]! + 0.05).clamp(0.0, 1.0);
      }
      
      // Aumentar pontos XP
      _totalPoints += 10;
      
      // Verificar se completou uma lição
      if (_completedLessons < _totalLessons) {
        _completedLessons++;
      }
    });

    // Salvar progresso se backend conectado
    if (_isBackendConnected) {
      _saveUserProgress();
    }
  }

  /// Salvar progresso do usuário
  Future<void> _saveUserProgress() async {
    try {
      if (_isBackendConnected) {
        await _smartApiService.askEducationQuestion(
          'Salvar progresso: $_completedLessons lições, $_totalPoints pontos, streak: $_currentStreak',
          language: _useCreole ? 'crioulo-gb' : 'pt-BR',
        );
        print('💾 Progresso salvo no backend');
      }
    } catch (e) {
      print('⚠️ Erro ao salvar progresso: $e');
    }
  }

  void _startQuiz() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_useCreole ? 'Quiz ta prepara...' : 'Quiz em preparação...'),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 2),
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
      case 'science':
        return _useCreole ? 'Siénsia' : 'Ciências';
      case 'environment':
        return _useCreole ? 'Meiu Ambenti' : 'Meio Ambiente';
      default:
        return _useCreole ? 'Sikolansa' : 'Educação';
    }
  }

  Future<void> _startListening() async {
    if (!_speechEnabled) return;
    setState(() => _isListening = true);
  }

  Future<void> _stopListening() async {
    setState(() => _isListening = false);
  }

  void _handleMenuSelection(String value) {
    switch (value) {
      case 'level':
        _showLevelDialog();
        break;
      case 'connection':
        _showConnectionDialog();
        break;
      case 'progress':
        _showProgressDialog();
        break;
    }
  }

  void _showLevelDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_useCreole ? 'Nível di difisuldadi' : 'Nível de dificuldade'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              value: 'beginner',
              groupValue: _currentLevel,
              title: Text(_useCreole ? 'Inisianti' : 'Iniciante'),
              onChanged: (value) {
                setState(() => _currentLevel = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              value: 'intermediate',
              groupValue: _currentLevel,
              title: Text(_useCreole ? 'Intirmédiu' : 'Intermediário'),
              onChanged: (value) {
                setState(() => _currentLevel = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              value: 'advanced',
              groupValue: _currentLevel,
              title: Text(_useCreole ? 'Avansadu' : 'Avançado'),
              onChanged: (value) {
                setState(() => _currentLevel = value!);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showConnectionDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_useCreole ? 'Status di Konexon' : 'Status da Conexão'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _isGemmaConnected ? Icons.check_circle : Icons.cancel,
                  color: _isGemmaConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text('Gemma-3n: ${_isGemmaConnected ? "Conectado" : "Offline"}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  _isBackendConnected ? Icons.check_circle : Icons.cancel,
                  color: _isBackendConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text('Backend: ${_isBackendConnected ? "Conectado" : "Offline"}'),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _useCreole 
                  ? 'Gemma-3n kria konteúdu personalizadu. Backend guarda progresu.'
                  : 'Gemma-3n cria conteúdo personalizado. Backend salva progresso.',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          if (!_isGemmaConnected || !_isBackendConnected)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _initializeServices(); // Tentar reconectar
              },
              child: Text(_useCreole ? 'Tenta konekta' : 'Tentar conectar'),
            ),
        ],
      ),
    );
  }

  void _showProgressDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_useCreole ? 'Minhu Progresu' : 'Meu Progresso'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🎯 ${_useCreole ? "Lison kompletu" : "Lições completas"}: $_completedLessons/$_totalLessons'),
            const SizedBox(height: 8),
            Text('🔥 ${_useCreole ? "Sikwénsia" : "Sequência"}: $_currentStreak ${_useCreole ? "dia" : "dias"}'),
            const SizedBox(height: 8),
            Text('⭐ ${_useCreole ? "Pontu totál" : "Pontos totais"}: $_totalPoints XP'),
            const SizedBox(height: 16),
            Text(
              _useCreole ? 'Status: ' : 'Status: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_connectionStatus),
          ],
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

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_useCreole ? 'Erro' : 'Erro'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
