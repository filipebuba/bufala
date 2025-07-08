import 'dart:async';

import 'package:flutter/material.dart';

import '../models/mental_health_models.dart';
import '../services/wellness_coaching_service.dart';

class CoachingSessionScreen extends StatefulWidget {
  const CoachingSessionScreen({
    required this.sessionType,
    super.key,
  });
  final String sessionType;

  @override
  State<CoachingSessionScreen> createState() => _CoachingSessionScreenState();
}

class _CoachingSessionScreenState extends State<CoachingSessionScreen>
    with TickerProviderStateMixin {
  final WellnessCoachingService _wellnessService = WellnessCoachingService();

  CoachingSession? _currentSession;
  bool _isSessionActive = false;
  Timer? _sessionTimer;
  int _sessionDuration = 0;

  // Animações
  late AnimationController _breathingController;
  late AnimationController _progressController;
  late Animation<double> _breathingAnimation;
  late Animation<double> _progressAnimation;

  // Estados específicos por tipo
  int _breathingPhase = 0; // 0: inspirar, 1: segurar, 2: expirar, 3: segurar
  final List<String> _breathingInstructions = [
    'Inspire',
    'Segure',
    'Expire',
    'Segure'
  ];
  final List<int> _breathingDurations = [4, 2, 6, 2]; // segundos

  final String _meditationPhase = 'preparação';
  List<String> _meditationInstructions = [];

  double _currentMoodRating = 3;
  String _stressDescription = '';

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupSessionContent();
  }

  void _initializeAnimations() {
    _breathingController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _progressController = AnimationController(
      duration: const Duration(minutes: 5),
      vsync: this,
    );

    _breathingAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _breathingController,
      curve: Curves.easeInOut,
    ));

    _progressAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.linear,
    ));
  }

  void _setupSessionContent() {
    switch (widget.sessionType) {
      case 'meditation':
        _meditationInstructions = [
          'Encontre uma posição confortável',
          'Feche os olhos suavemente',
          'Respire naturalmente',
          'Observe seus pensamentos sem julgamento',
          'Traga a atenção de volta à respiração',
        ];
        break;
    }
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _breathingController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(_getSessionTitle()),
          backgroundColor: _getSessionColor(),
          foregroundColor: Colors.white,
          actions: [
            if (_isSessionActive)
              IconButton(
                icon: const Icon(Icons.pause),
                onPressed: _pauseSession,
              ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildSessionHeader(),
              const SizedBox(height: 24),
              if (_isSessionActive) ...[
                _buildActiveSession(),
              ] else ...[
                _buildSessionStart(),
              ],
              const SizedBox(height: 24),
              _buildSessionInfo(),
            ],
          ),
        ),
      );

  String _getSessionTitle() {
    switch (widget.sessionType) {
      case 'breathing':
        return 'Exercício de Respiração';
      case 'meditation':
        return 'Sessão de Meditação';
      case 'voice_check':
        return 'Check-in de Voz';
      case 'mood_tracking':
        return 'Rastreamento de Humor';
      case 'stress_relief':
        return 'Alívio de Estresse';
      default:
        return 'Sessão de Coaching';
    }
  }

  Color _getSessionColor() {
    switch (widget.sessionType) {
      case 'breathing':
        return Colors.blue[700]!;
      case 'meditation':
        return Colors.purple[700]!;
      case 'voice_check':
        return Colors.green[700]!;
      case 'mood_tracking':
        return Colors.orange[700]!;
      case 'stress_relief':
        return Colors.red[700]!;
      default:
        return Colors.grey[700]!;
    }
  }

  Widget _buildSessionHeader() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getSessionColor(),
              _getSessionColor().withValues(alpha: 0.7)
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_getSessionIcon(), color: Colors.white, size: 40),
            const SizedBox(height: 12),
            Text(
              _getSessionTitle(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getSessionDescription(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            if (_isSessionActive) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.access_time, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${_sessionDuration ~/ 60}:${(_sessionDuration % 60).toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ],
          ],
        ),
      );

  IconData _getSessionIcon() {
    switch (widget.sessionType) {
      case 'breathing':
        return Icons.air;
      case 'meditation':
        return Icons.self_improvement;
      case 'voice_check':
        return Icons.mic;
      case 'mood_tracking':
        return Icons.sentiment_satisfied;
      case 'stress_relief':
        return Icons.spa;
      default:
        return Icons.psychology;
    }
  }

  String _getSessionDescription() {
    switch (widget.sessionType) {
      case 'breathing':
        return 'Exercícios de respiração guiada para relaxamento e foco';
      case 'meditation':
        return 'Meditação mindfulness para clareza mental e paz interior';
      case 'voice_check':
        return 'Análise vocal para monitorar seu estado emocional';
      case 'mood_tracking':
        return 'Registro e acompanhamento do seu humor atual';
      case 'stress_relief':
        return 'Técnicas rápidas para alívio de estresse e tensão';
      default:
        return 'Sessão personalizada de coaching de bem-estar';
    }
  }

  Widget _buildActiveSession() {
    switch (widget.sessionType) {
      case 'breathing':
        return _buildBreathingSession();
      case 'meditation':
        return _buildMeditationSession();
      case 'voice_check':
        return _buildVoiceCheckSession();
      case 'mood_tracking':
        return _buildMoodTrackingSession();
      case 'stress_relief':
        return _buildStressReliefSession();
      default:
        return _buildGenericSession();
    }
  }

  Widget _buildBreathingSession() => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                _breathingInstructions[_breathingPhase],
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              AnimatedBuilder(
                animation: _breathingAnimation,
                builder: (context, child) => Transform.scale(
                  scale: _breathingAnimation.value,
                  child: Container(
                    width: 150,
                    height: 150,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Colors.blue[300]!,
                          Colors.blue[600]!,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.air,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              LinearProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _pauseSession,
                    child: const Text('Pausar'),
                  ),
                  ElevatedButton(
                    onPressed: _stopSession,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Finalizar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildMeditationSession() => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                'Fase: ${_meditationPhase.toUpperCase()}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (_meditationInstructions.isNotEmpty)
                Text(
                  _meditationInstructions[0],
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 32),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.purple[300]!,
                      Colors.purple[600]!,
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.self_improvement,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              LinearProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.purple[600]!),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _pauseSession,
                    child: const Text('Pausar'),
                  ),
                  ElevatedButton(
                    onPressed: _stopSession,
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Finalizar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  Widget _buildVoiceCheckSession() => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'Fale por 30 segundos sobre como você está se sentindo',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green[600],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mic,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Gravando...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: _progressAnimation.value,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
              ),
            ],
          ),
        ),
      );

  Widget _buildMoodTrackingSession() => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'Como você está se sentindo agora?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children:
                    ['😢', '😕', '😐', '😊', '😄'].asMap().entries.map((entry) {
                  final index = entry.key;
                  final emoji = entry.value;
                  final rating = index + 1.0;
                  final isSelected = _currentMoodRating == rating;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _currentMoodRating = rating;
                      });
                    },
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isSelected ? Colors.orange[200] : Colors.grey[200],
                        border: Border.all(
                          color: isSelected
                              ? Colors.orange[600]!
                              : Colors.grey[400]!,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 30),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Descreva como você está se sentindo...',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) {
                  _stressDescription = value;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveMoodTracking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  foregroundColor: Colors.white,
                ),
                child: const Text('Salvar'),
              ),
            ],
          ),
        ),
      );

  Widget _buildStressReliefSession() => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'Técnicas de Alívio de Estresse',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              _buildStressReliefTechnique(
                'Respiração 4-7-8',
                'Inspire por 4, segure por 7, expire por 8',
                Icons.air,
                _startBreathingTechnique,
              ),
              const SizedBox(height: 16),
              _buildStressReliefTechnique(
                'Relaxamento Muscular',
                'Tense e relaxe cada grupo muscular',
                Icons.accessibility_new,
                _startMuscleRelaxation,
              ),
              const SizedBox(height: 16),
              _buildStressReliefTechnique(
                'Visualização',
                'Imagine um lugar calmo e seguro',
                Icons.visibility,
                _startVisualization,
              ),
            ],
          ),
        ),
      );

  Widget _buildStressReliefTechnique(String title, String description,
          IconData icon, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.red[600], size: 30),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.red[800],
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(color: Colors.red[600]),
                    ),
                  ],
                ),
              ),
              Icon(Icons.play_arrow, color: Colors.red[600]),
            ],
          ),
        ),
      );

  Widget _buildGenericSession() => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'Sessão em andamento...',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              const CircularProgressIndicator(),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _stopSession,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Finalizar'),
              ),
            ],
          ),
        ),
      );

  Widget _buildSessionStart() => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Text(
                'Pronto para começar?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                _getSessionInstructions(),
                style: const TextStyle(fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _startSession,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getSessionColor(),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Iniciar Sessão',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  String _getSessionInstructions() {
    switch (widget.sessionType) {
      case 'breathing':
        return 'Este exercício irá guiá-lo através de técnicas de respiração profunda. Encontre um lugar confortável e silencioso.';
      case 'meditation':
        return 'Prepare-se para uma sessão de meditação mindfulness. Sente-se confortavelmente e tenha alguns minutos livres.';
      case 'voice_check':
        return 'Você será solicitado a falar sobre como está se sentindo. Certifique-se de estar em um ambiente silencioso.';
      case 'mood_tracking':
        return 'Vamos registrar seu humor atual e qualquer pensamento ou sentimento relevante.';
      case 'stress_relief':
        return 'Escolha entre diferentes técnicas para aliviar o estresse e a tensão.';
      default:
        return 'Esta sessão foi personalizada para suas necessidades específicas de bem-estar.';
    }
  }

  Widget _buildSessionInfo() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Benefícios',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._getSessionBenefits().map((benefit) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: Colors.green)),
                        Expanded(child: Text(benefit)),
                      ],
                    ),
                  )),
            ],
          ),
        ),
      );

  List<String> _getSessionBenefits() {
    switch (widget.sessionType) {
      case 'breathing':
        return [
          'Reduz ansiedade e estresse',
          'Melhora foco e concentração',
          'Promove relaxamento',
          'Regula sistema nervoso'
        ];
      case 'meditation':
        return [
          'Aumenta autoconsciência',
          'Reduz pensamentos negativos',
          'Melhora clareza mental',
          'Promove paz interior'
        ];
      case 'voice_check':
        return [
          'Monitora estado emocional',
          'Detecta padrões de humor',
          'Fornece insights personalizados',
          'Acompanha progresso ao longo do tempo'
        ];
      case 'mood_tracking':
        return [
          'Identifica padrões de humor',
          'Promove autoconhecimento',
          'Ajuda na gestão emocional',
          'Fornece dados para melhoria'
        ];
      case 'stress_relief':
        return [
          'Alívio imediato de tensão',
          'Técnicas práticas e rápidas',
          'Melhora resposta ao estresse',
          'Promove bem-estar geral'
        ];
      default:
        return ['Promove bem-estar geral', 'Melhora qualidade de vida'];
    }
  }

  Future<void> _startSession() async {
    try {
      final session =
          await _wellnessService.startCoachingSession(widget.sessionType);

      if (session != null) {
        setState(() {
          _currentSession = session;
          _isSessionActive = true;
          _sessionDuration = 0;
        });

        _progressController.forward();

        _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() {
            _sessionDuration++;
          });
        });

        if (widget.sessionType == 'breathing') {
          _startBreathingCycle();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao iniciar sessão: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _startBreathingCycle() {
    _breathingController.duration =
        Duration(seconds: _breathingDurations[_breathingPhase]);
    _breathingController.forward().then((_) {
      if (_isSessionActive) {
        setState(() {
          _breathingPhase = (_breathingPhase + 1) % 4;
        });
        _breathingController.reset();
        _startBreathingCycle();
      }
    });
  }

  void _pauseSession() {
    setState(() {
      _isSessionActive = false;
    });
    _sessionTimer?.cancel();
    _breathingController.stop();
    _progressController.stop();
  }

  Future<void> _stopSession() async {
    setState(() {
      _isSessionActive = false;
    });

    _sessionTimer?.cancel();
    _breathingController.stop();
    _progressController.stop();

    if (_currentSession != null) {
      // Salvar progresso da sessão
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sessão finalizada com sucesso! 🎉'),
          backgroundColor: Colors.green,
        ),
      );
    }

    Navigator.of(context).pop();
  }

  void _saveMoodTracking() {
    // Implementar salvamento do rastreamento de humor
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Humor registrado com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _startBreathingTechnique() {
    // Implementar técnica específica de respiração
  }

  void _startMuscleRelaxation() {
    // Implementar relaxamento muscular
  }

  void _startVisualization() {
    // Implementar visualização guiada
  }
}
