import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/smart_api_service.dart';

class SmartAgricultureScreen extends StatefulWidget {
  const SmartAgricultureScreen({super.key});

  @override
  State<SmartAgricultureScreen> createState() => _SmartAgricultureScreenState();
}

class _SmartAgricultureScreenState extends State<SmartAgricultureScreen> 
    with TickerProviderStateMixin {
  final SmartApiService _smartApiService = SmartApiService();
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  
  late AnimationController _fadeAnimationController;
  late AnimationController _pulseAnimationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  // Estado da aplicação
  String _selectedCropType = 'arroz';
  String _selectedSeason = 'chuva';
  bool _useCreole = false;
  bool _isLoading = false;
  
  // Estado da resposta
  String _response = '';
  String _responseSource = '';
  double _responseTime = 0;
  double _confidence = 0;
  
  // Histórico de perguntas
  final List<ConversationItem> _conversationHistory = [];

  // Dados das culturas
  final List<Map<String, String>> _cropTypes = [
    {'key': 'arroz', 'pt': 'Arroz', 'crioulo': 'Aros', 'icon': '🌾'},
    {'key': 'milho', 'pt': 'Milho', 'crioulo': 'Milho', 'icon': '🌽'},
    {'key': 'caju', 'pt': 'Caju', 'crioulo': 'Kaju', 'icon': '🥜'},
    {'key': 'amendoim', 'pt': 'Amendoim', 'crioulo': 'Amendoim', 'icon': '🥜'},
    {'key': 'mandioca', 'pt': 'Mandioca', 'crioulo': 'Mandioka', 'icon': '🍠'},
    {'key': 'hortaliças', 'pt': 'Hortaliças', 'crioulo': 'Hortalisas', 'icon': '🥬'},
    {'key': 'tomate', 'pt': 'Tomate', 'crioulo': 'Tomate', 'icon': '🍅'},
    {'key': 'alface', 'pt': 'Alface', 'crioulo': 'Alfase', 'icon': '🥬'},
  ];

  final List<Map<String, String>> _seasons = [
    {'key': 'chuva', 'pt': 'Época das Chuvas', 'crioulo': 'Tempu di Chuva', 'icon': '🌧️'},
    {'key': 'seca', 'pt': 'Época Seca', 'crioulo': 'Tempu Seku', 'icon': '☀️'},
    {'key': 'transição', 'pt': 'Transição', 'crioulo': 'Transison', 'icon': '🌤️'},
  ];

  // Perguntas rápidas
  final Map<String, List<String>> _quickQuestions = {
    'pt': [
      'Como plantar arroz na época das chuvas?',
      'Qual o melhor fertilizante para milho?',
      'Como controlar pragas no caju?',
      'Quando é a melhor época para plantar mandioca?',
      'Como preparar o solo para hortaliças?',
      'Qual a quantidade de água ideal para tomate?',
    ],
    'crioulo': [
      'Kuma planta aros na tempu di chuva?',
      'Kual fertilizanti melhor pa milho?',
      'Kuma kontrola praga na kaju?',
      'Kuand ki tempu melhor pa planta mandioka?',
      'Kuma prepara tera pa hortalisas?',
      'Kual kantidade di awa bon pa tomate?',
    ],
  };

  @override
  void initState() {
    super.initState();
    
    // Configurar animações
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeInOut),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseAnimationController, curve: Curves.easeInOut),
    );
    
    // Iniciar animação de pulso
    _pulseAnimationController.repeat(reverse: true);
    
    // Verificar conectividade
    _checkConnectivity();
  }

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    _fadeAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    final hasConnection = await _smartApiService.hasInternetConnection();
    if (!hasConnection) {
      _showSnackBar(
        _useCreole ? 'Sem internet - uza modo offline' : 'Sem internet - usando modo offline',
        isError: true,
      );
    }
  }

  Future<void> _submitQuestion() async {
    if (_questionController.text.trim().isEmpty) {
      _showSnackBar(
        _useCreole ? 'Pergunta nan podi ta vazi' : 'Pergunta não pode estar vazia',
        isError: true,
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _response = '';
      _responseSource = '';
      _responseTime = 0.0;
      _confidence = 0.0;
    });

    // Adicionar pergunta ao histórico
    _conversationHistory.add(ConversationItem(
      type: ConversationItemType.question,
      content: _questionController.text.trim(),
      timestamp: DateTime.now(),
    ));

    final stopwatch = Stopwatch()..start();

    try {
      // Preparar pergunta contextualizada
      final contextualizedQuestion = _buildContextualizedQuestion();
      
      print('[🌱 SMART-AGRI] Enviando pergunta: $contextualizedQuestion');

      final response = await _smartApiService.askAgricultureQuestion(
        question: contextualizedQuestion,
        language: _useCreole ? 'crioulo-gb' : 'pt-BR',
        cropType: _selectedCropType,
        season: _selectedSeason,
      );

      stopwatch.stop();
      final totalTime = stopwatch.elapsedMilliseconds / 1000.0;

      setState(() {
        if (response.success && response.data != null) {
          _response = response.data!;
          _responseSource = response.source;
          _responseTime = response.responseTime > 0 ? response.responseTime : totalTime;
          _confidence = response.confidence;
          
          // Adicionar resposta ao histórico
          _conversationHistory.add(ConversationItem(
            type: ConversationItemType.answer,
            content: _response,
            source: _responseSource,
            responseTime: _responseTime,
            confidence: _confidence,
            timestamp: DateTime.now(),
          ));
          
          _showSnackBar(
            _useCreole ? 'Resposta resebi!' : 'Resposta recebida!',
            isError: false,
          );
          
          _fadeAnimationController.forward();
          
        } else {
          final errorMsg = response.error ?? 'Erro desconhecido';
          _response = _useCreole ? 'Erro: $errorMsg' : 'Erro: $errorMsg';
          _responseSource = 'Sistema de Erro';
          _responseTime = totalTime;
          _confidence = 0.0;
          
          _showSnackBar(_response, isError: true);
        }
      });
    } catch (e) {
      stopwatch.stop();
      setState(() {
        _response = _useCreole ? 'Erro na konekson: $e' : 'Erro de conexão: $e';
        _responseSource = 'Erro de Conectividade';
        _responseTime = stopwatch.elapsedMilliseconds / 1000.0;
        _confidence = 0.0;
      });
      _showSnackBar(_response, isError: true);
    } finally {
      setState(() {
        _isLoading = false;
      });
      
      // Limpar campo de pergunta
      _questionController.clear();
      
      // Scroll para a resposta
      _scrollToBottom();
    }
  }

  String _buildContextualizedQuestion() {
    final cropName = _getCropName();
    final seasonName = _getSeasonName();
    
    final context = _useCreole
        ? 'Na Guiné-Bissau, na tempu di $seasonName pa kultura di $cropName:'
        : 'Na Guiné-Bissau, na época $seasonName para cultivo de $cropName:';

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

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _askQuickQuestion(String question) {
    _questionController.text = question;
    _submitQuestion();
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    _showSnackBar(
      _useCreole ? 'Tekstu kopiadu!' : 'Texto copiado!',
      isError: false,
    );
  }

  void _clearHistory() {
    setState(() {
      _conversationHistory.clear();
      _response = '';
      _responseSource = '';
      _responseTime = 0.0;
      _confidence = 0.0;
    });
    _fadeAnimationController.reset();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: Text(_useCreole ? 'Konsulta Agrikultura' : 'Consulta Agrícola'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(_useCreole ? Icons.language : Icons.translate),
            onPressed: () {
              setState(() {
                _useCreole = !_useCreole;
              });
              _showSnackBar(
                _useCreole ? 'Mudadu pa kriol' : 'Mudado para português',
                isError: false,
              );
            },
            tooltip: _useCreole ? 'Mudar para português' : 'Mudar pa kriol',
          ),
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: _clearHistory,
            tooltip: _useCreole ? 'Limpa historia' : 'Limpar histórico',
          ),
        ],
      ),
      body: Column(
        children: [
          // Configurações superiores
          _buildConfigurationPanel(),
          
          // Área de conversa
          Expanded(
            child: _buildConversationArea(),
          ),
          
          // Área de entrada
          _buildInputArea(),
        ],
      ),
    );

  Widget _buildConfigurationPanel() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Seletor de cultura
          Row(
            children: [
              Text(
                _useCreole ? 'Kultura:' : 'Cultura:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCropType,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _cropTypes.map((crop) => DropdownMenuItem<String>(
                      value: crop['key'],
                      child: Row(
                        children: [
                          Text(crop['icon'] ?? '🌱'),
                          const SizedBox(width: 8),
                          Text(crop[_useCreole ? 'crioulo' : 'pt'] ?? crop['key']!),
                        ],
                      ),
                    )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCropType = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Seletor de época
          Row(
            children: [
              Text(
                _useCreole ? 'Tempu:' : 'Época:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSeason,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _seasons.map((season) => DropdownMenuItem<String>(
                      value: season['key'],
                      child: Row(
                        children: [
                          Text(season['icon'] ?? '📅'),
                          const SizedBox(width: 8),
                          Text(season[_useCreole ? 'crioulo' : 'pt'] ?? season['key']!),
                        ],
                      ),
                    )).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSeason = value!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );

  Widget _buildConversationArea() => Container(
      padding: const EdgeInsets.all(16),
      child: _conversationHistory.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              controller: _scrollController,
              itemCount: _conversationHistory.length,
              itemBuilder: (context, index) {
                final item = _conversationHistory[index];
                return _buildConversationItem(item);
              },
            ),
    );

  Widget _buildEmptyState() => Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: Icon(
              Icons.agriculture,
              size: 80,
              color: Colors.green[300],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            _useCreole
                ? 'Faça sua pergunta sobre agricultura'
                : 'Fasa bo pergunta riba agrikultura',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildQuickQuestions(),
        ],
      ),
    );

  Widget _buildQuickQuestions() {
    final questions = _quickQuestions[_useCreole ? 'crioulo' : 'pt'] ?? [];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _useCreole ? 'Pergunta rapidu:' : 'Perguntas rápidas:',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: questions.take(4).map((question) => GestureDetector(
              onTap: () => _askQuickQuestion(question),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green[300]!),
                ),
                child: Text(
                  question,
                  style: TextStyle(
                    color: Colors.green[800],
                    fontSize: 12,
                  ),
                ),
              ),
            )).toList(),
        ),
      ],
    );
  }

  Widget _buildConversationItem(ConversationItem item) => Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: item.type == ConversationItemType.question
          ? _buildQuestionBubble(item)
          : _buildAnswerBubble(item),
    );

  Widget _buildQuestionBubble(ConversationItem item) => Align(
      alignment: Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              item.content,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(item.timestamp),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );

  Widget _buildAnswerBubble(ConversationItem item) => FadeTransition(
      opacity: _fadeAnimation,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.9),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabeçalho da resposta
              Row(
                children: [
                  Icon(
                    _getSourceIcon(item.source),
                    color: _getSourceColor(item.source),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.source,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  if (item.responseTime > 0)
                    _buildTimeChip(item.responseTime),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 18),
                    onPressed: () => _copyToClipboard(item.content),
                    tooltip: _useCreole ? 'Kopia' : 'Copiar',
                  ),
                ],
              ),
        
              // Indicador de confiança
              if (item.confidence > 0)
                _buildConfidenceIndicator(item.confidence),
              
              const Divider(),
              
              // Conteúdo da resposta
              Text(
                item.content,
                style: const TextStyle(fontSize: 16, height: 1.5),
              ),
              
              const SizedBox(height: 8),
              
              // Timestamp
              Text(
                _formatTime(item.timestamp),
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );

  Widget _buildTimeChip(double responseTime) {
    Color chipColor;
    if (responseTime < 30) {
      chipColor = Colors.green;
    } else if (responseTime < 60) {
      chipColor = Colors.yellow[700]!;
    } else {
      chipColor = Colors.red;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),        decoration: BoxDecoration(
          color: chipColor.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: chipColor.withValues(alpha: 0.5)),
        ),
      child: Text(
        '${responseTime.toStringAsFixed(1)}s',
        style: TextStyle(
          fontSize: 12,
          color: chipColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildConfidenceIndicator(double confidence) => Container(
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Text(
            _useCreole ? 'Konfiansa:' : 'Confiança:',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: confidence,
              backgroundColor: Colors.grey[300],
              color: _getConfidenceColor(confidence),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '${(confidence * 100).toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 12,
              color: _getConfidenceColor(confidence),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

  IconData _getSourceIcon(String source) {
    if (source.contains('Docs Gemma')) return Icons.psychology;
    if (source.contains('Improved Gemma')) return Icons.smart_toy;
    if (source.contains('Fallback') || source.contains('Emergência')) return Icons.warning;
    if (source.contains('Erro')) return Icons.error;
    return Icons.assistant;
  }

  Color _getSourceColor(String source) {
    if (source.contains('Docs Gemma')) return Colors.green;
    if (source.contains('Improved Gemma')) return Colors.blue;
    if (source.contains('Fallback') || source.contains('Emergência')) return Colors.orange;
    if (source.contains('Erro')) return Colors.red;
    return Colors.grey;
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.6) return Colors.yellow[700]!;
    if (confidence >= 0.4) return Colors.orange;
    return Colors.red;
  }

  String _formatTime(DateTime timestamp) => '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';

  Widget _buildInputArea() => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Campo de entrada
          TextField(
            controller: _questionController,
            maxLines: 3,
            minLines: 1,
            decoration: InputDecoration(
              hintText: _useCreole
                  ? 'Faça bo pergunta riba agrikultura...'
                  : 'Faça sua pergunta sobre agricultura...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              filled: true,
              fillColor: Colors.grey[50],
              suffixIcon: _isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: _submitQuestion,
                    ),
            ),
            onSubmitted: (_) => _submitQuestion(),
            enabled: !_isLoading,
          ),
          
          // Perguntas rápidas na área de input
          if (_conversationHistory.isEmpty)
            const SizedBox(height: 12),
          if (_conversationHistory.isEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: (_quickQuestions[_useCreole ? 'crioulo' : 'pt'] ?? [])
                    .take(3)
                    .map((question) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => _askQuickQuestion(question),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Text(
                          question.length > 30 ? '${question.substring(0, 30)}...' : question,
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  )).toList(),
              ),
            ),
        ],
      ),
    );
}

// Classes auxiliares
class ConversationItem {

  ConversationItem({
    required this.type,
    required this.content,
    required this.timestamp, this.source = '',
    this.responseTime = 0.0,
    this.confidence = 0.0,
  });
  final ConversationItemType type;
  final String content;
  final String source;
  final double responseTime;
  final double confidence;
  final DateTime timestamp;
}

enum ConversationItemType {
  question,
  answer,
}
