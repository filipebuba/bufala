import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../services/environmental_api_service.dart';
import '../services/integrated_api_service.dart';
import '../widgets/connection_status.dart';
import '../widgets/feature_card.dart';
import '../widgets/quick_action_button.dart';
import 'agriculture_screen.dart';
import 'api_test_screen.dart'; // NOVO: Import da tela de teste

import 'gemma_meditation_test_screen.dart'; // NOVO: Import da tela de teste Gemma-3n
import 'education_screen.dart';
import 'environmental_menu_screen.dart';
import 'medical_emergency_unified_screen.dart';
import 'plant_diagnosis_screen.dart';
import 'translation_screen.dart';
import 'wellness_coaching_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isConnected = false;
  Map<String, dynamic>? _serverStatus;

  // Adicione as funções ausentes para evitar erros de compilação
// Removidas as duplicatas de métodos já existentes
// Removido método duplicado _navigateToEnvironmental

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    final apiService = context.read<IntegratedApiService>();

    final hasInternet = await apiService.hasInternetConnection();
    final serverStatus = await apiService.healthCheck();

    setState(() {
      _isConnected = hasInternet && serverStatus;
      _serverStatus = serverStatus ? {
      'status': 'online',
      'model': 'Moransa AI',
      'features': {'medical': true, 'education': true, 'agriculture': true}
    } : {
      'status': 'offline',
      'model': 'N/A',
      'features': {}
    };
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Row(
            children: [
              Icon(Icons.public, color: Colors.white),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  AppStrings.appName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          actions: [
            ConnectionStatus(isConnected: _isConnected),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _checkConnection,
            ),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: _checkConnection,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Cabeçalho de boas-vindas
                _buildWelcomeHeader(),
                const SizedBox(height: 24),

                // Status do servidor
                if (_serverStatus != null) _buildServerStatus(),
                const SizedBox(height: 24),

                // Ações rápidas
                _buildQuickActions(),
                const SizedBox(height: 24),

                // Funcionalidades principais
                const Text(
                  '🎯 Funcionalidades Principais',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),

                FeatureCard(
                  icon: Icons.self_improvement,
                  title: 'Wellness Coaching',
                  description:
                      'Análise de voz e coaching personalizado para saúde mental e bem-estar',
                  color: Colors.purple,
                  onTap: _navigateToWellness,
                ),
                const SizedBox(height: 12),
                FeatureCard(
                  icon: Icons.eco,
                  title: 'Sustentabilidade Ambiental',
                  description:
                      'Diagnóstico de plantas, biodiversidade, reciclagem e mais',
                  color: Colors.teal,
                  onTap: _navigateToEnvironmental,
                ),
                const SizedBox(height: 12),

                FeatureCard(
                  icon: Icons.spa,
                  title: 'Teste Meditação Gemma-3n',
                  description:
                      'Teste da funcionalidade de meditação com áudio do Gemma-3n',
                  color: Colors.deepPurple,
                  onTap: _navigateToGemmaMeditationTest,
                ),
                const SizedBox(height: 24),

                // Informações sobre idiomas
                _buildLanguageInfo(),
                const SizedBox(height: 24),

                // Dicas de uso offline
                _buildOfflineTips(),
              ],
            ),
          ),
        ),
      );

  Widget _buildWelcomeHeader() => Container(
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
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🌍 Bem-vindo ao Moransa',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Sistema de IA para comunidades da Guiné-Bissau',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Icon(Icons.health_and_safety,
                          color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Primeiros Socorros',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Flexible(
                  child: Row(
                    children: [
                      Icon(Icons.school, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Educação',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Flexible(
                  child: Row(
                    children: [
                      Icon(Icons.agriculture, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Agricultura',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                Flexible(
                  child: Row(
                    children: [
                      Icon(Icons.translate, color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          'Crioulo',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildServerStatus() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _isConnected ? Icons.cloud_done : Icons.cloud_off,
                    color: _isConnected ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isConnected ? 'Sistema Online' : 'Modo Offline',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              if (_serverStatus != null) ...[
                const SizedBox(height: 8),
                Text('Modelo: ${_serverStatus!['model'] ?? 'N/A'}'),
                Text('Status: ${_serverStatus!['status'] ?? 'N/A'}'),
                Text(
                  'Funcionalidades: ${_serverStatus!['features'] is Map ? (_serverStatus!['features'] as Map).keys.join(', ') : 'N/A'}',
                ),
              ],
            ],
          ),
        ),
      );

  Widget _buildQuickActions() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '⚡ Ações Rápidas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),


          Row(
            children: [
              Expanded(
                child: QuickActionButton(
                  icon: Icons.emergency,
                  label: 'Emergência',
                  color: Colors.red,
                  onTap: () => _navigateToMedical(emergency: true),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuickActionButton(
                  icon: Icons.camera_alt,
                  label: 'Analisar Foto',
                  color: Colors.blue,
                  onTap: _analyzeImage,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: QuickActionButton(
                  icon: Icons.translate,
                  label: 'Traduzir',
                  color: Colors.green,
                  onTap: _translateText,
                ),
              ),
            ],
          ),
        ],
      );

  void _navigateToEnvironmental() {
    final apiService =
        EnvironmentalApiService(baseUrl: AppConfig.apiBaseUrl);
    Navigator.push<Widget>(
      context,
      MaterialPageRoute<Widget>(
        builder: (context) => EnvironmentalMenuScreen(apiService: apiService),
      ),
    );
  }

  Widget _buildLanguageInfo() => Card(
        color: AppColors.accent.withValues(alpha: 0.1),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.language, color: AppColors.accent),
                  SizedBox(width: 8),
                  Text(
                    'Suporte a Idiomas',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                '• Português (padrão)\n'
                '• Crioulo da Guiné-Bissau\n'
                '• Aprendizado contínuo de idiomas locais',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      );

  Widget _buildOfflineTips() => Card(
        color: Colors.orange.withValues(alpha: 0.1),
        child: const Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.offline_bolt, color: Colors.orange),
                  SizedBox(width: 8),
                  Text(
                    'Uso Offline',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Mesmo sem internet, você pode:\n'
                '• Acessar informações básicas salvas\n'
                '• Usar guias de primeiros socorros\n'
                '• Consultar materiais educativos offline',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      );

  void _navigateToMedical({bool emergency = false}) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const MedicalEmergencyUnifiedScreen(),
      ),
    );
  }

  void _navigateToEducation() {
    // Navegar para a tela educacional revolucionária
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const EducationScreen(),
      ),
    );
  }

  void _navigateToAgriculture() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const AgricultureScreen(),
      ),
    );
  }

  void _navigateToWellness() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const WellnessCoachingScreen(),
      ),
    );
  }


  void _navigateToGemmaMeditationTest() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GemmaMeditationTestScreen(),
      ),
    );
  }

  void _analyzeImage() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const PlantDiagnosisScreen(),
      ),
    );
  }

  void _translateText() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const TranslationScreen(),
      ),
    );
  }
}
