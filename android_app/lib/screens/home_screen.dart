import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../services/environmental_api_service.dart';
import '../services/integrated_api_service.dart';
import '../widgets/connection_status.dart';
import '../widgets/feature_card.dart';
import '../widgets/quick_action_button.dart';

import 'education_screen.dart';
import 'environmental_menu_screen.dart';
import 'medical_emergency_unified_screen.dart';
import 'plant_diagnosis_screen.dart';
import 'voiceguide_accessibility_screen.dart';
import 'wellness_coaching_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isConnected = false;
  Map<String, dynamic>? _serverStatus;
  late PageController _pageController;
  late PageController _morancaPageController;
  int _currentCarouselIndex = 0;
  int _currentMorancaIndex = 0;

  final List<Map<String, String>> _guineaBissauImages = [
    {
      'image': 'assets/images/bissau_island.svg',
      'title': 'Ilhas de Bissau',
      'description': 'Belezas naturais das ilhas da Guiné-Bissau'
    },
    {
      'image': 'assets/images/village_scene.svg',
      'title': 'Aldeias Tradicionais',
      'description': 'Vida comunitária nas aldeias guineenses'
    },
    {
      'image': 'assets/images/coastal_scene.svg',
      'title': 'Costa Atlântica',
      'description': 'Pescadores e manguezais da costa'
    },
  ];

  final List<Map<String, String>> _morancaImages = [
    {
      'image': 'assets/images/village_community.svg',
      'title': 'Nossa Moransa',
      'description': 'Moransa é mais que uma casa; é o nosso refúgio, onde a nossa alma descansa'
    },
    {
      'image': 'assets/images/river_life.svg',
      'title': 'Rios da Vida',
      'description': 'Como poderíamos levar conhecimento vital para onde as estradas não chegam?'
    },
    {
      'image': 'assets/images/farmer_plowing.svg',
      'title': 'Homens da Bolanha',
      'description': 'A tecnologia que poderia cumprir a promessa: construir algo que trouxesse ajuda real'
    },
    {
      'image': 'assets/images/pregnant_woman.svg',
      'title': 'Esperança Maternal',
      'description': 'Este projeto nasceu da minha dor, para servir como refúgio de esperança'
    },
    {
      'image': 'assets/images/children_playing.svg',
      'title': 'Futuro Brincando',
      'description': 'A materialização da esperança em código para as nossas crianças'
    },
    {
      'image': 'assets/images/community_gathering.svg',
      'title': 'Sabedoria Coletiva',
      'description': 'A comunidade traduz e valida: falantes nativos constroem o conhecimento'
    },
    {
      'image': 'assets/images/helping_hands.svg',
      'title': 'Mãos que Ajudam',
      'description': 'Garantir que a esperança chegue a todos, não importa quão distante seja a estrada'
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _morancaPageController = PageController();
    _checkConnection();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _morancaPageController.dispose();
    super.dispose();
  }

  Future<void> _checkConnection() async {
    final apiService = context.read<IntegratedApiService>();

    final hasInternet = await apiService.hasInternetConnection();
    final serverStatus = await apiService.healthCheck();

    setState(() {
      _isConnected = hasInternet && serverStatus;
      _serverStatus = serverStatus
          ? {
              'status': 'online',
              'model': 'Moransa AI',
              'features': {
                'medical': true,
                'education': true,
                'agriculture': true
              }
            }
          : {'status': 'offline', 'model': 'N/A', 'features': {}};
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary,
                  AppColors.primaryDark,
                  Color(0xFF1565C0),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.eco,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            AppStrings.appName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Text(
                            'Nha Moransa',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 9,
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  child: ConnectionStatus(isConnected: _isConnected),
                ),
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    onPressed: _checkConnection,
                    tooltip: 'Atualizar conexão',
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),
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

                // Carrossel de imagens da Guiné-Bissau
                _buildGuineaBissauCarousel(),
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
                  icon: Icons.school,
                  title: 'Educação',
                  description: 'Materiais educativos e aprendizado em crioulo',
                  color: Colors.blue,
                  onTap: _navigateToEducation,
                ),
                const SizedBox(height: 24),

                // Carrossel da Nossa Moransa
                _buildMorancaCarousel(),
              ],
            ),
          ),
        ),
      );

  Widget _buildGuineaBissauCarousel() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🏝️ Guiné-Bissau',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentCarouselIndex = index;
                  });
                },
                itemCount: _guineaBissauImages.length,
                itemBuilder: (context, index) {
                  final item = _guineaBissauImages[index];
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // SVG Image
                        Positioned.fill(
                          child: SvgPicture.asset(
                            item['image']!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Gradient overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.6),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Text content
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item['description']!,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Dots indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _guineaBissauImages.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentCarouselIndex == index ? 12 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentCarouselIndex == index
                      ? AppColors.primary
                      : Colors.grey.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
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
                  icon: Icons.accessibility,
                  label: 'Acessibilidade',
                  color: Colors.purple,
                  onTap: _navigateToAccessibility,
                ),
              ),
            ],
          ),
        ],
      );

  void _navigateToEnvironmental() {
    final apiService = EnvironmentalApiService(baseUrl: AppConfig.apiBaseUrl);
    Navigator.push<Widget>(
      context,
      MaterialPageRoute<Widget>(
        builder: (context) => EnvironmentalMenuScreen(apiService: apiService),
      ),
    );
  }

  Widget _buildMorancaCarousel() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '💝 Nossa Moransa - Esperança em Código',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: PageView.builder(
                controller: _morancaPageController,
                 onPageChanged: (index) {
                   setState(() {
                     _currentMorancaIndex = index;
                   });
                 },
                 itemCount: _morancaImages.length,
                itemBuilder: (context, index) {
                  final item = _morancaImages[index];
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withOpacity(0.8),
                          AppColors.primaryDark.withOpacity(0.9),
                          const Color(0xFF1565C0).withOpacity(0.8),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // SVG Image
                        Positioned.fill(
                          child: SvgPicture.asset(
                            item['image']!,
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.white.withOpacity(0.1),
                              BlendMode.overlay,
                            ),
                          ),
                        ),
                        // Gradient overlay
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.7),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Text content
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['title']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                item['description']!,
                                style: const TextStyle(
                                   color: Colors.white70,
                                   fontSize: 15,
                                   height: 1.4,
                                 ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Index indicator
                        Positioned(
                          top: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${index + 1}/${_morancaImages.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Dots indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
               _morancaImages.length,
               (index) => GestureDetector(
                 onTap: () {
                   _morancaPageController.animateToPage(
                     index,
                     duration: const Duration(milliseconds: 300),
                     curve: Curves.easeInOut,
                   );
                 },
                 child: Container(
                   margin: const EdgeInsets.symmetric(horizontal: 4),
                   width: _currentMorancaIndex == index ? 24 : 8,
                   height: 8,
                   decoration: BoxDecoration(
                     color: _currentMorancaIndex == index
                         ? AppColors.primary
                         : Colors.grey.withOpacity(0.4),
                     borderRadius: BorderRadius.circular(4),
                   ),
                 ),
               ),
             ),
          ),
          const SizedBox(height: 16),
          // Inspirational quote
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: const Column(
              children: [
                Icon(
                  Icons.format_quote,
                  color: AppColors.primary,
                  size: 24,
                ),
                SizedBox(height: 8),
                Text(
                  'Construímos o Moransa não apenas porque a tecnologia o tornou possível, mas porque a memória daqueles que perdemos o tornou necessário.',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: AppColors.primaryDark,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
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

  void _navigateToWellness() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const WellnessCoachingScreen(),
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

  void _navigateToAccessibility() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const VoiceGuideAccessibilityScreen(),
      ),
    );
  }

  // void _translateText() - Removido, será implementado na v2
}
