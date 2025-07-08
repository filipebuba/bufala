import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/mental_health_models.dart';
import '../services/voice_analysis_service.dart';
import '../services/wellness_coaching_service.dart';
import 'wellness_profile_setup_screen.dart';

class WellnessCoachingScreen extends StatefulWidget {
  const WellnessCoachingScreen({super.key});

  @override
  State<WellnessCoachingScreen> createState() => _WellnessCoachingScreenState();
}

class _WellnessCoachingScreenState extends State<WellnessCoachingScreen>
    with TickerProviderStateMixin {
  final WellnessCoachingService _coachingService = WellnessCoachingService();
  final VoiceAnalysisService _voiceService = VoiceAnalysisService();

  late TabController _tabController;
  bool _isLoading = true;
  bool _hasProfile = false;
  Map<String, dynamic>? _wellnessAnalysis;
  Map<String, dynamic>? _progressStats;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _initializeServices();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeServices() async {
    setState(() => _isLoading = true);

    try {
      await _coachingService.initialize();
      await _voiceService.initialize();

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
                      // Perfil criado com sucesso, reinicializar
                      await _initializeServices();
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
            Tab(icon: Icon(Icons.mic), text: 'Análise Voz'),
            Tab(icon: Icon(Icons.self_improvement), text: 'Coaching'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Diário'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          const Center(child: Text('Análise de Voz (em desenvolvimento)')),
          const Center(child: Text('Sessões de Coaching (em desenvolvimento)')),
          const Center(child: Text('Diário de Bem-estar (em desenvolvimento)')),
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
                onPressed: () => _tabController.animateTo(3),
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
    final session = await _coachingService.startCoachingSession('breathing');
    if (session != null) {
      _showSessionResultDialog(session);
      await _loadWellnessData();
    }
  }

  Future<void> _startMeditationSession() async {
    final session = await _coachingService.startCoachingSession('meditation');
    if (session != null) {
      _showSessionResultDialog(session);
      await _loadWellnessData();
    }
  }

  Future<void> _startMoodTracking() async {
    final session =
        await _coachingService.startCoachingSession('mood_tracking');
    if (session != null) {
      _showSessionResultDialog(session);
      await _loadWellnessData();
    }
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
}
