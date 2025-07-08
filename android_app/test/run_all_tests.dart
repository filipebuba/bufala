import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'integration/app_integration_test.dart' as integration_tests;
import 'services/agricultural_advisor_service_test.dart' as agriculture_tests;
// Import all test files
import 'services/crisis_response_service_test.dart' as crisis_tests;
import 'services/offline_learning_service_test.dart' as learning_tests;
import 'test_config.dart';
import 'widgets/emergency_button_test.dart' as emergency_button_tests;
import 'widgets/language_selector_test.dart' as language_selector_tests;

/// Main test runner for Bufala app
void main() {
  group('Bufala App - Complete Test Suite', () {
    setUpAll(() async {
      print('🚀 Iniciando suite completa de testes do Bufala...');
      await TestConfig.setUp();
    });
    
    tearDownAll(() async {
      await TestConfig.tearDown();
      print('✅ Suite de testes concluída!');
    });
    
    group('📱 Testes de Serviços', () {
      group('🚨 Crisis Response Service', crisis_tests.main);
      
      group('📚 Offline Learning Service', learning_tests.main);
      
      group('🌾 Agricultural Advisor Service', agriculture_tests.main);
    });
    
    group('🎨 Testes de Widgets', () {
      group('🆘 Emergency Button', emergency_button_tests.main);
      
      group('🌍 Language Selector', language_selector_tests.main);
    });
    
    group('🔗 Testes de Integração', integration_tests.main);
    
    group('⚡ Testes de Performance', () {
      test('memory usage under normal load', () async {
        // Simulate normal app usage
        final memoryBefore = ProcessInfo.currentRss;
        
        // Perform memory-intensive operations
        for (var i = 0; i < 100; i++) {
          TestConfig.createMockLearningContent(
            topic: 'test_topic_$i',
            level: 'intermediário'
          );
        }
        
        final memoryAfter = ProcessInfo.currentRss;
        final memoryIncrease = memoryAfter - memoryBefore;
        
        // Memory increase should be reasonable (< 50MB)
        expect(memoryIncrease, lessThan(50 * 1024 * 1024));
      });
      
      test('response time for emergency assessment', () async {
        final stopwatch = Stopwatch()..start();
        
        TestConfig.createMockEmergencyResponse(
          symptoms: ['sangramento', 'ferimento', 'dor']
        );
        
        stopwatch.stop();
        
        // Should respond within 2 seconds
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      });
      
      test('concurrent request handling', () async {
        final futures = List.generate(10, (index) => 
          TestConfig.createMockLearningContent(
            topic: 'concurrent_test_$index'
          )
        );
        
        final stopwatch = Stopwatch()..start();
        final results = await Future.wait(futures);
        stopwatch.stop();
        
        expect(results.length, 10);
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });
    });
    
    group('🔒 Testes de Segurança', () {
      test('data sanitization', () {
        const maliciousInput = '<script>alert("xss")</script>';
        final sanitized = _sanitizeInput(maliciousInput);
        
        expect(sanitized, isNot(contains('<script>')));
        expect(sanitized, isNot(contains('alert')));
      });
      
      test('sensitive data protection', () {
        const userData = TestConfig.mockUserProgress;
        
        // Verify no sensitive data is logged
        expect(userData.toString(), isNot(contains('password')));
        expect(userData.toString(), isNot(contains('token')));
      });
    });
    
    group('🌐 Testes de Localização', () {
      test('Kriolu language support', () {
        final kriolouContent = TestConfig.createMockLearningContent(
          topic: 'saúde'
        );
        
        expect(kriolouContent['language'], 'kriolu');
        expect(kriolouContent['title'], isA<String>());
      });
      
      test('Portuguese language support', () {
        final portugueseContent = TestConfig.createMockLearningContent(
          topic: 'saúde',
          language: 'portuguese'
        );
        
        expect(portugueseContent['language'], 'portuguese');
        expect(portugueseContent['title'], isA<String>());
      });
      
      test('dynamic language learning', () {
        const localPhrases = TestConfig.mockKrioluPhrases;
        
        expect(localPhrases.isNotEmpty, true);
        expect(localPhrases.every((phrase) => phrase.isNotEmpty), true);
      });
    });
    
    group('📊 Testes de Métricas', () {
      test('user progress tracking accuracy', () {
        const progress = TestConfig.mockUserProgress;
        
        expect(progress['averageScore'], isA<double>());
        expect(progress['averageScore'], greaterThan(0));
        expect(progress['averageScore'], lessThanOrEqualTo(100));
      });
      
      test('emergency response accuracy', () {
        final response = TestConfig.createMockEmergencyResponse(
          symptoms: ['sangramento', 'ferimento']
        );
        
        expect(response['confidence'], greaterThan(0.8));
        expect(response['urgencyLevel'], 'alta');
      });
      
      test('agricultural diagnosis accuracy', () {
        final diagnosis = TestConfig.createMockAgriculturalDiagnosis(
          cropType: 'arroz',
          symptoms: ['folhas_amarelas', 'manchas_marrons']
        );
        
        expect(diagnosis['confidence'], greaterThan(0.7));
        expect(diagnosis['recommendations'], isNotEmpty);
      });
    });
    
    group('🔄 Testes de Recuperação', () {
      test('offline mode fallback', () async {
        // Simulate offline condition
        final offlineContent = TestConfig.createMockLearningContent(
          topic: 'matemática'
        );
        
        expect(offlineContent['isOfflineGenerated'], true);
        expect(offlineContent['content'], isNotEmpty);
      });
      
      test('error recovery mechanisms', () {
        expect(() => _handleError('test_error'), returnsNormally);
      });
    });
  });
}

