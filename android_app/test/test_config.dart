import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Test configuration and utilities for Bufala app tests
class TestConfig {
  static const String testDatabaseName = 'bufala_test.db';
  static const String testCachePath = 'test_cache';
  
  /// Mock data for testing
  static const Map<String, dynamic> mockUserProgress = {
    'userId': 'test_user_123',
    'completedLessons': ['lesson1', 'lesson2', 'lesson3'],
    'currentLevel': 'intermediário',
    'totalScore': 250,
    'averageScore': 83.3,
    'timeSpent': 1800, // 30 minutes
    'strengths': ['leitura', 'matemática'],
    'weaknesses': ['escrita'],
    'preferredLanguage': 'kriolu'
  };
  
  static const Map<String, dynamic> mockEmergencyCase = {
    'id': 'emergency_001',
    'symptoms': ['sangramento', 'ferimento', 'dor'],
    'urgencyLevel': 'alta',
    'timestamp': '2024-01-15T10:30:00Z',
    'location': {'lat': 11.8037, 'lng': -15.1804}, // Bissau coordinates
    'language': 'kriolu'
  };
  
  static const Map<String, dynamic> mockCropDiagnosis = {
    'cropType': 'arroz',
    'symptoms': ['folhas amarelas', 'manchas marrons'],
    'diagnosis': 'deficiência_nutrientes',
    'confidence': 0.87,
    'recommendations': [
      'Aplicar fertilizante rico em nitrogênio',
      'Verificar drenagem do solo',
      'Monitorar pH do solo'
    ],
    'severity': 'moderada'
  };
  
  static const List<String> mockKrioluPhrases = [
    'Na kasa ku na',
    'I sta bon',
    'Undi ku bo sta bai?',
    'N ta bai na merkadu',
    'Kuma ku bo sta?',
    'Obrigadu pa tudu'
  ];
  
  static const Map<String, List<String>> mockLanguageSupport = {
    'kriolu': ['Na kasa', 'I sta bon', 'Obrigadu'],
    'portuguese': ['Em casa', 'Está bem', 'Obrigado'],
    'balanta': ['Nha kasa', 'A sta bon', 'Obrigadu'],
    'fula': ['Suudu am', 'Mi yiɗi', 'Jaraama']
  };
  
  /// Setup method for tests
  static Future<void> setUp() async {
    // Initialize shared preferences for testing
    SharedPreferences.setMockInitialValues({
      'user_language': 'kriolu',
      'offline_mode': false,
      'first_launch': false,
      'user_progress': mockUserProgress,
    });
    
    // Setup test database
    await _setupTestDatabase();
    
    // Setup mock services
    await _setupMockServices();
  }
  
  /// Cleanup method for tests
  static Future<void> tearDown() async {
    await _cleanupTestDatabase();
    await _cleanupTestCache();
  }
  
  /// Setup test database
  static Future<void> _setupTestDatabase() async {
    // Implementation for test database setup
    // This would typically involve creating a temporary database
    // and populating it with test data
  }
  
  /// Cleanup test database
  static Future<void> _cleanupTestDatabase() async {
    // Implementation for test database cleanup
  }
  
  /// Cleanup test cache
  static Future<void> _cleanupTestCache() async {
    // Implementation for test cache cleanup
  }
  
  /// Setup mock services
  static Future<void> _setupMockServices() async {
    // Implementation for mock service setup
  }
  
  /// Create mock emergency response
  static Map<String, dynamic> createMockEmergencyResponse({
    required List<String> symptoms,
    String language = 'kriolu',
  }) => {
      'urgencyLevel': _determineUrgencyLevel(symptoms),
      'instructions': _generateMockInstructions(symptoms, language),
      'estimatedTime': '2-5 minutos',
      'confidence': 0.92,
      'language': language,
    };
  
