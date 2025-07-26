import 'package:android_app/main.dart' as app;
import 'package:android_app/services/crisis_response_service.dart';
import 'package:android_app/services/endpoints/agriculture_service.dart';
import 'package:android_app/services/offline_learning_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'app_integration_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  ICrisisResponseService,
  IOfflineLearningService,
  IAgricultureService,
])

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Android App Integration Tests', () {
    testWidgets('complete emergency flow', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();
      
      // Act - Navigate to emergency section
      await tester.tap(find.byIcon(Icons.emergency));
      await tester.pumpAndSettle();
      
      // Verify emergency button is present
      expect(find.text('EMERGÊNCIA'), findsOneWidget);
      
      // Tap emergency button
      await tester.tap(find.text('EMERGÊNCIA'));
      await tester.pumpAndSettle();
      
      // Verify symptom input screen appears
      expect(find.text('Descreva os sintomas'), findsOneWidget);
      
      // Enter symptoms
      await tester.enterText(find.byType(TextField), 'sangramento ferimento');
      await tester.tap(find.text('Analisar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Assert - Verify emergency response appears
      expect(find.textContaining('pressão'), findsOneWidget);
      expect(find.textContaining('ferimento'), findsOneWidget);
    });
    
    testWidgets('complete education flow', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();
      
      // Act - Navigate to education section
      await tester.tap(find.byIcon(Icons.school));
      await tester.pumpAndSettle();
      
      // Verify education interface
      expect(find.text('Educação'), findsOneWidget);
      
      // Select a topic
      await tester.tap(find.text('Alfabetização'));
      await tester.pumpAndSettle();
      
      // Verify content generation
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      // Assert - Verify educational content appears
      expect(find.textContaining('lição'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsOneWidget); // Progress bar
    });
    
    testWidgets('complete agriculture flow', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();
      
      // Act - Navigate to agriculture section
      await tester.tap(find.byIcon(Icons.agriculture));
      await tester.pumpAndSettle();
      
      // Verify agriculture interface
      expect(find.text('Agricultura'), findsOneWidget);
      
      // Select crop diagnosis
      await tester.tap(find.text('Diagnóstico de Culturas'));
      await tester.pumpAndSettle();
      
      // Select crop type
      await tester.tap(find.text('Arroz'));
      await tester.pumpAndSettle();
      
      // Enter symptoms
      await tester.enterText(find.byType(TextField), 'folhas amarelas manchas');
      await tester.tap(find.text('Diagnosticar'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Assert - Verify diagnosis appears
      expect(find.textContaining('diagnóstico'), findsOneWidget);
      expect(find.textContaining('recomendação'), findsOneWidget);
    });
    
    testWidgets('language switching functionality', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();
      
      // Act - Open language selector
      await tester.tap(find.byIcon(Icons.language));
      await tester.pumpAndSettle();
      
      // Switch to Kriolu
      await tester.tap(find.text('Kriolu'));
      await tester.pumpAndSettle();
      
      // Assert - Verify interface changed to Kriolu
      expect(find.text('Urjénsia'), findsOneWidget);
      expect(find.text('Skola'), findsOneWidget);
      
      // Switch back to Portuguese
      await tester.tap(find.byIcon(Icons.language));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Português'));
      await tester.pumpAndSettle();
      
      // Assert - Verify interface changed back to Portuguese
      expect(find.text('Emergência'), findsOneWidget);
      expect(find.text('Educação'), findsOneWidget);
    });
    
    testWidgets('offline functionality', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();
      
      // Simulate offline mode
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Modo Offline'));
      await tester.pumpAndSettle();
      
      // Act - Try emergency function offline
      await tester.tap(find.byIcon(Icons.emergency));
      await tester.pumpAndSettle();
      await tester.tap(find.text('EMERGÊNCIA'));
      await tester.pumpAndSettle();
      
      // Assert - Verify offline indicator
      expect(find.byIcon(Icons.offline_bolt), findsOneWidget);
      
      // Verify functionality still works
      await tester.enterText(find.byType(TextField), 'febre');
      await tester.tap(find.text('Analisar'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      expect(find.textContaining('recomendação'), findsOneWidget);
    });
    
    testWidgets('accessibility features', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();
      
      // Enable accessibility features
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Acessibilidade'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Texto Grande'));
      await tester.pumpAndSettle();
      
      // Act - Navigate through app with accessibility
      await tester.tap(find.byIcon(Icons.emergency));
      await tester.pumpAndSettle();
      
      // Assert - Verify accessibility features
      final emergencyButton = find.text('EMERGÊNCIA');
      expect(emergencyButton, findsOneWidget);
      
      final semantics = tester.getSemantics(emergencyButton);
      expect(semantics.hasAction(SemanticsAction.tap), true);
      expect(semantics.label, isNotEmpty);
    });
    
    testWidgets('performance under load', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();
      
      final stopwatch = Stopwatch()..start();
      
      // Act - Perform multiple operations quickly
      for (var i = 0; i < 5; i++) {
        await tester.tap(find.byIcon(Icons.emergency));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.school));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.agriculture));
        await tester.pumpAndSettle();
      }
      
      stopwatch.stop();
      
      // Assert - Verify performance is acceptable
      expect(stopwatch.elapsedMilliseconds, lessThan(10000)); // < 10 seconds
    });
    
    testWidgets('data persistence', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();
      
      // Act - Generate some learning content
      await tester.tap(find.byIcon(Icons.school));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Alfabetização'));
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Complete a lesson
      await tester.tap(find.text('Completar Lição'));
      await tester.pumpAndSettle();
      
      // Restart app (simulate app restart)
      await tester.binding.defaultBinaryMessenger.handlePlatformMessage(
        'flutter/platform',
        null,
        (data) {},
      );
      
      app.main();
      await tester.pumpAndSettle();
      
      // Assert - Verify progress was saved
      await tester.tap(find.byIcon(Icons.school));
      await tester.pumpAndSettle();
      
      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      // Progress should be > 0
    });
    
    testWidgets('error handling and recovery', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle();
      
      // Act - Trigger an error condition
      await tester.tap(find.byIcon(Icons.emergency));
      await tester.pumpAndSettle();
      await tester.tap(find.text('EMERGÊNCIA'));
      await tester.pumpAndSettle();
      
      // Enter invalid input
      await tester.enterText(find.byType(TextField), '');
      await tester.tap(find.text('Analisar'));
      await tester.pumpAndSettle();
      
      // Assert - Verify error is handled gracefully
      expect(find.textContaining('erro'), findsOneWidget);
      expect(find.text('Tentar Novamente'), findsOneWidget);
      
      // Test recovery
      await tester.tap(find.text('Tentar Novamente'));
      await tester.pumpAndSettle();
      
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}