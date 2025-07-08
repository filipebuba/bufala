import 'package:bufala/services/language_service.dart';
import 'package:bufala/widgets/language_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Generate mocks
@GenerateMocks([LanguageService])
import 'language_selector_test.mocks.dart';

void main() {
  group('LanguageSelector Widget Tests', () {
    late MockLanguageService mockLanguageService;
    
    setUp(() {
      mockLanguageService = MockLanguageService();
    });
    
    testWidgets('should display available languages', (WidgetTester tester) async {
      // Arrange
      when(mockLanguageService.getAvailableLanguages())
          .thenReturn(['kriolu', 'portuguese', 'balanta', 'fula']);
      
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
      expect(find.byType(DropdownButton<String>), findsOneWidget);
      
      // Tap to open dropdown
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      
      expect(find.text('Kriolu'), findsOneWidget);
      expect(find.text('Português'), findsOneWidget);
      expect(find.text('Balanta'), findsOneWidget);
      expect(find.text('Fula'), findsOneWidget);
    });
    
    testWidgets('should call callback when language is selected', (WidgetTester tester) async {
      // Arrange
      String? selectedLanguage;
      
      when(mockLanguageService.getAvailableLanguages())
          .thenReturn(['kriolu', 'portuguese']);
      
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
      
      // Act
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Português'));
      await tester.pumpAndSettle();
      
      // Assert
      expect(selectedLanguage, 'portuguese');
    });
    
    testWidgets('should show current selected language', (WidgetTester tester) async {
      // Arrange
      when(mockLanguageService.getAvailableLanguages())
          .thenReturn(['kriolu', 'portuguese']);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageSelector(
              languageService: mockLanguageService,
              currentLanguage: 'kriolu',
              onLanguageChanged: (language) {},
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.text('Kriolu'), findsOneWidget);
    });
    
    testWidgets('should handle automatic language detection', (WidgetTester tester) async {
      // Arrange
      when(mockLanguageService.detectLanguage())
          .thenAnswer((_) async => 'kriolu');
      when(mockLanguageService.getAvailableLanguages())
          .thenReturn(['kriolu', 'portuguese']);
      
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
      verify(mockLanguageService.detectLanguage()).called(1);
    });
    
    testWidgets('should show language learning progress', (WidgetTester tester) async {
      // Arrange
      when(mockLanguageService.getAvailableLanguages())
          .thenReturn(['kriolu', 'portuguese']);
      when(mockLanguageService.getLanguageLearningProgress('kriolu'))
          .thenReturn(0.75);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageSelector(
              languageService: mockLanguageService,
              showLearningProgress: true,
              onLanguageChanged: (language) {},
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(LinearProgressIndicator), findsWidgets);
    });
    
    testWidgets('should handle offline mode', (WidgetTester tester) async {
      // Arrange
      when(mockLanguageService.getAvailableLanguages())
          .thenReturn(['kriolu', 'portuguese']);
      when(mockLanguageService.isOffline()).thenReturn(true);
      
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
      expect(find.byIcon(Icons.offline_bolt), findsOneWidget);
    });
    
    testWidgets('should display language flags', (WidgetTester tester) async {
      // Arrange
      when(mockLanguageService.getAvailableLanguages())
          .thenReturn(['kriolu', 'portuguese']);
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LanguageSelector(
              languageService: mockLanguageService,
              showFlags: true,
              onLanguageChanged: (language) {},
            ),
          ),
        ),
      );
      
      // Act
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.byType(Image), findsWidgets);
    });
    
    testWidgets('should be accessible', (WidgetTester tester) async {
      // Arrange
      when(mockLanguageService.getAvailableLanguages())
          .thenReturn(['kriolu', 'portuguese']);
      
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
      final semantics = tester.getSemantics(find.byType(DropdownButton<String>));
      expect(semantics.hasAction(SemanticsAction.tap), true);
      expect(semantics.label, contains('idioma'));
    });
  });
}