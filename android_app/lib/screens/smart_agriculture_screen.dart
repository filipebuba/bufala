import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../config/app_config.dart';
import '../services/environmental_api_service.dart';
import '../services/integrated_api_service.dart';
import 'agriculture_helpers.dart';

class SmartAgricultureScreen extends StatefulWidget {
  const SmartAgricultureScreen({super.key});

  @override
  State<SmartAgricultureScreen> createState() => _SmartAgricultureScreenState();
}

class _SmartAgricultureScreenState extends State<SmartAgricultureScreen>
    with TickerProviderStateMixin {
  final IntegratedApiService _apiService = IntegratedApiService();
  final EnvironmentalApiService _environmentalApiService =
      EnvironmentalApiService(baseUrl: AppConfig.apiBaseUrl);
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

  // Alertas ambientais do Gemma 3 - Sistema Avançado
  List<Map<String, dynamic>> _environmentalAlerts = [];
  List<Map<String, dynamic>> _predictiveAlerts = [];
  List<Map<String, dynamic>> _cropSpecificAlerts = [];
  Map<String, dynamic> _weatherForecast = {};
  List<Map<String, dynamic>> _soilConditions = [];
  bool _loadingAlerts = false;
  final bool _loadingPredictive = false;
  bool _alertsExpanded = false;
  final String _selectedAlertFilter = 'todos';
  DateTime _lastAlertUpdate = DateTime.now();
  Timer? _alertTimer;

  // Perguntas rápidas
  final Map<String, List<String>> _quickQuestions = {
    'pt': [
      'Como preparar o solo para plantio?',
      'Qual a melhor época para plantar arroz?',
      'Como combater pragas naturalmente?',
      'Quando devo irrigar as plantas?',
    ],
    'crioulo': [
      'Kuma prepara tera pa planta?',
      'Kal tempu bon pa planta aros?',
      'Kuma kombate praga natural?',
      'Kuandu misti rega planta?',
    ],
  };

  // Dados das culturas
  final List<Map<String, String>> _cropTypes = [
    {'key': 'arroz', 'pt': 'Arroz', 'crioulo': 'Aros', 'icon': '🌾'},
    {'key': 'milho', 'pt': 'Milho', 'crioulo': 'Milho', 'icon': '🌽'},
    {'key': 'caju', 'pt': 'Caju', 'crioulo': 'Kaju', 'icon': '🥜'},
    {'key': 'amendoim', 'pt': 'Amendoim', 'crioulo': 'Amendoim', 'icon': '🥜'},
    {'key': 'mandioca', 'pt': 'Mandioca', 'crioulo': 'Mandioka', 'icon': '🍠'},
    {
      'key': 'hortaliças',
      'pt': 'Hortaliças',
      'crioulo': 'Hortalisas',
      'icon': '🥬'
    },
    {'key': 'tomate', 'pt': 'Tomate', 'crioulo': 'Tomate', 'icon': '🍅'},
    {'key': 'alface', 'pt': 'Alface', 'crioulo': 'Alfase', 'icon': '🥬'},
  ];

  final List<Map<String, String>> _seasons = [
    {
      'key': 'chuva',
      'pt': 'Época das Chuvas',
      'crioulo': 'Tempu di Chuva',
      'icon': '🌧️'
    },
    {'key': 'seca', 'pt': 'Época Seca', 'crioulo': 'Tempu Seku', 'icon': '☀️'},
    {
      'key': 'transição',
      'pt': 'Transição',
      'crioulo': 'Transison',
      'icon': '🌤️'
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadEnvironmentalAlerts();
    _setupAlertTimer();
  }

  void _initializeAnimations() {
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _pulseAnimationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeAnimationController, curve: Curves.easeIn),
    );
    _pulseAnimation = Tween<double>(begin: 1, end: 1.1).animate(
      CurvedAnimation(
          parent: _pulseAnimationController, curve: Curves.easeInOut),
    );

    _fadeAnimationController.forward();
    _pulseAnimationController.repeat(reverse: true);
  }

  void _setupAlertTimer() {
    _alertTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _loadEnvironmentalAlerts();
    });
  }

  @override
  void dispose() {
    _alertTimer?.cancel();
    _questionController.dispose();
    _scrollController.dispose();
    _fadeAnimationController.dispose();
    _pulseAnimationController.dispose();
    super.dispose();
  }

  Future<void> _loadEnvironmentalAlerts() async {
    if (_loadingAlerts) return;

    setState(() {
      _loadingAlerts = true;
    });

    try {
      final alerts = await _environmentalApiService.getEnvironmentalAlerts();

      setState(() {
        _environmentalAlerts = alerts.cast<Map<String, dynamic>>();
        _predictiveAlerts = [];
        _cropSpecificAlerts = [];
        _weatherForecast = {};
        _soilConditions = [];
        _lastAlertUpdate = DateTime.now();
      });
    } catch (e) {
      debugPrint('Erro ao carregar alertas: $e');
    } finally {
      setState(() {
        _loadingAlerts = false;
      });
    }
  }

  Future<void> _submitQuestion() async {
    final question = _questionController.text.trim();
    if (question.isEmpty || _isLoading) return;

    setState(() {
      _isLoading = true;
      _conversationHistory.add(ConversationItem(
        text: question,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });

    _questionController.clear();
    _scrollToBottom();

    try {
      final stopwatch = Stopwatch()..start();

      final response = await _apiService.askAgricultureQuestion(
        question,
        language: _useCreole ? 'crioulo' : 'pt-BR',
        cropType: _selectedCropType,
        season: _selectedSeason,
      );

      stopwatch.stop();

      setState(() {
        _response = response['response'] ?? 'Resposta não disponível';
        _responseSource = response['source'] ?? 'Desconhecido';
        _responseTime = stopwatch.elapsedMilliseconds / 1000.0;
        _confidence = response['confidence']?.toDouble() ?? 0.0;

        _conversationHistory.add(ConversationItem(
          text: _response,
          isUser: false,
          timestamp: DateTime.now(),
          source: _responseSource,
          responseTime: _responseTime,
          confidence: _confidence,
        ));
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _conversationHistory.add(ConversationItem(
          text: _useCreole
              ? 'Erro na konsulta. Tenta denovu.'
              : 'Erro na consulta. Tente novamente.',
          isUser: false,
          timestamp: DateTime.now(),
          isError: true,
        ));
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _askQuickQuestion(String question) {
    _questionController.text = question;
    _submitQuestion();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Colors.green[50],
        appBar: AppBar(
          title: Text(
            _useCreole ? 'Agrikultura Intelijenti' : 'Agricultura Inteligente',
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
              tooltip:
                  _useCreole ? 'Mudar para Português' : 'Mudar para Crioulo',
            )
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Controles superiores
              _buildControlsSection(),
              // Alertas ambientais - limitado em altura
              Flexible(
                flex: 0,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: SingleChildScrollView(
                    child: _buildAlertsSection(),
                  ),
                ),
              ),
              // Área de conversa
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: _conversationHistory.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.agriculture,
                                size: 64,
                                color: Colors.green,
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Faça sua pergunta sobre agricultura',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _conversationHistory.length,
                          itemBuilder: (context, index) {
                            final item = _conversationHistory[index];
                            return _buildConversationItem(item);
                          },
                        ),
                ),
              ),
              // Área de input
              _buildInputArea(),
            ],
          ),
        ),
      );

  Widget _buildControlsSection() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(25),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildCropSelector(),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSeasonSelector(),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildCropSelector() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedCropType,
            isExpanded: true,
            items: _cropTypes.map((crop) {
              return DropdownMenuItem<String>(
                value: crop['key'],
                child: Row(
                  children: [
                    Text(crop['icon']!, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Text(
                      _useCreole ? crop['crioulo']! : crop['pt']!,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedCropType = value;
                });
                _loadEnvironmentalAlerts();
              }
            },
          ),
        ),
      );

  Widget _buildSeasonSelector() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedSeason,
            isExpanded: true,
            items: _seasons.map((season) {
              return DropdownMenuItem<String>(
                value: season['key'],
                child: Row(
                  children: [
                    Text(season['icon']!, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        _useCreole ? season['crioulo']! : season['pt']!,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedSeason = value;
                });
                _loadEnvironmentalAlerts();
              }
            },
          ),
        ),
      );

  Widget _buildAlertsSection() {
    if (_environmentalAlerts.isEmpty &&
        _predictiveAlerts.isEmpty &&
        !_loadingAlerts) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.warning_amber,
              color: Colors.orange[700],
            ),
            title: Text(
              _useCreole ? 'Alerta Ambiental' : 'Alertas Ambientais',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange[700],
              ),
            ),
            trailing: IconButton(
              icon: Icon(
                _alertsExpanded ? Icons.expand_less : Icons.expand_more,
              ),
              onPressed: () {
                setState(() {
                  _alertsExpanded = !_alertsExpanded;
                });
              },
            ),
          ),
          if (_alertsExpanded) ..._buildExpandedAlerts(),
        ],
      ),
    );
  }

  List<Widget> _buildExpandedAlerts() {
    var widgets = <Widget>[];

    if (_loadingAlerts) {
      widgets.add(
        const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    } else {
      // Alertas tradicionais
      if (_environmentalAlerts.isNotEmpty) {
        widgets.add(_buildAlertsList('Tradicionais', _environmentalAlerts));
      }

      // Alertas preditivos
      if (_predictiveAlerts.isNotEmpty) {
        widgets.add(_buildAlertsList('Preditivos', _predictiveAlerts));
      }

      // Alertas específicos da cultura
      if (_cropSpecificAlerts.isNotEmpty) {
        widgets.add(_buildAlertsList('Específicos', _cropSpecificAlerts));
      }
    }

    return widgets;
  }

  Widget _buildAlertsList(String title, List<Map<String, dynamic>> alerts) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            ...alerts.map((alert) => _buildAlertCard(alert)).toList(),
          ],
        ),
      );

  Widget _buildAlertCard(Map<String, dynamic> alert) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              alert['title'] as String? ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              alert['description'] as String? ?? '',
              style: const TextStyle(fontSize: 11),
            ),
            if (alert['severity'] != null)
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _getSeverityColor(alert['severity'] as String? ?? ''),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  alert['severity'] as String? ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      );

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'alta':
      case 'high':
        return Colors.red;
      case 'média':
      case 'medium':
        return Colors.orange;
      case 'baixa':
      case 'low':
        return Colors.yellow[700]!;
      default:
        return Colors.grey;
    }
  }

  Widget _buildConversationItem(ConversationItem item) => Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor:
                  item.isUser ? Colors.blue[100] : Colors.green[100],
              child: Icon(
                item.isUser ? Icons.person : Icons.agriculture,
                size: 16,
                color: item.isUser ? Colors.blue[700] : Colors.green[700],
              ),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: item.isUser
                          ? Colors.blue[50]
                          : item.isError
                              ? Colors.red[50]
                              : Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: item.isUser
                            ? Colors.blue[200]!
                            : item.isError
                                ? Colors.red[200]!
                                : Colors.green[200]!,
                      ),
                    ),
                    child: Text(
                      item.text,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  if (!item.isUser && !item.isError) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (item.source != null) ...[
                          Icon(
                            Icons.source,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            item.source!,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        if (item.responseTime != null) ...[
                          Icon(
                            Icons.timer,
                            size: 12,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${item.responseTime!.toStringAsFixed(1)}s',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('HH:mm').format(item.timestamp),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildInputArea() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(25),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, -1),
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
            if (_conversationHistory.isEmpty) const SizedBox(height: 12),
            if (_conversationHistory.isEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: (_quickQuestions[_useCreole ? 'crioulo' : 'pt'] ??
                          [])
                      .take(3)
                      .map((question) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () => _askQuickQuestion(question),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green[100],
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.green[300]!),
                                ),
                                child: Text(
                                  question,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ))
                      .toList(),
                ),
              ),
          ],
        ),
      );
}
