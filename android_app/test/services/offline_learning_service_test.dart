import 'package:android_app/models/assessment_result.dart';
import 'package:android_app/models/learning_content.dart';
import 'package:android_app/models/user_progress.dart';
import 'package:android_app/services/offline_learning_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('OfflineLearningService Tests', () {
    late OfflineLearningService service;
    
    setUp(() {
      service = OfflineLearningService();
    });
    
    group('Content Generation', () {
      test('should generate appropriate content for beginner level', () async {
        // Arrange
        const topic = 'alfabetização';
        const level = 'iniciante';
        const language = 'kriolu';
        
        // Act
        final content = await service.generateContent(
          topic: topic,
          level: level,
          language: language
        );
        
        // Assert
        expect(content, isA<LearningContent>());
        expect(content.difficulty, 'iniciante');
        expect(content.language, 'kriolu');
        expect(content.exercises.isNotEmpty, true);
      });
      
      test('should adapt content based on user progress', () async {
        // Arrange
        final userProgress = UserProgress(
          userId: 'test_user',
          completedLessons: ['lesson1', 'lesson2'],
          currentLevel: 'intermediário',
          strengths: ['leitura'],
          weaknesses: ['escrita']
        );
        
        // Act
        final content = await service.generateAdaptiveContent(
          userProgress: userProgress,
          topic: 'matemática'
        );
        
        // Assert
        expect(content.difficulty, 'intermediário');
        expect(content.exercises.any((ex) => ex.type == 'escrita'), true);
      });
      
      test('should generate multilingual content', () async {
        // Arrange
        const topic = 'saúde';
        
        // Act
        final krioloContent = await service.generateContent(
          topic: topic,
          language: 'kriolu'
        );
        final portugueseContent = await service.generateContent(
          topic: topic,
          language: 'portuguese'
        );
        
        // Assert
        expect(krioloContent.language, 'kriolu');
        expect(portugueseContent.language, 'portuguese');
        expect(krioloContent.title, isNot(equals(portugueseContent.title)));
      });
    });
    
    group('Assessment System', () {
      test('should assess user knowledge correctly', () async {
        // Arrange
        final answers = {
          'question1': 'resposta_correta',
          'question2': 'resposta_incorreta',
          'question3': 'resposta_correta'
        };
        
        // Act
        final result = await service.assessKnowledge(answers);
        
        // Assert
        expect(result, isA<AssessmentResult>());
        expect(result.score, closeTo(66.7, 0.1)); // 2/3 correct
        expect(result.recommendations.isNotEmpty, true);
      });
      
      test('should provide personalized recommendations', () async {
        // Arrange
        final lowScoreAnswers = {
          'question1': 'resposta_incorreta',
          'question2': 'resposta_incorreta',
          'question3': 'resposta_incorreta'
        };
        
        // Act
        final result = await service.assessKnowledge(lowScoreAnswers);
        
        // Assert
        expect(result.score, lessThan(50));
        expect(result.recommendations.any((rec) => 
          rec.toLowerCase().contains('revisar')), true);
      });
    });
    
    group('Progress Tracking', () {
      test('should track user progress correctly', () async {
        // Arrange
        const userId = 'test_user';
        const lessonId = 'lesson_math_1';
        const score = 85.0;
        
        // Act
        await service.updateProgress(userId, lessonId, score);
        final progress = await service.getUserProgress(userId);
        
        // Assert
        expect(progress.completedLessons.contains(lessonId), true);
        expect(progress.averageScore, greaterThanOrEqualTo(score));
      });
      
      test('should identify learning patterns', () async {
        // Arrange
        const userId = 'test_user';
        final mockProgress = UserProgress(
          userId: userId,
          completedLessons: ['math1', 'math2', 'reading1'],
          scores: {'math1': 90, 'math2': 85, 'reading1': 60},
          timeSpent: {'math1': 30, 'math2': 25, 'reading1': 45}
        );
        
        // Act
        final patterns = service.analyzeLearningPatterns(mockProgress);
        
        // Assert
        expect(patterns.strengths.contains('matemática'), true);
        expect(patterns.weaknesses.contains('leitura'), true);
      });
    });
    
    group('Offline Functionality', () {
      test('should work without internet connection', () async {
        // Arrange
        service.setOfflineMode(true);
        
        // Act
        final content = await service.generateContent(
          topic: 'alfabetização',
          language: 'kriolu'
        );
        
        // Assert
        expect(content, isA<LearningContent>());
        expect(content.isOfflineGenerated, true);
      });
      
      test('should cache content for offline use', () async {
        // Arrange
        const topic = 'matemática';
        
        // Act
        await service.cacheContent(topic);
        service.setOfflineMode(true);
        final content = await service.generateContent(topic: topic);
        
        // Assert
        expect(content, isA<LearningContent>());
        expect(service.isCached(topic), true);
      });
    });
    
    group('Language Learning', () {
      test('should adapt to local language patterns', () async {
        // Arrange
        final localPhrases = [
          'Na kasa ku na',
          'I sta bon',
          'Undi ku bo sta bai?'
        ];
        
        // Act
        await service.learnLocalLanguage('kriolu', localPhrases);
        final content = await service.generateContent(
          topic: 'conversação',
          language: 'kriolu'
        );
        
        // Assert
        expect(content.usesLocalPhrases, true);
        expect(content.exercises.any((ex) => 
          localPhrases.any((phrase) => ex.content.contains(phrase))), true);
      });
    });
    
    group('Performance Tests', () {
      test('should generate content within time limit', () async {
        // Arrange
        final stopwatch = Stopwatch()..start();
        
        // Act
        await service.generateContent(
          topic: 'alfabetização',
          language: 'kriolu'
        );
        stopwatch.stop();
        
        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(3000)); // < 3 seconds
      });
      
      test('should handle multiple concurrent requests', () async {
        // Arrange
        final futures = List.generate(5, (index) => 
          service.generateContent(
            topic: 'topic_$index',
            language: 'kriolu'
          )
        );
        
        // Act
        final results = await Future.wait(futures);
        
        // Assert
        expect(results.length, 5);
        expect(results.every((content) => content != null), true);
      });
    });
  });
}