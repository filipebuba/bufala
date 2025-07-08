import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const BackendTestApp());
}

class BackendTestApp extends StatelessWidget {
  const BackendTestApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
      title: 'Bu Fala Backend Test',
      home: BackendTestScreen(),
    );
}

class BackendTestScreen extends StatefulWidget {
  const BackendTestScreen({super.key});

  @override
  State<BackendTestScreen> createState() => _BackendTestScreenState();
}

class _BackendTestScreenState extends State<BackendTestScreen> {
  final Dio _dio = Dio();
  static const String _baseUrl = 'http://10.0.2.2:5000'; // Para emulador
  final List<String> _testResults = [];
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _dio.options.baseUrl = _baseUrl;
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 30);
  }

  void _addResult(String result) {
    setState(() {
      _testResults.add(result);
    });
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isRunning = true;
      _testResults.clear();
    });

    _addResult('🧪 Iniciando testes de comunicação...\n');

    // Test 1: Health Check
    await _testHealthEndpoint();

    // Test 2: Medical Endpoint
    await _testMedicalEndpoint();

    // Test 3: Education Endpoint
    await _testEducationEndpoint();

    // Test 4: Agriculture Endpoint
    await _testAgricultureEndpoint();

    // Test 5: Translation Endpoint
    await _testTranslationEndpoint();

    // Test 6: Multimodal Endpoint
    await _testMultimodalEndpoint();

    _addResult('\n✅ Todos os testes concluídos!');

    setState(() {
      _isRunning = false;
    });
  }

  Future<void> _testHealthEndpoint() async {
    try {
      _addResult('🏥 Testando /health...');
      final response = await _dio.get<Map<String, dynamic>>('/health');

      if (response.statusCode == 200) {
        final data = response.data!;
        _addResult('✅ /health OK - Backend: ${data['backend']}');
        _addResult('📊 Status: ${data['status']}');
        _addResult('🤖 Modelo: ${data['model']}\n');
      } else {
        _addResult('❌ /health ERRO: ${response.statusCode}\n');
      }
    } catch (e) {
      _addResult('❌ /health FALHOU: $e\n');
    }
  }

  Future<void> _testMedicalEndpoint() async {
    try {
      _addResult('🏥 Testando /medical...');
      final response = await _dio.post<Map<String, dynamic>>(
        '/medical',
        data: {'question': 'Como tratar febre?', 'language': 'pt-BR'},
      );

      if (response.statusCode == 200) {
        final data = response.data!;
        final answer = data['answer'] as String?;
        _addResult('✅ /medical OK');
        _addResult('📝 Resposta: ${answer?.substring(0, 80)}...\n');
      } else {
        _addResult('❌ /medical ERRO: ${response.statusCode}\n');
      }
    } catch (e) {
      _addResult('❌ /medical FALHOU: $e\n');
    }
  }

  Future<void> _testEducationEndpoint() async {
    try {
      _addResult('📚 Testando /education...');
      final response = await _dio.post<Map<String, dynamic>>(
        '/education',
        data: {
          'question': 'Ensine sobre matemática básica',
          'subject': 'matemática',
          'level': 'básico',
          'language': 'pt-BR'
        },
      );

      if (response.statusCode == 200) {
        final data = response.data!;
        final answer = data['answer'] as String?;
        _addResult('✅ /education OK');
        _addResult('📝 Resposta: ${answer?.substring(0, 80)}...\n');
      } else {
        _addResult('❌ /education ERRO: ${response.statusCode}\n');
      }
    } catch (e) {
      _addResult('❌ /education FALHOU: $e\n');
    }
  }

  Future<void> _testAgricultureEndpoint() async {
    try {
      _addResult('🌱 Testando /agriculture...');
      final response = await _dio.post<Map<String, dynamic>>(
        '/agriculture',
        data: {
          'question': 'Como plantar arroz?',
          'crop_type': 'arroz',
          'language': 'pt-BR'
        },
      );

      if (response.statusCode == 200) {
        final data = response.data!;
        final answer = data['answer'] as String?;
        _addResult('✅ /agriculture OK');
        _addResult('📝 Resposta: ${answer?.substring(0, 80)}...\n');
      } else {
        _addResult('❌ /agriculture ERRO: ${response.statusCode}\n');
      }
    } catch (e) {
      _addResult('❌ /agriculture FALHOU: $e\n');
    }
  }

  Future<void> _testTranslationEndpoint() async {
    try {
      _addResult('🌐 Testando /translate...');
      final response = await _dio.post<Map<String, dynamic>>(
        '/translate',
        data: {
          'text': 'Olá, como você está?',
          'from_language': 'pt-BR',
          'to_language': 'en'
        },
      );

      if (response.statusCode == 200) {
        final data = response.data!;
        final translated = data['translated'] as String?;
        _addResult('✅ /translate OK');
        _addResult('📝 Tradução: $translated\n');
      } else {
        _addResult('❌ /translate ERRO: ${response.statusCode}\n');
      }
    } catch (e) {
      _addResult('❌ /translate FALHOU: $e\n');
    }
  }

  Future<void> _testMultimodalEndpoint() async {
    try {
      _addResult('🖼️ Testando /multimodal...');
      final response = await _dio.post<Map<String, dynamic>>(
        '/multimodal',
        data: {
          'text': 'Analise esta situação médica',
          'type': 'text_analysis',
          'language': 'pt-BR'
        },
      );

      if (response.statusCode == 200) {
        final data = response.data!;
        final answer = data['answer'] as String?;
        _addResult('✅ /multimodal OK');
        _addResult('📝 Resposta: ${answer?.substring(0, 80)}...\n');
      } else {
        _addResult('❌ /multimodal ERRO: ${response.statusCode}\n');
      }
    } catch (e) {
      _addResult('❌ /multimodal FALHOU: $e\n');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text('Bu Fala Backend Test'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Backend: $_baseUrl',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Status: ${_isRunning ? "Executando..." : "Aguardando"}',
                      style: TextStyle(
                        color: _isRunning ? Colors.orange : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isRunning ? null : _runAllTests,
              child: _isRunning
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Executando...'),
                      ],
                    )
                  : const Text('Executar Todos os Testes'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ListView.builder(
                    itemCount: _testResults.length,
                    itemBuilder: (context, index) {
                      final result = _testResults[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          result,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
}
