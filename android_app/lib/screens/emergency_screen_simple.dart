import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/crisis_response_models.dart';
import '../services/crisis_response_service.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final CrisisResponseService _crisisService = CrisisResponseService();
  // final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _useCreole = false;
  bool _isListening = false;
  String _response = '';
  CrisisResponseData? _currentCrisis;

  @override
  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _crisisService.initialize();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(_useCreole ? 'Urgensia' : 'Emergência'),
          backgroundColor: Colors.red[700],
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: Icon(_useCreole ? Icons.language : Icons.translate),
              onPressed: () {
                setState(() => _useCreole = !_useCreole);
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.red[50],
              child: Text(
                _useCreole
                    ? 'Sku bo iha urgensia médiku, shama 192 o ba ospital mais prósimu!'
                    : 'Em caso de emergência médica real, ligue 192 ou vá ao hospital mais próximo!',
                style: TextStyle(
                  color: Colors.red[800],
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: _currentCrisis == null
                  ? _buildEmergencyTypes()
                  : _buildCrisisResponse(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _isListening ? _stopListening : _startListening,
          backgroundColor: _isListening ? Colors.red : Colors.red[700],
          child: Icon(_isListening ? Icons.mic_off : Icons.mic),
        ),
      );

  Widget _buildEmergencyTypes() {
    final emergencies = [
      {
        'id': 'birth',
        'title': 'Parto de Emergência',
        'title_creole': 'Partu di Urgensia',
        'icon': Icons.pregnant_woman,
        'description': 'Complicações durante o parto',
        'description_creole': 'Komplikason durante partu',
      },
      {
        'id': 'bleeding',
        'title': 'Sangramento Severo',
        'title_creole': 'Sangramento Grandi',
        'icon': Icons.bloodtype,
        'description': 'Perda excessiva de sangue',
        'description_creole': 'Perda di sangui demasiu',
      },
      {
        'id': 'fever',
        'title': 'Febre Alta',
        'title_creole': 'Febri Altu',
        'icon': Icons.thermostat,
        'description': 'Temperatura corporal elevada',
        'description_creole': 'Temperatura korpu altu',
      },
      {
        'id': 'breathing',
        'title': 'Dificuldade Respiratória',
        'title_creole': 'Difikuldadi pa Respira',
        'icon': Icons.air,
        'description': 'Problemas para respirar',
        'description_creole': 'Problema pa respira',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: emergencies.length,
      itemBuilder: (context, index) {
        final emergency = emergencies[index];
        final title =
            emergency[_useCreole ? 'title_creole' : 'title'] as String;
        final description =
            emergency[_useCreole ? 'description_creole' : 'description']
                as String;

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: ListTile(
            leading: Icon(
              emergency['icon'] as IconData,
              size: 40,
              color: Colors.red[700],
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Text(description),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => _handleEmergency(emergency['id'] as String),
          ),
        );
      },
    );
  }

  Widget _buildCrisisResponse() {
    if (_currentCrisis == null) return const SizedBox();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() => _currentCrisis = null);
                },
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: Text(
                  _currentCrisis!.emergencyType,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_response.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _useCreole ? 'Orientason:' : 'Orientação:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _response,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          _buildSection(
            _useCreole ? 'Ason Imediatu:' : 'Ações Imediatas:',
            _currentCrisis!.immediateActions,
            Icons.flash_on,
            Colors.red,
          ),
          const SizedBox(height: 20),
          _buildSection(
            _useCreole ? 'Rekursu:' : 'Recursos:',
            _currentCrisis!.resources,
            Icons.medical_services,
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
          String title, List<String> items, IconData icon, Color color) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items
              .map((item) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: color.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          margin: const EdgeInsets.only(top: 6, right: 12),
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ))
              ,
        ],
      );

  Future<void> _handleEmergency(String emergencyId) async {
    setState(() => _response = _useCreole ? 'Ta analiza...' : 'Analisando...');

    try {
      final crisisData = await _crisisService.analyzeCrisis(
        textInput: 'Emergência: $emergencyId',
        language: _useCreole ? 'crioulo-gb' : 'pt-BR',
      );

      setState(() {
        _currentCrisis = crisisData;
        _response = _useCreole
            ? (crisisData.descriptionCreole ?? crisisData.description)
            : crisisData.description;
      });
    } catch (e) {
      setState(() {
        _response = _useCreole
            ? 'Erro iha análizi. Prukura ajuda médiku imediatamenti!'
            : 'Erro na análise. Procure ajuda médica imediatamente!';
      });
    }
  }

  Future<void> _startListening() async {
    setState(() => _isListening = true);
    // Simular reconhecimento de voz
    await Future.delayed(const Duration(seconds: 2));
    _handleEmergency('Emergência detectada por voz');
  }

  Future<void> _stopListening() async {
    setState(() => _isListening = false);
  }
}
