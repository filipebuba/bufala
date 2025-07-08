import 'dart:io';
import 'package:dio/dio.dart';

/// Teste para descobrir endpoints disponíveis no backend
void main() async {
  print('🔍 Descobrindo endpoints disponíveis no backend...');

  final dio = Dio();
  dio.options.baseUrl = 'http://192.168.15.7:5000';

  final endpoints = [
    '/',
    '/health',
    '/status',
    '/api/health',
    '/api/status',
    '/process_emergency',
    '/emergency',
    '/api/emergency',
    '/generate_content',
    '/education',
    '/api/education',
    '/translate',
    '/api/translate',
    '/process_audio',
    '/audio',
    '/api/audio',
    '/process_image',
    '/image',
    '/api/image',
  ];

  for (final endpoint in endpoints) {
    try {
      final response = await dio.get(endpoint);
      print('✅ $endpoint - Status: ${response.statusCode}');
      if (response.data != null) {
        final data = response.data.toString();
        final preview =
            data.length > 100 ? '${data.substring(0, 100)}...' : data;
        print('   Resposta: $preview');
      }
    } catch (e) {
      if (e is DioException && e.response != null) {
        print('❌ $endpoint - Status: ${e.response!.statusCode}');
      } else {
        print(
            '❌ $endpoint - Erro: ${e.toString().length > 50 ? "${e.toString().substring(0, 50)}..." : e.toString()}');
      }
    }
    print('');
  }

  exit(0);
}
