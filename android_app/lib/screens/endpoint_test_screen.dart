import 'package:flutter/material.dart';
import '../services/api_service.dart';

class EndpointTestScreen extends StatefulWidget {
  const EndpointTestScreen({super.key});

  @override
  State<EndpointTestScreen> createState() => _EndpointTestScreenState();
}

class _EndpointTestScreenState extends State<EndpointTestScreen> {
  final ApiService _apiService = ApiService();
  String _currentTest = '';
  String _result = '';
  bool _isLoading = false;

  Future<void> _testMedical() async {
    setState(() {
      _isLoading = true;
      _currentTest = 'Medical';
      _result = 'Testando endpoint médico...';
    });

    try {
      final response = await _apiService.askMedicalQuestion(
        question: 'Como tratar febre?',
      );

      setState(() {
        if (response.success && response.data != null) {
          _result = '✅ MEDICAL SUCCESS\n'
              'Answer: ${response.data!.substring(0, 100)}...';
        } else {
          _result = '❌ MEDICAL ERROR: ${response.error}';
        }
      });
    } catch (e) {
      setState(() {
        _result = '❌ MEDICAL EXCEPTION: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testEducation() async {
    setState(() {
      _isLoading = true;
      _currentTest = 'Education';
      _result = 'Testando endpoint educacional...';
    });

    try {
      final response = await _apiService.askEducationQuestion(
        question: 'Ensine matemática básica',
        subject: 'mathematics',
      );

      setState(() {
        if (response.success && response.data != null) {
          _result = '✅ EDUCATION SUCCESS\n'
              'Answer: ${response.data!.substring(0, 100)}...';
        } else {
          _result = '❌ EDUCATION ERROR: ${response.error}';
        }
      });
    } catch (e) {
      setState(() {
        _result = '❌ EDUCATION EXCEPTION: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testAgriculture() async {
    setState(() {
      _isLoading = true;
      _currentTest = 'Agriculture';
      _result = 'Testando endpoint agrícola...';
    });

    try {
      final response = await _apiService.askAgricultureQuestion(
        question: 'Como plantar arroz?',
        cropType: 'rice',
        season: 'rainy',
      );

      setState(() {
        if (response.success && response.data != null) {
          _result = '✅ AGRICULTURE SUCCESS\n'
              'Answer: ${response.data!.substring(0, 100)}...';
        } else {
          _result = '❌ AGRICULTURE ERROR: ${response.error}';
        }
      });
    } catch (e) {
      setState(() {
        _result = '❌ AGRICULTURE EXCEPTION: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testTranslate() async {
    setState(() {
      _isLoading = true;
      _currentTest = 'Translate';
      _result = 'Testando endpoint de tradução...';
    });

    try {
      final response = await _apiService.translateText(
        text: 'Olá, como está?',
        sourceLanguage: 'pt-BR',
        targetLanguage: 'crioulo-gb',
      );

      setState(() {
        if (response.success && response.data != null) {
          _result = '✅ TRANSLATE SUCCESS\n'
              'Translated: ${response.data!}';
        } else {
          _result = '❌ TRANSLATE ERROR: ${response.error}';
        }
      });
    } catch (e) {
      setState(() {
        _result = '❌ TRANSLATE EXCEPTION: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Teste de Endpoints'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Teste de Integração Backend-Flutter',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Botões de teste
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _testMedical,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[600],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Medical'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _testEducation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Education'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _testAgriculture,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Agriculture'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _testTranslate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[600],
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Translate'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Status
              if (_isLoading)
                Column(
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 8),
                    Text(
                      'Testando $_currentTest...',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

              const SizedBox(height: 20),

              // Resultado
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _result.isEmpty
                          ? 'Clique em um botão para testar o endpoint'
                          : _result,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                        color: _result.startsWith('✅')
                            ? Colors.green
                            : _result.startsWith('❌')
                                ? Colors.red
                                : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
