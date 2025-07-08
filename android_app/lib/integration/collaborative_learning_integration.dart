import 'package:flutter/material.dart';

import '../screens/ranking_screen.dart';
import '../screens/teach_language_screen.dart';
import '../screens/validation_screen.dart';

/// Exemplo de como integrar o sistema "Ensine o Bu Fala" no app principal
class MainAppIntegration {
  /// 1. Adicionar ao menu principal do app
  static Widget buildCollaborativeMenuItem(BuildContext context) => Card(
      margin: const EdgeInsets.all(8),
      elevation: 4,
      child: InkWell(
        onTap: () => _navigateToTeachingSystem(context),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange.shade300, Colors.orange.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.school,
                    color: Colors.white,
                    size: 32,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '🎓 Ensine o Bu Fala',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white70,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Ajude a preservar as línguas da Guiné-Bissau ensinando traduções para a comunidade',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildFeatureChip('📝 Ensinar'),
                  const SizedBox(width: 8),
                  _buildFeatureChip('✅ Validar'),
                  const SizedBox(width: 8),
                  _buildFeatureChip('🏆 Ranking'),
                ],
              ),
            ],
          ),
        ),
      ),
    );

  static Widget _buildFeatureChip(String text) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );

  static void _navigateToTeachingSystem(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const TeachLanguageScreen(),
      ),
    );
  }

  /// 2. Widget de estatísticas rápidas para dashboard
  static Widget buildQuickStats() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.school, color: Colors.orange.shade700),
              const SizedBox(width: 8),
              Text(
                'Sistema Colaborativo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(
                icon: '👥',
                value: '127',
                label: 'Professores',
              ),
              _StatItem(
                icon: '📝',
                value: '1,543',
                label: 'Frases',
              ),
              _StatItem(
                icon: '🌍',
                value: '7',
                label: 'Idiomas',
              ),
              _StatItem(
                icon: '✅',
                value: '89%',
                label: 'Validadas',
              ),
            ],
          ),
        ],
      ),
    );

  /// 3. Notificação de conquistas
  static void showBadgeEarned(BuildContext context, String badgeName) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.star,
              color: Colors.amber,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              '🎉 Conquista Desbloqueada!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badgeName,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.orange,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text(
                  'Continuar',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 4. Integração com bottom navigation
  static List<BottomNavigationBarItem> getBottomNavItems() => [
      const BottomNavigationBarItem(
        icon: Icon(Icons.home),
        label: 'Início',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.medical_services),
        label: 'Saúde',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.agriculture),
        label: 'Agricultura',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.school), // Nova aba para ensino colaborativo
        label: 'Ensinar',
      ),
      const BottomNavigationBarItem(
        icon: Icon(Icons.person),
        label: 'Perfil',
      ),
    ];

  /// 5. Widget de ações rápidas
  static Widget buildQuickActions(BuildContext context) => Row(
      children: [
        Expanded(
          child: _QuickActionCard(
            icon: Icons.school,
            title: 'Ensinar Frase',
            subtitle: '+10 pontos',
            color: Colors.orange,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => const TeachLanguageScreen(),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.check_circle,
            title: 'Validar',
            subtitle: '+50 pontos',
            color: Colors.green,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => const ValidationScreen(
                  validatorId: 'user_123', // TODO: ID do usuário atual
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _QuickActionCard(
            icon: Icons.leaderboard,
            title: 'Ranking',
            subtitle: 'Ver posição',
            color: Colors.amber,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (context) => const RankingScreen(),
              ),
            ),
          ),
        ),
      ],
    );
}

/// Widget auxiliar para estatísticas
class _StatItem extends StatelessWidget {

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });
  final String icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
}

/// Widget auxiliar para ações rápidas
class _QuickActionCard extends StatelessWidget {

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
}

/// Exemplo de uso no main app
class ExampleMainScreen extends StatefulWidget {
  const ExampleMainScreen({super.key});

  @override
  State<ExampleMainScreen> createState() => _ExampleMainScreenState();
}

class _ExampleMainScreenState extends State<ExampleMainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Bu Fala - Preservando Culturas'),
        backgroundColor: Colors.green,
      ),
      body: _buildCurrentScreen(),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: MainAppIntegration.getBottomNavItems(),
      ),
    );

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeScreen();
      case 1:
        return const Center(child: Text('Tela de Saúde'));
      case 2:
        return const Center(child: Text('Tela de Agricultura'));
      case 3:
        return const TeachLanguageScreen(); // Sistema colaborativo
      case 4:
        return const Center(child: Text('Perfil do Usuário'));
      default:
        return _buildHomeScreen();
    }
  }

  Widget _buildHomeScreen() => SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Menu principal com sistema colaborativo
          MainAppIntegration.buildCollaborativeMenuItem(context),
          const SizedBox(height: 24),

          // Ações rápidas
          const Text(
            'Ações Rápidas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          MainAppIntegration.buildQuickActions(context),
          const SizedBox(height: 24),

          // Estatísticas do sistema colaborativo
          MainAppIntegration.buildQuickStats(),
          const SizedBox(height: 24),

          // Outros widgets do app...
          const Text(
            'Outras Funcionalidades',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          // ... resto do app
        ],
      ),
    );
}
