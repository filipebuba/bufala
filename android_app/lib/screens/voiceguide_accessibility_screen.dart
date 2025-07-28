import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import '../services/integrated_api_service.dart';
import '../services/voice_guide_service.dart' as voice_guide_service;

class VoiceGuideAccessibilityScreen extends StatefulWidget {
  const VoiceGuideAccessibilityScreen({super.key});

  @override
  State<VoiceGuideAccessibilityScreen> createState() =>
      _VoiceGuideAccessibilityScreenState();
}

// Importar modelos do VoiceGuideService
// Os modelos EnvironmentAnalysis e NavigationInstructions já estão definidos no VoiceGuideService

class _VoiceGuideAccessibilityScreenState
    extends State<VoiceGuideAccessibilityScreen> with TickerProviderStateMixin {
  final IntegratedApiService _apiService = IntegratedApiService();
  final voice_guide_service.VoiceGuideService _voiceGuideService = voice_guide_service.VoiceGuideService();
  final FlutterTts _flutterTts = FlutterTts();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _commandController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final ImagePicker _imagePicker = ImagePicker();

  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  // Estado do sistema
  bool _isTranscribing = false;
  bool _isLoading = false;
  bool _isEmergencyMode = false;
  bool _isSpeaking = false;
  String _currentMode = 'accessibility'; // 'accessibility', 'navigation', 'emergency'
  String _currentTab = 'accessibility'; // 'accessibility' ou 'navigation'
  String _sourceLanguage = 'pt-BR';
  String _targetLanguage = 'crioulo-gb';

  // Dados da transcrição e navegação
  final List<TranscriptionItem> _transcriptions = [];
  String _lastTranslation = '';
  String _visualDescription = '';
  voice_guide_service.EnvironmentAnalysis? _currentAnalysis;
  voice_guide_service.NavigationInstructions? _currentInstructions;
  String _lastCommand = '';
  File? _selectedImage;
  
  // Comandos de voz para navegação
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

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );

    _pulseController.repeat(reverse: true);
    _initializeTts();
    _checkServiceHealth();
    _announceWelcome();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _textController.dispose();
    _destinationController.dispose();
    _commandController.dispose();
    _scrollController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  // ==========================================
  // INICIALIZAÇÃO E CONFIGURAÇÃO
  // ==========================================

  Future<void> _initializeTts() async {
    await _flutterTts.setLanguage(_sourceLanguage);
    await _flutterTts.setSpeechRate(0.6);
    await _flutterTts.setVolume(1);
    await _flutterTts.setPitch(1);

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
    await _speak(
        'VoiceGuide AI ativado. Você está no modo acessibilidade. Use as abas para navegar entre acessibilidade e navegação.');
  }

  Future<void> _checkServiceHealth() async {
    final isAvailable = await _voiceGuideService.isServiceAvailable();
    if (!isAvailable) {
      await _speak(
          'Atenção: Serviço VoiceGuide não disponível. Funcionando em modo offline.');
    }
  }

  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  Future<void> _startTranscription() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.getAccessibilitySupport(
        'Iniciar transcrição de voz',
        accessibilityType: 'transcription',
        userNeeds: 'start_transcription',
      );

      if (response['success'] == true) {
        setState(() {
          _isTranscribing = true;
        });

        _showSnackBar(
            'Transcrição iniciada - falando será transcrito em tempo real',
            isError: false);

        // Simular polling de transcrições (em produção, usar WebSocket)
        _startTranscriptionPolling();
      } else {
        _showSnackBar('Erro ao iniciar transcrição: ${response['error'] ?? 'Erro desconhecido'}',
            isError: true);
      }
    } catch (e) {
      _showSnackBar('Erro de conexão: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _stopTranscription() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.getAccessibilitySupport(
        'Parar transcrição de voz',
        accessibilityType: 'transcription',
        userNeeds: 'stop_transcription',
      );

      if (response['success'] == true) {
        setState(() {
          _isTranscribing = false;
        });

        _showSnackBar('Transcrição parada', isError: false);
      }
    } catch (e) {
      _showSnackBar('Erro ao parar transcrição: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _startTranscriptionPolling() {
    if (!_isTranscribing) return;

    // Polling a cada 2 segundos para buscar novas transcrições
    Future.delayed(const Duration(seconds: 2), () async {
      if (_isTranscribing) {
        await _fetchRecentTranscriptions();
        _startTranscriptionPolling();
      }
    });
  }

  Future<void> _fetchRecentTranscriptions() async {
    try {
      final response = await _apiService.getAccessibilitySupport(
        'Buscar transcrições recentes',
        accessibilityType: 'transcription',
        userNeeds: 'recent_transcriptions',
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final transcriptions = data['transcriptions'] as List<dynamic>? ?? [];

        for (final item in transcriptions) {
          final transcription =
              TranscriptionItem.fromJson(item as Map<String, dynamic>);

          // Verificar se já existe
          final exists = _transcriptions.any((t) =>
              t.timestamp == transcription.timestamp &&
              t.originalText == transcription.originalText);

          if (!exists) {
            setState(() {
              _transcriptions.insert(0, transcription);

              // Manter apenas últimas 20
              if (_transcriptions.length > 20) {
                _transcriptions.removeLast();
              }
            });

            _fadeController.forward();
          }
        }
      }
    } catch (e) {
      print('Erro ao buscar transcrições: $e');
    }
  }

  Future<void> _translateText() async {
    if (_textController.text.trim().isEmpty) {
      _showSnackBar('Digite um texto para traduzir', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.translateText(
        _textController.text.trim(),
        fromLanguage: _sourceLanguage,
        toLanguage: _targetLanguage,
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final translatedText = data['translated_text'] ?? data['response'] ?? data['answer'] ?? data.toString();

        setState(() {
          _lastTranslation = translatedText;
        });

        _fadeController.forward();
        _showSnackBar('Texto traduzido com sucesso', isError: false);
      } else {
        _showSnackBar('Erro na tradução: ${response['error'] ?? 'Erro desconhecido'}', isError: true);
      }
    } catch (e) {
      _showSnackBar('Erro de conexão: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _describeEnvironment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiService.getAccessibilitySupport(
        'Descrever ambiente visual',
        accessibilityType: 'visual',
        userNeeds: 'descrição do ambiente',
      );

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'] as Map<String, dynamic>;
        final description = data['response'] ?? data['answer'] ?? data.toString();

        setState(() {
          _visualDescription = description;
        });

        _fadeController.forward();
        _showSnackBar('Ambiente descrito - feedback por voz ativo',
            isError: false);
      } else {
        _showSnackBar('Erro na descrição visual: ${response['error'] ?? 'Erro desconhecido'}',
            isError: true);
      }
    } catch (e) {
      _showSnackBar('Erro de conexão: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
                child: Text(message, style: const TextStyle(fontSize: 16))),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 5 : 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _copyText(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar('Texto copiado!', isError: false);
  }

  // ==========================================
  // FUNCIONALIDADES DE NAVEGAÇÃO
  // ==========================================

  Future<void> _analyzeEnvironment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _speak('Analisando ambiente... Por favor aguarde.');
      
      final response = await _voiceGuideService.analyzeEnvironment(
        context: 'Análise de ambiente para navegação segura',
      );

      if (response != null) {
        setState(() {
          _currentAnalysis = response;
        });

        await _speak('Análise concluída: ${response.analysis}');
        
        if (response.navigationSuggestions.isNotEmpty) {
          await _speak('Sugestões de navegação: ${response.navigationSuggestions.join(', ')}');
        }
        
        _showSnackBar('Ambiente analisado com sucesso', isError: false);
      } else {
        await _speak('Erro na análise do ambiente. Tente novamente.');
        _showSnackBar('Erro na análise do ambiente', isError: true);
      }
    } catch (e) {
      await _speak('Erro de conexão na análise: $e');
      _showSnackBar('Erro de conexão: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generateNavigation() async {
    if (_destinationController.text.trim().isEmpty) {
      await _speak('Por favor, digite um destino para navegação.');
      _showSnackBar('Digite um destino', isError: true);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _speak('Gerando instruções de navegação para ${_destinationController.text}...');
      
      final response = await _voiceGuideService.generateNavigationInstructions(
        destination: _destinationController.text.trim(),
        currentAnalysis: _currentAnalysis?.analysis ?? '',
      );

      if (response != null) {
        setState(() {
          _currentInstructions = response;
        });

        await _speak('Navegação gerada para ${response.destination}. Tempo estimado: ${response.estimatedTime}.');
        
        for (int i = 0; i < response.steps.length && i < 3; i++) {
          await _speak('Passo ${i + 1}: ${response.steps[i]}');
        }
        
        _showSnackBar('Navegação gerada com sucesso', isError: false);
      } else {
        await _speak('Erro ao gerar navegação. Tente novamente.');
        _showSnackBar('Erro na geração de navegação', isError: true);
      }
    } catch (e) {
      await _speak('Erro de conexão na navegação: $e');
      _showSnackBar('Erro de conexão: $e', isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _activateEmergency() async {
    setState(() {
      _isEmergencyMode = true;
      _currentMode = 'emergency';
    });

    HapticFeedback.vibrate();
    await _speak('MODO EMERGÊNCIA ATIVADO! Analisando situação...');

    try {
      final emergency = await _voiceGuideService.activateEmergencyMode(
        context: 'Emergência ativada por comando de voz do usuário',
      );

      if (emergency != null) {
        await _speak('EMERGÊNCIA: ${emergency.emergencyInstructions}');

        var contacts = 'Contatos de emergência: ';
        emergency.emergencyContacts.forEach((key, value) {
          contacts += '$key: $value. ';
        });
        await _speak(contacts);
      } else {
        await _speak(
            'EMERGÊNCIA ATIVADA: Pare onde está e peça ajuda! Ligue 190 para polícia ou 192 para emergência médica!');
      }
    } catch (e) {
      await _speak(
          'EMERGÊNCIA: Erro no sistema. Ligue imediatamente 190 ou 192!');
    }
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
        await _speak('Imagem capturada. Analisando...');
        await _analyzeEnvironment();
      }
    } catch (e) {
      await _speak('Erro ao capturar imagem: $e');
    }
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 2,
    child: Scaffold(
      appBar: AppBar(
        title: Text(
          _isEmergencyMode
              ? '🚨 EMERGÊNCIA ATIVA'
              : '🌟 VoiceGuide AI - Assistente Completo',
        ),
        backgroundColor: _isEmergencyMode ? Colors.red : Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (_isSpeaking)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            ),
          IconButton(
            icon: Icon(_isEmergencyMode ? Icons.emergency : Icons.help),
            onPressed: () async {
              if (_isEmergencyMode) {
                setState(() {
                  _isEmergencyMode = false;
                  _currentMode = 'accessibility';
                });
                await _speak('Modo emergência desativado.');
              } else {
                await _speak('Comandos disponíveis: analisar ambiente, navegar para destino, emergência, descrever ambiente, traduzir texto.');
              }
            },
            tooltip: _isEmergencyMode ? 'Desativar emergência' : 'Ajuda',
          ),
        ],
        bottom: _isEmergencyMode ? null : TabBar(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          onTap: (index) async {
            setState(() {
              _currentTab = index == 0 ? 'accessibility' : 'navigation';
            });
            await _speak(index == 0 ? 'Modo acessibilidade ativado' : 'Modo navegação ativado');
          },
          tabs: const [
            Tab(
              icon: Icon(Icons.accessibility),
              text: 'Acessibilidade',
            ),
            Tab(
              icon: Icon(Icons.navigation),
              text: 'Navegação',
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: _isEmergencyMode
                ? [Colors.red[100]!, Colors.red[50]!]
                : [Colors.deepPurple[50]!, Colors.white],
          ),
        ),
        child: _isEmergencyMode
            ? _buildEmergencyInterface()
            : TabBarView(
                children: [
                  // Aba de Acessibilidade
                  _buildAccessibilityInterface(),
                  
                  // Aba de Navegação
                  _buildNavigationInterface(),
                ],
              ),
      ),
    ),
  );

  Widget _buildAccessibilityInterface() => Column(
      children: [
        // Painel de controle
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.deepPurple[50],
            border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
          ),
          child: Column(
            children: [
              const Row(
                children: [
                  Icon(Icons.record_voice_over, color: Colors.deepPurple),
                  SizedBox(width: 8),
                  Text(
                    'Transcrição e Tradução Simultânea',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Controles de transcrição
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading
                          ? null
                          : (_isTranscribing
                              ? _stopTranscription
                              : _startTranscription),
                      icon: _isTranscribing
                          ? ScaleTransition(
                              scale: _pulseAnimation,
                              child:
                                  const Icon(Icons.stop, color: Colors.white),
                            )
                          : const Icon(Icons.mic),
                      label: Text(_isTranscribing
                          ? 'PARAR TRANSCRIÇÃO'
                          : 'INICIAR TRANSCRIÇÃO'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isTranscribing ? Colors.red : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Seletor de idiomas
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _sourceLanguage,
                      decoration: const InputDecoration(
                        labelText: 'Idioma de origem',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'pt-BR', child: Text('🇧🇷 Português')),
                        DropdownMenuItem(
                            value: 'en-US', child: Text('🇺🇸 Inglês')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _sourceLanguage = value!;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.arrow_forward),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _targetLanguage,
                      decoration: const InputDecoration(
                        labelText: 'Traduzir para',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'crioulo-gb', child: Text('🇬🇼 Crioulo')),
                        DropdownMenuItem(
                            value: 'pt-BR', child: Text('🇧🇷 Português')),
                        DropdownMenuItem(
                            value: 'en-US', child: Text('🇺🇸 Inglês')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _targetLanguage = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Área de tradução manual
        Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tradução Manual',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: const InputDecoration(
                        hintText: 'Digite texto para traduzir...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _translateText,
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.translate),
                  ),
                ],
              ),
              if (_lastTranslation.isNotEmpty) ...[
                const SizedBox(height: 12),
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.translate,
                                color: Colors.blue, size: 16),
                            const SizedBox(width: 4),
                            const Text('Tradução:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.copy, size: 16),
                              onPressed: () => _copyText(_lastTranslation),
                              tooltip: 'Copiar tradução',
                            ),
                          ],
                        ),
                        Text(
                          _lastTranslation,
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Lista de transcrições
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Transcrições em Tempo Real',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const Spacer(),
                    if (_transcriptions.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(_transcriptions.clear);
                        },
                        child: const Text('Limpar'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _transcriptions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.mic_off,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _isTranscribing
                                    ? 'Aguardando fala para transcrever...'
                                    : 'Inicie a transcrição para ver as conversas',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: _transcriptions.length,
                          itemBuilder: (context, index) {
                            final item = _transcriptions[index];
                            return _buildTranscriptionItem(item);
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

  Widget _buildNavigationInterface() => Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho de navegação
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: const Row(
              children: [
                Icon(Icons.navigation, color: Colors.blue, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Navegação Assistida por Voz',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Campo de destino
          TextField(
            controller: _destinationController,
            decoration: const InputDecoration(
              labelText: 'Destino',
              hintText: 'Digite o local para onde deseja ir...',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.place),
            ),
          ),

          const SizedBox(height: 16),

          // Botões de ação
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _analyzeEnvironment,
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.camera_alt),
                  label: const Text('ANALISAR AMBIENTE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isLoading ? null : _generateNavigation,
                  icon: const Icon(Icons.navigation),
                  label: const Text('NAVEGAR'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Botão de emergência
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _activateEmergency,
              icon: const Icon(Icons.emergency),
              label: const Text('EMERGÊNCIA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Análise do ambiente
          if (_currentAnalysis != null) ...[
            const Text(
              'Análise do Ambiente:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _currentAnalysis!.analysis,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (_currentAnalysis!.navigationSuggestions.isNotEmpty) ...[
                     const SizedBox(height: 8),
                     const Text('Sugestões de navegação:', style: TextStyle(fontWeight: FontWeight.bold)),
                     ...(_currentAnalysis!.navigationSuggestions.map((s) => Text('• $s'))),
                   ],
                ],
              ),
            ),
          ],

          // Instruções de navegação
          if (_currentInstructions != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Instruções de Navegação:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Destino: ${_currentInstructions!.destination}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text('Tempo estimado: ${_currentInstructions!.estimatedTime}'),
                  const SizedBox(height: 8),
                  const Text('Passos:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...(_currentInstructions!.steps.asMap().entries.map(
                    (entry) => Text('${entry.key + 1}. ${entry.value}'),
                  )),
                ],
              ),
            ),
          ],
        ],
      ),
    );

  Widget _buildEmergencyInterface() => Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.emergency,
            size: 100,
            color: Colors.red,
          ),
          const SizedBox(height: 24),
          const Text(
            'MODO EMERGÊNCIA ATIVO',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'O sistema está em modo de emergência.\nSiga as instruções de voz.',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                setState(() {
                  _isEmergencyMode = false;
                  _currentMode = 'accessibility';
                });
                await _speak('Modo emergência desativado.');
              },
              icon: const Icon(Icons.check),
              label: const Text('DESATIVAR EMERGÊNCIA'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red[200]!),
            ),
            child: const Column(
              children: [
                Text(
                  'Contatos de Emergência:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 8),
                Text('🚨 Polícia: 190'),
                Text('🚑 SAMU: 192'),
                Text('🚒 Bombeiros: 193'),
              ],
            ),
          ),
        ],
      ),
    );

  Widget _buildVisualImpairedInterface() => Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange[200]!),
            ),
            child: const Row(
              children: [
                Icon(Icons.visibility, color: Colors.orange, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Assistente Visual com Feedback Sonoro',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Botão de descrição do ambiente
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _describeEnvironment,
              icon: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.camera_alt),
              label: const Text('DESCREVER AMBIENTE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Descrição visual
          if (_visualDescription.isNotEmpty) ...[
            const Text(
              'Descrição do Ambiente:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.description, color: Colors.orange),
                        const SizedBox(width: 8),
                        const Text(
                          'Ambiente Detectado',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () => _copyText(_visualDescription),
                          tooltip: 'Copiar descrição',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _visualDescription,
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Toque em "Descrever Ambiente" para obter\ndescr ição visual detalhada com feedback sonoro',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],

          const Spacer(),

          // Informações de acessibilidade
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.accessibility, color: Colors.blue),
                    SizedBox(width: 8),
                    Text(
                      'Recursos de Acessibilidade',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text('• Descrição visual automática por câmera'),
                Text('• Feedback sonoro em tempo real'),
                Text('• Navegação por comando de voz'),
                Text('• Funcionamento 100% offline'),
              ],
            ),
          ),
        ],
      ),
    );

  Widget _buildTranscriptionItem(TranscriptionItem item) => Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
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
              const Icon(Icons.record_voice_over, color: Colors.deepPurple, size: 16),
              const SizedBox(width: 4),
              Text(
                item.timestamp,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.copy, size: 16),
                onPressed: () => _copyText(
                    '${item.originalText}\n${item.translatedText ?? ''}'),
                tooltip: 'Copiar textos',
              ),
            ],
          ),

          // Texto original
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.originalText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),

          // Tradução
          if (item.translatedText != null &&
              item.translatedText!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.translate, color: Colors.blue, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Tradução:',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.translatedText!,
                    style: const TextStyle(fontSize: 15),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
}

// Classe para itens de transcrição
class TranscriptionItem {

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
  final String timestamp;
  final String originalText;
  final String language;
  final String? translatedText;
}
