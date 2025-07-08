import 'package:flutter/material.dart';

import '../services/environmental_api_service.dart';
import 'biodiversity_screen.dart';
import 'environmental_alerts_screen.dart';
import 'environmental_education_screen.dart';
import 'plant_diagnosis_screen.dart';
import 'recycling_screen.dart';

class EnvironmentalMenuScreen extends StatelessWidget {
  const EnvironmentalMenuScreen(
      {required this.apiService, super.key, this.userId});
  final EnvironmentalApiService apiService;
  final String? userId;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Sustentabilidade Ambiental')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.local_florist, color: Colors.green),
            title: const Text('Diagnóstico de Plantas (Imagem)'),
            subtitle: const Text('Identifique doenças e pragas por foto'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<Widget>(
                  builder: (context) => PlantDiagnosisScreen(
                      apiService: apiService, userId: userId),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.eco, color: Colors.teal),
            title: const Text('Rastreamento de Biodiversidade'),
            subtitle: const Text('Catalogar espécies por imagem e localização'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<Widget>(
                  builder: (context) => BiodiversityScreen(api: apiService),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.recycling, color: Colors.blue),
            title: const Text('Reciclagem Inteligente'),
            subtitle: const Text('Escaneie materiais e ganhe pontos'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<Widget>(
                  builder: (context) => RecyclingScreen(api: apiService),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.menu_book, color: Colors.brown),
            title: const Text('Educação Ambiental'),
            subtitle: const Text('Acesse módulos educativos'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<Widget>(
                  builder: (context) =>
                      EnvironmentalEducationScreen(api: apiService),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.warning, color: Colors.red),
            title: const Text('Alertas Ambientais'),
            subtitle: const Text('Veja alertas de riscos ambientais'),
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
        ],
      ),
    );
}
