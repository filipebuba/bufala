import 'package:flutter/material.dart';
import '../services/wellness_coaching_service.dart';

class DailyWellnessScreen extends StatefulWidget {
  const DailyWellnessScreen({super.key});

  @override
  State<DailyWellnessScreen> createState() => _DailyWellnessScreenState();
}

class _DailyWellnessScreenState extends State<DailyWellnessScreen>
    with TickerProviderStateMixin {
  final WellnessCoachingService _wellnessService = WellnessCoachingService();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(colorScheme),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    children: [
                      _buildWelcomeCard(colorScheme),
                      const SizedBox(height: 16),
                      _buildMoodSection(colorScheme),
                      const SizedBox(height: 16),
                      _buildPhysicalWellbeingSection(colorScheme),
                      const SizedBox(height: 16),
                      _buildActivitiesSection(colorScheme),
                      const SizedBox(height: 16),
                      _buildFeelingsSection(colorScheme),
                      const SizedBox(height: 16),
                      _buildNotesSection(colorScheme),
                      const SizedBox(height: 24),
                      _buildSaveButton(colorScheme),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(ColorScheme colorScheme) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: colorScheme.primary,
      foregroundColor: colorScheme.onPrimary,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Bem-estar Diário',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                colorScheme.primary,
                colorScheme.primary.withOpacity(0.8),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: _showHistory,
          tooltip: 'Histórico',
        ),
        IconButton(
          icon: const Icon(Icons.insights),
          onPressed: _showInsights,
          tooltip: 'Insights',
        ),
      ],
    );
  }

  Widget _buildWelcomeCard(ColorScheme colorScheme) {
    final now = DateTime.now();
    final weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
    final months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer,
              colorScheme.primaryContainer.withOpacity(0.7),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.wb_sunny_outlined,
                  color: colorScheme.onPrimaryContainer,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Como foi seu dia hoje?',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${weekdays[now.weekday % 7]}, ${now.day} de ${months[now.month - 1]}',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSection(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.psychology_outlined,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Estado Emocional',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildModernSlider(
              'Humor Geral',
              _moodRating,
              Icons.sentiment_satisfied_outlined,
              (value) => setState(() => _moodRating = value),
              ['😢', '😕', '😐', '😊', '😄'],
              colorScheme,
            ),
            const SizedBox(height: 16),
            _buildModernSlider(
              'Nível de Energia',
              _energyLevel,
              Icons.battery_charging_full_outlined,
              (value) => setState(() => _energyLevel = value),
              ['🪫', '🔋', '⚡', '⚡⚡', '⚡⚡⚡'],
              colorScheme,
            ),
            const SizedBox(height: 16),
            _buildModernSlider(
              'Nível de Estresse',
              _stressLevel,
              Icons.psychology_outlined,
              (value) => setState(() => _stressLevel = value),
              ['😌', '🙂', '😐', '😰', '😵'],
              colorScheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhysicalWellbeingSection(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.fitness_center_outlined,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Bem-estar Físico',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildModernSlider(
              'Qualidade do Sono',
              _sleepQuality,
              Icons.bedtime_outlined,
              (value) => setState(() => _sleepQuality = value),
              ['😴', '😪', '😐', '😊', '😄'],
              colorScheme,
            ),
            const SizedBox(height: 16),
            _buildNumberSlider(
              'Horas de Sono',
              _sleepHours.toDouble(),
              Icons.access_time_outlined,
              3,
              12,
              '${_sleepHours}h',
              (value) => setState(() => _sleepHours = value.round()),
              colorScheme,
            ),
            const SizedBox(height: 16),
            _buildNumberSlider(
              'Exercício',
              _exerciseMinutes.toDouble(),
              Icons.directions_run_outlined,
              0,
              120,
              '${_exerciseMinutes}min',
              (value) => setState(() => _exerciseMinutes = value.round()),
              colorScheme,
            ),
            const SizedBox(height: 16),
            _buildNumberSlider(
              'Meditação',
              _meditationMinutes.toDouble(),
              Icons.self_improvement_outlined,
              0,
              60,
              '${_meditationMinutes}min',
              (value) => setState(() => _meditationMinutes = value.round()),
              colorScheme,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernSlider(
    String label,
    double value,
    IconData icon,
    void Function(double) onChanged,
    List<String> emojis,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                emojis[value.round() - 1],
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: colorScheme.primary,
            inactiveTrackColor: colorScheme.outline.withOpacity(0.3),
            thumbColor: colorScheme.primary,
            overlayColor: colorScheme.primary.withOpacity(0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: 1,
            max: 5,
            divisions: 4,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildNumberSlider(
    String label,
    double value,
    IconData icon,
    double min,
    double max,
    String displayValue,
    void Function(double) onChanged,
    ColorScheme colorScheme,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                displayValue,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: colorScheme.secondary,
            inactiveTrackColor: colorScheme.outline.withOpacity(0.3),
            thumbColor: colorScheme.secondary,
            overlayColor: colorScheme.secondary.withOpacity(0.2),
            trackHeight: 4,
          ),
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).round(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildActivitiesSection(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_activity_outlined,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Atividades de Bem-estar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'O que você fez hoje para cuidar de si?',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableActivities.map((activity) {
                    final isSelected = _selectedActivities.contains(activity);
                    return SizedBox(
                      width: (constraints.maxWidth - 16) / 2,
                      child: FilterChip(
                        label: Text(
                          activity,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        selected: isSelected,
                        selectedColor: colorScheme.primaryContainer,
                        checkmarkColor: colorScheme.onPrimaryContainer,
                        backgroundColor: colorScheme.surface,
                        side: BorderSide(
                          color: isSelected 
                              ? colorScheme.primary 
                              : colorScheme.outline.withOpacity(0.5),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedActivities.add(activity);
                            } else {
                              _selectedActivities.remove(activity);
                            }
                          });
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeelingsSection(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.favorite_outline,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Como você se sentiu hoje?',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Selecione todos os sentimentos que se aplicam',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LayoutBuilder(
              builder: (context, constraints) {
                return Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _availableFeelings.map((feeling) {
                    final isSelected = _selectedFeelings.contains(feeling);
                    return SizedBox(
                      width: (constraints.maxWidth - 12) / 3,
                      child: FilterChip(
                        label: Text(
                          feeling,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        selected: isSelected,
                        selectedColor: _getFeelingColor(feeling, colorScheme),
                        backgroundColor: colorScheme.surface,
                        side: BorderSide(
                          color: isSelected 
                              ? _getFeelingBorderColor(feeling, colorScheme)
                              : colorScheme.outline.withOpacity(0.5),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedFeelings.add(feeling);
                            } else {
                              _selectedFeelings.remove(feeling);
                            }
                          });
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Color _getFeelingColor(String feeling, ColorScheme colorScheme) {
    const positiveFeellings = [
      'Feliz', 'Calmo', 'Motivado', 'Grato', 'Confiante', 'Energizado'
    ];
    const negativeFeellings = [
      'Ansioso', 'Estressado', 'Irritado', 'Preocupado', 'Triste'
    ];

    if (positiveFeellings.contains(feeling)) {
      return Colors.green.withOpacity(0.2);
    } else if (negativeFeellings.contains(feeling)) {
      return Colors.red.withOpacity(0.2);
    }
    return colorScheme.secondaryContainer;
  }

  Color _getFeelingBorderColor(String feeling, ColorScheme colorScheme) {
    const positiveFeellings = [
      'Feliz', 'Calmo', 'Motivado', 'Grato', 'Confiante', 'Energizado'
    ];
    const negativeFeellings = [
      'Ansioso', 'Estressado', 'Irritado', 'Preocupado', 'Triste'
    ];

    if (positiveFeellings.contains(feeling)) {
      return Colors.green;
    } else if (negativeFeellings.contains(feeling)) {
      return Colors.red;
    }
    return colorScheme.secondary;
  }

  Widget _buildNotesSection(ColorScheme colorScheme) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.edit_note_outlined,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reflexões do Dia',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      Text(
                        'Escreva sobre como foi seu dia',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Hoje foi um dia especial porque...',
                hintStyle: TextStyle(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colorScheme.primary, width: 2),
                ),
                filled: true,
                fillColor: colorScheme.surface,
              ),
              onChanged: (value) {
                _notes = value;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(ColorScheme colorScheme) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveDailyMetrics,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSaving
            ? SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(colorScheme.onPrimary),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_outlined, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Salvar Dia',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

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
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 8),
                  const Text('Métricas salvas com sucesso! 🎉'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Erro ao salvar: $e')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
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
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Histórico de Bem-estar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.green.withOpacity(0.2),
                          child: const Icon(Icons.trending_up, color: Colors.green),
                        ),
                        title: const Text('Ontem'),
                        subtitle: const Text('Humor: 4/5 • Energia: 3/5'),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    ),
                    Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blue.withOpacity(0.2),
                          child: const Icon(Icons.trending_flat, color: Colors.blue),
                        ),
                        title: const Text('Anteontem'),
                        subtitle: const Text('Humor: 3/5 • Energia: 4/5'),
                        trailing: const Icon(Icons.chevron_right),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Esta funcionalidade mostrará seu histórico completo em breve.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInsights() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.insights, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            const Text('Insights de Bem-estar'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Card(
              color: Colors.blue.withOpacity(0.1),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb, color: Colors.blue),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Você tem dormido bem! Continue assim.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Card(
              color: Colors.orange.withOpacity(0.1),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Tente adicionar mais exercícios à sua rotina.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
