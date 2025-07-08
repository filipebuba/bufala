import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AgricultureScreenFixed extends StatefulWidget {
  const AgricultureScreenFixed({super.key});

  @override
  State<AgricultureScreenFixed> createState() => _AgricultureScreenFixedState();
}

class _AgricultureScreenFixedState extends State<AgricultureScreenFixed> {
  final ApiService _apiService = ApiService();
  final TextEditingController _questionController = TextEditingController();

  String _selectedCropType = 'arroz';
  String _selectedSeason = 'chuva';
  bool _useCreole = false;
  bool _isLoading = false;
  String _response = '';

  final List<Map<String, String>> _cropTypes = [
    {'key': 'arroz', 'pt': 'Arroz', 'crioulo': 'Aros'},
    {'key': 'milho', 'pt': 'Milho', 'crioulo': 'Milho'},
    {'key': 'caju', 'pt': 'Caju', 'crioulo': 'Kaju'},
    {'key': 'amendoim', 'pt': 'Amendoim', 'crioulo': 'Amendoim'},
    {'key': 'mandioca', 'pt': 'Mandioca', 'crioulo': 'Mandioka'},
    {'key': 'hortaliças', 'pt': 'Hortaliças', 'crioulo': 'Hortalisas'},
  ];

  final List<Map<String, String>> _seasons = [
    {'key': 'chuva', 'pt': 'Época das Chuvas', 'crioulo': 'Tempu di Chuva'},
    {'key': 'seca', 'pt': 'Época Seca', 'crioulo': 'Tempu Seku'},
    {'key': 'transição', 'pt': 'Transição', 'crioulo': 'Transison'},
  ];

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _submitQuestion() async {
    if (_questionController.text.trim().isEmpty) {
      _showSnackBar(
        _useCreole
            ? 'Pergunta nan podi ta vazi'
            : 'Pergunta não pode estar vazia',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _response = '';
    });

    try {
      // Preparar pergunta detalhada para o backend
      final detailedQuestion = _buildDetailedQuestion();

      final response = await _apiService.askAgricultureQuestion(
        question: detailedQuestion,
        language: _useCreole ? 'crioulo-gb' : 'pt-BR',
        cropType: _selectedCropType,
        season: _selectedSeason,
      );

      setState(() {
        if (response.success && response.data != null) {
          _response = response.data!;
          _showSnackBar(
            _useCreole ? 'Resposta resebi!' : 'Resposta recebida!',
            isError: false,
          );
        } else {
          _response = _useCreole
              ? 'Erro: ${response.error ?? "Problema na komunikason"}'
              : 'Erro: ${response.error ?? "Problema na comunicação"}';
          _showSnackBar(_response, isError: true);
        }
      });
    } catch (e) {
      setState(() {
        _response = _useCreole ? 'Erro di konekson: $e' : 'Erro de conexão: $e';
      });
      _showSnackBar(_response, isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _buildDetailedQuestion() {
    final context = _useCreole
        ? 'Na Guiné-Bissau, na tempu di ${_getSeasonName()} pa kultura di ${_getCropName()}:'
        : 'Na Guiné-Bissau, na época ${_getSeasonName()} para cultivo de ${_getCropName()}:';

    return '$context ${_questionController.text.trim()}';
  }

  String _getCropName() {
    final crop = _cropTypes.firstWhere(
      (c) => c['key'] == _selectedCropType,
      orElse: () => _cropTypes.first,
    );
    return crop[_useCreole ? 'crioulo' : 'pt'] ?? _selectedCropType;
  }

  String _getSeasonName() {
    final season = _seasons.firstWhere(
      (s) => s['key'] == _selectedSeason,
      orElse: () => _seasons.first,
    );
    return season[_useCreole ? 'crioulo' : 'pt'] ?? _selectedSeason;
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  void _askQuickQuestion(String question) {
    _questionController.text = question;
    _submitQuestion();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            _useCreole ? 'Agrikultura' : 'Agricultura',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green[700],
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(_useCreole ? Icons.language : Icons.translate),
              onPressed: () {
                setState(() {
                  _useCreole = !_useCreole;
                });
              },
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.green[700]!, Colors.green[50]!],
            ),
          ),
          child: Column(
            children: [
              // Header com ícone
              Container(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.agriculture,
                      size: 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _useCreole
                          ? 'Agrikultura Sustentavel'
                          : 'Agricultura Sustentável',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _useCreole
                          ? 'Konsulta agrikola ku IA pa Guiné-Bissau'
                          : 'Consultoria agrícola com IA para Guiné-Bissau',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Conteúdo principal
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Seletor de cultura
                        _buildCropSelector(),
                        const SizedBox(height: 20),

                        // Seletor de época
                        _buildSeasonSelector(),
                        const SizedBox(height: 20),

                        // Campo de pergunta
                        _buildQuestionField(),
                        const SizedBox(height: 20),

                        // Botão de enviar
                        _buildSubmitButton(),
                        const SizedBox(height: 20),

                        // Perguntas rápidas
                        _buildQuickQuestions(),
                        const SizedBox(height: 20),

                        // Resposta
                        if (_response.isNotEmpty) _buildResponse(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  Widget _buildCropSelector() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _useCreole ? 'Kultura:' : 'Cultura:',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.green[300]!),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCropType,
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: Colors.green[700]),
                items: _cropTypes
                    .map((crop) => DropdownMenuItem<String>(
                          value: crop['key'],
                          child: Row(
                            children: [
                              Icon(Icons.eco,
                                  color: Colors.green[600], size: 20),
                              const SizedBox(width: 10),
                              Text(crop[_useCreole ? 'crioulo' : 'pt'] ?? ''),
                            ],
                          ),
                        ))
                    .toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      _selectedCropType = value;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      );

  Widget _buildSeasonSelector() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _useCreole ? 'Tempu:' : 'Época:',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blue[300]!),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedSeason,
                isExpanded: true,
                icon: Icon(Icons.arrow_drop_down, color: Colors.blue[700]),
                items: _seasons.map((season) {
                  final icon = season['key'] == 'chuva'
                      ? Icons.water_drop
                      : season['key'] == 'seca'
                          ? Icons.wb_sunny
                          : Icons.autorenew;

                  return DropdownMenuItem<String>(
                    value: season['key'],
                    child: Row(
                      children: [
                        Icon(icon, color: Colors.blue[600], size: 20),
                        const SizedBox(width: 10),
                        Text(season[_useCreole ? 'crioulo' : 'pt'] ?? ''),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() {
                      _selectedSeason = value;
                    });
                  }
                },
              ),
            ),
          ),
        ],
      );

  Widget _buildQuestionField() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _useCreole ? 'Su pergunta:' : 'Sua pergunta:',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _questionController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: _useCreole
                  ? 'Esempu: Kuma planta aros na tempu di chuva?'
                  : 'Exemplo: Como plantar arroz na época das chuvas?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.green[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.green[700]!, width: 2),
              ),
              prefixIcon: Icon(Icons.help_outline, color: Colors.green[600]),
            ),
          ),
        ],
      );

  Widget _buildSubmitButton() => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : _submitQuestion,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: _isLoading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      _useCreole ? 'Ta biska...' : 'Buscando...',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                )
              : Text(
                  _useCreole ? 'Manda pergunta' : 'Enviar pergunta',
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
        ),
      );

  Widget _buildQuickQuestions() {
    final questions = _useCreole
        ? [
            'Kuma planta aros na tempu di chuva?',
            'Kual manera pa trata praga di milho?',
            'Kuma kolhe kaju?',
            'Kuma garda semente?',
          ]
        : [
            'Como plantar arroz na época das chuvas?',
            'Como tratar pragas do milho naturalmente?',
            'Quando colher caju?',
            'Como armazenar sementes?',
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _useCreole ? 'Pergunta rapidu:' : 'Perguntas rápidas:',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: questions
              .map((question) => GestureDetector(
                    onTap: () => _askQuickQuestion(question),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.touch_app,
                              size: 16, color: Colors.green[700]),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              question,
                              style: TextStyle(
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildResponse() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _useCreole ? 'Resposta:' : 'Resposta:',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.green[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.agriculture, color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      _useCreole ? 'Konselho agrikola:' : 'Conselho agrícola:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  _response,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          ),
        ],
      );
}
