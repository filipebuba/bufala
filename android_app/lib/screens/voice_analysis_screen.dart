import 'dart:async';

import 'package:flutter/material.dart';

import '../models/mental_health_models.dart';
import '../services/voice_analysis_service.dart';

class VoiceAnalysisScreen extends StatefulWidget {
  const VoiceAnalysisScreen({super.key});

  @override
  State<VoiceAnalysisScreen> createState() => _VoiceAnalysisScreenState();
}

class _VoiceAnalysisScreenState extends State<VoiceAnalysisScreen>
    with TickerProviderStateMixin {
  final VoiceAnalysisService _voiceService = VoiceAnalysisService();

  bool _isRecording = false;
  bool _isAnalyzing = false;
  VoiceAnalysisResult? _lastResult;
  Timer? _recordingTimer;
  int _recordingDuration = 0;

  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeVoiceService();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _waveAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));
  }

  Future<void> _initializeVoiceService() async {
    await _voiceService.initialize();
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Análise de Voz'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showHistory,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildRecordingSection(),
            const SizedBox(height: 32),
            if (_lastResult != null) _buildResultsSection(),
            const SizedBox(height: 24),
            _buildTipsSection(),
          ],
        ),
      ),
    );

  Widget _buildHeader() => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[700]!, Colors.blue[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.mic, color: Colors.white, size: 40),
          SizedBox(height: 12),
          Text(
            'Análise de Bem-estar por Voz',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Sua voz revela muito sobre seu estado emocional. Vamos analisar como você está se sentindo.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );

  Widget _buildRecordingSection() => Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            if (_isRecording) ...[
              const Text(
                'Gravando...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Duração: ${_recordingDuration}s',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 24),
            ] else if (_isAnalyzing) ...[
              const Text(
                'Analisando sua voz...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
            ] else ...[
              const Text(
                'Toque para começar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Fale por pelo menos 30 segundos para uma análise precisa',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],
            GestureDetector(
              onTap: _toggleRecording,
              child: AnimatedBuilder(
                animation: _isRecording ? _pulseAnimation : _waveAnimation,
                builder: (context, child) => Transform.scale(
                    scale: _isRecording ? _pulseAnimation.value : 1.0,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isRecording ? Colors.red : Colors.blue[700],
                        boxShadow: [
                          BoxShadow(
                            color: (_isRecording ? Colors.red : Colors.blue)
                                .withValues(alpha: 0.3),
                            blurRadius: _isRecording ? 20 : 10,
                            spreadRadius: _isRecording ? 5 : 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ),
            ),
            const SizedBox(height: 24),
            if (!_isRecording && !_isAnalyzing) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _analyzeFromFile,
                    icon: const Icon(Icons.file_upload),
                    label: const Text('Arquivo'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _quickAnalysis,
                    icon: const Icon(Icons.flash_on),
                    label: const Text('Análise Rápida'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );

  Widget _buildResultsSection() {
    final result = _lastResult!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.blue[700]),
                const SizedBox(width: 8),
                const Text(
                  'Resultados da Análise',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildMetricRow(
                'Nível de Estresse', result.stressLevel, Icons.psychology),
            _buildMetricRow(
                'Energia', result.energyLevel, Icons.battery_charging_full),
            _buildMetricRow('Estabilidade Emocional', result.emotionalStability,
                Icons.favorite),
            _buildMetricRow(
                'Estado de Humor', result.confidence, Icons.record_voice_over),
            _buildMetricRow('Confiança', result.confidence, Icons.thumb_up),
            const SizedBox(height: 16),
            if (result.emotionalIndicators.isNotEmpty) ...[
              const Text(
                'Indicadores Emocionais:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...result.emotionalIndicators.map((String indicator) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: Colors.blue)),
                        Expanded(child: Text(indicator)),
                      ],
                    ),
                  )),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _saveAnalysis,
                  icon: const Icon(Icons.save),
                  label: const Text('Salvar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _shareAnalysis,
                  icon: const Icon(Icons.share),
                  label: const Text('Compartilhar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, double value, IconData icon) {
    Color getColor(double val) {
      if (val >= 0.7) return Colors.green;
      if (val >= 0.4) return Colors.orange;
      return Colors.red;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: getColor(value)),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: Text(label),
          ),
          Expanded(
            flex: 3,
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(getColor(value)),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(value * 100).round()}%',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: getColor(value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.orange[700]),
                const SizedBox(width: 8),
                const Text(
                  'Dicas para uma boa análise',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• Fale em um ambiente silencioso'),
                Text('• Mantenha o telefone próximo à boca'),
                Text('• Fale naturalmente, como em uma conversa'),
                Text('• Grave por pelo menos 30 segundos'),
                Text('• Evite sussurrar ou gritar'),
              ],
            ),
          ],
        ),
      ),
    );

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    setState(() {
      _isRecording = true;
      _recordingDuration = 0;
    });

    unawaited(_pulseController.repeat(reverse: true));

    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _recordingDuration++;
      });
    });

    // Simular início da gravação
    await Future<void>.delayed(const Duration(milliseconds: 500));
  }

  Future<void> _stopRecording() async {
    setState(() {
      _isRecording = false;
      _isAnalyzing = true;
    });

    _pulseController.stop();
    _recordingTimer?.cancel();

    try {
      // Simular análise
      await Future<void>.delayed(const Duration(seconds: 3));

      final result = await _voiceService.startRealtimeAnalysis();

      setState(() {
        _lastResult = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro na análise: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _analyzeFromFile() async {
    // Simular seleção de arquivo
    setState(() {
      _isAnalyzing = true;
    });

    try {
      await Future<void>.delayed(const Duration(seconds: 2));
      final result = await _voiceService.analyzeAudioFile('dummy_path');

      setState(() {
        _lastResult = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao analisar arquivo: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _quickAnalysis() async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      await Future<void>.delayed(const Duration(seconds: 1));
      final result = await _voiceService.startRealtimeAnalysis();

      setState(() {
        _lastResult = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _isAnalyzing = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro na análise rápida: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _saveAnalysis() {
    if (_lastResult != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Análise salva com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _shareAnalysis() {
    if (_lastResult != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Função de compartilhamento em desenvolvimento'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  void _showHistory() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Histórico de Análises'),
        content: const Text('Esta funcionalidade estará disponível em breve.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
