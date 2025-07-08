import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_strings.dart';
import '../services/smart_api_service.dart';
import '../widgets/connection_status.dart';
import '../widgets/quick_action_button.dart';

class MedicalScreen extends StatefulWidget {
  const MedicalScreen({super.key});

  @override
  State<MedicalScreen> createState() => _MedicalScreenState();
}

class _MedicalScreenState extends State<MedicalScreen> {
  final TextEditingController _queryController = TextEditingController();
  final SmartApiService _apiService = SmartApiService();
  bool _isLoading = false;
  String? _response;
  bool _isConnected = false;
  List<Map<String, dynamic>> _emergencyContacts = [];
  List<Map<String, dynamic>> _quickActions = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
    _checkConnection();
  }

  void _initializeData() {
    _emergencyContacts = [
      {
        'name': 'Hospital Nacional Simão Mendes',
        'phone': '+245 320 1234',
        'type': 'hospital',
        'available': true,
      },
      {
        'name': 'Cruz Vermelha',
        'phone': '+245 320 5678',
        'type': 'emergency',
        'available': true,
      },
      {
        'name': 'Bombeiros',
        'phone': '117',
        'type': 'fire',
        'available': true,
      },
    ];

    _quickActions = [
      {
        'title': 'Primeiros Socorros',
        'icon': Icons.healing,
        'color': AppColors.medicalPrimary,
        'action': 'first_aid',
      },
      {
        'title': 'Parto de Emergência',
        'icon': Icons.pregnant_woman,
        'color': AppColors.medicalSecondary,
        'action': 'emergency_birth',
      },
      {
        'title': 'Sintomas',
        'icon': Icons.sick,
        'color': AppColors.medicalAccent,
        'action': 'symptoms',
      },
      {
        'title': 'Medicamentos',
        'icon': Icons.medication,
        'color': AppColors.medicalPrimary,
        'action': 'medications',
      },
    ];
  }

  Future<void> _checkConnection() async {
    try {
      final isConnected = await _apiService.hasInternetConnection();
      setState(() {
        _isConnected = isConnected;
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
      });
    }
  }

  Future<void> _submitQuery() async {
    if (_queryController.text.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _response = null;
    });

    try {
      final response = await _apiService.askMedicalQuestion(
        question: _queryController.text,
      );
      setState(() {
        _response = response.data ?? 'Resposta não disponível';
      });
    } catch (e) {
      setState(() {
        _response = 'Erro: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleQuickAction(String action) async {
    var query = '';

    switch (action) {
      case 'first_aid':
        query = 'Como fazer primeiros socorros básicos?';
        break;
      case 'emergency_birth':
        query = 'Como ajudar em um parto de emergência?';
        break;
      case 'symptoms':
        query = 'Como identificar sintomas graves?';
        break;
      case 'medications':
        query = 'Quais medicamentos básicos ter em casa?';
        break;
    }

    _queryController.text = query;
    await _submitQuery();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text(
            AppStrings.medical,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: AppColors.medicalPrimary,
          elevation: 0,
          actions: [
            MiniConnectionStatus(
              isConnected: _isConnected,
              onTap: _checkConnection,
            ),
            const SizedBox(width: 16),
          ],
        ),
        body: Column(
          children: [
            // Emergency Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.medicalPrimary,
                    AppColors.medicalPrimary.withOpacity(0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.medical_services,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Assistência Médica',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _isConnected
                        ? 'IA disponível para ajudar'
                        : 'Modo offline - Informações básicas',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick Actions
                    const Text(
                      'Ações Rápidas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.2,
                      ),
                      itemCount: _quickActions.length,
                      itemBuilder: (context, index) {
                        final action = _quickActions[index];
                        return QuickActionButton(
                          icon: action['icon'] as IconData? ?? Icons.help,
                          label: action['title']?.toString() ?? '',
                          color: action['color'] as Color? ?? Colors.blue,
                          onTap: () => _handleQuickAction(
                              action['action']?.toString() ?? ''),
                          isEnabled: _isConnected,
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Query Input
                    const Text(
                      'Faça sua pergunta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          TextField(
                            controller: _queryController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText:
                                  'Ex: Como tratar uma ferida? O que fazer em caso de febre alta?',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.all(16),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _submitQuery,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.medicalPrimary,
                                foregroundColor: Colors.white,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Enviar Pergunta',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Response
                    if (_response != null) ...[
                      const SizedBox(height: 24),
                      const Text(
                        'Resposta',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.medicalPrimary.withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          _response!,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.textPrimary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Emergency Contacts
                    const Text(
                      'Contatos de Emergência',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ..._emergencyContacts.map((contact) => Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.medicalPrimary.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _getContactIcon(
                                      contact['type']?.toString() ?? 'phone'),
                                  color: AppColors.medicalPrimary,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      contact['name']?.toString() ?? '',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      contact['phone']?.toString() ?? '',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  // TODO: Implement phone call
                                },
                                icon: const Icon(
                                  Icons.phone,
                                  color: AppColors.medicalPrimary,
                                ),
                              ),
                            ],
                          ),
                        )),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  IconData _getContactIcon(String type) {
    switch (type) {
      case 'hospital':
        return Icons.local_hospital;
      case 'emergency':
        return Icons.emergency;
      case 'fire':
        return Icons.fire_truck;
      default:
        return Icons.phone;
    }
  }

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }
}
