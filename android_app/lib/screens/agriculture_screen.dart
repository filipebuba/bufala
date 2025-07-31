import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../services/emergency_service.dart';

/// Tela principal de agricultura com informações sobre culturas e proteção
class AgricultureScreen extends StatefulWidget {
  /// Construtor da tela de agricultura
  const AgricultureScreen({super.key});

  @override
  State<AgricultureScreen> createState() => _AgricultureScreenState();
}

class _AgricultureScreenState extends State<AgricultureScreen> {
  String? selectedAgricultureType;
  Map<String, dynamic>? agricultureInfo;

  @override
  void initState() {
    super.initState();
    EmergencyService.initializeData();
  }

  void _selectAgricultureType(String type) {
    final appProvider = Provider.of<AppProvider>(context, listen: false);
    final language = appProvider.currentLanguage == 'pt' ? 'pt' : 'crioulo';

    setState(() {
      selectedAgricultureType = type;
      agricultureInfo = EmergencyService.getAgricultureInfo(type, language);
    });
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final isPortuguese = appProvider.currentLanguage == 'pt';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isPortuguese ? 'Agricultura' : 'Agrikultura',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.green[700],
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green[700]!, Colors.green[50]!],
          ),
        ),
        child: selectedAgricultureType == null
            ? _buildAgricultureTypesList(isPortuguese)
            : _buildAgricultureDetails(isPortuguese),
      ),
    );
  }

  Widget _buildAgricultureTypesList(bool isPortuguese) {
    final agricultureTypes = [
      {
        'key': 'crop_protection',
        'title': isPortuguese ? 'Proteção de Culturas' : 'Protesaun di Kultura',
        'subtitle': isPortuguese
            ? 'Como proteger suas plantações de pragas e doenças'
            : 'Kuma proteje kultura di praga i duensa',
        'icon': Icons.shield,
        'color': Colors.green[600]!,
      },
      {
        'key': 'planting_calendar',
        'title':
            isPortuguese ? 'Calendário de Plantio' : 'Kalendario di Planta',
        'subtitle': isPortuguese
            ? 'Quando plantar cada cultura na Guiné-Bissau'
            : 'Kandu planta kada kultura na Guiné-Bissau',
        'icon': Icons.calendar_month,
        'color': Colors.brown[600]!,
      },
    ];

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(
                Icons.agriculture,
                size: 60,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                isPortuguese
                    ? 'Agricultura Sustentável'
                    : 'Agrikultura Sustentavel',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                isPortuguese
                    ? 'Técnicas agrícolas para a Guiné-Bissau'
                    : 'Teknika agrikola pa Guiné-Bissau',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: agricultureTypes.length,
              itemBuilder: (context, index) {
                final agriculture = agricultureTypes[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: InkWell(
                    onTap: () =>
                        _selectAgricultureType(agriculture['key'] as String),
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        gradient: LinearGradient(
                          colors: [
                            (agriculture['color'] as Color).withValues(alpha: 0.1),
                            Colors.white,
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: agriculture['color'] as Color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              agriculture['icon'] as IconData,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  agriculture['title'] as String,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  agriculture['subtitle'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAgricultureDetails(bool isPortuguese) {
    if (agricultureInfo == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    selectedAgricultureType = null;
                    agricultureInfo = null;
                  });
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              Expanded(
                child: Text(
                  agricultureInfo!['title']?.toString() ?? 'Título',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (agricultureInfo!['problems'] != null)
                    ..._buildProblems(isPortuguese),
                  const SizedBox(height: 20),
                  if (agricultureInfo!['solutions'] != null)
                    ..._buildSolutions(isPortuguese),
                  const SizedBox(height: 20),
                  if (agricultureInfo!['natural_remedies'] != null)
                    ..._buildNaturalRemedies(isPortuguese),
                  if (agricultureInfo!['rainy_season'] != null)
                    ..._buildSeasonInfo(isPortuguese),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildProblems(bool isPortuguese) => [
        Text(
          isPortuguese ? 'Problemas Comuns:' : 'Problema Komun:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.red[700],
          ),
        ),
        const SizedBox(height: 10),
        ...((agricultureInfo!['problems'] as List<dynamic>?) ?? [])
            .map<Widget>((problem) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.warning, size: 16, color: Colors.red[700]),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          problem.toString(),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ))
            ,
      ];

  List<Widget> _buildSolutions(bool isPortuguese) => [
        Text(
          isPortuguese ? 'Soluções:' : 'Solusaun:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.green[700],
          ),
        ),
        const SizedBox(height: 10),
        ...((agricultureInfo!['solutions'] as List<dynamic>?) ?? [])
            .map<Widget>((solution) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border(
                      left: BorderSide(
                        width: 4,
                        color: Colors.green[700]!,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.green[700], size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          solution.toString(),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ))
            ,
      ];

  List<Widget> _buildNaturalRemedies(bool isPortuguese) => [
        Text(
          isPortuguese ? 'Remédios Naturais:' : 'Remediu Natural:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.brown[700],
          ),
        ),
        const SizedBox(height: 10),
        ...((agricultureInfo!['natural_remedies'] as List<dynamic>?) ?? [])
            .map<Widget>((remedy) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.brown[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border(
                      left: BorderSide(
                        width: 4,
                        color: Colors.red[700]!,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.eco, color: Colors.brown[700], size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          remedy.toString(),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ))
            ,
      ];

  List<Widget> _buildSeasonInfo(bool isPortuguese) => [
        Text(
          isPortuguese ? 'Época Chuvosa:' : 'Tempu di Chuva:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
        ),
        const SizedBox(height: 10),
        ...((agricultureInfo!['rainy_season'] as List<dynamic>?) ?? [])
            .map<Widget>((crop) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.water_drop, color: Colors.blue[700], size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          crop.toString(),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ))
            ,
        const SizedBox(height: 20),
        Text(
          isPortuguese ? 'Época Seca:' : 'Tempu Seku:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.orange[700],
          ),
        ),
        const SizedBox(height: 10),
        ...((agricultureInfo!['dry_season'] as List<dynamic>?) ?? [])
            .map<Widget>((crop) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.wb_sunny, color: Colors.orange[700], size: 16),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          crop.toString(),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ))
            ,
      ];
}
