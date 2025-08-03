import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../services/emergency_service.dart';
import '../services/integrated_api_service.dart';

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
  List<dynamic> environmentalAlerts = [];
  bool isLoadingAlerts = false;
  final IntegratedApiService _apiService = IntegratedApiService();

  @override
  void initState() {
    super.initState();
    EmergencyService.initializeData();
    _initializeApiService();
    _loadEnvironmentalAlerts();
  }

  /// Inicializar o serviço de API
  Future<void> _initializeApiService() async {
    try {
      await _apiService.initialize();
    } catch (e) {
      print('Erro ao inicializar API: $e');
    }
  }

  /// Carregar alertas ambientais em tempo real
  Future<void> _loadEnvironmentalAlerts() async {
    if (mounted) {
      setState(() {
        isLoadingAlerts = true;
      });
    }

    try {
      final response = await _apiService.get(
          '/api/environmental/alerts?location=Bissau&types=agriculture,weather');

      if (response['success'] == true && response['alerts'] != null) {
        if (mounted) {
          setState(() {
            environmentalAlerts = _cleanAlerts(response['alerts']);
            isLoadingAlerts = false;
          });
        }
      }
    } catch (e) {
      print('Erro ao carregar alertas: $e');
      if (mounted) {
        setState(() {
          isLoadingAlerts = false;
        });
      }
    }
  }

  /// Limpar e personalizar alertas
  List<dynamic> _cleanAlerts(dynamic alertsData) {
    if (alertsData is! List) return [];

    final alerts = alertsData;
    return alerts.map((alert) => {
        'title': _cleanText((alert['title'] ?? '').toString()),
        'message': _cleanText((alert['message'] ?? '').toString()),
        'description': _cleanText((alert['description'] ?? '').toString()),
        'severity': alert['severity'] ?? 'medium',
        'type': alert['type'] ?? 'general',
        'recommendations': (alert['recommendations'] as List?)
                ?.map((rec) => _cleanText(rec.toString()))
                .toList() ??
            [],
        'category': alert['category'] ?? 'geral',
      }).toList();
  }

  /// Função para limpar texto e remover caracteres especiais
  String _cleanText(String text) {
    if (text.isEmpty) return text;

    // Remove caracteres especiais e formatação markdown
    var cleaned = text
        .replaceAll(RegExp(r'\*+'), '') // Remove asteriscos
        .replaceAll(RegExp(r'#+'), '') // Remove hashtags
        .replaceAll(RegExp(r'`+'), '') // Remove backticks
        .replaceAll(RegExp(r'_{2,}'), '') // Remove underlines duplos
        .replaceAll(RegExp(r'-{2,}'), '') // Remove traços duplos
        .replaceAll(RegExp(r'\[|\]'), '') // Remove colchetes
        .replaceAll(RegExp(r'\(|\)'), '') // Remove parênteses extras
        .replaceAll(RegExp(r'"([^"]*)"'), r'$1') // Remove aspas duplas
        .replaceAll(RegExp(r"'([^']*)'"), r'$1') // Remove aspas simples
        .replaceAll(
            RegExp(r'\n{3,}'), '\n\n') // Reduz quebras de linha excessivas
        .replaceAll(RegExp(r'[\u0000-\u001F\u007F-\u009F]'),
            '') // Remove caracteres de controle
        .replaceAll(RegExp(r'[^\x20-\x7E\u00C0-\u017F\u0100-\u024F]'),
            '') // Mantém apenas caracteres imprimíveis e acentos
        .trim();

    // Capitaliza primeira letra
    if (cleaned.isNotEmpty) {
      cleaned = cleaned[0].toUpperCase() + cleaned.substring(1);
    }

    return cleaned;
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
                    : 'Tekniku agrikola pa Guiné-Bissau',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.green[100],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),

        // Widget de alertas ambientais
        _buildEnvironmentalAlertsCard(isPortuguese),

        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: agricultureTypes.length,
            itemBuilder: (context, index) {
              final type = agricultureTypes[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => _selectAgricultureType(type['key'] as String),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            (type['color'] as Color).withValues(alpha: 0.1),
                            (type['color'] as Color).withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: type['color'] as Color,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              type['icon'] as IconData,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  type['title'] as String,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  type['subtitle'] as String,
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
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEnvironmentalAlertsCard(bool isPortuguese) => Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.orange[50]!,
                Colors.red[50]!,
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange[600],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.warning_amber,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isPortuguese ? 'Alertas Ambientais' : 'Alertas Ambiental',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  if (isLoadingAlerts)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (isLoadingAlerts)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      isPortuguese
                          ? 'Carregando alertas...'
                          : 'Karga alertas...',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                )
              else if (environmentalAlerts.isNotEmpty)
                Column(
                  children:
                      environmentalAlerts.take(3).map<Widget>((dynamic alert) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: BorderDirectional(
                          start: BorderSide(
                            color: _getSeverityColor(
                                alert['severity']?.toString() ?? 'medium'),
                            width: 4,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getSeverityColor(
                                      alert['severity']?.toString() ??
                                          'medium'),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  (alert['severity']?.toString() ?? 'medium')
                                      .toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  (alert['title']?.toString() ?? ''),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            (alert['message']?.toString() ?? ''),
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    )).toList(),
                )
              else
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[600],
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isPortuguese
                              ? 'Nenhum alerta no momento'
                              : 'Nada alerta agora',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loadEnvironmentalAlerts,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text(
                    isPortuguese ? 'Atualizar' : 'Atualiza',
                    style: const TextStyle(fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

  Widget _buildAgricultureDetails(bool isPortuguese) {
    if (agricultureInfo == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho com título
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.green[600]!, Colors.green[400]!],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.agriculture,
                        color: Colors.white,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          agricultureInfo!['title']?.toString() ?? '',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    agricultureInfo!['subtitle']?.toString() ?? '',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.green[100],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Seções dinâmicas baseadas no tipo
          ...agricultureInfo!.entries
              .where((entry) =>
                  entry.key != 'title' &&
                  entry.key != 'subtitle' &&
                  entry.value is Map)
              .map((entry) => _buildInfoSection(
                    entry.key,
                    entry.value as Map<String, dynamic>,
                    isPortuguese,
                  )),

          const SizedBox(height: 20),

          // Botão para voltar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  selectedAgricultureType = null;
                  agricultureInfo = null;
                });
              },
              icon: const Icon(Icons.arrow_back),
              label: Text(
                isPortuguese ? 'Voltar' : 'Volta',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(
    String key,
    Map<String, dynamic> section,
    bool isPortuguese,
  ) {
    IconData icon;
    Color color;

    switch (key) {
      case 'protection_methods':
        icon = Icons.shield;
        color = Colors.blue[600]!;
        break;
      case 'natural_pesticides':
        icon = Icons.nature;
        color = Colors.green[600]!;
        break;
      case 'prevention':
        icon = Icons.health_and_safety;
        color = Colors.orange[600]!;
        break;
      case 'planting_times':
        icon = Icons.schedule;
        color = Colors.purple[600]!;
        break;
      case 'crop_calendar':
        icon = Icons.calendar_today;
        color = Colors.teal[600]!;
        break;
      default:
        icon = Icons.info;
        color = Colors.grey[600]!;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withValues(alpha: 0.1),
                color.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      section['title']?.toString() ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (section['description'] != null)
                Text(
                  section['description']?.toString() ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
              if (section['items'] != null) ...[
                const SizedBox(height: 12),
                ...((section['items'] as List).map((item) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              item.toString(),
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ))),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
      case 'critical':
        return Colors.red[700]!;
      case 'medium':
        return Colors.yellow[700]!;
      case 'low':
      default:
        return Colors.blue;
    }
  }
}
