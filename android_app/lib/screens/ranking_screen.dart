import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/collaborative_learning_models.dart' as models;
import '../services/collaborative_learning_service.dart';

/// Tela de ranking dos professores colaborativos
class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen>
    with TickerProviderStateMixin {
  final CollaborativeLearningService _service = CollaborativeLearningService();
  late TabController _tabController;

  models.TeacherRanking? _ranking;
  models.LearningStats? _stats;
  bool _isLoading = true;
  
  // Animações
  late AnimationController _listController;
  late AnimationController _statsController;
  late List<Animation<double>> _itemAnimations;
  late Animation<double> _statsAnimation;
  
  final List<Color> _podiumColors = [
    Colors.amber,      // 1º lugar - Ouro
    Colors.grey[400]!, // 2º lugar - Prata  
    Colors.orange,     // 3º lugar - Bronze
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeAnimations();
    _loadRanking();
  }
  
  void _initializeAnimations() {
    _listController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _statsController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _statsAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _statsController,
      curve: Curves.easeOutBack,
    ));
    
    // Inicializar animações dos itens
    _itemAnimations = List.generate(10, (index) => Tween<double>(
        begin: 0,
        end: 1,
      ).animate(CurvedAnimation(
        parent: _listController,
        curve: Interval(
          index * 0.1,
          math.min(1, (index + 1) * 0.1 + 0.3),
          curve: Curves.easeOutBack,
        ),
      )));
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _listController.dispose();
    _statsController.dispose();
    super.dispose();
  }

  Future<void> _loadRanking() async {
    setState(() => _isLoading = true);

    final rankingResponse = await _service.getTeacherRanking();
    final statsResponse = await _service.getLearningStats();

    setState(() {
      if (rankingResponse.success) _ranking = rankingResponse.data;
      if (statsResponse.success) _stats = statsResponse.data;
      _isLoading = false;
    });
    
    // Iniciar animações após carregar os dados
    _statsController.forward();
    _listController.forward();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('🏆 Ranking dos Professores'),
        backgroundColor: Colors.amber,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Semanal'),
            Tab(text: 'Mensal'),
            Tab(text: 'Todos os Tempos'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStatsHeader(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildRankingList(_ranking?.weeklyTop ?? []),
                      _buildRankingList(_ranking?.monthlyTop ?? []),
                      _buildRankingList(_ranking?.allTimeTop ?? []),
                    ],
                  ),
                ),
              ],
            ),
    );

  Widget _buildStatsHeader() {
    final stats = _stats;
    if (stats == null) return const SizedBox();

    return AnimatedBuilder(
      animation: _statsAnimation,
      builder: (context, child) => Transform.scale(
          scale: _statsAnimation.value,
          child: Opacity(
            opacity: _statsAnimation.value,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.amber.shade300, Colors.amber.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.amber.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.analytics,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Estatísticas da Comunidade',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        '👥',
                        '${stats.activeTeachers}',
                        'Professores Ativos',
                      ),
                      _buildStatCard(
                        '📝',
                        '${stats.totalPhrases}',
                        'Frases Ensinadas',
                      ),
                      _buildStatCard(
                        '✅',
                        '${stats.validatedPhrases}',
                        'Validadas',
                      ),
                      _buildStatCard(
                        '🌍',
                        '${stats.languagesSupported}',
                        'Idiomas',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
    );
  }

  Widget _buildStatCard(String emoji, String value, String label) => Column(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );

  Widget _buildRankingList(List<models.TeacherProfile> teachers) {
    if (teachers.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Nenhum ranking disponível',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: teachers.length,
      itemBuilder: (context, index) {
        final teacher = teachers[index];
        final position = index + 1;
        return _buildTeacherCard(teacher, position);
      },
    );
  }

  Widget _buildTeacherCard(models.TeacherProfile teacher, int position) {
    final index = position - 1;
    final isTopThree = position <= 3;
    final animationIndex = math.min(index, _itemAnimations.length - 1);
    
    Color getPodiumColor(int pos) {
      switch (pos) {
        case 1:
          return Colors.amber; // Ouro
        case 2:
          return Colors.grey.shade400; // Prata
        case 3:
          return Colors.brown.shade400; // Bronze
        default:
          return Colors.blue.shade100;
      }
    }

    String getPositionEmoji() {
      switch (position) {
        case 1:
          return '🥇';
        case 2:
          return '🥈';
        case 3:
          return '🥉';
        default:
          return '🎯';
      }
    }

    return AnimatedBuilder(
      animation: _itemAnimations[animationIndex],
      builder: (context, child) => Transform.translate(
          offset: Offset(
            0,
            50 * (1 - _itemAnimations[animationIndex].value),
          ),
          child: Opacity(
            opacity: _itemAnimations[animationIndex].value,
            child: Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: isTopThree ? 8 : 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: isTopThree
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            getPodiumColor(position).withOpacity(0.15),
                            getPodiumColor(position).withOpacity(0.05),
                          ],
                        )
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.grey[50]!,
                            Colors.white,
                          ],
                        ),
                  boxShadow: isTopThree
                      ? [
                          BoxShadow(
                            color: getPodiumColor(position).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  children: [
                    // Avatar e posição
                    Stack(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                getPodiumColor(position),
                                getPodiumColor(position).withOpacity(0.7),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: getPodiumColor(position).withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              getPositionEmoji(),
                              style: const TextStyle(fontSize: 24),
                            ),
                          ),
                        ),
                        if (isTopThree)
                          Positioned(
                            top: -4,
                            right: -4,
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: getPodiumColor(position),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  position.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),

                    // Avatar do professor
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.orange.shade200,
                      child: Text(
                        teacher.name.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Informações do professor
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            teacher.name,
                            style: TextStyle(
                              fontSize: isTopThree ? 18 : 16,
                              fontWeight: isTopThree ? FontWeight.bold : FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            'Ensina: ${teacher.languagesTeaching.join(", ")}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              _buildInfoChip(
                                Icons.star,
                                '${teacher.points}',
                                Colors.amber,
                              ),
                              const SizedBox(width: 8),
                              _buildInfoChip(
                                Icons.school,
                                '${teacher.totalPhrasesTaught}',
                                Colors.blue,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Nível e precisão
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: getPodiumColor(position),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '#$position',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Nível ${teacher.level}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${(teacher.accuracyRate * 100).toStringAsFixed(1)}% precisão',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
    );
  }
  
  Widget _buildInfoChip(IconData icon, String value, Color color) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
}
