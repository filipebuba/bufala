import 'package:android_app/services/language_service.dart';
import 'package:android_app/widgets/language_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock implementation for testing
class MockLanguageService implements ILanguageService {
  @override
  List<String> getAvailableLanguages() {
    return ['pt', 'en', 'fr', 'crioulo'];
  }

  @override
  Future<String> detectLanguage() async {
    return 'pt';
  }

  @override
  double getLanguageLearningProgress(String language) {
    return 0.75; // Mock progress
  }

  @override
  bool isOffline() {
    return false; // Mock online state
  }
}

void main() {
  group('LanguageSelector Widget Tests', () {
    late MockLanguageService mockLanguageService;

    setUp(() {
      mockLanguageService = MockLanguageService();
    });

    testWidgets('should display language selector widget', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageSelector(
              languageService: mockLanguageService,
              onLanguageChanged: (language) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(LanguageSelector), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });

    testWidgets('should handle callback function', (WidgetTester tester) async {
      // Arrange
      String? selectedLanguage;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageSelector(
              languageService: mockLanguageService,
              onLanguageChanged: (language) {
                selectedLanguage = language;
              },
            ),
          ),
        ),
      );

      // Assert - Widget should be created without errors
      expect(find.byType(LanguageSelector), findsOneWidget);
    });

    testWidgets('should display with current language', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageSelector(
              languageService: mockLanguageService,
              currentLanguage: 'pt',
              onLanguageChanged: (language) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(LanguageSelector), findsOneWidget);
    });

    testWidgets('should handle auto detect mode', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageSelector(
              languageService: mockLanguageService,
              autoDetect: true,
              onLanguageChanged: (language) {},
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(LanguageSelector), findsOneWidget);
    });

    testWidgets('should work with basic configuration', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageSelector(
              languageService: mockLanguageService,
              onLanguageChanged: (language) {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(LanguageSelector), findsOneWidget);
      expect(find.byType(DropdownButton<String>), findsOneWidget);
    });
  });
}