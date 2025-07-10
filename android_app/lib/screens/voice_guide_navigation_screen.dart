import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/voice_guide_service.dart';
import '../services/smart_api_service.dart';

// Modelo para itens de transcrição
class TranscriptionItem {
  final String timestamp;
  final String originalText;
  final String language;
  final String? translatedText;

  TranscriptionItem({
    required this.timestamp,
    required this.originalText,
    required this.language,
    this.translatedText,
  });

  factory TranscriptionItem.fromJson(Map<String, dynamic> json) => TranscriptionItem(
    timestamp: json['timestamp']?.toString() ?? '',
    originalText: json['original_text']?.toString() ?? '',
    language: json['language']?.toString() ?? 'pt-BR',
    translatedText: json['translated_text']?.toString(),
  );
}

class VoiceGuideNavigationScreen extends StatefulWidget {
  const VoiceGuideNavigationScreen({super.key});

  @override
  State<VoiceGuideNavigationScreen> createState() => _VoiceGuideNavigationScreenState();
}

class _VoiceGuideNavigationScreenState extends State<VoiceGuideNavigationScreen>
    with TickerProviderStateMixin {
  final VoiceGuideService _voiceGuideService = VoiceGuideService();
  final SmartApiService _smartApiService = SmartApiService();
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _commandController = TextEditingController();
  final TextEditingController _translationController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  // Controladores de animação
  late AnimationController _pulseController;
  late AnimationController _emergencyController;
  late Animation<double> _pulseAnimation;
  late Animation<Color?> _emergencyAnimation;

  // Estado do sistema
  bool _isLoading = false;
  bool _isEmergencyMode = false;
  bool _isSpeaking = false;
  bool _isTranscribing = false;
  String _currentLanguage = 'pt-BR';
  String _currentMode = 'navigation'; // navigation, accessibility, emergency
  String _visualDescription = '';
  
  Map<String, String> _supportedLanguages = {
    'pt-BR': 'Português (Brasil)',
    'en-US': 'English (US)',
    'pt-GW': 'Crioulo (Guiné-Bissau)',
    'fr-FR': 'Français',
    'es-ES': 'Español'
  };

  // Dados atuais
  EnvironmentAnalysis? _currentAnalysis;
  NavigationInstructions? _currentInstructions;
  String _lastCommand = '';
  File? _selectedImage;
  List<TranscriptionItem> _transcriptions = [];

  // Comandos de voz para navegação sem botões
  final Map<String, String> _voiceCommands = {
    'analisar ambiente': 'Analisa o ambiente atual usando a câmera',
    'navegar para': 'Inicia navegação para um destino',
    'emergência': 'Ativa o modo de emergência',
    'descrever ambiente': 'Descreve visualmente o ambiente',
    'traduzir texto': 'Traduz o texto falado',
    'modo navegação': 'Muda para o modo de navegação',
    'modo acessibilidade': 'Muda para o modo de acessibilidade',
    'repetir instruções': 'Repete as últimas instruções',
    'ajuda': 'Lista todos os comandos disponíveis',
    'parar fala': 'Para a síntese de voz atual'
  };

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeTts();
    _checkServiceHealth();
    _announceWelcome();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _emergencyController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _emergencyAnimation = ColorTween(
      begin: Colors.red,
      end: Colors.red[900],
    ).animate(CurvedAnimation(
      parent: _emergencyController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage(_currentLanguage);
    await _flutterTts.setSpeechRate(0.6);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    _flutterTts.setStartHandler(() {
      setState(() {
        _isSpeaking = true;
      });
    });
    
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isSpeaking = false;
      });
    });
  }

  Future<void> _announceWelcome() async {
    await Future.delayed(const Duration(milliseconds: 500));
    await _speak('Bu Fala VoiceGuide ativado. Diga "ajuda" para ouvir todos os comandos disponíveis. Você está no modo navegação.');
  }

  Future<void> _checkServiceHealth() async {
    final isAvailable = await _voiceGuideService.isServiceAvailable();
    if (!isAvailable) {
      await _speak('Atenção: Serviço VoiceGuide não disponível. Funcionando em modo offline.');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _emergencyController.dispose();
    _destinationController.dispose();
    _commandController.dispose();
    _translationController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  // ==========================================
  // PROCESSAMENTO DE COMANDOS DE VOZ
  // ==========================================

  Future<void> _processVoiceCommand(String command) async {
    final lowerCommand = command.toLowerCase().trim();
    
    setState(() {
      _lastCommand = command;
      _isLoading = true;
    });

    try {
      if (lowerCommand.contains('ajuda')) {
        await _announceHelp();
      } else if (lowerCommand.contains('analisar ambiente')) {
        await _analyzeEnvironment();
      } else if (lowerCommand.contains('navegar para')) {
        final destination = lowerCommand.replaceAll('navegar para', '').trim();
        if (destination.isNotEmpty) {
          _destinationController.text = destination;
          await _generateNavigation();
        } else {
          await _speak('Por favor, diga o destino após "navegar para"');
        }
      } else if (lowerCommand.contains('emergência')) {
        await _activateEmergency();
      } else if (lowerCommand.contains('descrever ambiente')) {
        await _describeEnvironment();
      } else if (lowerCommand.contains('traduzir texto')) {
        await _speak('Diga o texto que deseja traduzir após este aviso.');
        // Aqui seria implementada a captura de áudio para tradução
      } else if (lowerCommand.contains('modo navegação')) {
        _switchToNavigationMode();
      } else if (lowerCommand.contains('modo acessibilidade')) {
        _switchToAccessibilityMode();
      } else if (lowerCommand.contains('repetir instruções')) {
        await _repeatLastInstructions();
      } else if (lowerCommand.contains('parar fala')) {
        await _flutterTts.stop();
      } else {
        // Processar comando genérico
        await _processGenericCommand(command);
      }
    } catch (e) {
      await _speak('Erro ao processar comando: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _announceHelp() async {
    String helpText = 'Comandos disponíveis: ';
    _voiceCommands.forEach((command, description) {
      helpText += '$command, ';
    });
    helpText += 'Para navegar, diga "navegar para" seguido do destino. Para emergência, diga "emergência".';
    await _speak(helpText);
  }

  void _switchToNavigationMode() {
    setState(() {
      _currentMode = 'navigation';
    });
    _speak('Modo navegação ativado. Diga "analisar ambiente" ou "navegar para" seguido do destino.');
  }

  void _switchToAccessibilityMode() {
    setState(() {
      _currentMode = 'accessibility';
    });
    _speak('Modo acessibilidade ativado. Diga "descrever ambiente" para descrição visual ou "traduzir texto" para tradução.');
  }

  Future<void> _repeatLastInstructions() async {
    if (_currentInstructions != null) {
      await _speak(_currentInstructions!.instructions);
    } else {
      await _speak('Nenhuma instrução de navegação disponível. Diga "navegar para" seguido do destino.');
    }
  }

  // ==========================================
  // FUNCIONALIDADES DE NAVEGAÇÃO
  // ==========================================

  Future<void> _analyzeEnvironment() async {
    await _speak('Analisando ambiente. Posicione a câmera para o local que deseja analisar.');
    
    // Capturar imagem automaticamente
    await _pickImage();
    
    if (_selectedImage == null) {
      await _speak('Não foi possível capturar imagem. Tente novamente.');
      return;
    }

    try {
      final bytes = await _selectedImage!.readAsBytes();
      final imageBase64 = VoiceGuideService.imageToBase64(bytes);

      final analysis = await _voiceGuideService.analyzeEnvironment(
        imageBase64: imageBase64,
        context: 'Análise do ambiente atual para navegação assistiva',
      );

      if (analysis != null) {
        setState(() {
          _currentAnalysis = analysis;
        });

        await _speak('Ambiente analisado. ${analysis.analysis}');

        if (analysis.emergencyDetected) {
          await _speak('ATENÇÃO: Perigo detectado no ambiente!');
          _showEmergencyAlert();
        }
      } else {
        await _speak('Erro ao analisar ambiente. Tente novamente.');
      }
    } catch (e) {
      await _speak('Erro na análise: $e');
    }
  }

  Future<void> _generateNavigation() async {
    if (_destinationController.text.trim().isEmpty) {
      await _speak('Destino não especificado. Diga "navegar para" seguido do destino.');
      return;
    }

    await _speak('Gerando instruções de navegação para ${_destinationController.text}');

    try {
      final instructions = await _voiceGuideService.generateNavigationInstructions(
        destination: _destinationController.text.trim(),
        currentAnalysis: _currentAnalysis?.analysis ?? '',
      );

      if (instructions != null) {
        setState(() {
          _currentInstructions = instructions;
        });

        await _speak('Instruções de navegação: ${instructions.instructions}');
        
        if (instructions.safetyAlerts.isNotEmpty) {
          await _speak('Alertas de segurança: ${instructions.safetyAlerts.join(", ")}');
        }
      } else {
        await _speak('Erro ao gerar instruções de navegação. Tente novamente.');
      }
    } catch (e) {
      await _speak('Erro na navegação: $e');
    }
  }

  // ==========================================
  // FUNCIONALIDADES DE ACESSIBILIDADE
  // ==========================================

  Future<void> _describeEnvironment() async {
    await _speak('Capturando imagem para descrição visual do ambiente.');
    
    await _pickImage();
    
    if (_selectedImage == null) {
      await _speak('Não foi possível capturar imagem. Tente novamente.');
      return;
    }

    try {
      final bytes = await _selectedImage!.readAsBytes();
      final imageBase64 = VoiceGuideService.imageToBase64(bytes);

      final response = await _smartApiService.describeImage(
        imageBase64,
        'Descreva detalhadamente este ambiente para uma pessoa com deficiência visual, incluindo objetos, pessoas, obstáculos e características importantes.',
      );

      if (response['success'] == true) {
        final description = response['description'] ?? 'Descrição não disponível';
        setState(() {
          _visualDescription = description;
        });
        
        await _speak('Descrição do ambiente: $description');
      } else {
        await _speak('Erro ao descrever ambiente. Tente novamente.');
      }
    } catch (e) {
      await _speak('Erro na descrição visual: $e');
    }
  }

  Future<void> _translateText(String text) async {
    if (text.trim().isEmpty) {
      await _speak('Texto vazio para tradução.');
      return;
    }

    try {
      final response = await _smartApiService.translateText(
        text,
        _currentLanguage,
        'pt-BR', // Traduzir sempre para português
      );

      if (response['success'] == true) {
        final translatedText = response['translated_text'] ?? 'Tradução não disponível';
        await _speak('Texto original: $text. Tradução: $translatedText');
        
        // Adicionar à lista de transcrições
        final transcription = TranscriptionItem(
          timestamp: DateTime.now().toString().substring(11, 19),
          originalText: text,
          language: _currentLanguage,
          translatedText: translatedText,
        );
        
        setState(() {
          _transcriptions.insert(0, transcription);
        });
      } else {
        await _speak('Erro ao traduzir texto. Tente novamente.');
      }
    } catch (e) {
      await _speak('Erro na tradução: $e');
    }
  }

  // ==========================================
  // FUNCIONALIDADES DE EMERGÊNCIA
  // ==========================================

  Future<void> _activateEmergency() async {
    setState(() {
      _isEmergencyMode = true;
      _currentMode = 'emergency';
    });

    _emergencyController.repeat(reverse: true);
    HapticFeedback.vibrate();
    
    await _speak('MODO EMERGÊNCIA ATIVADO! Analisando situação...');

    try {
      final emergency = await _voiceGuideService.activateEmergencyMode(
        context: 'Emergência ativada por comando de voz do usuário',
      );
      
      if (emergency != null) {
        await _speak('EMERGÊNCIA: ${emergency.emergencyInstructions}');
        
        // Anunciar contatos de emergência
        String contacts = 'Contatos de emergência: ';
        emergency.emergencyContacts.forEach((key, value) {
          contacts += '$key: $value. ';
        });
        await _speak(contacts);
        
      } else {
        await _speak('EMERGÊNCIA ATIVADA: Pare onde está e peça ajuda! Ligue 190 para polícia ou 192 para emergência médica!');
      }
    } catch (e) {
      await _speak('EMERGÊNCIA: Erro no sistema. Ligue imediatamente 190 ou 192!');
    }
  }

  Future<void> _deactivateEmergency() async {
    final success = await _voiceGuideService.deactivateEmergencyMode();
    
    setState(() {
      _isEmergencyMode = false;
      _currentMode = 'navigation';
    });
    
    _emergencyController.stop();
    
    if (success) {
      await _speak('Modo emergência desativado. Sistema voltou ao modo navegação normal.');
    }
  }

  // ==========================================
  // FUNCIONALIDADES AUXILIARES
  // ==========================================

  Future<void> _processGenericCommand(String command) async {
    try {
      final response = await _voiceGuideService.processVoiceCommand(command);
      
      if (response != null) {
        await _speak(response.response);
        
        if (response.type == 'navigation' && response.destination != null) {
          _destinationController.text = response.destination!;
          await _generateNavigation();
        }
      } else {
        await _speak('Comando não reconhecido. Diga "ajuda" para ouvir os comandos disponíveis.');
      }
    } catch (e) {
      await _speak('Erro ao processar comando: $e');
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      await _speak('Erro ao capturar imagem: $e');
    }
  }

  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  void _showEmergencyAlert() {
    HapticFeedback.vibrate();
    _emergencyController.repeat(reverse: true);
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ==========================================
  // INTERFACE DO USUÁRIO
  // ==========================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEmergencyMode 
              ? '🚨 EMERGÊNCIA ATIVA' 
              : 'Bu Fala VoiceGuide - ${_currentMode == 'navigation' ? 'Navegação' : 'Acessibilidade'}',
        ),
        backgroundColor: _isEmergencyMode ? Colors.red : Colors.blue,
        actions: [
          if (_isSpeaking)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _isEmergencyMode 
                ? [Colors.red[100]!, Colors.red[50]!]
                : [Colors.blue[50]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Indicador de status
                _buildStatusIndicator(),
                const SizedBox(height: 20),
                
                // Área de comando de voz
                _buildVoiceCommandArea(),
                const SizedBox(height: 20),
                
                // Conteúdo baseado no modo atual
                Expanded(
                  child: _buildModeContent(),
                ),
                
                // Instruções de uso
                _buildUsageInstructions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _isEmergencyMode ? Colors.red[100] : Colors.blue[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isEmergencyMode ? Colors.red : Colors.blue,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isLoading ? _pulseAnimation.value : 1.0,
                child: Icon(
                  _isEmergencyMode 
                      ? Icons.warning 
                      : _currentMode == 'navigation' 
                          ? Icons.navigation 
                          : Icons.accessibility,
                  color: _isEmergencyMode ? Colors.red : Colors.blue,
                  size: 32,
                ),
              );
            },
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEmergencyMode 
                      ? 'MODO EMERGÊNCIA ATIVO'
                      : 'Modo ${_currentMode == 'navigation' ? 'Navegação' : 'Acessibilidade'}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _isEmergencyMode ? Colors.red : Colors.blue,
                  ),
                ),
                Text(
                  _isSpeaking 
                      ? 'Falando...' 
                      : _isLoading 
                          ? 'Processando...' 
                          : 'Aguardando comando de voz',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceCommandArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.mic, color: Colors.blue),
              const SizedBox(width: 8),
              const Text(
                'Comando de Voz',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _commandController,
            decoration: const InputDecoration(
              hintText: 'Digite ou fale seu comando...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.keyboard_voice),
            ),
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                _processVoiceCommand(value);
                _commandController.clear();
              }
            },
          ),
          const SizedBox(height: 8),
          Text(
            'Último comando: $_lastCommand',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeContent() {
    if (_isEmergencyMode) {
      return _buildEmergencyContent();
    } else if (_currentMode == 'navigation') {
      return _buildNavigationContent();
    } else {
      return _buildAccessibilityContent();
    }
  }

  Widget _buildNavigationContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Campo de destino
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.place, color: Colors.green),
                    SizedBox(width: 8),
                    Text(
                      'Destino',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _destinationController,
                  decoration: const InputDecoration(
                    hintText: 'Para onde deseja ir?',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Análise do ambiente
           if (_currentAnalysis != null) ...[Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.visibility, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Análise do Ambiente',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_currentAnalysis!.analysis),
                ],
              ),
            ),
             const SizedBox(height: 16),
           ],
          
          // Instruções de navegação
           if (_currentInstructions != null) ...[Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.directions, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Instruções de Navegação',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_currentInstructions!.instructions),
                  if (_currentInstructions!.safetyAlerts.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Text(
                      'Alertas de Segurança:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                    ),
                    ...(_currentInstructions!.safetyAlerts.map(
                      (alert) => Padding(
                        padding: const EdgeInsets.only(left: 16, top: 4),
                        child: Text('• $alert'),
                      ),
                    )),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAccessibilityContent() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Descrição visual
          if (_visualDescription.isNotEmpty) ..[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.description, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'Descrição Visual',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(_visualDescription),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Transcrições e traduções
          if (_transcriptions.isNotEmpty) ..[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.purple[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.translate, color: Colors.purple),
                      SizedBox(width: 8),
                      Text(
                        'Traduções Recentes',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...(_transcriptions.take(3).map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Original: ${item.originalText}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          if (item.translatedText != null)
                            Text(
                              'Tradução: ${item.translatedText}',
                              style: TextStyle(color: Colors.purple[700]),
                            ),
                        ],
                      ),
                    ),
                  )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmergencyContent() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red[300]!, width: 2),
      ),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _emergencyAnimation,
            builder: (context, child) {
              return Icon(
                Icons.warning,
                size: 64,
                color: _emergencyAnimation.value,
              );
            },
          ),
          const SizedBox(height: 16),
          const Text(
            '🚨 MODO EMERGÊNCIA ATIVO',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Diga "desativar emergência" para voltar ao modo normal',
            style: TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          const Text(
            'Contatos de Emergência:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Polícia: 190'),
          const Text('Emergência Médica: 192'),
          const Text('Bombeiros: 193'),
        ],
      ),
    );
  }

  Widget _buildUsageInstructions() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎤 Comandos de Voz Principais:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '• "Ajuda" - Lista todos os comandos\n'
            '• "Analisar ambiente" - Analisa o local\n'
            '• "Navegar para [destino]" - Inicia navegação\n'
            '• "Descrever ambiente" - Descrição visual\n'
            '• "Emergência" - Ativa modo de emergência',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}