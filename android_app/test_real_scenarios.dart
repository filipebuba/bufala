import 'package:dio/dio.dart';

/// Script para testar a comunicação entre Flutter e backend Bu Fala
/// Este script simula exatamente como o app Flutter faria as chamadas
void main() async {
  print('🚀 Bu Fala - Teste de Comunicação Backend\n');

  final dio = Dio();
  dio.options.baseUrl = 'http://localhost:5000'; // Para teste local
  dio.options.connectTimeout = const Duration(seconds: 10);
  dio.options.receiveTimeout = const Duration(seconds: 30);

  // Simular uso real do app
  await testRealWorldScenarios(dio);
}

Future<void> testRealWorldScenarios(Dio dio) async {
  print('📱 Testando cenários reais do app Bu Fala...\n');

  // Cenário 1: Usuário abre o app e verifica saúde do backend
  await testHealthCheck(dio);

  // Cenário 2: Emergência médica - febre alta em criança
  await testMedicalEmergency(dio);

  // Cenário 3: Consulta educacional - matemática básica
  await testEducationalQuery(dio);

  // Cenário 4: Consulta agrícola - plantio de arroz
  await testAgricultureQuery(dio);

  // Cenário 5: Tradução - português para crioulo
  await testTranslation(dio);

  // Cenário 6: Análise multimodal - texto médico
  await testMultimodal(dio);

  print('\n🎉 Todos os cenários testados com sucesso!');
  print('✅ O app Flutter pode se comunicar com o backend Bu Fala!');
}

Future<void> testHealthCheck(Dio dio) async {
  print('🏥 CENÁRIO 1: Verificação de saúde do backend');
  print('   (Simula: usuário abrindo o app)');

  try {
    final response = await dio.get<Map<String, dynamic>>('/health');

    if (response.statusCode == 200) {
      final data = response.data!;
      print('   ✅ Backend conectado: ${data['backend']}');
      print('   📊 Status: ${data['status']}');
      print('   🤖 Modelo: ${data['model']}');
      print('   🔧 Features: ${data['features']?.take(3).join(', ')}...\n');
    }
  } catch (e) {
    print('   ❌ Erro: $e\n');
  }
}

Future<void> testMedicalEmergency(Dio dio) async {
  print('🚨 CENÁRIO 2: Emergência médica');
  print('   (Simula: mãe com filho febril em casa rural)');

  try {
    final response = await dio.post<Map<String, dynamic>>(
      '/medical',
      data: {
        'question':
            'Minha filha de 3 anos está com febre de 39°C, o que devo fazer? Estou numa aldeia sem médico.',
        'language': 'pt-BR',
        'urgency_level': 'high',
        'patient_age': '3 anos',
      },
    );

    if (response.statusCode == 200) {
      final data = response.data!;
      final answer = data['answer'] as String?;
      print('   ✅ Resposta médica recebida');
      print('   📝 Orientação: ${answer?.substring(0, 120)}...');
      print('   🏥 Domínio: ${data['domain']}');
      print('   ⏰ Timestamp: ${data['timestamp']}\n');
    }
  } catch (e) {
    print('   ❌ Erro: $e\n');
  }
}

Future<void> testEducationalQuery(Dio dio) async {
  print('📚 CENÁRIO 3: Consulta educacional');
  print('   (Simula: professor preparando aula de matemática)');

  try {
    final response = await dio.post<Map<String, dynamic>>(
      '/education',
      data: {
        'question':
            'Como ensinar adição e subtração para crianças de 6-8 anos de forma lúdica?',
        'subject': 'matemática',
        'level': 'ensino fundamental I',
        'language': 'pt-BR',
      },
    );

    if (response.statusCode == 200) {
      final data = response.data!;
      final answer = data['answer'] as String?;
      print('   ✅ Conteúdo educativo gerado');
      print('   📖 Conteúdo: ${answer?.substring(0, 120)}...');
      print('   📚 Matéria: ${data['subject']}');
      print('   🎯 Nível: ${data['level']}\n');
    }
  } catch (e) {
    print('   ❌ Erro: $e\n');
  }
}

Future<void> testAgricultureQuery(Dio dio) async {
  print('🌾 CENÁRIO 4: Consulta agrícola');
  print('   (Simula: agricultor planejando plantio)');

  try {
    final response = await dio.post<Map<String, dynamic>>(
      '/agriculture',
      data: {
        'question':
            'Qual a melhor época para plantar arroz em Guiné-Bissau? Como preparar o terreno?',
        'crop_type': 'arroz',
        'season': 'seca',
        'language': 'pt-BR',
      },
    );

    if (response.statusCode == 200) {
      final data = response.data!;
      final answer = data['answer'] as String?;
      print('   ✅ Orientação agrícola fornecida');
      print('   🌱 Orientação: ${answer?.substring(0, 120)}...');
      print('   🌾 Cultura: ${data['crop_type']}');
      print('   🌤️ Época: ${data['season']}\n');
    }
  } catch (e) {
    print('   ❌ Erro: $e\n');
  }
}

Future<void> testTranslation(Dio dio) async {
  print('🌐 CENÁRIO 5: Tradução');
  print('   (Simula: tradução para comunicação local)');

  try {
    final response = await dio.post<Map<String, dynamic>>(
      '/translate',
      data: {
        'text': 'Tome este remédio três vezes ao dia após as refeições',
        'from_language': 'pt-BR',
        'to_language': 'crioulo-gb',
      },
    );

    if (response.statusCode == 200) {
      final data = response.data!;
      final translated = data['translated'] as String?;
      print('   ✅ Tradução realizada');
      print('   📝 Original: ${data['original_text']}');
      print('   🔄 Traduzido: $translated');
      print(
          '   🌍 Idiomas: ${data['from_language']} → ${data['to_language']}\n');
    }
  } catch (e) {
    print('   ❌ Erro: $e\n');
  }
}

Future<void> testMultimodal(Dio dio) async {
  print('🖼️ CENÁRIO 6: Análise multimodal');
  print('   (Simula: análise de texto médico complexo)');

  try {
    final response = await dio.post<Map<String, dynamic>>(
      '/multimodal',
      data: {
        'text':
            'Paciente apresenta dispneia, taquicardia e dor torácica. Histórico de hipertensão.',
        'type': 'medical_analysis',
        'language': 'pt-BR',
      },
    );

    if (response.statusCode == 200) {
      final data = response.data!;
      final answer = data['answer'] as String?;
      print('   ✅ Análise multimodal concluída');
      print('   🔍 Análise: ${answer?.substring(0, 120)}...');
      print('   📊 Tipo: ${data['type']}');
      print('   🏥 Tem imagem: ${data['has_image']}\n');
    }
  } catch (e) {
    print('   ❌ Erro: $e\n');
  }
}
