import 'package:flutter/material.dart';
import 'services/integrated_api_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => const MaterialApp(
        home: ApiTestScreen(),
      );
}

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  _ApiTestScreenState createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final IntegratedApiService _apiService = IntegratedApiService();
  String _result = '';
  bool _isLoading = false;

  Future<void> _testEducation() async {
    setState(() {
      _isLoading = true;
      _result = 'Testando endpoint education...';
    });

    try {
      final response = await _apiService.askEducationQuestion(
        'Ensine-me sobre matemática básica',
        subject: 'mathematics',
      );

      setState(() {
        if (response['success'] == true) {
          _result = 'SUCCESS - Education:\n${response['data'] ?? 'No answer'}';
        } else {
          _result = 'ERROR - Education: ${response['error']}';
        }
      });
    } catch (e) {
      setState(() {
        _result = 'EXCEPTION - Education: $e';
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
      _result = 'Testando endpoint agriculture...';
    });

    try {
      final response = await _apiService.askAgricultureQuestion(
        'Como plantar arroz?',
        cropType: 'rice',
        season: 'rainy',
      );

      setState(() {
        if (response['success'] == true) {
          _result = 'SUCCESS - Agriculture:\n${response['data'] ?? 'No answer'}';
        } else {
          _result = 'ERROR - Agriculture: ${response['error']}';
        }
      });
    } catch (e) {
      setState(() {
        _result = 'EXCEPTION - Agriculture: $e';
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
      _result = 'Testando endpoint translate...';
    });

    try {
      final response = await _apiService.translateText(
        'Olá, como está?',
        fromLanguage: 'pt-BR',
        toLanguage: 'crioulo-gb',
      );

      setState(() {
        if (response['success'] == true) {
          _result =
              'SUCCESS - Translate:\n${response['data'] ?? 'No translation'}';
        } else {
          _result = 'ERROR - Translate: ${response['error']}';
        }
      });
    } catch (e) {
      setState(() {
        _result = 'EXCEPTION - Translate: $e';
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
          title: const Text('Teste ApiService'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _testEducation,
                      child: const Text('Test Education'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _testAgriculture,
                      child: const Text('Test Agriculture'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _testTranslate,
                      child: const Text('Test Translate'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_isLoading) const CircularProgressIndicator(),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _result,
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
