import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'services/modular_backend_service.dart';
import 'services/enhanced_api_service.dart';
import 'services/connection_state.dart';

/// Tela de teste de conectividade com o backend Bu Fala
class ConnectionTestScreen extends StatefulWidget {
  @override
  _ConnectionTestScreenState createState() => _ConnectionTestScreenState();
}

class _ConnectionTestScreenState extends State<ConnectionTestScreen> {
  final ApiService _apiService = ApiService();
  final ModularBackendService _modularService = ModularBackendService();
  final EnhancedApiService _enhancedService = EnhancedApiService();
  final ConnectionMonitor _monitor = ConnectionMonitor();
  
  String _connectionStatus = 'Não testado';
  String _lastError = '';
  bool _isLoading = false;
  Map<String, dynamic> _testResults = {};

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  void _startMonitoring() {
    _monitor.startMonitoring();
    _monitor.connectionStream.listen((state) {
      if (mounted) {
        setState(() {
          _connectionStatus = state.isConnected ? 'Conectado' : 'Desconectado';
          _lastError = state.lastError ?? '';
        });
      }
    });
  }

  Future<void> _testAllConnections() async {
    setState(() {
      _isLoading = true;
      _testResults.clear();
    });

    try {
      // Teste 1: Conectividade básica
      final hasInternet = await _apiService.hasInternetConnection();
      _testResults['internet'] = hasInternet;

      // Teste 2: Health check do backend
      final healthCheck = await _apiService.healthCheck();
      _testResults['backend_health'] = healthCheck;

      // Teste 3: Teste de consulta médica
      final medicalTest = await _apiService.askMedicalQuestion(
        'Teste de conectividade médica',
        language: 'pt-BR',
      );
      _testResults['medical_query'] = medicalTest != null;

      // Teste 4: Teste de consulta educacional
      final educationTest = await _apiService.askEducationQuestion(
        'Teste de conectividade educacional',
        language: 'pt-BR',
      );
      _testResults['education_query'] = educationTest != null;

      // Teste 5: Teste de consulta agrícola
      final agricultureTest = await _apiService.askAgricultureQuestion(
        'Teste de conectividade agrícola',
        language: 'pt-BR',
      );
      _testResults['agriculture_query'] = agricultureTest != null;

      // Teste 6: Teste do serviço modular
      await _modularService.initialize();
      final modularHealth = await _modularService.healthCheck();
      _testResults['modular_service'] = modularHealth;

      // Teste 7: Teste do serviço aprimorado
      await _enhancedService.initialize();
      final enhancedHealth = await _enhancedService.healthCheck();
      _testResults['enhanced_service'] = enhancedHealth;

    } catch (e) {
      setState(() {
        _lastError = 'Erro durante os testes: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Teste de Conectividade Bu Fala'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status da conexão
            Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status da Conexão',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          _connectionStatus == 'Conectado'
                              ? Icons.check_circle
                              : Icons.error,
                          color: _connectionStatus == 'Conectado'
                              ? Colors.green
                              : Colors.red,
                        ),
                        SizedBox(width: 8),
                        Text(_connectionStatus),
                      ],
                    ),
                    if (_lastError.isNotEmpty) ..[
                      SizedBox(height: 8),
                      Text(
                        'Último erro: $_lastError',
                        style: TextStyle(color: Colors.red, fontSize: 12),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Botão de teste
            ElevatedButton(
              onPressed: _isLoading ? null : _testAllConnections,
              child: _isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Testando...'),
                      ],
                    )
                  : Text('Testar Todas as Conexões'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Resultados dos testes
            if (_testResults.isNotEmpty)
              Expanded(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resultados dos Testes',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Expanded(
                          child: ListView(
                            children: _testResults.entries.map((entry) {
                              final isSuccess = entry.value == true;
                              return ListTile(
                                leading: Icon(
                                  isSuccess ? Icons.check : Icons.close,
                                  color: isSuccess ? Colors.green : Colors.red,
                                ),
                                title: Text(_getTestName(entry.key)),
                                subtitle: Text(
                                  isSuccess ? 'Sucesso' : 'Falha',
                                  style: TextStyle(
                                    color: isSuccess ? Colors.green : Colors.red,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getTestName(String key) {
    switch (key) {
      case 'internet':
        return 'Conectividade com Internet';
      case 'backend_health':
        return 'Health Check do Backend';
      case 'medical_query':
        return 'Consulta Médica';
      case 'education_query':
        return 'Consulta Educacional';
      case 'agriculture_query':
        return 'Consulta Agrícola';
      case 'modular_service':
        return 'Serviço Modular';
      case 'enhanced_service':
        return 'Serviço Aprimorado';
      default:
        return key;
    }
  }

  @override
  void dispose() {
    _monitor.stopMonitoring();
    super.dispose();
  }
}

/// Widget principal para executar o teste
class ConnectionTestApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bu Fala Connection Test',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ConnectionTestScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

/// Função main para executar apenas o teste de conectividade
void main() {
  runApp(ConnectionTestApp());
}