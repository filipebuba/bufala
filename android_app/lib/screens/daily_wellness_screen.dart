import 'package:flutter/material.dart';
import '../services/wellness_coaching_service.dart';

class DailyWellnessScreen extends StatefulWidget {
  const DailyWellnessScreen({super.key});

  @override
  State<DailyWellnessScreen> createState() => _DailyWellnessScreenState();
}

class _DailyWellnessScreenState extends State<DailyWellnessScreen> {
  final WellnessCoachingService _wellnessService = WellnessCoachingService();

  // Métricas do dia
  double _moodRating = 3;
  double _energyLevel = 3;
  double _stressLevel = 3;
  double _sleepQuality = 3;
  int _sleepHours = 8;
  int _exerciseMinutes = 0;
  int _meditationMinutes = 0;

  // Atividades de bem-estar
  final List<String> _selectedActivities = [];
  final List<String> _availableActivities = [
    'Caminhada',
    'Exercício físico',
    'Meditação',
    'Leitura',
    'Tempo na natureza',
    'Socialização',
    'Hobby',
    'Respiração profunda',
    'Música relaxante',
    'Banho relaxante',
  ];

  // Sentimentos
  final List<String> _selectedFeelings = [];
  final List<String> _availableFeelings = [
    'Feliz',
    'Calmo',
    'Ansioso',
    'Estressado',
    'Motivado',
    'Cansado',
    'Grato',
    'Irritado',
    'Confiante',
    'Preocupado',
    'Energizado',
    'Triste',
  ];

  String _notes = '';
  bool _isSaving = false;

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Bem-estar Diário'),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _showHistory,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildMoodSection(),
            const SizedBox(height: 24),
            _buildPhysicalWellbeingSection(),
            const SizedBox(height: 24),
            _buildActivitiesSection(),
            const SizedBox(height: 24),
            _buildFeelingsSection(),
            const SizedBox(height: 24),
            _buildNotesSection(),
            const SizedBox(height: 32),
            _buildSaveButton(),
          ],
        ),
      ),
    );

  Widget _buildHeader() {
    final now = DateTime.now();
    final weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    final months = [
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple[700]!, Colors.purple[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.today, color: Colors.white, size: 40),
          const SizedBox(height: 12),
          const Text(
            'Como foi seu dia hoje?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${weekdays[now.weekday % 7]}, ${now.day} de ${months[now.month - 1]}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSection() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Como você se sente hoje?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSliderRow(
              'Humor Geral',
              _moodRating,
              Icons.sentiment_satisfied,
              (value) => setState(() => _moodRating = value),
              ['😢', '😕', '😐', '😊', '😄'],
            ),
            _buildSliderRow(
              'Nível de Energia',
              _energyLevel,
              Icons.battery_charging_full,
              (value) => setState(() => _energyLevel = value),
              ['🪫', '🔋', '⚡', '⚡⚡', '⚡⚡⚡'],
            ),
            _buildSliderRow(
              'Nível de Estresse',
              _stressLevel,
              Icons.psychology,
              (value) => setState(() => _stressLevel = value),
              ['😌', '🙂', '😐', '😰', '😵'],
            ),
          ],
        ),
      ),
    );

  Widget _buildPhysicalWellbeingSection() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bem-estar Físico',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildSliderRow(
              'Qualidade do Sono',
              _sleepQuality,
              Icons.bedtime,
              (value) => setState(() => _sleepQuality = value),
              ['😴', '😪', '😐', '😊', '😄'],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.access_time),
                const SizedBox(width: 8),
                const Text('Horas de sono: '),
                Expanded(
                  child: Slider(
                    value: _sleepHours.toDouble(),
                    min: 3,
                    max: 12,
                    divisions: 9,
                    label: '${_sleepHours}h',
                    onChanged: (value) {
                      setState(() {
                        _sleepHours = value.round();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.fitness_center),
                const SizedBox(width: 8),
                const Text('Exercício (min): '),
                Expanded(
                  child: Slider(
                    value: _exerciseMinutes.toDouble(),
                    max: 120,
                    divisions: 12,
                    label: '${_exerciseMinutes}min',
                    onChanged: (value) {
                      setState(() {
                        _exerciseMinutes = value.round();
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.self_improvement),
                const SizedBox(width: 8),
                const Text('Meditação (min): '),
                Expanded(
                  child: Slider(
                    value: _meditationMinutes.toDouble(),
                    max: 60,
                    divisions: 12,
                    label: '${_meditationMinutes}min',
                    onChanged: (value) {
                      setState(() {
                        _meditationMinutes = value.round();
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

  Widget _buildSliderRow(
    String label,
    double value,
    IconData icon,
    void Function(double) onChanged,
    List<String> emojis,
  ) => Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(label)),
            Text(
              emojis[value.round() - 1],
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 1,
          max: 5,
          divisions: 4,
          label: value.round().toString(),
          onChanged: onChanged,
        ),
      ],
    );

  Widget _buildActivitiesSection() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Atividades de Bem-estar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'O que você fez hoje para cuidar de si mesmo?',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableActivities.map((activity) {
                final isSelected = _selectedActivities.contains(activity);
                return FilterChip(
                  label: Text(activity),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedActivities.add(activity);
                      } else {
                        _selectedActivities.remove(activity);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );

  Widget _buildFeelingsSection() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Como você se sentiu hoje?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Selecione todos os sentimentos que se aplicam:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableFeelings.map((feeling) {
                final isSelected = _selectedFeelings.contains(feeling);
                return FilterChip(
                  label: Text(feeling),
                  selected: isSelected,
                  selectedColor: _getFeelingColor(feeling),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedFeelings.add(feeling);
                      } else {
                        _selectedFeelings.remove(feeling);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );

  Color _getFeelingColor(String feeling) {
    const positiveFeellings = [
      'Feliz',
      'Calmo',
      'Motivado',
      'Grato',
      'Confiante',
      'Energizado'
    ];
    const negativeFeellings = [
      'Ansioso',
      'Estressado',
      'Irritado',
      'Preocupado',
      'Triste'
    ];

    if (positiveFeellings.contains(feeling)) {
      return Colors.green.withValues(alpha: 0.3);
    } else if (negativeFeellings.contains(feeling)) {
      return Colors.red.withValues(alpha: 0.3);
    }
    return Colors.blue.withValues(alpha: 0.3);
  }

  Widget _buildNotesSection() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reflexões do Dia',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Escreva sobre como foi seu dia, conquistas, desafios ou qualquer coisa importante:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 4,
              decoration: const InputDecoration(
                hintText:
                    'Ex: Hoje foi um dia desafiador no trabalho, mas consegui terminar um projeto importante...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _notes = value;
              },
            ),
          ],
        ),
      ),
    );

  Widget _buildSaveButton() => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveDailyMetrics,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.purple[700],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Salvar Dia',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );

  Future<void> _saveDailyMetrics() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final success = await _wellnessService.recordDailyMetrics(
        moodRating: _moodRating,
        stressLevel: _stressLevel,
        energyLevel: _energyLevel,
        sleepHours: _sleepHours,
        activities: _selectedActivities,
        notes: _notes,
      );

      if (success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Métricas do dia salvas com sucesso! 🎉'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        }
      } else {
        throw Exception('Falha ao salvar métricas');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  void _showHistory() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Histórico de Bem-estar'),
        content: const Text(
            'Esta funcionalidade mostrará seu histórico de bem-estar diário em breve.'),
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
