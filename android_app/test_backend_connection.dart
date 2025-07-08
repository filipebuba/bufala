import 'dart:io';
import 'lib/services/gemma3_backend_service.dart';

/// Teste simples para verificar conectividade com o backend Gemma-3
void main() async {
  print('🔄 Testando conectividade com backend Gemma-3...');
  print('📍 URL: http://192.168.15.7:5000');

  final service = Gemma3BackendService();

  try {
    // Testar inicialização
    final connected = await service.initialize();

    if (connected) {
      print('✅ Conectado com sucesso ao backend Gemma-3!');

      // Testar status de saúde
      final healthStatus = await service.getHealthStatus();
      print('💚 Status do backend: $healthStatus');

      // Testar tradução simples
      print('\n🔄 Testando tradução...');
      final translatedText = await service.translateText(
        text: 'Olá, como você está?',
        fromLanguage: 'pt-BR',
        toLanguage: 'en',
      );
      print('🌐 Tradução: "Olá, como você está?" -> "$translatedText"');

      // Testar geração de conteúdo educativo
      print('\n🔄 Testando geração de conteúdo educativo...');
      final educationalContent = await service.generateEducationalContent(
        subject: 'matemática',
        language: 'pt-BR',
        topics: ['números básicos'],
      );
      print('📚 Conteúdo gerado: ${educationalContent.title}');
      print('📝 Descrição: ${educationalContent.description}');

      print(
          '\n🎉 Todos os testes passaram! O backend está funcionando corretamente.');
    } else {
      print('❌ Falha ao conectar com o backend');
      print(
          '🔍 Verifique se o backend está rodando em http://192.168.15.7:5000');
    }
  } catch (e) {
    print('❌ Erro durante o teste: $e');
    print('🔍 Detalhes do erro:');
    print('   - Verifique se o backend está rodando');
    print('   - Verifique a conectividade de rede');
    print('   - Verifique se o IP 192.168.15.7:5000 está correto');
  }

  exit(0);
}
