import 'package:android_app/providers/phrase_provider.dart';
import 'package:android_app/providers/teacher_provider.dart';
import 'package:android_app/services/api_service.dart';
import 'package:android_app/services/audio_service.dart';
import 'package:android_app/services/image_service.dart';
import 'package:android_app/widgets/home_screen.dart';
import 'package:android_app/widgets/validation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';

import 'test_widgets.mocks.dart';

@GenerateMocks([
  IApiService,
  IAudioService,
  IImageService,
  IPhraseProvider,
  ITeacherProvider
])
void main() {
  group('Widget Tests', () {
    late MockIApiService mockApiService;
    late MockIAudioService mockAudioService;
    late MockIImageService mockImageService;
    late MockIPhraseProvider mockPhraseProvider;
    late MockITeacherProvider mockTeacherProvider;

    setUp(() {
      mockApiService = MockIApiService();
      mockAudioService = MockIAudioService();
      mockImageService = MockIImageService();
      mockPhraseProvider = MockIPhraseProvider();
      mockTeacherProvider = MockITeacherProvider();
    });

    testWidgets('HomeScreen displays correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(MaterialApp(
        home: HomeScreen(
          apiService: mockApiService,
          audioService: mockAudioService,
          imageService: mockImageService,
        ),
      ));

      // Assert
      expect(find.text('Bu-Fala'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('ValidationScreen displays correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(MaterialApp(
        home: ValidationScreen(
          phraseProvider: mockPhraseProvider,
          teacherProvider: mockTeacherProvider,
        ),
      ));

      // Assert
      expect(find.text('Validação de Frases'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNWidgets(2)); // Approve and reject buttons
    });
  });
}