import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class AgricultureScreenEnhanced extends StatefulWidget {
  const AgricultureScreenEnhanced({super.key});

  @override
  State<AgricultureScreenEnhanced> createState() =>
      _AgricultureScreenEnhancedState();
}

class _AgricultureScreenEnhancedState extends State<AgricultureScreenEnhanced>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  final TextEditingController _questionController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _selectedCropType = 'arroz';
  String _selectedSeason = 'chuva';
  bool _useCreole = false;
  bool _isLoading = false;
  String _response = '';
  String _responseSource = '';
  double _responseTime = 0;

  final List<Map<String, String>> _cropTypes = [
    {'key': 'arroz', 'pt': 'Arroz', 'crioulo': 'Aros'},
    {'key': 'milho', 'pt': 'Milho', 'crioulo': 'Milho'},
    {'key': 'caju', 'pt': 'Caju', 'crioulo': 'Kaju'},
    {'key': 'amendoim', 'pt': 'Amendoim', 'crioulo': 'Amendoim'},
    {'key': 'mandioca', 'pt': 'Mandioca', 'crioulo': 'Mandioka'},
    {'key': 'hortaliças', 'pt': 'Hortaliças', 'crioulo': 'Hortalisas'},
    {'key': 'tomate', 'pt': 'Tomate', 'crioulo': 'Tomate'},
    {'key': 'alface', 'pt': 'Alface', 'crioulo': 'Alfase'},
  ];

  final List<Map<String, String>> _seasons = [
    {'key': 'chuva', 'pt': 'Época das Chuvas', 'crioulo': 'Tempu di Chuva'},
    {'key': 'seca', 'pt': 'Época Seca', 'crioulo': 'Tempu Seku'},
    {'key': 'transição', 'pt': 'Transição', 'crioulo': 'Transison'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _animationController.dispose();
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
      _responseSource = '';
      _responseTime = 0.0;
    });

    final stopwatch = Stopwatch()..start();

    try {
      // Preparar pergunta detalhada para o backend
      final detailedQuestion = _buildDetailedQuestion();

      final response = await _apiService.askAgricultureQuestion(
        question: detailedQuestion,
        language: _useCreole ? 'crioulo-gb' : 'pt-BR',
        cropType: _selectedCropType,
        season: _selectedSeason,
      );

      stopwatch.stop();
      final responseTime = stopwatch.elapsedMilliseconds / 1000.0;

      setState(() {
        _responseTime = responseTime;

        if (response.success && response.data != null) {
          final rawResponse = response.data!;
          _processResponse(rawResponse);

          _showSnackBar(
            _useCreole ? 'Resposta resebi!' : 'Resposta recebida!',
            isError: false,
          );

          _animationController.forward();
        } else {
          _response = _useCreole
              ? 'Erro: ${response.error ?? "Problema na komunikason"}'
              : 'Erro: ${response.error ?? "Problema na comunicação"}';
          _responseSource = 'Sistema de Erro';
          _showSnackBar(_response, isError: true);
        }
      });
    } catch (e) {
      stopwatch.stop();
      setState(() {
        _response = _useCreole ? 'Erro di konekson: $e' : 'Erro de conexão: $e';
        _responseSource = 'Erro de Conectividade';
        _responseTime = stopwatch.elapsedMilliseconds / 1000.0;
      });
      _showSnackBar(_response, isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _processResponse(String rawResponse) {
    // Detectar tipo de resposta e extrair informações
    if (rawResponse.contains('[Docs Gemma •')) {
      // Resposta do Docs Gemma Service
      final parts = rawResponse.split('[Docs Gemma •');
      if (parts.length > 1) {
        _response = parts[0].trim();
        final timePart = parts[1].split(']')[0];
        _responseSource = 'Docs Gemma ($timePart)';
      } else {
        _response = rawResponse;
        _responseSource = 'Docs Gemma Service';
      }
    } else if (rawResponse.contains('[Improved Gemma •')) {
      // Resposta do Improved Gemma Service
      final parts = rawResponse.split('[Improved Gemma •');
      if (parts.length > 1) {
        _response = parts[0].trim();
        final timePart = parts[1].split(']')[0];
        _responseSource = 'Improved Gemma ($timePart)';
      } else {
        _response = rawResponse;
        _responseSource = 'Improved Gemma Service';
      }
    } else if (rawResponse.contains('[Fallback Response')) {
      // Resposta de fallback
      final parts = rawResponse.split('[Fallback Response');
      _response = parts[0].trim();
      _responseSource = 'Resposta de Emergência';
    } else {
      // Resposta padrão
      _response = rawResponse;
      _responseSource = 'Bu Fala AI';
    }

    // Limpar formatação extra
    _response = _cleanResponse(_response);
  }

  String _cleanResponse(String response) {
    // Remover formatações RTF e caracteres especiais
    var cleaned = response;

    // Remover código RTF se presente
    if (cleaned.contains(r'{\rtf1')) {
      final rtfStart = cleaned.indexOf(r'{\rtf1');
      cleaned = cleaned.substring(0, rtfStart).trim();
    }

    // Remover quebras de linha excessivas
    cleaned = cleaned.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    // Remover espaços excessivos
    cleaned = cleaned.replaceAll(RegExp(r' {2,}'), ' ');

    return cleaned.trim();
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
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: Duration(seconds: isError ? 4 : 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _askQuickQuestion(String question) {
    _questionController.text = question;
    _submitQuestion();
  }

  void _copyResponse() {
    if (_response.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _response));
      _showSnackBar(
        _useCreole ? 'Resposta kopiadu!' : 'Resposta copiada!',
        isError: false,
      );
    }
  }

  Widget _buildResponseCard() => FadeTransition(
        opacity: _fadeAnimation,
        child: Card(
          elevation: 8,
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      _responseSource.contains('Fallback') ||
                              _responseSource.contains('Erro')
                          ? Icons.warning
                          : Icons.psychology,
                      color: _responseSource.contains('Fallback') ||
                              _responseSource.contains('Erro')
                          ? Colors.orange
                          : Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _responseSource,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    if (_responseTime > 0)
                      Chip(
                        label: Text('${_responseTime.toStringAsFixed(1)}s'),
                        backgroundColor: _responseTime < 30
                            ? Colors.green[100]
                            : _responseTime < 60
                                ? Colors.yellow[100]
                                : Colors.red[100],
                      ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: _copyResponse,
                      tooltip:
                          _useCreole ? 'Kopia resposta' : 'Copiar resposta',
                    ),
                  ],
                ),
                const Divider(),
                Text(
                  _response,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
              ],
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            _useCreole ? 'Agrikultura AI' : 'Agricultura AI',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.green[700],
          foregroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(_useCreole ? Icons.language : Icons.translate),
              onPressed: () {
                setState(() {
                  _useCreole = !_useCreole;
                });
              },
              tooltip: _useCreole ? 'Mudar pa Portugués' : 'Mudar para Crioulo',
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.green[700]!,
                Colors.green[50]!,
              ],
            ),
          ),
          child: Column(
            children: [
              // Formulário de pergunta
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seleção de cultura
                    Text(
                      _useCreole ? 'Kultura:' : 'Cultura:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCropType,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: _cropTypes.map((crop) => DropdownMenuItem<String>(
                          value: crop['key'],
                          child:
                              Text(crop[_useCreole ? 'crioulo' : 'pt'] ?? ''),
                        )).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCropType = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Seleção de época
                    Text(
                      _useCreole ? 'Tempu:' : 'Época:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedSeason,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: _seasons.map((season) => DropdownMenuItem<String>(
                          value: season['key'],
                          child:
                              Text(season[_useCreole ? 'crioulo' : 'pt'] ?? ''),
                        )).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSeason = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Campo de pergunta
                    Text(
                      _useCreole ? 'Su pergunta:' : 'Sua pergunta:',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _questionController,
                      decoration: InputDecoration(
                        hintText: _useCreole
                            ? 'Skrive su pergunta kí...'
                            : 'Escreva sua pergunta aqui...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.all(12),
                      ),
                      maxLines: 3,
                      enabled: !_isLoading,
                    ),
                    const SizedBox(height: 16),

                    // Botão de envio
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _submitQuestion,
                        icon: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.green[700]!,
                                  ),
                                ),
                              )
                            : const Icon(Icons.send),
                        label: Text(
                          _isLoading
                              ? (_useCreole
                                  ? 'Processando...'
                                  : 'Processando...')
                              : (_useCreole
                                  ? 'Manda Pergunta'
                                  : 'Enviar Pergunta'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[700],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Perguntas rápidas
              if (!_isLoading) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    _useCreole ? 'Pergunta ligeru:' : 'Perguntas rápidas:',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      _buildQuickButton(
                        _useCreole ? 'Modi planta?' : 'Como plantar?',
                      ),
                      _buildQuickButton(
                        _useCreole
                            ? 'Kuma trata doensa?'
                            : 'Como tratar doenças?',
                      ),
                      _buildQuickButton(
                        _useCreole
                            ? 'Tempu di kolheita?'
                            : 'Tempo de colheita?',
                      ),
                      _buildQuickButton(
                        _useCreole ? 'Kuma rega?' : 'Como regar?',
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Resposta
              if (_response.isNotEmpty)
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildResponseCard(),
                  ),
                ),
            ],
          ),
        ),
      );

  Widget _buildQuickButton(String text) => Container(
        margin: const EdgeInsets.only(right: 8),
        child: ElevatedButton(
          onPressed: () => _askQuickQuestion(text),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: Colors.green[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(text),
        ),
      );
}
