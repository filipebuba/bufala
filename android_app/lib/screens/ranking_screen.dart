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
    with SingleTickerProviderStateMixin {
  final CollaborativeLearningService _service = CollaborativeLearningService();
  late TabController _tabController;

  models.TeacherRanking? _ranking;
  models.LearningStats? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRankingData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRankingData() async {
    setState(() => _isLoading = true);

    final rankingResponse = await _service.getTeacherRanking();
    final statsResponse = await _service.getLearningStats();

    setState(() {
      if (rankingResponse.success) _ranking = rankingResponse.data;
      if (statsResponse.success) _stats = statsResponse.data;
      _isLoading = false;
    });
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

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade300, Colors.amber.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        children: [
          const Text(
            '📊 Estatísticas da Comunidade',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
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
    Color getPositionColor() {
      switch (position) {
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

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: position <= 3 ? 4 : 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: position <= 3
              ? Border.all(color: getPositionColor(), width: 2)
              : null,
        ),
        child: Row(
          children: [
            // Posição e emoji
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: getPositionColor(),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    getPositionEmoji(),
                    style: const TextStyle(fontSize: 16),
                  ),
                  Text(
                    '$position°',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: position <= 3 ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
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
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Ensina: ${teacher.languagesTeaching.join(", ")}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${teacher.points} pts',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.school, size: 16, color: Colors.blue.shade600),
                      const SizedBox(width: 4),
                      Text(
                        '${teacher.totalPhrasesTaught} frases',
                        style: const TextStyle(fontSize: 12),
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Nível ${teacher.level}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade800,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
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
    );
  }
}
