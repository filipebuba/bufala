import 'package:android_app/models/community_stats.dart';
import 'package:android_app/models/phrase.dart';
import 'package:android_app/models/teacher.dart';
import 'package:android_app/models/validation_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Phrase Model Tests', () {
    test('should create Phrase with all properties', () {
      // Arrange
      final createdAt = DateTime.now();
      
      // Act
      final phrase = Phrase(
        id: '1',
        originalText: 'Bom dia',
        translatedText: 'Good morning',
        language: 'crioulo',
        category: 'greetings',
        audioPath: '/path/to/audio.wav',
        isValidated: true,
        teacherId: 'teacher1',
        createdAt: createdAt,
      );

      // Assert
      expect(phrase.id, '1');
      expect(phrase.originalText, 'Bom dia');
      expect(phrase.translatedText, 'Good morning');
      expect(phrase.language, 'crioulo');
      expect(phrase.category, 'greetings');
      expect(phrase.audioPath, '/path/to/audio.wav');
      expect(phrase.isValidated, true);
      expect(phrase.teacherId, 'teacher1');
      expect(phrase.createdAt, createdAt);
    });

    test('should convert Phrase to JSON', () {
      // Arrange
      final createdAt = DateTime.parse('2024-01-15T10:30:00.000Z');
      final phrase = Phrase(
        id: '1',
        originalText: 'Bom dia',
        translatedText: 'Good morning',
        language: 'crioulo',
        category: 'greetings',
        audioPath: '/path/to/audio.wav',
        isValidated: true,
        teacherId: 'teacher1',
        createdAt: createdAt,
      );

      // Act
      final json = phrase.toJson();

      // Assert
      expect(json['id'], '1');
      expect(json['originalText'], 'Bom dia');
      expect(json['translatedText'], 'Good morning');
      expect(json['language'], 'crioulo');
      expect(json['category'], 'greetings');
      expect(json['audioPath'], '/path/to/audio.wav');
      expect(json['isValidated'], true);
      expect(json['teacherId'], 'teacher1');
      expect(json['createdAt'], '2024-01-15T10:30:00.000Z');
    });

    test('should create Phrase from JSON', () {
      // Arrange
      final json = {
        'id': '1',
        'originalText': 'Bom dia',
        'translatedText': 'Good morning',
        'language': 'crioulo',
        'category': 'greetings',
        'audioPath': '/path/to/audio.wav',
        'isValidated': true,
        'teacherId': 'teacher1',
        'createdAt': '2024-01-15T10:30:00.000Z',
      };

      // Act
      final phrase = Phrase.fromJson(json);

      // Assert
      expect(phrase.id, '1');
      expect(phrase.originalText, 'Bom dia');
      expect(phrase.translatedText, 'Good morning');
      expect(phrase.language, 'crioulo');
      expect(phrase.category, 'greetings');
      expect(phrase.audioPath, '/path/to/audio.wav');
      expect(phrase.isValidated, true);
      expect(phrase.teacherId, 'teacher1');
      expect(phrase.createdAt, DateTime.parse('2024-01-15T10:30:00.000Z'));
    });

    test('should handle copyWith method', () {
      // Arrange
      final originalPhrase = Phrase(
        id: '1',
        originalText: 'Bom dia',
        translatedText: 'Good morning',
        language: 'crioulo',
        category: 'greetings',
        audioPath: '/path/to/audio.wav',
        isValidated: false,
        teacherId: 'teacher1',
        createdAt: DateTime.now(),
      );

      // Act
      final updatedPhrase = originalPhrase.copyWith(
        isValidated: true,
        translatedText: 'Bom dia (updated)',
      );

      // Assert
      expect(updatedPhrase.id, originalPhrase.id);
      expect(updatedPhrase.originalText, originalPhrase.originalText);
      expect(updatedPhrase.translatedText, 'Bom dia (updated)');
      expect(updatedPhrase.isValidated, true);
      expect(updatedPhrase.teacherId, originalPhrase.teacherId);
    });

    test('should validate required fields', () {
      // Act & Assert
      expect(
        () => Phrase(
          id: '',
          originalText: 'Test',
          translatedText: 'Teste',
          language: 'crioulo',
          category: 'test',
          audioPath: '',
          isValidated: false,
          teacherId: 'teacher1',
          createdAt: DateTime.now(),
        ),
        throwsAssertionError,
      );
    });
  });

  group('Teacher Model Tests', () {
    test('should create Teacher with all properties', () {
      // Act
      final teacher = Teacher(
        id: '1',
        name: 'João Silva',
        points: 150,
        phrasesCount: 25,
        accuracy: 0.92,
        level: 'Intermediário',
        avatar: 'avatar1.png',
        joinedAt: DateTime.now(),
      );

      // Assert
      expect(teacher.id, '1');
      expect(teacher.name, 'João Silva');
      expect(teacher.points, 150);
      expect(teacher.phrasesCount, 25);
      expect(teacher.accuracy, 0.92);
      expect(teacher.level, 'Intermediário');
      expect(teacher.avatar, 'avatar1.png');
      expect(teacher.joinedAt, isA<DateTime>());
    });

    test('should convert Teacher to JSON', () {
      // Arrange
      final joinedAt = DateTime.parse('2024-01-01T00:00:00.000Z');
      final teacher = Teacher(
        id: '1',
        name: 'João Silva',
        points: 150,
        phrasesCount: 25,
        accuracy: 0.92,
        level: 'Intermediário',
        avatar: 'avatar1.png',
        joinedAt: joinedAt,
      );

      // Act
      final json = teacher.toJson();

      // Assert
      expect(json['id'], '1');
      expect(json['name'], 'João Silva');
      expect(json['points'], 150);
      expect(json['phrasesCount'], 25);
      expect(json['accuracy'], 0.92);
      expect(json['level'], 'Intermediário');
      expect(json['avatar'], 'avatar1.png');
      expect(json['joinedAt'], '2024-01-01T00:00:00.000Z');
    });

    test('should create Teacher from JSON', () {
      // Arrange
      final json = {
        'id': '1',
        'name': 'João Silva',
        'points': 150,
        'phrasesCount': 25,
        'accuracy': 0.92,
        'level': 'Intermediário',
        'avatar': 'avatar1.png',
        'joinedAt': '2024-01-01T00:00:00.000Z',
      };

      // Act
      final teacher = Teacher.fromJson(json);

      // Assert
      expect(teacher.id, '1');
      expect(teacher.name, 'João Silva');
      expect(teacher.points, 150);
      expect(teacher.phrasesCount, 25);
      expect(teacher.accuracy, 0.92);
      expect(teacher.level, 'Intermediário');
      expect(teacher.avatar, 'avatar1.png');
      expect(teacher.joinedAt, DateTime.parse('2024-01-01T00:00:00.000Z'));
    });

    test('should calculate level based on points', () {
      // Test different point ranges
      expect(Teacher.calculateLevel(50), 'Iniciante');
      expect(Teacher.calculateLevel(150), 'Intermediário');
      expect(Teacher.calculateLevel(350), 'Avançado');
      expect(Teacher.calculateLevel(600), 'Expert');
      expect(Teacher.calculateLevel(1200), 'Mestre');
    });

    test('should get level color', () {
      // Arrange
      final teacher = Teacher(
        id: '1',
        name: 'Test',
        points: 150,
        phrasesCount: 25,
        accuracy: 0.92,
        level: 'Intermediário',
        avatar: 'avatar.png',
        joinedAt: DateTime.now(),
      );

      // Act
      final color = teacher.getLevelColor();

      // Assert
      expect(color, isNotNull);
    });

    test('should validate accuracy range', () {
      // Act & Assert
      expect(
        () => Teacher(
          id: '1',
          name: 'Test',
          points: 100,
          phrasesCount: 10,
          accuracy: 1.5, // Invalid accuracy > 1.0
          level: 'Iniciante',
          avatar: 'avatar.png',
          joinedAt: DateTime.now(),
        ),
        throwsAssertionError,
      );
    });
  });

  group('ValidationResult Model Tests', () {
    test('should create ValidationResult with all properties', () {
      // Act
      final result = ValidationResult(
        isValid: true,
        confidence: 0.95,
        suggestions: ['Suggestion 1', 'Suggestion 2'],
        correctedText: 'Corrected text',
        feedback: 'Great translation!',
      );

      // Assert
      expect(result.isValid, true);
      expect(result.confidence, 0.95);
      expect(result.suggestions, ['Suggestion 1', 'Suggestion 2']);
      expect(result.correctedText, 'Corrected text');
      expect(result.feedback, 'Great translation!');
    });

    test('should convert ValidationResult to JSON', () {
      // Arrange
      final result = ValidationResult(
        isValid: true,
        confidence: 0.95,
        suggestions: ['Suggestion 1', 'Suggestion 2'],
        correctedText: 'Corrected text',
        feedback: 'Great translation!',
      );

      // Act
      final json = result.toJson();

      // Assert
      expect(json['isValid'], true);
      expect(json['confidence'], 0.95);
      expect(json['suggestions'], ['Suggestion 1', 'Suggestion 2']);
      expect(json['correctedText'], 'Corrected text');
      expect(json['feedback'], 'Great translation!');
    });

    test('should create ValidationResult from JSON', () {
      // Arrange
      final json = {
        'isValid': true,
        'confidence': 0.95,
        'suggestions': ['Suggestion 1', 'Suggestion 2'],
        'correctedText': 'Corrected text',
        'feedback': 'Great translation!',
      };

      // Act
      final result = ValidationResult.fromJson(json);

      // Assert
      expect(result.isValid, true);
      expect(result.confidence, 0.95);
      expect(result.suggestions, ['Suggestion 1', 'Suggestion 2']);
      expect(result.correctedText, 'Corrected text');
      expect(result.feedback, 'Great translation!');
    });

    test('should handle empty suggestions list', () {
      // Arrange
      final result = ValidationResult(
        isValid: false,
        confidence: 0.3,
        suggestions: [],
        correctedText: null,
        feedback: 'Needs improvement',
      );

      // Assert
      expect(result.suggestions, isEmpty);
      expect(result.correctedText, isNull);
    });

    test('should validate confidence range', () {
      // Act & Assert
      expect(
        () => ValidationResult(
          isValid: true,
          confidence: 1.5, // Invalid confidence > 1.0
          suggestions: [],
          correctedText: null,
          feedback: 'Test',
        ),
        throwsAssertionError,
      );
    });
  });

  group('CommunityStats Model Tests', () {
    test('should create CommunityStats with all properties', () {
      // Act
      final stats = CommunityStats(
        totalTeachers: 45,
        totalPhrases: 1250,
        totalValidations: 890,
        averageAccuracy: 0.87,
        activeLanguages: ['crioulo', 'português', 'inglês'],
        topCategories: ['greetings', 'food', 'family'],
        weeklyGrowth: 12.5,
        lastUpdated: DateTime.now(),
      );

      // Assert
      expect(stats.totalTeachers, 45);
      expect(stats.totalPhrases, 1250);
      expect(stats.totalValidations, 890);
      expect(stats.averageAccuracy, 0.87);
      expect(stats.activeLanguages, ['crioulo', 'português', 'inglês']);
      expect(stats.topCategories, ['greetings', 'food', 'family']);
      expect(stats.weeklyGrowth, 12.5);
      expect(stats.lastUpdated, isA<DateTime>());
    });

    test('should convert CommunityStats to JSON', () {
      // Arrange
      final lastUpdated = DateTime.parse('2024-01-15T10:30:00.000Z');
      final stats = CommunityStats(
        totalTeachers: 45,
        totalPhrases: 1250,
        totalValidations: 890,
        averageAccuracy: 0.87,
        activeLanguages: ['crioulo', 'português', 'inglês'],
        topCategories: ['greetings', 'food', 'family'],
        weeklyGrowth: 12.5,
        lastUpdated: lastUpdated,
      );

      // Act
      final json = stats.toJson();

      // Assert
      expect(json['totalTeachers'], 45);
      expect(json['totalPhrases'], 1250);
      expect(json['totalValidations'], 890);
      expect(json['averageAccuracy'], 0.87);
      expect(json['activeLanguages'], ['crioulo', 'português', 'inglês']);
      expect(json['topCategories'], ['greetings', 'food', 'family']);
      expect(json['weeklyGrowth'], 12.5);
      expect(json['lastUpdated'], '2024-01-15T10:30:00.000Z');
    });

    test('should create CommunityStats from JSON', () {
      // Arrange
      final json = {
        'totalTeachers': 45,
        'totalPhrases': 1250,
        'totalValidations': 890,
        'averageAccuracy': 0.87,
        'activeLanguages': ['crioulo', 'português', 'inglês'],
        'topCategories': ['greetings', 'food', 'family'],
        'weeklyGrowth': 12.5,
        'lastUpdated': '2024-01-15T10:30:00.000Z',
      };

      // Act
      final stats = CommunityStats.fromJson(json);

      // Assert
      expect(stats.totalTeachers, 45);
      expect(stats.totalPhrases, 1250);
      expect(stats.totalValidations, 890);
      expect(stats.averageAccuracy, 0.87);
      expect(stats.activeLanguages, ['crioulo', 'português', 'inglês']);
      expect(stats.topCategories, ['greetings', 'food', 'family']);
      expect(stats.weeklyGrowth, 12.5);
      expect(stats.lastUpdated, DateTime.parse('2024-01-15T10:30:00.000Z'));
    });

    test('should calculate validation rate', () {
      // Arrange
      final stats = CommunityStats(
        totalTeachers: 45,
        totalPhrases: 1000,
        totalValidations: 800,
        averageAccuracy: 0.87,
        activeLanguages: ['crioulo'],
        topCategories: ['greetings'],
        weeklyGrowth: 12.5,
        lastUpdated: DateTime.now(),
      );

      // Act
      final validationRate = stats.getValidationRate();

      // Assert
      expect(validationRate, 0.8);
    });

    test('should handle zero phrases for validation rate', () {
      // Arrange
      final stats = CommunityStats(
        totalTeachers: 45,
        totalPhrases: 0,
        totalValidations: 0,
        averageAccuracy: 0.0,
        activeLanguages: ['crioulo'],
        topCategories: [],
        weeklyGrowth: 0.0,
        lastUpdated: DateTime.now(),
      );

      // Act
      final validationRate = stats.getValidationRate();

      // Assert
      expect(validationRate, 0.0);
    });

    test('should validate non-negative values', () {
      // Act & Assert
      expect(
        () => CommunityStats(
          totalTeachers: -1, // Invalid negative value
          totalPhrases: 1250,
          totalValidations: 890,
          averageAccuracy: 0.87,
          activeLanguages: ['crioulo'],
          topCategories: ['greetings'],
          weeklyGrowth: 12.5,
          lastUpdated: DateTime.now(),
        ),
        throwsAssertionError,
      );
    });
  });
}