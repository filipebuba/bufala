import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/mental_health_models.dart';
import '../services/voice_analysis_service.dart';
import '../services/wellness_coaching_service.dart';
import '../services/gemma3_backend_service.dart';
import 'wellness_profile_setup_screen.dart';
import 'chat_screen.dart';
import 'voice_guided_breathing_screen.dart';
import 'mood_tracking_screen.dart';

class WellnessCoachingScreen extends StatefulWidget {
  const WellnessCoachingScreen({super.key});

  @override
  State<WellnessCoachingScreen> createState() => _WellnessCoachingScreenState();
}

class _WellnessCoachingScreenState extends State<WellnessCoachingScreen>
    with TickerProviderStateMixin {
  final WellnessCoachingService _coachingService = WellnessCoachingService();
  final VoiceAnalysisService _voiceService = VoiceAnalysisService();
  final Gemma3BackendService _gemmaService = Gemma3BackendService();

  late TabController _tabController;
  bool _isLoading = true;
  bool _hasProfile = false;
  Map<String, dynamic>? _wellnessAnalysis;
  Map<String, dynamic>? _progressStats;
  
  // Variáveis do diário
  final TextEditingController _diaryController = TextEditingController();
  final List<Map<String, dynamic>> _diaryEntries = [];
  bool _isSavingEntry = false;
  String _selectedMood = 'neutro';
  double _energyLevel = 5;
  final List<String> _selectedTags = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeServices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _diaryController.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    setState(() => _isLoading = true);

    try {
      await _coachingService.initialize();
      await _voiceService.initialize();
      await _gemmaService.initialize();

      _hasProfile = _coachingService.currentProfile != null;

      if (_hasProfile) {
        await _loadWellnessData();
      }
    } on Exception catch (e) {
      debugPrint('❌ Erro ao inicializar serviços: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadWellnessData() async {
    try {
      final analysis = await _coachingService.performWellnessAnalysis();
      final stats = _coachingService.getProgressStats(days: 7);

      setState(() {
        _wellnessAnalysis = analysis;
        _progressStats = stats;
      });
    } on Exception catch (e) {
      debugPrint('❌ Erro ao carregar dados: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Inicializando Wellness Coach...'),
            ],
          ),
        ),
      );
    }

    if (!_hasProfile) {
      return Scaffold(
        appBar: AppBar(title: const Text('Wellness Coach')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.psychology,
                  size: 80,
                  color: AppColors.primary,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Bem-vindo ao Wellness Coach!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Para começar, vamos configurar seu perfil personalizado de bem-estar.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const WellnessProfileSetupScreen(),
                      ),
                    );

                    if (result == true) {
                      // Perfil criado com sucesso, recarregar apenas os dados
                      setState(() => _isLoading = true);
                      try {
                        await _coachingService.reloadUserData();
                        _hasProfile = _coachingService.currentProfile != null;
                        if (_hasProfile) {
                          await _loadWellnessData();
                        }
                      } catch (e) {
                        debugPrint('❌ Erro ao recarregar dados: $e');
                      } finally {
                        setState(() => _isLoading = false);
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                  child: const Text(
                    'Configurar Perfil',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.psychology, color: Colors.white),
            SizedBox(width: 8),
            Text(
              'Wellness Coach',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWellnessData,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Dashboard'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Diário'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          _buildDiaryTab(),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildDashboardTab() => RefreshIndicator(
        onRefresh: _loadWellnessData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeSection(),
              const SizedBox(height: 20),
              _buildWellnessScoreCard(),
              const SizedBox(height: 20),
              _buildQuickActionsSection(),
              const SizedBox(height: 20),
              _buildProgressSection(),
              const SizedBox(height: 20),
              _buildRecommendationsSection(),
              const SizedBox(height: 20),
              _buildRecentSessionsSection(),
            ],
          ),
        ),
      );

  Widget _buildWelcomeSection() {
    final profile = _coachingService.currentProfile;
    if (profile == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '🌟 Olá, ${profile.name}!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Como está seu bem-estar hoje?',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.track_changes, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                '${profile.goals.length} metas ativas',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              const SizedBox(width: 16),
              const Icon(Icons.psychology, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                '${_coachingService.sessions.length} sessões realizadas',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWellnessScoreCard() {
    if (_wellnessAnalysis == null || _wellnessAnalysis!.containsKey('error')) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.info, size: 48, color: Colors.grey),
              const SizedBox(height: 8),
              const Text(
                'Dados Insuficientes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                  'Registre suas métricas diárias para ver sua pontuação de bem-estar.'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _tabController.animateTo(1),
                child: const Text('Registrar Métricas'),
              ),
            ],
          ),
        ),
      );
    }

    final wellnessScore =
        (_wellnessAnalysis!['wellness_score'] ?? 0.0) as double;
    final trends = _wellnessAnalysis!['trends'] as Map<String, dynamic>? ?? {};

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Pontuação de Bem-estar',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getScoreColor(wellnessScore).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _getScoreLabel(wellnessScore),
                    style: TextStyle(
                      color: _getScoreColor(wellnessScore),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 120,
                  width: 120,
                  child: CircularProgressIndicator(
                    value: wellnessScore / 100,
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getScoreColor(wellnessScore),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Text(
                      '${wellnessScore.toInt()}',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _getScoreColor(wellnessScore),
                      ),
                    ),
                    const Text(
                      'pontos',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildTrendIndicator(
                    'Humor', (trends['mood_trend'] ?? 'stable') as String),
                _buildTrendIndicator(
                    'Estresse', (trends['stress_trend'] ?? 'stable') as String),
                _buildTrendIndicator(
                    'Energia', (trends['energy_trend'] ?? 'stable') as String),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendIndicator(String label, String trend) {
    IconData icon;
    Color color;

    switch (trend) {
      case 'improving':
        icon = Icons.trending_up;
        color = Colors.green;
        break;
      case 'declining':
        icon = Icons.trending_down;
        color = Colors.red;
        break;
      default:
        icon = Icons.trending_flat;
        color = Colors.grey;
    }

    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildQuickActionsSection() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⚡ Ações Rápidas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.mic,
                  label: 'Check Vocal',
                  color: Colors.blue,
                  onTap: _startVoiceCheck,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.self_improvement,
                  label: 'Respiração',
                  color: Colors.green,
                  onTap: _startBreathingSession,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.psychology,
                  label: 'Meditação',
                  color: Colors.purple,
                  onTap: _startMeditationSession,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.mood,
                  label: 'Humor',
                  color: Colors.orange,
                  onTap: _startMoodTracking,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.chat,
                  label: 'Chat IA',
                  color: Colors.teal,
                  onTap: _startAIChat,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildQuickActionCard(
                  icon: Icons.tips_and_updates,
                  label: 'Dicas',
                  color: Colors.amber,
                  onTap: _getWellnessTips,
                ),
              ),
            ],
          ),
        ],
      );

  Widget _buildQuickActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildProgressSection() {
    if (_progressStats == null || _progressStats!.containsKey('error')) {
      return const SizedBox.shrink();
    }

    final stats = _progressStats!;
    final averages = stats['averages'] as Map<String, dynamic>? ?? {};

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Progresso (7 dias)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildProgressBar('Humor',
                ((averages['mood'] ?? 5.0) as double) / 10.0, Colors.blue),
            const SizedBox(height: 12),
            _buildProgressBar(
                'Energia', (averages['energy'] ?? 0.5) as double, Colors.green),
            const SizedBox(height: 12),
            _buildProgressBar('Baixo Estresse',
                1.0 - ((averages['stress'] ?? 0.5) as double), Colors.orange),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, double value, Color color) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text('${(value * 100).toInt()}%',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ],
      );

  Widget _buildRecommendationsSection() {
    if (_wellnessAnalysis == null || _wellnessAnalysis!.containsKey('error')) {
      return const SizedBox.shrink();
    }

    final recommendations =
        (_wellnessAnalysis!['recommendations'] as List<dynamic>?) ?? [];
    if (recommendations.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '💡 Recomendações Personalizadas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...recommendations.take(3).map((rec) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lightbulb_outline,
                          size: 20, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(child: Text(rec.toString())),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentSessionsSection() {
    final recentSessions = _coachingService.sessions.take(3).toList();
    if (recentSessions.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🎯 Sessões Recentes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...recentSessions.map(_buildSessionTile),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionTile(CoachingSession session) {
    IconData icon;
    Color color;

    switch (session.type) {
      case 'breathing':
        icon = Icons.air;
        color = Colors.green;
        break;
      case 'meditation':
        icon = Icons.self_improvement;
        color = Colors.purple;
        break;
      case 'voice_check':
        icon = Icons.mic;
        color = Colors.blue;
        break;
      case 'mood_tracking':
        icon = Icons.mood;
        color = Colors.orange;
        break;
      default:
        icon = Icons.psychology;
        color = Colors.grey;
    }

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.1),
        child: Icon(icon, color: color),
      ),
      title: Text(_getSessionTypeName(session.type)),
      subtitle: Text(_formatSessionDate(session.startTime)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color:
              _getProgressColor(session.progressScore).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${(session.progressScore * 100).toInt()}%',
          style: TextStyle(
            color: _getProgressColor(session.progressScore),
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() => FloatingActionButton.extended(
        onPressed: _showQuickActionDialog,
        icon: const Icon(Icons.add),
        label: const Text('Nova Sessão'),
        backgroundColor: AppColors.primary,
      );

  // ================= MÉTODOS AUXILIARES =================

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getScoreLabel(double score) {
    if (score >= 80) return 'Excelente';
    if (score >= 60) return 'Bom';
    if (score >= 40) return 'Regular';
    return 'Precisa atenção';
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.8) return Colors.green;
    if (progress >= 0.6) return Colors.orange;
    return Colors.red;
  }

  String _getSessionTypeName(String type) {
    switch (type) {
      case 'breathing':
        return 'Respiração';
      case 'meditation':
        return 'Meditação';
      case 'voice_check':
        return 'Check Vocal';
      case 'mood_tracking':
        return 'Humor';
      case 'stress_relief':
        return 'Alívio Estresse';
      default:
        return 'Sessão';
    }
  }

  String _formatSessionDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) {
      return 'Hoje, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Ontem';
    } else {
      return '${diff.inDays} dias atrás';
    }
  }

  // ================= AÇÕES =================

  Future<void> _startVoiceCheck() async {
    try {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Iniciando análise vocal...'),
            ],
          ),
        ),
      );

      final session =
          await _coachingService.startCoachingSession('voice_check');

      if (mounted) {
        Navigator.of(context).pop(); // Fechar dialog de loading

        if (session != null) {
          _showSessionResultDialog(session);
          await _loadWellnessData();
        }
      }
    } on Exception catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao iniciar análise vocal: $e')),
        );
      }
    }
  }

  Future<void> _startBreathingSession() async {
    // Navegar para a tela de respiração guiada por voz
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const VoiceGuidedBreathingScreen(
          personalizedPrompt: 'Sessão de respiração para relaxamento e redução do estresse',
        ),
      ),
    ).then((_) {
      // Recarregar dados quando voltar da sessão
      _loadWellnessData();
    });
  }

  Future<void> _startMeditationSession() async {
    // Navegar para a tela de meditação guiada por voz
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const VoiceGuidedBreathingScreen(
          sessionType: 'meditation',
          durationMinutes: 10,
          personalizedPrompt: 'Sessão de meditação para relaxamento e foco mental',
        ),
      ),
    ).then((_) {
      // Recarregar dados quando voltar da sessão
      _loadWellnessData();
    });
  }

  Future<void> _startMoodTracking() async {
    // Navegar para a tela de mood tracking
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const MoodTrackingScreen(),
      ),
    ).then((_) {
      // Recarregar dados quando voltar da sessão
      _loadWellnessData();
    });
  }

  void _showQuickActionDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Nova Sessão de Coaching'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.air, color: Colors.green),
              title: const Text('Exercícios de Respiração'),
              onTap: () {
                Navigator.of(context).pop();
                _startBreathingSession();
              },
            ),
            ListTile(
              leading: const Icon(Icons.self_improvement, color: Colors.purple),
              title: const Text('Meditação Guiada'),
              onTap: () {
                Navigator.of(context).pop();
                _startMeditationSession();
              },
            ),
            ListTile(
              leading: const Icon(Icons.mic, color: Colors.blue),
              title: const Text('Análise Vocal'),
              onTap: () {
                Navigator.of(context).pop();
                _startVoiceCheck();
              },
            ),
            ListTile(
              leading: const Icon(Icons.mood, color: Colors.orange),
              title: const Text('Rastreamento de Humor'),
              onTap: () {
                Navigator.of(context).pop();
                _startMoodTracking();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSessionResultDialog(CoachingSession session) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_getSessionTypeName(session.type)} Concluída'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Progresso: ${(session.progressScore * 100).toInt()}%'),
            const SizedBox(height: 12),
            if (session.recommendations.isNotEmpty) ...[
              const Text('Recomendações:',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...session.recommendations.take(3).map(
                    (rec) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text('• $rec'),
                    ),
                  ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ================= MÉTODOS GEMMA-3 =================

  Future<void> _startAIChat() async {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ChatScreen(
          
        ),
      ),
    );
  }

  Future<void> _getWellnessTips() async {
    try {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Gerando dicas personalizadas...'),
            ],
          ),
        ),
      );

      final profile = _coachingService.currentProfile;
      final profileInfo = profile != null
          ? 'Perfil: ${profile.name}, Metas: ${profile.goals.join(", ")}'
          : 'Usuário geral';

      final response = await _gemmaService.sendChatMessage(
        message:
            'Gere 5 dicas personalizadas de bem-estar e saúde mental para hoje. $profileInfo',
        context: 'wellness_tips',
      );

      if (mounted) {
        Navigator.of(context).pop(); // Fechar dialog de loading

        final tips = _cleanGemmaText(
        response['response'] ?? response['answer'] ??
                'Não foi possível gerar dicas no momento.');

        showDialog<void>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.tips_and_updates, color: Colors.amber),
                SizedBox(width: 8),
                Text('Dicas de Bem-estar'),
              ],
            ),
            content: SingleChildScrollView(
              child: Text(tips),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao gerar dicas: $e')),
        );
      }
    }
  }

  String _cleanGemmaText(String text) {
    if (text.isEmpty) return text;
    
    return text
        // Remover marcadores de markdown
        .replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'$1') // Remove negrito
        .replaceAll(RegExp(r'##\s*'), '') // Remove cabeçalhos
        .replaceAll(RegExp(r'\*(.*?)\*'), r'$1') // Remove itálico
        .replaceAll(RegExp(r'`(.*?)`'), r'$1') // Remove código
        .replaceAll(RegExp(r'```[\s\S]*?```'), '') // Remove blocos de código
        .replaceAll(RegExp(r'\[.*?\]\(.*?\)'), '') // Remove links
        
        // Remover caracteres de formatação
        .replaceAll(RegExp(r'[\*_~`]'), '') // Remove caracteres de markdown
        .replaceAll(RegExp(r'#{1,6}\s*'), '') // Remove headers
        .replaceAll(RegExp(r'>\s*'), '') // Remove citações
        .replaceAll(RegExp(r'\|.*?\|'), '') // Remove tabelas
        
        // Normalizar aspas
        .replaceAll(RegExp(r'["'']'), '"') // Normalizar aspas
        
        // Limpar quebras de linha e espaços
        .replaceAll(RegExp(r'\n\s*\n'), '\n') // Remove quebras excessivas
        .replaceAll(RegExp(r'\s+'), ' ') // Normalizar espaços
        .replaceAll(RegExp(r'\n\s*[-•]\s*'), '\n• ') // Normalizar listas
        .replaceAll(RegExp(r'\s*—\s*'), ' - ') // Normalizar travessões
        .replaceAll(RegExp(r'\.\.\.*'), '...') // Normalizar reticências
        .replaceAll(RegExp(r'\u00A0'), ' ') // Remover espaços não-quebráveis
        .replaceAll(RegExp(r'[\x00-\x1F\x7F]'), '') // Remover caracteres de controle
        .trim();
  }

  // ================= DIÁRIO DE BEM-ESTAR =================

  Widget _buildDiaryTab() => DefaultTabController(
      length: 2,
      child: Column(
        children: [
          Material(
            elevation: 2,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
                indicatorColor: Theme.of(context).colorScheme.primary,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                tabs: const [
                  Tab(icon: Icon(Icons.edit_outlined), text: 'Nova Entrada'),
                  Tab(icon: Icon(Icons.history_outlined), text: 'Histórico'),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildNewEntryTab(),
                _buildHistoryTab(),
              ],
            ),
          ),
        ],
      ),
    );

  Widget _buildNewEntryTab() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Cabeçalho moderno
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.primaryContainer,
                        colorScheme.primaryContainer.withOpacity(0.7),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.edit_note_outlined,
                            color: colorScheme.onPrimaryContainer,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Diário de Bem-estar',
                                  style: TextStyle(
                                    color: colorScheme.onPrimaryContainer,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Como você está se sentindo hoje? ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                                  style: TextStyle(
                                    color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Seletor de humor
              _buildMoodSelector(),
              const SizedBox(height: 16),

              // Nível de energia
              _buildEnergyLevelSlider(),
              const SizedBox(height: 16),

              // Tags de sentimentos
              _buildEmotionTags(),
              const SizedBox(height: 16),

              // Campo de texto principal
              _buildDiaryTextInput(),
              const SizedBox(height: 24),

              // Botão de salvar
              _buildSaveButton(),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildMoodSelector() {
    final colorScheme = Theme.of(context).colorScheme;
    final moods = [
      {'key': 'muito_baixo', 'emoji': '😢', 'label': 'Muito Baixo', 'color': Colors.red},
      {'key': 'baixo', 'emoji': '😔', 'label': 'Baixo', 'color': Colors.orange},
      {'key': 'neutro', 'emoji': '😐', 'label': 'Neutro', 'color': Colors.grey},
      {'key': 'bom', 'emoji': '😊', 'label': 'Bom', 'color': Colors.lightGreen},
      {'key': 'muito_bom', 'emoji': '😄', 'label': 'Muito Bom', 'color': Colors.green},
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.sentiment_satisfied_outlined,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Como está seu humor?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.spaceEvenly,
                  children: moods.map((mood) {
                    final isSelected = _selectedMood == mood['key'];
                    return SizedBox(
                      width: (constraints.maxWidth - 32) / 5,
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedMood = mood['key'] as String),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? (mood['color'] as Color).withOpacity(0.2)
                                : colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected 
                                  ? (mood['color'] as Color)
                                  : colorScheme.outline.withOpacity(0.3),
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected ? [
                              BoxShadow(
                                color: (mood['color'] as Color).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ] : null,
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                mood['emoji'] as String,
                                style: TextStyle(
                                  fontSize: isSelected ? 32 : 24,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                mood['label'] as String,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                  color: isSelected 
                                      ? (mood['color'] as Color)
                                      : colorScheme.onSurfaceVariant,
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
                    }).toList(),
                  ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnergyLevelSlider() {
    final colorScheme = Theme.of(context).colorScheme;
    final energyColor = _getEnergyColor();
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.battery_charging_full_outlined,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Nível de Energia',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: energyColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: energyColor),
                  ),
                  child: Text(
                    '${_energyLevel.toInt()}/10',
                    style: TextStyle(
                      color: energyColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: energyColor,
                inactiveTrackColor: energyColor.withOpacity(0.3),
                thumbColor: energyColor,
                overlayColor: energyColor.withOpacity(0.2),
                valueIndicatorColor: energyColor,
                trackHeight: 6,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              ),
              child: Slider(
                value: _energyLevel,
                min: 1,
                max: 10,
                divisions: 9,
                label: '${_energyLevel.toInt()}/10',
                onChanged: (value) => setState(() => _energyLevel = value),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Muito Baixa',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Muito Alta',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmotionTags() {
    final colorScheme = Theme.of(context).colorScheme;
    final availableTags = [
      'Ansioso', 'Calmo', 'Estressado', 'Feliz', 'Triste', 'Motivado',
      'Cansado', 'Esperançoso', 'Preocupado', 'Grato', 'Irritado', 'Relaxado'
    ];

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology_outlined,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Como você se sente?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_selectedTags.length}/3',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: availableTags.map((tag) {
                final isSelected = _selectedTags.contains(tag);
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  child: FilterChip(
                    label: Text(
                      tag,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected 
                            ? colorScheme.onPrimaryContainer
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected && _selectedTags.length < 3) {
                          _selectedTags.add(tag);
                        } else if (!selected) {
                          _selectedTags.remove(tag);
                        }
                      });
                    },
                    selectedColor: colorScheme.primaryContainer,
                    backgroundColor: colorScheme.surface,
                    checkmarkColor: colorScheme.onPrimaryContainer,
                    side: BorderSide(
                      color: isSelected 
                          ? colorScheme.primary
                          : colorScheme.outline.withOpacity(0.5),
                      width: isSelected ? 2 : 1,
                    ),
                    elevation: isSelected ? 2 : 0,
                    shadowColor: colorScheme.primary.withOpacity(0.3),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiaryTextInput() {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit_note_outlined,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Escreva sobre seu dia',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.outline.withOpacity(0.5),
                ),
              ),
              child: TextField(
                controller: _diaryController,
                maxLines: 8,
                style: TextStyle(
                  fontSize: 16,
                  color: colorScheme.onSurface,
                  height: 1.5,
                ),
                decoration: InputDecoration(
                  hintText: 'O que aconteceu hoje? Como você se sentiu? O que aprendeu?\n\nEscreva livremente sobre seus pensamentos e sentimentos...',
                  hintStyle: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: colorScheme.surface,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    final colorScheme = Theme.of(context).colorScheme;
    final canSave = _selectedMood.isNotEmpty && _diaryController.text.trim().isNotEmpty;
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: canSave ? LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            colorScheme.primary,
            colorScheme.primary.withOpacity(0.8),
          ],
        ) : null,
      ),
      child: ElevatedButton(
        onPressed: (_isSavingEntry || !canSave) ? null : _saveDiaryEntry,
        style: ElevatedButton.styleFrom(
          backgroundColor: canSave ? Colors.transparent : colorScheme.surfaceContainerHighest,
          foregroundColor: canSave ? Colors.white : colorScheme.onSurfaceVariant,
          padding: const EdgeInsets.symmetric(vertical: 18),
          elevation: canSave ? 4 : 0,
          shadowColor: canSave ? colorScheme.primary.withOpacity(0.3) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _isSavingEntry
              ? Row(
                  key: const ValueKey('loading'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          canSave ? Colors.white : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Salvando...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: canSave ? Colors.white : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                )
              : Row(
                  key: const ValueKey('save'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      canSave ? Icons.save_outlined : Icons.save_outlined,
                      color: canSave ? Colors.white : colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      canSave ? 'Salvar Entrada' : 'Preencha os campos obrigatórios',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: canSave ? Colors.white : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    if (_diaryEntries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.book_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Nenhuma entrada ainda',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Comece escrevendo sua primeira entrada no diário',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _diaryEntries.length,
      itemBuilder: (context, index) {
        final entry = _diaryEntries[_diaryEntries.length - 1 - index]; // Mais recente primeiro
        return _buildDiaryEntryCard(entry);
      },
    );
  }

  Widget _buildDiaryEntryCard(Map<String, dynamic> entry) {
    final date = DateTime.parse(entry['date'] as String);
    final mood = entry['mood'] as String;
    final moodData = _getMoodData(mood);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho da entrada
            Row(
              children: [
                Text(
                  moodData['emoji'] as String,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${date.day}/${date.month}/${date.year}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (moodData['color'] as Color).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    moodData['label'] as String,
                    style: TextStyle(
                      color: moodData['color'] as Color,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Métricas
            Row(
              children: [
                _buildMetricChip('Energia', '${(entry['energy'] as double).toInt()}/10', Colors.orange),
                const SizedBox(width: 8),
                if ((entry['tags'] as List).isNotEmpty)
                  _buildMetricChip('Tags', '${(entry['tags'] as List).length}', Colors.blue),
              ],
            ),
            const SizedBox(height: 12),

            // Tags
            if ((entry['tags'] as List).isNotEmpty) ...[
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: (entry['tags'] as List<String>).map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(fontSize: 12),
                    ),
                  )).toList(),
              ),
              const SizedBox(height: 12),
            ],

            // Conteúdo
            Text(
              entry['content'] as String,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip(String label, String value, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
          ),
        ],
      ),
    );

  // Métodos auxiliares
  Color _getEnergyColor() {
    if (_energyLevel <= 3) return Colors.red;
    if (_energyLevel <= 5) return Colors.orange;
    if (_energyLevel <= 7) return Colors.yellow[700]!;
    return Colors.green;
  }

  Map<String, dynamic> _getMoodData(String mood) {
    final moods = {
      'muito_baixo': {'emoji': '😢', 'label': 'Muito Baixo', 'color': Colors.red},
      'baixo': {'emoji': '😔', 'label': 'Baixo', 'color': Colors.orange},
      'neutro': {'emoji': '😐', 'label': 'Neutro', 'color': Colors.grey},
      'bom': {'emoji': '😊', 'label': 'Bom', 'color': Colors.lightGreen},
      'muito_bom': {'emoji': '😄', 'label': 'Muito Bom', 'color': Colors.green},
    };
    return moods[mood] ?? moods['neutro']!;
  }

  Future<void> _saveDiaryEntry() async {
    if (_diaryController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, escreva algo no diário antes de salvar'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSavingEntry = true);

    try {
      final entry = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'date': DateTime.now().toIso8601String(),
        'mood': _selectedMood,
        'energy': _energyLevel,
        'tags': List<String>.from(_selectedTags),
        'content': _diaryController.text.trim(),
      };

      // Simular salvamento (aqui você pode integrar com backend)
      await Future.delayed(const Duration(seconds: 1));
      
      setState(() {
        _diaryEntries.add(entry);
        _diaryController.clear();
        _selectedMood = 'neutro';
        _energyLevel = 5.0;
        _selectedTags.clear();
        _isSavingEntry = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Entrada salva com sucesso! 📝'),
          backgroundColor: Colors.green,
        ),
      );

      // Opcional: mudar para aba de histórico
      DefaultTabController.of(context).animateTo(1);
      
    } catch (e) {
      setState(() => _isSavingEntry = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar entrada: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
