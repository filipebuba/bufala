import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/integrated_api_service.dart';

class VoiceGuideAccessibilityScreen extends StatefulWidget {
  const VoiceGuideAccessibilityScreen({super.key});

  @override
  State<VoiceGuideAccessibilityScreen> createState() =>
      _VoiceGuideAccessibilityScreenState();
}

class _VoiceGuideAccessibilityScreenState
    extends State<VoiceGuideAccessibilityScreen> with TickerProviderStateMixin {
  final IntegratedApiService _apiService = IntegratedApiService();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  // Estado do sistema
  bool _isTranscribing = false;
  bool _isLoading = false;
  String _currentMode = 'deaf_mute'; // 'deaf_mute' ou 'visual_impaired'
  String _sourceLanguage = 'pt-BR';
  String _targetLanguage = 'crioulo-gb';

  // Dados da transcrição
  final List<TranscriptionItem> _transcriptions = [];
  String _lastTranslation = '';
  String _visualDescription = '';

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
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('🌟 VoiceGuide AI'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
                _currentMode == 'deaf_mute' ? Icons.hearing : Icons.visibility),
            onPressed: () {
              setState(() {
                _currentMode = _currentMode == 'deaf_mute'
                    ? 'visual_impaired'
                    : 'deaf_mute';
              });
            },
            tooltip: 'Alternar modo de acessibilidade',
          ),
        ],
      ),
      body: _currentMode == 'deaf_mute'
          ? _buildDeafMuteInterface()
          : _buildVisualImpairedInterface(),
    );

  Widget _buildDeafMuteInterface() => Column(
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
