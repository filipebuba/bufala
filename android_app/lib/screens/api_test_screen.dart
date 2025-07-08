import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ApiTestScreen extends StatefulWidget {
  const ApiTestScreen({super.key});

  @override
  State<ApiTestScreen> createState() => _ApiTestScreenState();
}

class _ApiTestScreenState extends State<ApiTestScreen> {
  final ApiService _apiService = ApiService();
  String _result = 'Aguardando teste...';
  bool _isLoading = false;

  Future<void> _testMedicalEndpoint() async {
    setState(() {
      _isLoading = true;
      _result = 'Testando endpoint médico...';
    });

    try {
      final response = await _apiService.askMedicalQuestion(
        question: 'dor de cabeça forte',
      );

      setState(() {
        if (response.success && response.data != null) {
          _result = 'SUCESSO: ${response.data!}';
        } else {
          _result = 'ERRO (mas com fallback): ${response.error}';
        }
      });
    } catch (e) {
      setState(() {
        _result = 'ERRO INESPERADO: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testEducationEndpoint() async {
    setState(() {
      _isLoading = true;
      _result = 'Testando endpoint educacional...';
    });

    try {
      final response = await _apiService.askEducationQuestion(
        question: 'matemática básica',
      );

      setState(() {
        if (response.success && response.data != null) {
          _result = 'SUCESSO: ${response.data!}';
        } else {
          _result = 'ERRO (mas com fallback): ${response.error}';
        }
      });
    } catch (e) {
      setState(() {
        _result = 'ERRO INESPERADO: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testAgricultureEndpoint() async {
    setState(() {
      _isLoading = true;
      _result = 'Testando endpoint agrícola...';
    });

    try {
      final response = await _apiService.askAgricultureQuestion(
        question: 'como plantar arroz',
      );

      setState(() {
        if (response.success && response.data != null) {
          _result = 'SUCESSO: ${response.data!}';
        } else {
          _result = 'ERRO (mas com fallback): ${response.error}';
        }
      });
    } catch (e) {
      setState(() {
        _result = 'ERRO INESPERADO: $e';
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
          title: const Text('Teste API Backend'),
          backgroundColor: Colors.blue[700],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Teste de Comunicação Flutter ↔ Backend',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _testMedicalEndpoint,
                child: const Text('Testar Endpoint Médico'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isLoading ? null : _testEducationEndpoint,
                child: const Text('Testar Endpoint Educacional'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isLoading ? null : _testAgricultureEndpoint,
                child: const Text('Testar Endpoint Agrícola'),
              ),
              const SizedBox(height: 20),
              if (_isLoading) const CircularProgressIndicator(),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _result,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
