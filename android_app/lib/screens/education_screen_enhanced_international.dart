import 'package:flutter/material.dart';

import '../models/international_teaching_models.dart' as intl;
import '../models/offline_learning_models.dart';
import '../services/gemma3_backend_service.dart';
import '../services/international_teaching_service_simple.dart';
import '../services/offline_learning_service.dart';
import '../services/smart_api_service.dart';
import '../utils/app_colors.dart';

class EducationScreenEnhancedFixed extends StatefulWidget {
  const EducationScreenEnhancedFixed({super.key});

  @override
  State<EducationScreenEnhancedFixed> createState() =>
      _EducationScreenEnhancedFixedState();
}

class _EducationScreenEnhancedFixedState
    extends State<EducationScreenEnhancedFixed> with TickerProviderStateMixin {
  // Services
  late OfflineLearningService _learningService;
  late Gemma3BackendService _gemmaService;
  late SmartApiService _smartApiService;
  late InternationalTeachingServiceSimple _teachingService;

  // Learning State
  bool _isLoading = false;
  bool _useCreole = false;
  String _selectedSubject = '';
  final String _currentLevel = 'beginner';
  final List<OfflineLearningContent> _availableContent = [];

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
  final String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeServices();
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
    _teachingService = InternationalTeachingServiceSimple();

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

        // Carregar idiomas suportados
        _activeLanguages = _teachingService.supportedLanguages;

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

  /// Carregar progresso do usuário
  Future<void> _loadUserProgress() async {
    try {
      // Se backend conectado, tentar carregar progresso real
      if (_isBackendConnected) {
        final progressResponse = await _smartApiService.askEducationQuestion(
          question: 'Carregar progresso educacional do usuário',
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
        'international': 0.15, // Nova seção internacional
      };
      _completedLessons = 18;
      _totalLessons = 25;
      _currentStreak = 5;
      _totalPoints = 150;
    });
  }

  /// Alternar seção internacional
  void _toggleInternationalSection() {
    setState(() {
      _showInternationalSection = !_showInternationalSection;
      if (_showInternationalSection) {
        _activeLanguages = _teachingService.localLanguages
            .take(3)
            .cast<intl.SupportedLanguage>()
            .toList();
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
      final sessionId = await _teachingService.startTeachingSession(
        userId: 'current_user', // TODO: ID do usuário atual
        targetLanguage: _selectedTeachingLanguage!,
        sourceLanguage: _activeLanguages.first,
        topic: 'Introdução às línguas locais',
      );

      print('✅ Sessão de ensino criada: $sessionId');
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
        targetLanguage: _activeLanguages.first,
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
                color: AppColors.primaryGreen.withAlpha((0.1 * 255).toInt()),
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

  /// Mostrar mensagem de erro
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// Mostrar mensagem de sucesso
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
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
                  : _showInternationalSection
                      ? _buildInternationalTeachingSection()
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
          IconButton(
            icon: const Icon(Icons.public),
            onPressed: _toggleInternationalSection,
            tooltip:
                _useCreole ? 'Ensino internacional' : 'Ensino Internacional',
          ),
        ],
      );

  Widget _buildProgressHeader() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryGreen,
              AppColors.primaryGreen.withAlpha((0.8 * 255).toInt())
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
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
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '$_totalPoints ${_useCreole ? 'pontu' : 'pontos'}',
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.local_fire_department,
                          color: Colors.orange, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '$_currentStreak ${_useCreole ? 'dia' : 'dias'}',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            CircularProgressIndicator(
              value: _completedLessons / _totalLessons,
              backgroundColor: Colors.white.withAlpha((0.3 * 255).toInt()),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 6,
            ),
            const SizedBox(width: 8),
            Text(
              '$_completedLessons/$_totalLessons',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );

  Widget _buildConnectionStatus() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: _isBackendConnected && _isGemmaConnected
            ? Colors.green.withAlpha((0.1 * 255).toInt())
            : Colors.orange.withAlpha((0.1 * 255).toInt()),
        child: Row(
          children: [
            Icon(
              _isBackendConnected && _isGemmaConnected
                  ? Icons.cloud_done
                  : Icons.cloud_off,
              color: _isBackendConnected && _isGemmaConnected
                  ? Colors.green
                  : Colors.orange,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _connectionStatus,
                style: TextStyle(
                  fontSize: 12,
                  color: _isBackendConnected && _isGemmaConnected
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _buildEnhancedSubjectSelection() {
    final subjects = [
      {
        'id': 'literacy',
        'title': _useCreole ? 'Alfabetisason' : 'Alfabetização',
        'subtitle':
            _useCreole ? 'Aprende lee i skribe' : 'Aprenda a ler e escrever',
        'icon': Icons.library_books,
        'color': Colors.blue,
        'progress': _subjectProgress['literacy'] ?? 0.0,
      },
      {
        'id': 'math',
        'title': _useCreole ? 'Matematika' : 'Matemática',
        'subtitle': _useCreole ? 'Numero i konta' : 'Números e contas',
        'icon': Icons.calculate,
        'color': Colors.orange,
        'progress': _subjectProgress['math'] ?? 0.0,
      },
      {
        'id': 'health',
        'title': _useCreole ? 'Saúdi' : 'Saúde',
        'subtitle': _useCreole ? 'Kuidadu ku korpu' : 'Cuidados com o corpo',
        'icon': Icons.health_and_safety,
        'color': Colors.red,
        'progress': _subjectProgress['health'] ?? 0.0,
      },
      {
        'id': 'agriculture',
        'title': _useCreole ? 'Agrikultura' : 'Agricultura',
        'subtitle': _useCreole ? 'Planta i koleta' : 'Plantar e colher',
        'icon': Icons.agriculture,
        'color': Colors.green,
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
      {
        'id': 'international',
        'title': _useCreole ? 'Ensino Internacional' : 'Ensino Internacional',
        'subtitle': _useCreole ? 'Lingua di mundu' : 'Línguas do mundo',
        'icon': Icons.public,
        'color': Colors.indigo,
        'progress': _subjectProgress['international'] ?? 0.0,
      },
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
        ),
        itemCount: subjects.length,
        itemBuilder: (context, index) => _buildSubjectCard(subjects[index]),
      ),
    );
  }

  Widget _buildSubjectCard(Map<String, dynamic> subject) {
    final color = subject['color'] as Color;
    final progress = subject['progress'] as double;

    return GestureDetector(
      onTap: () {
        if (subject['id'] == 'international') {
          _toggleInternationalSection();
        } else {
          _selectSubject(subject['id'] as String);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withAlpha((0.8 * 255).toInt())],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withAlpha((0.3 * 255).toInt()),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    subject['icon'] as IconData,
                    color: Colors.white,
                    size: 32,
                  ),
                  const Spacer(),
                  if (subject['id'] == 'international')
                    const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 20,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                subject['title'] as String,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subject['subtitle'] as String,
                style: TextStyle(
                  color: Colors.white.withAlpha((0.8 * 255).toInt()),
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _useCreole ? 'Progresu' : 'Progresso',
                        style: TextStyle(
                          color: Colors.white.withAlpha((0.8 * 255).toInt()),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor:
                        Colors.white.withAlpha((0.3 * 255).toInt()),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInternationalTeachingSection() => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header da seção internacional
            Card(
              elevation: 4,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.indigo,
                      Colors.indigo.withAlpha((0.8 * 255).toInt())
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.public, color: Colors.white, size: 32),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _useCreole
                                    ? 'Ensino Internacional'
                                    : 'Ensino Internacional',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _useCreole
                                    ? 'Ensina lingua di Guiné-Bissau pa mundu sabi'
                                    : 'Ensine as línguas da Guiné-Bissau para o mundo',
                                style: TextStyle(
                                  color: Colors.white
                                      .withAlpha((0.9 * 255).toInt()),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Estatísticas
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatChip(
                            '${_teachingService.supportedLanguages.length}',
                            'Línguas'),
                        _buildStatChip(
                            '${_teachingService.localLanguages.length}',
                            'Locais'),
                        _buildStatChip('7', 'ONGs'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Seleção de língua
            Text(
              _useCreole ? 'Selecsiona Lingua' : 'Selecionar Língua',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _teachingService.supportedLanguages.map<Widget>((language) {
                final isSelected =
                    _selectedTeachingLanguage?.code == language.code;
                return GestureDetector(
                  onTap: () => _selectTeachingLanguage(language),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.indigo : Colors.grey[200],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? Colors.indigo : Colors.grey[300]!,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          language.flag ?? '🌍',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          language.name,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        if (language.isLocal) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.star,
                            size: 12,
                            color: isSelected ? Colors.amber : Colors.orange,
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Seleção de público-alvo
            Text(
              _useCreole ? 'Publiku Alvu' : 'Público-Alvo',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...(_teachingService.system.targetAudiences.map((audience) {
              final isSelected = _selectedAudience?.id == audience.id;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        isSelected ? Colors.indigo : Colors.grey[300],
                    child: Icon(
                      _getAudienceIcon(audience.context),
                      color: isSelected ? Colors.white : Colors.grey[600],
                    ),
                  ),
                  title: Text(
                    audience.name,
                    style: TextStyle(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                  subtitle: Text(audience.description),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: Colors.indigo)
                      : null,
                  onTap: () => _selectTargetAudience(audience),
                  selected: isSelected,
                  selectedTileColor:
                      Colors.indigo.withAlpha((0.1 * 255).toInt()),
                ),
              );
            })),
            const SizedBox(height: 24),

            // Ações
            if (_selectedTeachingLanguage != null &&
                _selectedAudience != null) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _startInternationalTeaching,
                      icon: const Icon(Icons.play_arrow),
                      label:
                          Text(_useCreole ? 'Kumesa Ensinu' : 'Iniciar Ensino'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _translateText('Olá, como está?'),
                      icon: const Icon(Icons.translate),
                      label: Text(_useCreole ? 'Tradus' : 'Traduzir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],

            // Campo de tradução personalizada
            if (_selectedTeachingLanguage != null) ...[
              const SizedBox(height: 24),
              Text(
                _useCreole ? 'Tradus Textu' : 'Traduzir Texto',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: _useCreole
                            ? 'Skribe textu pa tradus...'
                            : 'Digite o texto para traduzir...',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          onPressed: () {
                            if (_searchController.text.isNotEmpty) {
                              _translateText(_searchController.text);
                            }
                          },
                          icon: const Icon(Icons.translate),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      );

  Widget _buildStatChip(String value, String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha((0.2 * 255).toInt()),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withAlpha((0.8 * 255).toInt()),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );

  IconData _getAudienceIcon(intl.LearningContext context) {
    switch (context) {
      case intl.LearningContext.classroom:
        return Icons.school;
      case intl.LearningContext.community:
        return Icons.groups;
      case intl.LearningContext.family:
        return Icons.family_restroom;
      case intl.LearningContext.ngo:
        return Icons.volunteer_activism;
      case intl.LearningContext.hospital:
        return Icons.local_hospital;
      case intl.LearningContext.field:
        return Icons.agriculture;
      case intl.LearningContext.emergency:
        return Icons.emergency;
    }
  }

  Widget _buildEnhancedLearningContent() {
    // Placeholder para conteúdo de aprendizado regular
    return const Center(
      child: Text('Conteúdo de aprendizado da matéria selecionada'),
    );
  }

  Widget _buildFloatingActionButtons() => Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (_showInternationalSection)
            FloatingActionButton(
              heroTag: 'help',
              backgroundColor: Colors.indigo,
              onPressed: _showHelpDialog,
              child: const Icon(Icons.help_outline),
            ),
          if (_showInternationalSection) const SizedBox(height: 8),
          FloatingActionButton(
            heroTag: 'back',
            backgroundColor: AppColors.primaryGreen,
            child:
                Icon(_showInternationalSection ? Icons.arrow_back : Icons.add),
            onPressed: () {
              if (_showInternationalSection) {
                setState(() {
                  _showInternationalSection = false;
                  _selectedSubject = '';
                });
              }
            },
          ),
        ],
      );

  void _showHelpDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_useCreole ? 'Ajuda' : 'Ajuda'),
        content: Text(
          _useCreole
              ? 'Selecsiona lingua i publiku pa kumesa ensinu. Sistema ta ajuda tradus i kria kontedu.'
              : 'Selecione uma língua e público-alvo para começar o ensino. O sistema ajudará com traduções e criação de conteúdo.',
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

  // Helper methods
  void _selectSubject(String subjectId) {
    setState(() {
      _selectedSubject = subjectId;
      _showInternationalSection = false;
    });
  }

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
      case 'international':
        return _useCreole ? 'Ensino Internacional' : 'Ensino Internacional';
      default:
        return '';
    }
  }
}
