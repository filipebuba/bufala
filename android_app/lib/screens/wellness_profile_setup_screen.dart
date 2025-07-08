import 'package:flutter/material.dart';
import '../services/wellness_coaching_service.dart';

class WellnessProfileSetupScreen extends StatefulWidget {
  const WellnessProfileSetupScreen({super.key});

  @override
  State<WellnessProfileSetupScreen> createState() =>
      _WellnessProfileSetupScreenState();
}

class _WellnessProfileSetupScreenState
    extends State<WellnessProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final WellnessCoachingService _wellnessService = WellnessCoachingService();

  String _name = '';
  int _age = 25;
  final List<String> _stressors = [];
  final List<String> _goals = [];
  String _activityLevel = 'Moderado';
  int _sleepHours = 8;

  final List<String> _availableStressors = [
    'Trabalho',
    'Relacionamentos',
    'Saúde',
    'Finanças',
    'Família',
    'Estudos',
    'Outro'
  ];

  final List<String> _availableGoals = [
    'Reduzir estresse',
    'Melhorar sono',
    'Aumentar energia',
    'Desenvolver mindfulness',
    'Melhorar humor',
    'Aumentar autoestima',
    'Controlar ansiedade'
  ];

  final List<String> _activityLevels = ['Baixo', 'Moderado', 'Alto'];

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Configurar Perfil de Bem-estar'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildBasicInfo(),
              const SizedBox(height: 24),
              _buildStressorsSection(),
              const SizedBox(height: 24),
              _buildGoalsSection(),
              const SizedBox(height: 24),
              _buildLifestyleSection(),
              const SizedBox(height: 32),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );

  Widget _buildHeader() => Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[700]!, Colors.green[500]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.self_improvement, color: Colors.white, size: 40),
          SizedBox(height: 12),
          Text(
            'Vamos criar seu perfil personalizado',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Essas informações nos ajudam a oferecer recomendações mais precisas para seu bem-estar.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );

  Widget _buildBasicInfo() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informações Básicas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor, insira seu nome';
                }
                return null;
              },
              onSaved: (value) => _name = value!,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 8),
                const Text('Idade: '),
                Expanded(
                  child: Slider(
                    value: _age.toDouble(),
                    min: 16,
                    max: 80,
                    divisions: 64,
                    label: '$_age anos',
                    onChanged: (value) {
                      setState(() {
                        _age = value.round();
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

  Widget _buildStressorsSection() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Principais Fontes de Estresse',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Selecione as áreas que mais causam estresse em sua vida:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableStressors.map((stressor) {
                final isSelected = _stressors.contains(stressor);
                return FilterChip(
                  label: Text(stressor),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _stressors.add(stressor);
                      } else {
                        _stressors.remove(stressor);
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

  Widget _buildGoalsSection() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Objetivos de Bem-estar',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'O que você gostaria de melhorar?',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableGoals.map((goal) {
                final isSelected = _goals.contains(goal);
                return FilterChip(
                  label: Text(goal),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _goals.add(goal);
                      } else {
                        _goals.remove(goal);
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

  Widget _buildLifestyleSection() => Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estilo de Vida',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Nível de Atividade Física',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.fitness_center),
              ),
              value: _activityLevel,
              items: _activityLevels.map((level) => DropdownMenuItem(
                  value: level,
                  child: Text(level),
                )).toList(),
              onChanged: (value) {
                setState(() {
                  _activityLevel = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.bedtime),
                const SizedBox(width: 8),
                const Text('Horas de sono por noite: '),
                Expanded(
                  child: Slider(
                    value: _sleepHours.toDouble(),
                    min: 4,
                    max: 12,
                    divisions: 8,
                    label: '$_sleepHours horas',
                    onChanged: (value) {
                      setState(() {
                        _sleepHours = value.round();
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

  Widget _buildSaveButton() => SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: const Text(
          'Salvar Perfil',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (_stressors.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Por favor, selecione pelo menos uma fonte de estresse'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (_goals.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecione pelo menos um objetivo'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      try {
        final success = await _wellnessService.createWellnessProfile(
          name: _name,
          age: _age,
          concerns: _stressors,
          goals: _goals,
        );

        if (!success) {
          throw Exception('Falha ao criar perfil');
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil salvo com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop(true); // Retorna true para indicar sucesso
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao salvar perfil: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}
