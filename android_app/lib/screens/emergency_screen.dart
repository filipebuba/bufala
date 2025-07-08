import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';

import '../models/crisis_response_models.dart';
import '../services/crisis_response_service.dart';
import '../services/gemma3_backend_service.dart';
import '../services/smart_api_service.dart';
import '../utils/app_colors.dart';
import '../widgets/emergency_details_view.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final SmartApiService _apiService = SmartApiService();
  final CrisisResponseService _crisisService = CrisisResponseService();
  final Gemma3BackendService _gemmaService = Gemma3BackendService();

  bool _isLoading = false;
  String _response = '';
  CrisisResponseData? _currentCrisis;

  // Funcionalidades multimodais
  // final SpeechToText _speechToText = SpeechToText();
  final ImagePicker _imagePicker = ImagePicker();
  bool _speechEnabled = false; // was: false // _speechEnabled = false;
  bool _isListening = false;
  final String _lastWords = '';
  File? _selectedImage;
  String? _currentLocation;

  // Idioma atual
  String _currentLanguage = 'pt-BR';
  bool _useCreole = false;

  final List<Map<String, dynamic>> _emergencies = [
    {
      'id': 'childbirth',
      'title': 'Parto de Emergência',
      'title_creole': 'Partu di Emerjénsia',
      'description': 'Orientações para assistir parto em casa',
      'description_creole': 'Orientason pa djuda partu na kasa',
      'icon': Icons.pregnant_woman,
      'color': Colors.red,
      'severity': 'critical',
    },
    {
      'id': 'severe_bleeding',
      'title': 'Hemorragia Severa',
      'title_creole': 'Emorrajia Gravi',
      'description': 'Como controlar sangramento grave',
      'description_creole': 'Kuma kontrola sangramento gravi',
      'icon': Icons.bloodtype,
      'color': Colors.red[800],
      'severity': 'critical',
    },
    {
      'id': 'high_fever',
      'title': 'Febre Alta',
      'title_creole': 'Febri Altu',
      'description': 'Como tratar febre em crianças e adultos',
      'description_creole': 'Kuma trata febri na kriansa i adultu',
      'icon': Icons.thermostat,
      'color': Colors.orange,
      'severity': 'moderate',
    },
    {
      'id': 'wound_care',
      'title': 'Ferimentos',
      'title_creole': 'Ferida',
      'description': 'Primeiros socorros para cortes e feridas',
      'description_creole': 'Primeiru sokoru pa korte i ferida',
      'icon': Icons.healing,
      'color': Colors.blue,
      'severity': 'moderate',
    },
    {
      'id': 'breathing_difficulty',
      'title': 'Dificuldade Respiratória',
      'title_creole': 'Difikuldadi pa Respira',
      'description': 'Ajuda para problemas de respiração',
      'description_creole': 'Djuda pa problema di respirason',
      'icon': Icons.air,
      'color': Colors.purple,
      'severity': 'critical',
    },
    {
      'id': 'unknown_emergency',
      'title': 'Outra Emergência',
      'title_creole': 'Otra Emerjénsia',
      'description': 'Descreva sua emergência',
      'description_creole': 'Diskribe bu emerjénsia',
      'icon': Icons.help_outline,
      'color': Colors.grey[700],
      'severity': 'unknown',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Inicializar serviços
      await _crisisService.initialize();
      await _gemmaService.initialize();

      // Configurar speech-to-text
      _speechEnabled = false; // await _speechToText.initialize();

      // Obter localização
      await _getCurrentLocation();

      setState(() {});
    } catch (e) {
      print('Erro ao inicializar serviços: $e');
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentLocation = '${position.latitude}, ${position.longitude}';
      });
    } catch (e) {
      setState(() {
        _currentLocation = 'Localização não disponível';
      });
    }
  }

  Future<void> _handleEmergency(String emergencyId) async {
    setState(() {
      _isLoading = true;
      _response = '';
      _currentCrisis = null;
    });

    try {
      // Tentar usar o serviço Gemma-3 primeiro
      CrisisResponseData crisisData;

      if (_gemmaService.isInitialized) {
        // Usar backend Gemma-3 real
        crisisData = await _gemmaService.processEmergency(
          emergencyType: emergencyId,
          description: _lastWords.isNotEmpty ? _lastWords : null,
          imagePath: _selectedImage?.path,
          language: _useCreole ? 'crioulo-gb' : 'pt-BR',
          location: _currentLocation,
        );
        print('✅ Emergência processada com Gemma-3');
      } else {
        // Fallback para serviço local em caso de backend indisponível
        crisisData = await _crisisService.processEmergency(
          emergencyType: emergencyId,
          description: _lastWords.isNotEmpty ? _lastWords : null,
          imagePath: _selectedImage?.path,
          language: _useCreole ? 'crioulo-gb' : 'pt-BR',
        );
        print('🟡 Emergência processada com serviço local (fallback)');
      }

      setState(() {
        _currentCrisis = crisisData;
        _response = _useCreole
            ? (crisisData.descriptionCreole ?? crisisData.description)
            : crisisData.description;
      });
    } catch (e) {
      print('❌ Erro ao processar emergência: $e');
      setState(() {
        _response = _useCreole
            ? 'Eru: Ka konsigi sibi orientason. Buska djuda médiku imediatamenti.'
            : 'Erro: Não foi possível obter orientações. Procure ajuda médica imediatamente.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Funcionalidades de áudio
  Future<void> _startListening() async {
    if (!_speechEnabled) return;

    // Comentado: await _speechToText.listen(
    //   onResult: (result) {
    //     setState(() {
    //       _lastWords = result.recognizedWords;
    //     });
    //   },
    //   listenFor: const Duration(seconds: 30),
    //   pauseFor: const Duration(seconds: 3),
    //   partialResults: true,
    //   localeId: _useCreole ? 'pt_GW' : 'pt_BR',
    // );

    setState(() {
      _isListening = true;
    });
  }

  Future<void> _stopListening() async {
    // await _speechToText.stop();
    setState(() {
      _isListening = false;
    });
  }

  // Funcionalidades de imagem
  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      print('Erro ao capturar imagem: $e');
    }
  }

  // Gerar mensagem de emergência
  Future<void> _generateEmergencyMessage(String emergencyId) async {
    if (_currentLocation == null) return;

    try {
      final message = await _crisisService.generateEmergencyMessage(
        emergencyType: emergencyId,
        location: _currentLocation!,
        additionalInfo: _lastWords.isNotEmpty ? _lastWords : null,
        language: _useCreole ? 'crioulo-gb' : 'pt-BR',
      );

      // Mostrar mensagem gerada
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(
              _useCreole ? 'Mensajen di Emerjénsia' : 'Mensagem de Emergência'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(_useCreole ? 'Fecha' : 'Fechar'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('Erro ao gerar mensagem: $e');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(
            _useCreole ? 'Emerjénsia' : 'Emergências',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppColors.primary,
          elevation: 0,
          actions: [
            // Toggle de idioma
            IconButton(
              onPressed: () {
                setState(() {
                  _useCreole = !_useCreole;
                  _currentLanguage = _useCreole ? 'crioulo-gb' : 'pt-BR';
                });
              },
              icon: Icon(
                _useCreole ? Icons.translate : Icons.language,
                color: Colors.white,
              ),
              tooltip: _useCreole ? 'Português' : 'Crioulo',
            ),
          ],
        ),
        body: _currentCrisis == null
            ? _buildEmergencyTypeSelection()
            : Padding(
                padding: const EdgeInsets.all(16),
                child: EmergencyDetailsView(
                  crisis: _currentCrisis!,
                  language: _currentLanguage,
                ),
              ),
        floatingActionButton: _buildFloatingActionButtons(),
      );

  Widget _buildEmergencyTypeSelection() => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com status de localização
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withAlpha(77)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _useCreole ? 'Lokal Atual' : 'Localização Atual',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _currentLocation ??
                        (_useCreole
                            ? 'Buska lokal...'
                            : 'Obtendo localização...'),
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Instruções multimodais
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withAlpha(77)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline,
                          color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _useCreole ? 'Kuma Usa' : 'Como Usar',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _useCreole
                        ? '• Fala bu problema (botão mikrofoni)\n• Tira foto di situason (botão kámera)\n• Skolhe tipu di emerjénsia'
                        : '• Descreva o problema (botão microfone)\n• Tire foto da situação (botão câmera)\n• Escolha o tipo de emergência',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Input de voz
            if (_lastWords.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.purple.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.withAlpha(77)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.mic, color: Colors.purple, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _useCreole ? 'Bu fala:' : 'Você disse:',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.purple,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _lastWords,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

            // Imagem selecionada
            if (_selectedImage != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.withAlpha(77)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.camera_alt,
                            color: Colors.orange, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          _useCreole ? 'Foto kapturadu' : 'Foto capturada',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                            fontSize: 12,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () =>
                              setState(() => _selectedImage = null),
                          icon: const Icon(Icons.close, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedImage!,
                        height: 100,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),

            Text(
              _useCreole
                  ? 'Skolhe tipu di emerjénsia:'
                  : 'Escolha o tipo de emergência:',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: ListView.builder(
                itemCount: _emergencies.length,
                itemBuilder: (context, index) {
                  final emergency = _emergencies[index];
                  return _buildEmergencyCard(emergency);
                },
              ),
            ),
          ],
        ),
      );

  Widget _buildEmergencyCard(Map<String, dynamic> emergency) {
    final title = _useCreole ? emergency['title_creole'] : emergency['title'];
    final description =
        _useCreole ? emergency['description_creole'] : emergency['description'];
    final severity = emergency['severity'] as String;

    Color cardColor;
    switch (severity) {
      case 'critical':
        cardColor = Colors.red;
        break;
      case 'moderate':
        cardColor = Colors.orange;
        break;
      default:
        cardColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _handleEmergency(emergency['id']?.toString() ?? ''),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: cardColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.warning,
                  color: cardColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title.toString(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (severity == 'critical')
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _useCreole ? 'URJENTI' : 'URGENTE',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description.toString(),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyDetails() {
    if (_currentCrisis == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final crisis = _currentCrisis!;
    final title = _useCreole ? crisis.titleCreole : crisis.title;
    final description =
        _useCreole ? crisis.descriptionCreole : crisis.description;
    final actions =
        _useCreole ? crisis.immediateActionsCreole : crisis.immediateActions;
    final resources = _useCreole ? crisis.resourcesCreole : crisis.resources;
    final warnings = _useCreole ? crisis.warningsCreole : crisis.warnings;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com botão voltar
          Row(
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _currentCrisis = null;
                    _response = '';
                  });
                },
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: Text(
                  title ?? 'Emergência',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // Botão para gerar mensagem de emergência
              IconButton(
                onPressed: () => _generateEmergencyMessage(crisis.id),
                icon: const Icon(Icons.message, color: Colors.blue),
                tooltip: _useCreole ? 'Jera mensajen' : 'Gerar mensagem',
              ),
            ],
          ),

          // Indicador de severidade
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: _getSeverityColor(crisis.severity).withAlpha(25),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _getSeverityColor(crisis.severity).withAlpha(77),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _getSeverityIcon(crisis.severity),
                  color: _getSeverityColor(crisis.severity),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${_useCreole ? "Nivel" : "Nível"}: ${_getSeverityText(crisis.severity)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _getSeverityColor(crisis.severity),
                  ),
                ),
                const Spacer(),
                Text(
                  '${_useCreole ? "Tempu" : "Tempo"}: ${crisis.estimatedTime}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),

          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Análise IA (se disponível)
                    if (crisis.aiAnalysis != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.purple.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                          border:
                              Border.all(color: Colors.purple.withAlpha(77)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.psychology,
                                    color: Colors.purple, size: 16),
                                const SizedBox(width: 8),
                                Text(
                                  _useCreole ? 'Análizi IA' : 'Análise IA',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.purple,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_useCreole ? "Konfiansa" : "Confiança"}: ${((crisis.aiAnalysis!['confidence'] ?? 0.0) * 100).toInt()}%',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),

                    _buildSection(
                      _useCreole ? 'Ason Imediatu:' : 'Ações Imediatas:',
                      actions,
                      Icons.flash_on,
                      Colors.red,
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      _useCreole
                          ? 'Rekursu Nesesáriu:'
                          : 'Recursos Necessários:',
                      resources,
                      Icons.inventory,
                      Colors.blue,
                    ),
                    const SizedBox(height: 20),
                    _buildSection(
                      _useCreole ? 'Avisu Importanti:' : 'Avisos Importantes:',
                      warnings,
                      Icons.warning,
                      Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(
    String title,
    List<String>? items,
    IconData icon,
    Color color,
  ) {
    final safeItems = items ?? [];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...safeItems.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 6),
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${entry.key + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButtons() {
    if (_currentCrisis != null) return const SizedBox.shrink();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botão de câmera
        FloatingActionButton(
          heroTag: 'camera',
          onPressed: _pickImage,
          backgroundColor: Colors.orange,
          tooltip: _useCreole ? 'Tira foto' : 'Tirar foto',
          child: const Icon(Icons.camera_alt, color: Colors.white),
        ),
        const SizedBox(height: 16),

        // Botão de microfone
        FloatingActionButton(
          heroTag: 'microphone',
          onPressed: _isListening ? _stopListening : _startListening,
          backgroundColor: _isListening ? Colors.red : Colors.blue,
          tooltip: _useCreole
              ? (_isListening ? 'Para di grava' : 'Kumesa grava')
              : (_isListening ? 'Parar gravação' : 'Iniciar gravação'),
          child: Icon(
            _isListening ? Icons.mic_off : Icons.mic,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'critical':
        return Colors.red;
      case 'moderate':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity) {
      case 'critical':
        return Icons.emergency;
      case 'moderate':
        return Icons.warning;
      case 'low':
        return Icons.info;
      default:
        return Icons.help;
    }
  }

  String _getSeverityText(String severity) {
    if (_useCreole) {
      switch (severity) {
        case 'critical':
          return 'Kritiku';
        case 'moderate':
          return 'Médiu';
        case 'low':
          return 'Baxu';
        default:
          return 'Diskonhesidu';
      }
    } else {
      switch (severity) {
        case 'critical':
          return 'Crítico';
        case 'moderate':
          return 'Moderado';
        case 'low':
          return 'Baixo';
        default:
          return 'Desconhecido';
      }
    }
  }
}
