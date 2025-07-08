import 'dart:io';
import 'package:dio/dio.dart';

/// Teste para descobrir endpoints POST disponíveis no backend
void main() async {
  print('🔍 Testando endpoints POST no backend...');

  final dio = Dio();
  dio.options.baseUrl = 'http://192.168.15.7:5000';

  // Testar endpoints POST
  final postEndpoints = [
    '/education',
    '/translate',
    '/emergency',
    '/process_emergency',
    '/generate_content',
  ];

  for (final endpoint in postEndpoints) {
    try {
      final response = await dio.post(
        endpoint,
        data: {'test': true, 'message': 'Teste de conectividade'},
      );
      print('✅ POST $endpoint - Status: ${response.statusCode}');
      if (response.data != null) {
        final data = response.data.toString();
        final preview =
            data.length > 200 ? '${data.substring(0, 200)}...' : data;
        print('   Resposta: $preview');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        print('❌ POST $endpoint - Status: ${e.response!.statusCode}');
        if (e.response!.data != null) {
          final errorData = e.response!.data.toString();
          final preview = errorData.length > 100
              ? '${errorData.substring(0, 100)}...'
              : errorData;
          print('   Erro: $preview');
        }
      } else {
        print('❌ POST $endpoint - Erro de conexão');
      }
    }
    print('');
  }

  // Testar um endpoint específico com dados corretos
  print('🔍 Testando endpoint /education com dados específicos...');
  try {
    final response = await dio.post(
      '/education',
      data: {
        'subject': 'matemática',
        'level': 'beginner',
        'language': 'pt-BR',
        'topics': ['números básicos']
      },
    );
    print(
        '✅ POST /education (dados específicos) - Status: ${response.statusCode}');
    print('   Resposta: ${response.data}');
  } catch (e) {
    if (e is DioException && e.response != null) {
      print(
          '❌ POST /education (dados específicos) - Status: ${e.response!.statusCode}');
      print('   Erro: ${e.response!.data}');
    }
  }

  exit(0);
}
