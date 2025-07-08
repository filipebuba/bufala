import 'dart:io';
import 'package:dio/dio.dart';

/// Teste com os campos corretos esperados pelo backend
void main() async {
  print('🔍 Testando com campos corretos...');

  final dio = Dio();
  dio.options.baseUrl = 'http://192.168.15.7:5000';

  // Testar tradução com campo correto
  print('🌐 Testando tradução...');
  try {
    final response = await dio.post(
      '/translate',
      data: {
        'text': 'Olá, como você está?',
        'from_language': 'pt-BR',
        'to_language': 'en'
      },
    );
    print('✅ Tradução - Status: ${response.statusCode}');
    print('   Resultado: ${response.data}');
  } catch (e) {
    if (e is DioException && e.response != null) {
      print('❌ Tradução - Status: ${e.response!.statusCode}');
      print('   Erro: ${e.response!.data}');
    }
  }
  print('');

  // Testar educação com campo question
  print('📚 Testando educação...');
  try {
    final response = await dio.post(
      '/education',
      data: {
        'question':
            'Ensine-me sobre números básicos de matemática para iniciantes',
        'subject': 'matemática',
        'level': 'beginner',
        'language': 'pt-BR'
      },
    );
    print('✅ Educação - Status: ${response.statusCode}');
    print('   Resultado: ${response.data}');
  } catch (e) {
    if (e is DioException && e.response != null) {
      print('❌ Educação - Status: ${e.response!.statusCode}');
      print('   Erro: ${e.response!.data}');
    }
  }

  exit(0);
}
