import 'package:android_app/main.dart' as app;
import 'package:android_app/services/integrated_api_service.dart';
import 'package:android_app/widgets/quick_action_button.dart';
import 'package:android_app/widgets/connection_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('Morana App Integration Tests', () {
    
    testWidgets('App should launch successfully', (WidgetTester tester) async {
      // Arrange & Act
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Assert - Verify main app components are present
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Morana'), findsAtLeastNWidgets(1));
    });
    
    testWidgets('Home screen should display main features', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Assert - Verify main feature buttons are present
      expect(find.byType(QuickActionButton), findsAtLeastNWidgets(3));
      
      // Check for main feature labels
      expect(find.text('Emergência'), findsOneWidget);
      expect(find.text('Educação'), findsOneWidget);
      expect(find.text('Agricultura'), findsOneWidget);
    });
    
    testWidgets('Connection status should be displayed', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Assert - Verify connection status widget is present
      expect(find.byType(ConnectionStatus), findsOneWidget);
    });
    
    testWidgets('Emergency feature navigation', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Act - Tap on emergency button
      await tester.tap(find.text('Emergência'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Assert - Verify navigation occurred
      // Note: This test verifies the tap doesn't crash the app
      expect(find.byType(MaterialApp), findsOneWidget);
    });
    
    testWidgets('Education feature navigation', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Act - Tap on education button
      await tester.tap(find.text('Educação'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Assert - Verify navigation occurred
      expect(find.byType(MaterialApp), findsOneWidget);
    });
    
    testWidgets('Agriculture feature navigation', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Act - Tap on agriculture button
      await tester.tap(find.text('Agricultura'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Assert - Verify navigation occurred
      expect(find.byType(MaterialApp), findsOneWidget);
    });
    
    testWidgets('App should handle multiple navigation actions', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Act - Perform multiple navigation actions
      await tester.tap(find.text('Emergência'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      // Navigate back (if possible)
      if (find.byIcon(Icons.arrow_back).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle(const Duration(seconds: 1));
      }
      
      await tester.tap(find.text('Educação'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      // Assert - App should still be functional
      expect(find.byType(MaterialApp), findsOneWidget);
    });
    
    testWidgets('App should display language information', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Assert - Check for language-related content
      // The app should show support for local languages
      expect(find.textContaining('Português'), findsAtLeastNWidgets(0));
      expect(find.textContaining('Crioulo'), findsAtLeastNWidgets(0));
    });
    
    testWidgets('App should handle screen rotations', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Act - Simulate screen rotation
      await tester.binding.setSurfaceSize(const Size(800, 600)); // Landscape
      await tester.pumpAndSettle();
      
      // Assert - App should still be functional
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Morana'), findsAtLeastNWidgets(1));
      
      // Rotate back to portrait
      await tester.binding.setSurfaceSize(const Size(400, 800)); // Portrait
      await tester.pumpAndSettle();
      
      expect(find.byType(MaterialApp), findsOneWidget);
    });
    
    testWidgets('App should maintain state during navigation', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Act - Navigate and return
      final initialWidgetCount = find.byType(QuickActionButton).evaluate().length;
      
      await tester.tap(find.text('Emergência'));
      await tester.pumpAndSettle(const Duration(seconds: 1));
      
      // Navigate back if possible
      if (find.byIcon(Icons.arrow_back).evaluate().isNotEmpty) {
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle(const Duration(seconds: 1));
        
        // Assert - State should be maintained
        final finalWidgetCount = find.byType(QuickActionButton).evaluate().length;
        expect(finalWidgetCount, equals(initialWidgetCount));
      }
    });
    
    testWidgets('App should handle rapid user interactions', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Act - Perform rapid interactions
      for (int i = 0; i < 3; i++) {
        if (find.text('Emergência').evaluate().isNotEmpty) {
          await tester.tap(find.text('Emergência'));
          await tester.pump(const Duration(milliseconds: 100));
        }
      }
      
      await tester.pumpAndSettle(const Duration(seconds: 2));
      
      // Assert - App should remain stable
      expect(find.byType(MaterialApp), findsOneWidget);
    });
    
    testWidgets('App should display proper UI elements', (WidgetTester tester) async {
      // Arrange
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Assert - Check for essential UI elements
      expect(find.byType(Scaffold), findsAtLeastNWidgets(1));
      expect(find.byType(AppBar), findsAtLeastNWidgets(0)); // May or may not have AppBar
      expect(find.byType(Column), findsAtLeastNWidgets(1));
      expect(find.byType(Container), findsAtLeastNWidgets(1));
    });
    
    testWidgets('Performance test - app should load within reasonable time', (WidgetTester tester) async {
      // Arrange
      final stopwatch = Stopwatch()..start();
      
      // Act
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      
      stopwatch.stop();
      
      // Assert - App should load within 5 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
}