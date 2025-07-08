import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/app_colors.dart';

class AgricultureScreenNew extends StatefulWidget {
  const AgricultureScreenNew({super.key});

  @override
  State<AgricultureScreenNew> createState() => _AgricultureScreenNewState();
}

class _AgricultureScreenNewState extends State<AgricultureScreenNew> {
  final ApiService _apiService = ApiService();
  final TextEditingController _questionController = TextEditingController();

  String _selectedCropType = 'rice';
  String _selectedSeason = 'rainy';
  String _language = 'portuguese';
  bool _useCreole = false;
  bool _isLoading = false;
  String _response = '';

  final List<Map<String, String>> _cropTypes = [
    {'key': 'rice', 'pt': 'Arroz', 'crioulo': 'Aros'},
    {'key': 'millet', 'pt': 'Milheto', 'crioulo': 'Milheto'},
    {'key': 'corn', 'pt': 'Milho', 'crioulo': 'Milho'},
    {'key': 'cashew', 'pt': 'Caju', 'crioulo': 'Kaju'},
    {'key': 'peanuts', 'pt': 'Amendoim', 'crioulo': 'Amendoim'},
    {'key': 'vegetables', 'pt': 'Hortaliças', 'crioulo': 'Hortalisas'},
  ];

  final List<Map<String, String>> _seasons = [
    {'key': 'rainy', 'pt': 'Época das Chuvas', 'crioulo': 'Tempu di Chuva'},
    {'key': 'dry', 'pt': 'Época Seca', 'crioulo': 'Tempu Seku'},
    {'key': 'transition', 'pt': 'Transição', 'crioulo': 'Transison'},
  ];

  Future<void> _submitQuestion() async {
    if (_questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_useCreole
              ? 'Pergunta nan podi ta vazi'
              : 'Pergunta não pode estar vazia'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _response = '';
    });

    try {
      final response = await _apiService.askAgricultureQuestion(
        question: _questionController.text,
        cropType: _selectedCropType,
        season: _selectedSeason,
        language: _useCreole ? 'crioulo-gb' : 'portuguese',
      );

      setState(() {
        if (response.success && response.data != null) {
          _response = response.data!;
        } else {
          _response = _useCreole
              ? 'Erro: ${response.error ?? "Problema na komunikason"}'
              : 'Erro: ${response.error ?? "Problema na comunicação"}';
        }
      });
    } catch (e) {
      setState(() {
        _response = _useCreole ? 'Erro di konekson: $e' : 'Erro de conexão: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildQuickQuestions() {
    final questions = _useCreole
        ? [
            'Kuma planta aros?',
            'Kual tempu di semente?',
            'Kuma trata praga?',
            'Kuma rega plantason?',
          ]
        : [
            'Como plantar arroz na Guiné-Bissau?',
            'Qual a melhor época para semear?',
            'Como tratar pragas naturalmente?',
            'Como irrigar culturas?',
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _useCreole ? 'Pergunta Rapidu:' : 'Perguntas Rápidas:',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: questions
              .map((question) => ActionChip(
                    label: Text(question),
                    onPressed: () {
                      _questionController.text = question;
                      _submitQuestion();
                    },
                    backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
                    labelStyle: const TextStyle(color: AppColors.primaryGreen),
                  ))
              .toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(_useCreole ? 'Agrikultura' : 'Agricultura'),
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: Icon(_useCreole ? Icons.language : Icons.translate),
              onPressed: () {
                setState(() {
                  _useCreole = !_useCreole;
                  _language = _useCreole ? 'crioulo-gb' : 'portuguese';
                });
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com ícone
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGreen,
                      AppColors.primaryGreen.withOpacity(0.7)
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.agriculture,
                        size: 48, color: Colors.white),
                    const SizedBox(height: 8),
                    Text(
                      _useCreole
                          ? 'Konselheru Agrikola Bu Fala'
                          : 'Consultor Agrícola Bu Fala',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _useCreole
                          ? 'Djuda pa agrikultura sustentável'
                          : 'Orientações para agricultura sustentável',
                      style: const TextStyle(color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Seleção de cultura
              Text(
                _useCreole ? 'Tipu di Kultura:' : 'Tipo de Cultura:',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCropType,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: _cropTypes
                    .map((crop) => DropdownMenuItem(
                          value: crop['key'],
                          child:
                              Text(_useCreole ? crop['crioulo']! : crop['pt']!),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCropType = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Seleção de época
              Text(
                _useCreole ? 'Epoka:' : 'Época:',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedSeason,
                decoration: InputDecoration(
                  border: const OutlineInputBorder(),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: _seasons
                    .map((season) => DropdownMenuItem(
                          value: season['key'],
                          child: Text(
                              _useCreole ? season['crioulo']! : season['pt']!),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedSeason = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              // Campo de pergunta
              Text(
                _useCreole ? 'Bu Pergunta:' : 'Sua Pergunta:',
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _questionController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: _useCreole
                      ? 'Skibi bu pergunta sobri agrikultura...'
                      : 'Digite sua pergunta sobre agricultura...',
                  border: const OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),

              const SizedBox(height: 16),

              // Botão de envio
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _useCreole ? 'Manda Pergunta' : 'Enviar Pergunta',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Perguntas rápidas
              _buildQuickQuestions(),

              const SizedBox(height: 20),

              // Resposta
              if (_response.isNotEmpty) ...[
                Text(
                  _useCreole ? 'Risposta:' : 'Resposta:',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    border: Border.all(
                        color: AppColors.primaryGreen.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _response,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ),
              ],
            ],
          ),
        ),
      );

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }
}
