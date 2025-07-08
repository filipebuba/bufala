import 'package:flutter/material.dart';

import '../models/offline_learning_models.dart';
import '../models/international_teaching_models.dart' as intl;
import '../screens/content_view_screen.dart';
import '../services/gemma3_backend_service.dart';
import '../services/offline_learning_service.dart';
import '../services/smart_api_service.dart';
import '../services/international_teaching_service.dart';
import '../utils/app_colors.dart';

class EducationScreenEnhanced extends StatefulWidget {
  const EducationScreenEnhanced({super.key});

  @override
  State<EducationScreenEnhanced> createState() =>
      _EducationScreenEnhancedState();
}

class _EducationScreenEnhancedState extends State<EducationScreenEnhanced>
    with TickerProviderStateMixin {
  late OfflineLearningService _learningService;
  late Gemma3BackendService _gemmaService;
  late SmartApiService _smartApiService;
  late InternationalTeachingService _teachingService;

  // Speech and Audio
  bool _speechEnabled = false;
  bool _isListening = false;

  // Learning State
  bool _isLoading = false;
  bool _useCreole = false;
  String _selectedSubject = '';
  String _currentLevel = 'beginner';
  List<OfflineLearningContent> _availableContent = [];

  // International Teaching State
  bool _showInternationalSection = false;
  intl.SupportedLanguage? _selectedTeachingLanguage;
  intl.TargetAudience? _selectedAudience;
  List<intl.SupportedLanguage> _activeLanguages = [];

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
      CurvedAnimation(
          parent: _subjectAnimationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
          parent: _subjectAnimationController, curve: Curves.elasticOut),
    );

    _subjectAnimationController.forward();
  }

  Future<void> _initializeServices() async {
    _learningService = OfflineLearningService();
    _gemmaService = Gemma3BackendService();
    _smartApiService = SmartApiService();
    _teachingService = InternationalTeachingService();

    try {
      setState(() {
        _connectionStatus = 'Conectando ao Gemma-3n...';
      });

      // Inicializar Gemma-3
      final gemmaConnected = await _gemmaService.initialize();

      setState(() {
        _isGemmaConnected = gemmaConnected;
        _connectionStatus =
            gemmaConnected ? 'Gemma-3n ativo ✅' : 'Gemma-3n offline 🟡';
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

        print(
            '🔗 Status conexões: Gemma-3n: $gemmaConnected, Backend: $backendConnected');
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
      final response = await _smartApiService.askMedicalQuestion(
        question: 'conexao_teste_educacao',
        language: _useCreole ? 'crioulo-gb' : 'pt-BR',
      );
      return response.success;
    } catch (e) {
      print('❌ Erro teste backend: $e');
      return false;
    }
  }

  /// Alternar seção internacional
  void _toggleInternationalSection() {
    setState(() {
      _showInternationalSection = !_showInternationalSection;
      if (_showInternationalSection) {
        _activeLanguages = _teachingService.localLanguages.take(3).toList();
      }
    });
  }

  /// Selecionar língua de ensino
  void _selectTeachingLanguage(intl.SupportedLanguage language) {
    setState(() {
      _selectedTeachingLanguage = language;
    });
  }

  /// Selecionar público-alvo
  void _selectTargetAudience(intl.TargetAudience audience) {
    setState(() {
      _selectedAudience = audience;
    });
  }

  /// Iniciar sessão de ensino internacional
  Future<void> _startInternationalTeaching() async {
    if (_selectedTeachingLanguage == null || _selectedAudience == null) {
      _showErrorMessage('Selecione uma língua e público-alvo');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final session = await _teachingService.createTeachingSession(
        teacherId: 'current_user', // TODO: ID do usuário atual
        audience: _selectedAudience!,
        languages: [_selectedTeachingLanguage!, ..._activeLanguages],
        method: _teachingService.system.teachingMethods.first,
        topic: 'Introdução às línguas locais',
      );

      print('✅ Sessão de ensino criada: ${session.id}');
      _showSuccessMessage('Sessão de ensino iniciada com sucesso!');
    } catch (e) {
      print('❌ Erro ao criar sessão: $e');
      _showErrorMessage('Erro ao iniciar sessão de ensino');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Traduzir texto em tempo real
  Future<void> _translateText(String text) async {
    if (_selectedTeachingLanguage == null || _activeLanguages.isEmpty) {
      _showErrorMessage('Configure as línguas primeiro');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final translations = await _teachingService.translateText(
        text: text,
        sourceLanguage: _selectedTeachingLanguage!,
        targetLanguages: _activeLanguages,
        context: 'education',
      );

      // Mostrar traduções em um diálogo
      _showTranslationsDialog(text, translations);
    } catch (e) {
      print('❌ Erro na tradução: $e');
      _showErrorMessage('Erro ao traduzir texto');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Mostrar diálogo de traduções
  void _showTranslationsDialog(
      String originalText, Map<String, String> translations) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          _useCreole ? 'Traduson' : 'Traduções',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Texto original
              Card(
                color: AppColors.primaryGreen.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${_selectedTeachingLanguage?.name ?? 'Original'}:',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        originalText,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Traduções
              ...translations.entries.map((entry) {
                final language = _activeLanguages
                    .firstWhere((lang) => lang.code == entry.key);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              language.flag ?? '🌍',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${language.name} (${language.nativeName}):',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          entry.value,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_useCreole ? 'Fecha' : 'Fechar'),
          ),
        ],
      ),
    );
  }

  /// Testar conexão com backend usando health check
  Future<bool> _testBackendConnection() async {
    try {
      final response = await _smartApiService.healthCheck();
      return response.success;
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
          question: 'Carregar progresso educacional do usuário',
          language: _useCreole ? 'crioulo-gb' : 'pt-BR',
          subject: 'progress',
          level: 'data',
        );

        if (progressResponse.success) {
          print('✅ Progresso carregado do backend');
          // TODO: Parse real progress data from response
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

  /// Salvar progresso no backend
  Future<void> _saveUserProgress() async {
    try {
      if (_isBackendConnected) {
        final progressData = {
          'completed_lessons': _completedLessons,
          'total_lessons': _totalLessons,
          'current_streak': _currentStreak,
          'total_points': _totalPoints,
          'subject_progress': _subjectProgress,
          'last_updated': DateTime.now().toIso8601String(),
        };

        final saveResponse = await _smartApiService.askEducationQuestion(
          question: 'Salvar progresso educacional: $progressData',
          language: _useCreole ? 'crioulo-gb' : 'pt-BR',
          subject: 'progress_save',
          level: 'data',
        );

        if (saveResponse.success) {
          print('✅ Progresso salvo no backend');
        } else {
          print('⚠️ Falha ao salvar progresso no backend');
        }
      }
      // TODO: Implementar salvamento local também
    } catch (e) {
      print('❌ Erro ao salvar progresso: $e');
    }
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
                valueColor:
                    AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
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
            icon: Icon(
                _isCompactView ? Icons.view_comfortable : Icons.view_compact),
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
                child: Text(_useCreole
                    ? 'Nível di difisuldadi'
                    : 'Nível de dificuldade'),
              ),
              PopupMenuItem(
                value: 'connection',
                child:
                    Text(_useCreole ? 'Status konexon' : 'Status da conexão'),
              ),
              PopupMenuItem(
                value: 'progress',
                child: Text(_useCreole ? 'Minhu progresu' : 'Meu progresso'),
              ),
            ],
          ),
        ],
      );

  Widget _buildProgressHeader() => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryGreen,
              AppColors.primaryGreen.withValues(alpha: 0.8)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _useCreole ? 'Minhu Progresu' : 'Meu Progresso',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _useCreole
                          ? '$_completedLessons di $_totalLessons liçons kompletu'
                          : '$_completedLessons de $_totalLessons lições completas',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_fire_department,
                          color: Colors.orange, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '$_currentStreak',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: _completedLessons / _totalLessons,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  icon: Icons.star,
                  value: '$_totalPoints',
                  label: _useCreole ? 'Pontos' : 'Pontos',
                ),
                _buildStatItem(
                  icon: Icons.trending_up,
                  value:
                      '${(_completedLessons / _totalLessons * 100).toInt()}%',
                  label: _useCreole ? 'Kompletu' : 'Completo',
                ),
                _buildStatItem(
                  icon: Icons.access_time,
                  value: _currentLevel,
                  label: _useCreole ? 'Nível' : 'Nível',
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildStatItem(
          {required IconData icon,
          required String value,
          required String label}) =>
      Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      );

  Widget _buildConnectionStatus() => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _getConnectionStatusColor(),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Icon(
              _getConnectionStatusIcon(),
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _connectionStatus,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (_isBackendConnected || _isGemmaConnected)
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _initializeServices,
                tooltip: _useCreole ? 'Atualiza konexon' : 'Atualizar conexão',
              ),
          ],
        ),
      );

  Color _getConnectionStatusColor() {
    if (_isBackendConnected && _isGemmaConnected) {
      return Colors.green;
    } else if (_isBackendConnected || _isGemmaConnected) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  IconData _getConnectionStatusIcon() {
    if (_isBackendConnected && _isGemmaConnected) {
      return Icons.cloud_done;
    } else if (_isBackendConnected || _isGemmaConnected) {
      return Icons.cloud_queue;
    } else {
      return Icons.cloud_off;
    }
  }

  Widget _buildEnhancedSubjectSelection() {
    final subjects = [
      {
        'id': 'literacy',
        'title': _useCreole ? 'Alfabetisason' : 'Alfabetização',
        'subtitle': _useCreole ? 'Lê i skrebê' : 'Ler e escrever',
        'icon': Icons.book,
        'color': Colors.blue,
        'progress': _subjectProgress['literacy'] ?? 0.0,
      },
      {
        'id': 'math',
        'title': _useCreole ? 'Matematika' : 'Matemática',
        'subtitle': _useCreole ? 'Numeru i kontu' : 'Números e cálculos',
        'icon': Icons.calculate,
        'color': Colors.green,
        'progress': _subjectProgress['math'] ?? 0.0,
      },
      {
        'id': 'health',
        'title': _useCreole ? 'Saúdi' : 'Saúde',
        'subtitle': _useCreole ? 'Kuidadu ku korpu' : 'Cuidados com o corpo',
        'icon': Icons.local_hospital,
        'color': Colors.red,
        'progress': _subjectProgress['health'] ?? 0.0,
      },
      {
        'id': 'agriculture',
        'title': _useCreole ? 'Agrikultura' : 'Agricultura',
        'subtitle': _useCreole ? 'Plantason i animais' : 'Plantação e animais',
        'icon': Icons.agriculture,
        'color': Colors.brown,
        'progress': _subjectProgress['agriculture'] ?? 0.0,
      },
      {
        'id': 'science',
        'title': _useCreole ? 'Siensia' : 'Ciências',
        'subtitle': _useCreole ? 'Natura i mundu' : 'Natureza e mundo',
        'icon': Icons.science,
        'color': Colors.purple,
        'progress': _subjectProgress['science'] ?? 0.0,
      },
      {
        'id': 'environment',
        'title': _useCreole ? 'Ambiente' : 'Meio Ambiente',
        'subtitle': _useCreole ? 'Proteje natura' : 'Proteger a natureza',
        'icon': Icons.eco,
        'color': Colors.teal,
        'progress': _subjectProgress['environment'] ?? 0.0,
      },
    ];

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _slideAnimation.value),
        child: Opacity(
          opacity: _fadeAnimation.value,
          child: Column(
            children: [
              // Search Bar
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText:
                        _useCreole ? 'Buska materia...' : 'Buscar matéria...',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value.toLowerCase();
                    });
                  },
                ),
              ),

              // Subjects Grid
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: _isCompactView ? 3 : 2,
                    childAspectRatio: _isCompactView ? 0.8 : 1.1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: subjects
                      .where((subject) =>
                          _searchQuery.isEmpty ||
                          subject['title']
                              .toString()
                              .toLowerCase()
                              .contains(_searchQuery))
                      .length,
                  itemBuilder: (context, index) {
                    final filteredSubjects = subjects
                        .where((subject) =>
                            _searchQuery.isEmpty ||
                            subject['title']
                                .toString()
                                .toLowerCase()
                                .contains(_searchQuery))
                        .toList();

                    final subject = filteredSubjects[index];
                    return _buildSubjectCard(subject);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectCard(Map<String, dynamic> subject) => GestureDetector(
        onTap: () => _selectSubject(subject['id'] as String),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: (subject['color'] as Color).withValues(alpha: 0.2),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (subject['color'] as Color).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  subject['icon'] as IconData,
                  size: _isCompactView ? 24 : 32,
                  color: subject['color'] as Color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                subject['title'] as String,
                style: TextStyle(
                  fontSize: _isCompactView ? 14 : 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              if (!_isCompactView) ...[
                const SizedBox(height: 4),
                Text(
                  subject['subtitle'] as String,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 12),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${((subject['progress'] as double) * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: subject['color'] as Color,
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: subject['progress'] as double,
                        backgroundColor: Colors.grey.withValues(alpha: 0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                            subject['color'] as Color),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildEnhancedLearningContent() => Column(
        children: [
          // Subject Header
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _getSubjectColor(),
                  _getSubjectColor().withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getSubjectIcon(),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getSubjectTitle(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _getSubjectSubtitle(),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => setState(() => _selectedSubject = ''),
                ),
              ],
            ),
          ),

          // Content List
          Expanded(
            child: _buildContentList(),
          ),
        ],
      );

  Widget _buildContentList() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primaryGreen),
            SizedBox(height: 16),
            Text('Carregando conteúdo...'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _availableContent.length + 1, // +1 for add new lesson button
      itemBuilder: (context, index) {
        if (index == _availableContent.length) {
          return _buildAddLessonCard();
        }

        final content = _availableContent[index];
        return _buildContentCard(content, index);
      },
    );
  }

  Widget _buildContentCard(OfflineLearningContent content, int index) =>
      Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getSubjectColor().withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getContentIcon(content.type),
              color: _getSubjectColor(),
            ),
          ),
          title: Text(
            content.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
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
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '15 min', // Default estimated time
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    _getDifficultyIcon(content.level),
                    size: 16,
                    color: _getDifficultyColor(content.level),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    content.level,
                    style: TextStyle(
                      color: _getDifficultyColor(content.level),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          trailing: Icon(
            Icons.play_circle_fill,
            color: _getSubjectColor(),
            size: 32,
          ),
          onTap: () => _openContent(content),
        ),
      );

  Widget _buildAddLessonCard() {
    if (!_isBackendConnected && !_isGemmaConnected) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            const Icon(
              Icons.cloud_off,
              color: Colors.grey,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              _useCreole
                  ? 'Konexon internet presiza pa kria liçon nobu'
                  : 'Conexão com internet necessária para criar novas lições',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: _getSubjectColor().withValues(alpha: 0.3),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getSubjectColor().withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.add,
              color: _getSubjectColor(),
            ),
          ),
          title: Text(
            _useCreole ? 'Kria Liçon Nobu' : 'Criar Nova Lição',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: _getSubjectColor(),
            ),
          ),
          subtitle: Text(
            _useCreole
                ? 'Usa AI pa kria konteúdu personalizadu'
                : 'Use AI para criar conteúdo personalizado',
          ),
          trailing: Icon(
            Icons.auto_awesome,
            color: _getSubjectColor(),
          ),
          onTap: _createNewLessonWithAI,
        ),
      ),
    );
  }

  Widget _buildFloatingActionButtons() => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_speechEnabled)
            FloatingActionButton(
              heroTag: 'speech',
              onPressed: _listen,
              backgroundColor:
                  _isListening ? Colors.red : AppColors.primaryGreen,
              child: Icon(_isListening ? Icons.mic : Icons.mic_none),
            ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'help',
            onPressed: _showQuickHelp,
            backgroundColor: AppColors.primaryGreen,
            child: const Icon(Icons.help_outline),
          ),
        ],
      );

  // Helper Methods
  String _getSubjectTitle() {
    switch (_selectedSubject) {
      case 'literacy':
        return _useCreole ? 'Alfabetisason' : 'Alfabetização';
      case 'math':
        return _useCreole ? 'Matematika' : 'Matemática';
      case 'health':
        return _useCreole ? 'Saúdi' : 'Saúde';
      case 'agriculture':
        return _useCreole ? 'Agrikultura' : 'Agricultura';
      case 'science':
        return _useCreole ? 'Siensia' : 'Ciências';
      case 'environment':
        return _useCreole ? 'Ambiente' : 'Meio Ambiente';
      default:
        return '';
    }
  }

  String _getSubjectSubtitle() {
    switch (_selectedSubject) {
      case 'literacy':
        return _useCreole ? 'Lê i skrebê' : 'Ler e escrever';
      case 'math':
        return _useCreole ? 'Numeru i kontu' : 'Números e cálculos';
      case 'health':
        return _useCreole ? 'Kuidadu ku korpu' : 'Cuidados com o corpo';
      case 'agriculture':
        return _useCreole ? 'Plantason i animais' : 'Plantação e animais';
      case 'science':
        return _useCreole ? 'Natura i mundu' : 'Natureza e mundo';
      case 'environment':
        return _useCreole ? 'Proteje natura' : 'Proteger a natureza';
      default:
        return '';
    }
  }

  Color _getSubjectColor() {
    switch (_selectedSubject) {
      case 'literacy':
        return Colors.blue;
      case 'math':
        return Colors.green;
      case 'health':
        return Colors.red;
      case 'agriculture':
        return Colors.brown;
      case 'science':
        return Colors.purple;
      case 'environment':
        return Colors.teal;
      default:
        return AppColors.primaryGreen;
    }
  }

  IconData _getSubjectIcon() {
    switch (_selectedSubject) {
      case 'literacy':
        return Icons.book;
      case 'math':
        return Icons.calculate;
      case 'health':
        return Icons.local_hospital;
      case 'agriculture':
        return Icons.agriculture;
      case 'science':
        return Icons.science;
      case 'environment':
        return Icons.eco;
      default:
        return Icons.school;
    }
  }

  IconData _getContentIcon(String type) {
    switch (type) {
      case 'video':
        return Icons.play_circle;
      case 'audio':
        return Icons.volume_up;
      case 'text':
        return Icons.article;
      case 'quiz':
        return Icons.quiz;
      case 'exercise':
        return Icons.assignment;
      default:
        return Icons.school;
    }
  }

  IconData _getDifficultyIcon(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return Icons.sentiment_very_satisfied;
      case 'medium':
        return Icons.sentiment_neutral;
      case 'hard':
        return Icons.sentiment_very_dissatisfied;
      default:
        return Icons.help;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Action Methods
  Future<void> _selectSubject(String subjectId) async {
    setState(() {
      _selectedSubject = subjectId;
      _isLoading = true;
    });

    try {
      // Carregar conteúdo do backend ou Gemma se disponível
      if (_isBackendConnected || _isGemmaConnected) {
        await _loadSubjectContentFromAI(subjectId);
      } else {
        // Usar conteúdo offline
        _availableContent =
            await _learningService.getContentBySubject(subjectId);
      }
    } catch (e) {
      print('❌ Erro ao carregar conteúdo: $e');
      // Fallback para conteúdo offline
      _availableContent = await _learningService.getContentBySubject(subjectId);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Carregar conteúdo da matéria usando AI
  Future<void> _loadSubjectContentFromAI(String subjectId) async {
    try {
      final response = await _smartApiService.askEducationQuestion(
        question: 'Listar conteúdo disponível para ${_getSubjectTitle()}',
        language: _useCreole ? 'crioulo-gb' : 'pt-BR',
        subject: subjectId,
        level: _currentLevel,
      );

      if (response.success) {
        print('✅ Conteúdo carregado do AI: ${response.data}');
        // TODO: Parse AI response to create OfflineLearningContent objects
        // For now, use offline content as fallback
        _availableContent =
            await _learningService.getContentBySubject(subjectId);
      } else {
        print('⚠️ Falha ao carregar conteúdo do AI');
        _availableContent =
            await _learningService.getContentBySubject(subjectId);
      }
    } catch (e) {
      print('❌ Erro ao carregar conteúdo do AI: $e');
      _availableContent = await _learningService.getContentBySubject(subjectId);
    }
  }

  /// Criar nova lição usando AI
  Future<void> _createNewLessonWithAI() async {
    if (!_isBackendConnected && !_isGemmaConnected) {
      _showConnectionErrorDialog();
      return;
    }

    // Show lesson creation dialog
    final lessonTopic = await _showLessonCreationDialog();
    if (lessonTopic == null || lessonTopic.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _smartApiService.askEducationQuestion(
        question:
            'Criar nova lição sobre: $lessonTopic para ${_getSubjectTitle()}',
        language: _useCreole ? 'crioulo-gb' : 'pt-BR',
        subject: _selectedSubject,
        level: _currentLevel,
      );

      if (response.success) {
        print('✅ Nova lição criada: ${response.data}');

        // TODO: Parse AI response and create new OfflineLearningContent
        final newContent = OfflineLearningContent(
          id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
          title: lessonTopic,
          description: response.data ?? 'Conteúdo gerado por AI',
          type: 'text',
          level: _currentLevel,
          subject: _selectedSubject,
          content: response.data ?? '',
          languages: [if (_useCreole) 'crioulo-gb' else 'pt-BR'],
          metadata: {
            'ai_generated': true,
            'estimated_minutes': 15,
            'created_by': 'gemma-3n',
          },
          createdAt: DateTime.now(),
        );

        setState(() {
          _availableContent.insert(0, newContent);
        });

        _showSuccessMessage('Nova lição criada com sucesso!');
      } else {
        _showErrorMessage('Falha ao criar nova lição');
      }
    } catch (e) {
      print('❌ Erro ao criar lição: $e');
      _showErrorMessage('Erro ao criar nova lição');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String?> _showLessonCreationDialog() async {
    final controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_useCreole ? 'Kria Liçon Nobu' : 'Criar Nova Lição'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _useCreole
                  ? 'Ki tópiku bu kê aprende?'
                  : 'Que tópico você quer aprender?',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: _useCreole ? 'Ex: Konta até 10' : 'Ex: Contar até 10',
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_useCreole ? 'Kansela' : 'Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(_useCreole ? 'Kria' : 'Criar'),
          ),
        ],
      ),
    );
  }

  void _openContent(OfflineLearningContent content) {
    Navigator.push<void>(
      context,
      MaterialPageRoute<void>(
        builder: (context) => ContentViewScreen(content: content),
      ),
    ).then((_) {
      // Update progress when returning from content
      _updateProgress(content);
    });
  }

  void _updateProgress(OfflineLearningContent content) {
    setState(() {
      // Simulate progress update
      final currentProgress = _subjectProgress[_selectedSubject] ?? 0.0;
      _subjectProgress[_selectedSubject] =
          (currentProgress + 0.1).clamp(0.0, 1.0);

      _completedLessons++;
      _totalPoints += 10;

      // Update streak logic here if needed
    });

    // Save progress to backend
    _saveUserProgress();
  }

  Future<void> _listen() async {
    // TODO: Implement speech recognition
    setState(() {
      _isListening = !_isListening;
    });
  }

  void _showQuickHelp() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_useCreole ? 'Ajuda' : 'Ajuda'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_useCreole
                ? '• Skojê materia pa aprende\n• Toka lição pa kumesa\n• Usa mikrofone pa fala\n• Kria liçon nobu ku AI'
                : '• Escolha uma matéria para aprender\n• Toque em uma lição para começar\n• Use o microfone para falar\n• Crie novas lições com AI'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_useCreole ? 'OK' : 'OK'),
          ),
        ],
      ),
    );
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
        title:
            Text(_useCreole ? 'Nível di Difisuldadi' : 'Nível de Dificuldade'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ['beginner', 'intermediate', 'advanced']
              .map(
                (level) => RadioListTile<String>(
                  title: Text(level),
                  value: level,
                  groupValue: _currentLevel,
                  onChanged: (value) {
                    setState(() {
                      _currentLevel = value!;
                    });
                    Navigator.pop(context);
                  },
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  void _showConnectionDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_useCreole ? 'Status Konexon' : 'Status da Conexão'),
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
                Text(
                    'Gemma-3n: ${_isGemmaConnected ? "Conectado" : "Offline"}'),
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
                Text(
                    'Backend: ${_isBackendConnected ? "Conectado" : "Offline"}'),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _connectionStatus,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _initializeServices();
            },
            child: Text(_useCreole ? 'Tenta fali' : 'Tentar novamente'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_useCreole ? 'Fecha' : 'Fechar'),
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
            ..._subjectProgress.entries.map(
              (entry) => ListTile(
                title: Text(_getSubjectNameFromId(entry.key)),
                trailing: Text('${(entry.value * 100).toInt()}%'),
                leading: CircularProgressIndicator(
                  value: entry.value,
                  strokeWidth: 3,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_useCreole ? 'Fecha' : 'Fechar'),
          ),
        ],
      ),
    );
  }

  String _getSubjectNameFromId(String id) {
    switch (id) {
      case 'literacy':
        return _useCreole ? 'Alfabetisason' : 'Alfabetização';
      case 'math':
        return _useCreole ? 'Matematika' : 'Matemática';
      case 'health':
        return _useCreole ? 'Saúdi' : 'Saúde';
      case 'agriculture':
        return _useCreole ? 'Agrikultura' : 'Agricultura';
      case 'science':
        return _useCreole ? 'Siensia' : 'Ciências';
      case 'environment':
        return _useCreole ? 'Ambiente' : 'Meio Ambiente';
      default:
        return id;
    }
  }

  void _showConnectionErrorDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_useCreole ? 'Sem Konexon' : 'Sem Conexão'),
        content: Text(
          _useCreole
              ? 'Presiza konexon ku internet pa kria liçon nobu ku AI.'
              : 'É necessário conexão com internet para criar novas lições com AI.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(_useCreole ? 'OK' : 'OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
