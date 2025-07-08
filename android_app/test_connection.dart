import 'package:dio/dio.dart';

void main() async {
  final dio = Dio();

  try {
    print('🧪 Testando conexão com backend...');

    // Testar health endpoint
    final response = await dio.get('http://10.0.2.2:5000/health');

    if (response.statusCode == 200) {
      print('✅ Conexão com backend OK!');
      print('📊 Status: ${response.data}');
    } else {
      print('❌ Erro na conexão: ${response.statusCode}');
    }

    // Testar endpoint medical
    print('\n🏥 Testando endpoint medical...');
    final medicalResponse = await dio.post(
      'http://10.0.2.2:5000/medical',
      data: {'question': 'Como tratar uma dor de cabeça?', 'language': 'pt-BR'},
    );

    if (medicalResponse.statusCode == 200) {
      print('✅ Endpoint medical OK!');
      print(
          '📝 Resposta: ${medicalResponse.data['answer']?.substring(0, 100)}...');
    } else {
      print('❌ Erro no endpoint medical: ${medicalResponse.statusCode}');
    }
  } catch (e) {
    print('❌ Erro na conexão: $e');
  }
}
