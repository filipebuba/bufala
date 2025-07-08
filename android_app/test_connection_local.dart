import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();

  try {
    print('🧪 Testando conexão com backend (localhost)...');

    // Testar health endpoint
    final response =
        await dio.get<Map<String, dynamic>>('http://localhost:5000/health');

    if (response.statusCode == 200) {
      print('✅ Conexão com backend OK!');
      print('📊 Status: ${response.data}');
    } else {
      print('❌ Erro na conexão: ${response.statusCode}');
    }

    // Testar endpoint medical
    print('\n🏥 Testando endpoint medical...');
    final medicalResponse = await dio.post<Map<String, dynamic>>(
      'http://localhost:5000/medical',
      data: {'question': 'Como tratar uma dor de cabeça?', 'language': 'pt-BR'},
    );

    if (medicalResponse.statusCode == 200) {
      print('✅ Endpoint medical OK!');
      print(
          '📝 Resposta: ${medicalResponse.data?['answer']?.substring(0, 100)}...');
    } else {
      print('❌ Erro no endpoint medical: ${medicalResponse.statusCode}');
    }

    // Testar endpoint education
    print('\n📚 Testando endpoint education...');
    final educationResponse = await dio.post<Map<String, dynamic>>(
      'http://localhost:5000/education',
      data: {'question': 'Como plantar milho?', 'language': 'pt-BR'},
    );

    if (educationResponse.statusCode == 200) {
      print('✅ Endpoint education OK!');
      print(
          '📝 Resposta: ${educationResponse.data?['answer']?.substring(0, 100)}...');
    } else {
      print('❌ Erro no endpoint education: ${educationResponse.statusCode}');
    }

    // Testar endpoint agriculture
    print('\n🌱 Testando endpoint agriculture...');
    final agricultureResponse = await dio.post<Map<String, dynamic>>(
      'http://localhost:5000/agriculture',
      data: {
        'question': 'Qual é o melhor fertilizante para batata?',
        'language': 'pt-BR'
      },
    );

    if (agricultureResponse.statusCode == 200) {
      print('✅ Endpoint agriculture OK!');
      print(
          '📝 Resposta: ${agricultureResponse.data?['answer']?.substring(0, 100)}...');
    } else {
      print(
          '❌ Erro no endpoint agriculture: ${agricultureResponse.statusCode}');
    }
  } catch (e) {
    print('❌ Erro na conexão: $e');
  }
}