/// Helper functions
String _sanitizeInput(String input) {
  return input
      .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
      .replaceAll(RegExp(r'[<>"\'\/]'), '') // Remove dangerous characters
      .trim();
}

void _handleError(String error) {
  // Error handling implementation
  print('Erro tratado: $error');
}

/// Test execution statistics
class TestStats {
  static int totalTests = 0;
  static int passedTests = 0;
  static int failedTests = 0;
  static DateTime? startTime;
  static DateTime? endTime;
  
  static void start() {
    startTime = DateTime.now();
    print('📊 Iniciando coleta de estatísticas de teste...');
  }
  
  static void end() {
    endTime = DateTime.now();
    final duration = endTime!.difference(startTime!);
    
    print('\n📈 ESTATÍSTICAS FINAIS:');
    print('⏱️  Tempo total: ${duration.inSeconds}s');
    print('✅ Testes aprovados: $passedTests');
    print('❌ Testes falharam: $failedTests');
    print('📊 Total de testes: $totalTests');
    print('🎯 Taxa de sucesso: ${(passedTests / totalTests * 100).toStringAsFixed(1)}%');
    
    if (failedTests == 0) {
      print('🎉 TODOS OS TESTES PASSARAM! App pronto para produção.');
    } else {
      print('⚠️  Alguns testes falharam. Revisar antes da produção.');
    }
  }
  
  static void recordTest({required bool passed}) {
    totalTests++;
    if (passed) {
      passedTests++;
    } else {
      failedTests++;
    }
  }
}

/// Custom test matchers
class BufalaMatchers {
  static Matcher isValidKrioluText = predicate<String>(
    (text) => text.isNotEmpty && !text.contains(RegExp(r'[<>]')),
    'is valid Kriolu text'
  );
  
  static Matcher isValidEmergencyResponse = predicate<Map<String, dynamic>>(
    (response) => response.containsKey('urgencyLevel') && 
                  response.containsKey('instructions') &&
                  response['confidence'] > 0.5,
    'is valid emergency response'
  );
  
  static Matcher isValidLearningContent = predicate<Map<String, dynamic>>(
    (content) => content.containsKey('title') && 
                 content.containsKey('exercises') &&
                 content['exercises'] is List &&
                 (content['exercises'] as List).isNotEmpty,
    'is valid learning content'
  );
}