  /// Create mock learning content
  static Map<String, dynamic> createMockLearningContent({
    required String topic,
    String level = 'iniciante',
    String language = 'kriolu',
  }) => {
      'id': 'content_${topic}_$level',
      'title': 'Lição de $topic',
      'difficulty': level,
      'language': language,
      'content': 'Conteúdo educacional sobre $topic',
      'exercises': _generateMockExercises(topic, level),
      'estimatedDuration': 15, // minutes
      'isOfflineGenerated': true,
    };
  
  /// Create mock agricultural diagnosis
  static Map<String, dynamic> createMockAgriculturalDiagnosis({
    required String cropType,
    required List<String> symptoms,
  }) => {
      'cropType': cropType,
      'symptoms': symptoms,
      'possibleDiseases': _identifyMockDiseases(symptoms),
      'recommendations': _generateMockRecommendations(cropType, symptoms),
      'confidence': 0.85,
      'severity': _determineSeverity(symptoms),
      'treatmentUrgency': 'moderada',
    };
  
  // Helper methods
  static String _determineUrgencyLevel(List<String> symptoms) {
    if (symptoms.any((s) => ['sangramento', 'ferimento_grave', 'inconsciência'].contains(s))) {
      return 'alta';
    } else if (symptoms.any((s) => ['febre_alta', 'dor_intensa'].contains(s))) {
      return 'média';
    }
    return 'baixa';
  }
  
  static List<String> _generateMockInstructions(List<String> symptoms, String language) {
    final instructions = <String>[];
    
    if (symptoms.contains('sangramento')) {
      if (language == 'kriolu') {
        instructions.addAll([
          'Aplika presãu diretu na ferida',
          'Eleva a parti afetadu',
          'Chama ajuda médiku'
        ]);
      } else {
        instructions.addAll([
          'Aplicar pressão direta no ferimento',
          'Elevar a parte afetada',
          'Chamar ajuda médica'
        ]);
      }
    }
    
    return instructions;
  }
  
  static List<Map<String, dynamic>> _generateMockExercises(String topic, String level) => [
      {
        'id': 'ex1',
        'type': 'multiple_choice',
        'question': 'Pergunta sobre $topic',
        'options': ['Opção A', 'Opção B', 'Opção C'],
        'correctAnswer': 0,
      },
      {
        'id': 'ex2',
        'type': 'fill_blank',
        'question': 'Complete a frase sobre $topic: ___',
        'correctAnswer': 'resposta',
      },
    ];
  
  static List<String> _identifyMockDiseases(List<String> symptoms) {
    final diseases = <String>[];
    
    if (symptoms.contains('folhas_amarelas')) {
      diseases.add('deficiência_nitrogênio');
    }
    if (symptoms.contains('manchas_marrons')) {
      diseases.add('fungo_foliar');
    }
    
    return diseases.isEmpty ? ['condição_geral'] : diseases;
  }
  
  static List<String> _generateMockRecommendations(String cropType, List<String> symptoms) => [
      'Monitorar $cropType diariamente',
      'Aplicar tratamento adequado',
      'Verificar condições do solo',
    ];
  
  static String _determineSeverity(List<String> symptoms) {
    if (symptoms.length > 3) return 'alta';
    if (symptoms.length > 1) return 'moderada';
    return 'baixa';
  }
}

/// Test utilities
class TestUtils {
  /// Wait for async operations to complete
  static Future<void> waitForAsync([Duration? duration]) async {
    await Future.delayed(duration ?? const Duration(milliseconds: 100));
  }
  
  /// Simulate network delay
  static Future<void> simulateNetworkDelay() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }
  
  /// Generate random test data
  static String generateRandomId() => 'test_${DateTime.now().millisecondsSinceEpoch}';
  
  /// Verify widget accessibility
  static void verifyAccessibility(WidgetTester tester, Finder finder) {
    final semantics = tester.getSemantics(finder);
    expect(semantics.hasAction(SemanticsAction.tap), true);
    expect(semantics.label, isNotEmpty);
  }
}