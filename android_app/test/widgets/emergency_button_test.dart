import 'package:bufala/services/crisis_response_service.dart';
import 'package:bufala/widgets/emergency_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Generate mocks
@GenerateMocks([CrisisResponseService])
import 'emergency_button_test.mocks.dart';

void main() {
  group('EmergencyButton Widget Tests', () {
    late MockCrisisResponseService mockService;
    
    setUp(() {
      mockService = MockCrisisResponseService();
    });
    
    testWidgets('should display emergency button correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmergencyButton(
              onPressed: () {},
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(EmergencyButton), findsOneWidget);
      expect(find.byIcon(Icons.emergency), findsOneWidget);
      expect(find.text('EMERGÊNCIA'), findsOneWidget);
    });
    
    testWidgets('should respond to tap', (WidgetTester tester) async {
      // Arrange
      var wasPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmergencyButton(
              onPressed: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );
      
      // Act
      await tester.tap(find.byType(EmergencyButton));
      await tester.pump();
      
      // Assert
      expect(wasPressed, true);
    });
    
    testWidgets('should show loading state during emergency call', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmergencyButton(
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );
      
      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
    
    testWidgets('should be disabled when specified', (WidgetTester tester) async {
      // Arrange
      var wasPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmergencyButton(
              onPressed: () {
                wasPressed = true;
              },
              enabled: false,
            ),
          ),
        ),
      );
      
      // Act
      await tester.tap(find.byType(EmergencyButton));
      await tester.pump();
      
      // Assert
      expect(wasPressed, false);
    });
    
    testWidgets('should display correct text in different languages', (WidgetTester tester) async {
      // Test Kriolu
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmergencyButton(
              onPressed: () {},
              language: 'kriolu',
            ),
          ),
        ),
      );
      
      expect(find.text('URJÉNSIA'), findsOneWidget);
      
      // Test Portuguese
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmergencyButton(
              onPressed: () {},
              language: 'portuguese',
            ),
          ),
        ),
      );
      
      expect(find.text('EMERGÊNCIA'), findsOneWidget);
    });
    
    testWidgets('should have accessibility features', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmergencyButton(
              onPressed: () {},
            ),
          ),
        ),
      );
      
      // Assert
      final semantics = tester.getSemantics(find.byType(EmergencyButton));
      expect(semantics.hasAction(SemanticsAction.tap), true);
      expect(semantics.label, contains('Emergência'));
    });
  });
}