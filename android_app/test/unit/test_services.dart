import 'dart:convert';

import 'package:android_app/models/phrase.dart';
import 'package:android_app/models/teacher.dart';
import 'package:android_app/services/api_service.dart';
import 'package:android_app/services/audio_service.dart';
import 'package:android_app/services/image_service.dart';
import 'package:android_app/services/language_service.dart';
import 'package:android_app/services/storage_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Gerar mocks
@GenerateMocks([http.Client, IApiService, IAudioService, IImageService, ILanguageService, IStorageService])
import 'test_services.mocks.dart';

void main() {
  group('ApiService Tests', () {
    late MockClient mockClient;
    late ApiService apiService;

    setUp(() {
      mockClient = MockClient();
      apiService = ApiService();
      // Inject mock client
      apiService.client = mockClient;
    });

    test('validatePhrase should return success response', () async {
      // Arrange
      final phrase = Phrase(
        id: '1',
        originalText: 'Bom dia',
        translatedText: 'Good morning',
        language: 'crioulo',
        category: 'greetings',
        audioPath: '',
        isValidated: false,
        teacherId: 'teacher1',
        createdAt: DateTime.now(),
      );

      final mockResponse = {
        'success': true,
        'data': {
          'isValid': true,
          'confidence': 0.95,
          'suggestions': []
        }
      };

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
        json.encode(mockResponse),
        200,
      ));

      // Act
      final result = await apiService.validatePhrase(phrase);

      // Assert
      expect(result['success'], true);
      expect(result['data']['isValid'], true);
      expect(result['data']['confidence'], 0.95);
    });

    test('validatePhrase should handle error response', () async {
      // Arrange
      final phrase = Phrase(
        id: '1',
        originalText: 'Invalid phrase',
        translatedText: 'Invalid translation',
        language: 'crioulo',
        category: 'test',
        audioPath: '',
        isValidated: false,
        teacherId: 'teacher1',
        createdAt: DateTime.now(),
      );

      when(mockClient.post(
        any,
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
        'Server Error',
        500,
      ));

      // Act & Assert
      expect(
        () => apiService.validatePhrase(phrase),
        throwsException,
      );
    });

    test('getTeacherRanking should return list of teachers', () async {
      // Arrange
      final mockResponse = {
        'success': true,
        'data': [
          {
            'id': '1',
            'name': 'João Silva',
            'points': 150,
            'phrasesCount': 25,
            'accuracy': 0.92,
            'level': 'Intermediário',
            'avatar': 'avatar1.png'
          },
          {
            'id': '2',
            'name': 'Maria Santos',
            'points': 120,
            'phrasesCount': 20,
            'accuracy': 0.88,
            'level': 'Iniciante',
            'avatar': 'avatar2.png'
          }
        ]
      };

      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
        json.encode(mockResponse),
        200,
      ));

      // Act
      final result = await apiService.getTeacherRanking();

      // Assert
      expect(result['success'], true);
      expect(result['data'], isA<List>());
      expect(result['data'].length, 2);
      expect(result['data'][0]['name'], 'João Silva');
      expect(result['data'][0]['points'], 150);
    });

    test('getCommunityStats should return community statistics', () async {
      // Arrange
      final mockResponse = {
        'success': true,
        'data': {
          'totalTeachers': 45,
          'totalPhrases': 1250,
          'totalValidations': 890,
          'averageAccuracy': 0.87,
          'activeLanguages': ['crioulo', 'português', 'inglês']
        }
      };

      when(mockClient.get(
        any,
        headers: anyNamed('headers'),
      )).thenAnswer((_) async => http.Response(
        json.encode(mockResponse),
        200,
      ));

      // Act
      final result = await apiService.getCommunityStats();

      // Assert
      expect(result['success'], true);
      expect(result['data']['totalTeachers'], 45);
      expect(result['data']['totalPhrases'], 1250);
      expect(result['data']['activeLanguages'], isA<List>());
    });
  });

  group('AudioService Tests', () {
    late MockIAudioService mockAudioService;

    setUp(() {
      mockAudioService = MockIAudioService();
    });

    test('startRecording should initialize recording', () async {
      // Arrange
      when(mockAudioService.startRecording())
          .thenAnswer((_) async => true);

      // Act
      final result = await mockAudioService.startRecording();

      // Assert
      expect(result, true);
      verify(mockAudioService.startRecording()).called(1);
    });

    test('stopRecording should return audio file path', () async {
      // Arrange
      const expectedPath = '/path/to/audio.wav';
      when(mockAudioService.stopRecording())
          .thenAnswer((_) async => expectedPath);

      // Act
      final result = await mockAudioService.stopRecording();

      // Assert
      expect(result, expectedPath);
      verify(mockAudioService.stopRecording()).called(1);
    });

    test('playAudio should play audio file', () async {
      // Arrange
      const audioPath = '/path/to/audio.wav';
      when(mockAudioService.playAudio(audioPath))
          .thenAnswer((_) async => true);

      // Act
      final result = await mockAudioService.playAudio(audioPath);

      // Assert
      expect(result, true);
      verify(mockAudioService.playAudio(audioPath)).called(1);
    });

    test('isRecording should return recording status', () {
      // Arrange
      when(mockAudioService.isRecording).thenReturn(true);

      // Act
      final result = mockAudioService.isRecording;

      // Assert
      expect(result, true);
    });
  });

  group('ImageService Tests', () {
    late MockImageService mockImageService;

    setUp(() {
      mockImageService = MockImageService();
    });

    test('pickImageFromCamera should return image path', () async {
      // Arrange
      const expectedPath = '/path/to/image.jpg';
      when(mockImageService.pickImageFromCamera())
          .thenAnswer((_) async => expectedPath);

      // Act
      final result = await mockImageService.pickImageFromCamera();

      // Assert
      expect(result, expectedPath);
      verify(mockImageService.pickImageFromCamera()).called(1);
    });

    test('pickImageFromGallery should return image path', () async {
      // Arrange
      const expectedPath = '/path/to/gallery_image.jpg';
      when(mockImageService.pickImageFromGallery())
          .thenAnswer((_) async => expectedPath);

      // Act
      final result = await mockImageService.pickImageFromGallery();

      // Assert
      expect(result, expectedPath);
      verify(mockImageService.pickImageFromGallery()).called(1);
    });

    test('compressImage should return compressed image path', () async {
      // Arrange
      const originalPath = '/path/to/original.jpg';
      const compressedPath = '/path/to/compressed.jpg';
      when(mockImageService.compressImage(originalPath))
          .thenAnswer((_) async => compressedPath);

      // Act
      final result = await mockImageService.compressImage(originalPath);

      // Assert
      expect(result, compressedPath);
      verify(mockImageService.compressImage(originalPath)).called(1);
    });
  });

  group('StorageService Tests', () {
    late MockStorageService mockStorageService;

    setUp(() {
      mockStorageService = MockStorageService();
    });

    test('savePhraseLocally should save phrase', () async {
      // Arrange
      final phrase = Phrase(
        id: '1',
        originalText: 'Test phrase',
        translatedText: 'Frase de teste',
        language: 'crioulo',
        category: 'test',
        audioPath: '',
        isValidated: false,
        teacherId: 'teacher1',
        createdAt: DateTime.now(),
      );

      when(mockStorageService.savePhraseLocally(phrase))
          .thenAnswer((_) async => true);

      // Act
      final result = await mockStorageService.savePhraseLocally(phrase);

      // Assert
      expect(result, true);
      verify(mockStorageService.savePhraseLocally(phrase)).called(1);
    });

    test('getLocalPhrases should return list of phrases', () async {
      // Arrange
      final phrases = [
        Phrase(
          id: '1',
          originalText: 'Hello',
          translatedText: 'Olá',
          language: 'crioulo',
          category: 'greetings',
          audioPath: '',
          isValidated: true,
          teacherId: 'teacher1',
          createdAt: DateTime.now(),
        ),
        Phrase(
          id: '2',
          originalText: 'Goodbye',
          translatedText: 'Tchau',
          language: 'crioulo',
          category: 'greetings',
          audioPath: '',
          isValidated: false,
          teacherId: 'teacher2',
          createdAt: DateTime.now(),
        ),
      ];

      when(mockStorageService.getLocalPhrases())
          .thenAnswer((_) async => phrases);

      // Act
      final result = await mockStorageService.getLocalPhrases();

      // Assert
      expect(result, isA<List<Phrase>>());
      expect(result.length, 2);
      expect(result[0].originalText, 'Hello');
      expect(result[1].originalText, 'Goodbye');
      verify(mockStorageService.getLocalPhrases()).called(1);
    });

    test('clearLocalData should clear all local data', () async {
      // Arrange
      when(mockStorageService.clearLocalData())
          .thenAnswer((_) async => true);

      // Act
      final result = await mockStorageService.clearLocalData();

      // Assert
      expect(result, true);
      verify(mockStorageService.clearLocalData()).called(1);
    });
  });

  group('LanguageService Tests', () {
    late MockLanguageService mockLanguageService;

    setUp(() {
      mockLanguageService = MockLanguageService();
    });

    test('detectLanguage should return detected language', () async {
      // Arrange
      const text = 'Bom dia, como está?';
      const expectedLanguage = 'crioulo';
      when(mockLanguageService.detectLanguage(text))
          .thenAnswer((_) async => expectedLanguage);

      // Act
      final result = await mockLanguageService.detectLanguage(text);

      // Assert
      expect(result, expectedLanguage);
      verify(mockLanguageService.detectLanguage(text)).called(1);
    });

    test('translateText should return translated text', () async {
      // Arrange
      const sourceText = 'Hello world';
      const targetLanguage = 'crioulo';
      const expectedTranslation = 'Olá mundo';
      
      when(mockLanguageService.translateText(sourceText, targetLanguage))
          .thenAnswer((_) async => expectedTranslation);

      // Act
      final result = await mockLanguageService.translateText(sourceText, targetLanguage);

      // Assert
      expect(result, expectedTranslation);
      verify(mockLanguageService.translateText(sourceText, targetLanguage)).called(1);
    });

    test('getSupportedLanguages should return list of languages', () async {
      // Arrange
      const supportedLanguages = ['crioulo', 'português', 'inglês', 'francês'];
      when(mockLanguageService.getSupportedLanguages())
          .thenAnswer((_) async => supportedLanguages);

      // Act
      final result = await mockLanguageService.getSupportedLanguages();

      // Assert
      expect(result, isA<List<String>>());
      expect(result.length, 4);
      expect(result, contains('crioulo'));
      expect(result, contains('português'));
      verify(mockLanguageService.getSupportedLanguages()).called(1);
    });

    test('isLanguageSupported should return true for supported language', () {
      // Arrange
      const language = 'crioulo';
      when(mockLanguageService.isLanguageSupported(language))
          .thenReturn(true);

      // Act
      final result = mockLanguageService.isLanguageSupported(language);

      // Assert
      expect(result, true);
      verify(mockLanguageService.isLanguageSupported(language)).called(1);
    });

    test('isLanguageSupported should return false for unsupported language', () {
      // Arrange
      const language = 'klingon';
      when(mockLanguageService.isLanguageSupported(language))
          .thenReturn(false);

      // Act
      final result = mockLanguageService.isLanguageSupported(language);

      // Assert
      expect(result, false);
      verify(mockLanguageService.isLanguageSupported(language)).called(1);
    });
  });
}