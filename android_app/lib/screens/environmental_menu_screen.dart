import 'package:flutter/material.dart';

import '../services/environmental_api_service.dart';
import 'biodiversity_screen.dart';
import 'environmental_alerts_screen.dart';
import 'modern_environmental_education_screen.dart';
import 'plant_diagnosis_screen.dart';
import 'recycling_screen.dart';

class EnvironmentalMenuScreen extends StatelessWidget {
  const EnvironmentalMenuScreen(
      {required this.apiService, super.key, this.userId});
  final EnvironmentalApiService apiService;
  final String? userId;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(
            '🌱 Sustentabilidade Ambiental',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF2E7D32),
                  Color(0xFF4CAF50),
                  Color(0xFF81C784)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          elevation: 8,
          shadowColor: Colors.green.withOpacity(0.3),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF1F8E9), Color(0xFFE8F5E8)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const SizedBox(height: 10),
              _buildModernCard(
                context,
                icon: Icons.local_florist_rounded,
                iconColor: Colors.green,
                gradientColors: [Colors.green.shade50, Colors.green.shade100],
                title: '🌿 Diagnóstico de Plantas (Imagem)',
                subtitle: 'Identifique doenças e pragas por foto',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<Widget>(
                      builder: (context) => const PlantDiagnosisScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildModernCard(
                context,
                icon: Icons.eco_rounded,
                iconColor: Colors.teal,
                gradientColors: [Colors.teal.shade50, Colors.teal.shade100],
                title: '🦋 Rastreamento de Biodiversidade',
                subtitle: 'Catalogar espécies por imagem e localização',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<Widget>(
                      builder: (context) => BiodiversityScreen(api: apiService),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildModernCard(
                context,
                icon: Icons.recycling_rounded,
                iconColor: Colors.blue,
                gradientColors: [Colors.blue.shade50, Colors.blue.shade100],
                title: '♻️ Reciclagem Inteligente',
                subtitle: 'Escaneie materiais e ganhe pontos',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<Widget>(
                      builder: (context) => const RecyclingScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildModernCard(
                context,
                icon: Icons.warning_rounded,
                iconColor: Colors.red,
                gradientColors: [Colors.red.shade50, Colors.red.shade100],
                title: '⚠️ Alertas Ambientais',
                subtitle: 'Veja alertas de riscos ambientais',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<Widget>(
                      builder: (context) =>
                          EnvironmentalAlertsScreen(api: apiService),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _buildModernCard(
                context,
                icon: Icons.auto_stories_rounded,
                iconColor: Colors.purple,
                gradientColors: [Colors.purple.shade50, Colors.purple.shade100],
                title: '📚 Educação Ambiental Moderna',
                subtitle: 'Aprendizado personalizado com IA',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<Widget>(
                      builder: (context) =>
                          ModernEnvironmentalEducationScreen(api: apiService),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      );

  Widget _buildModernCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required List<Color> gradientColors,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) =>
      Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: iconColor.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: iconColor.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                            color: Color(0xFF1B5E20),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: iconColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: iconColor,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
