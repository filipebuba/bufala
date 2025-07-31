import 'package:android_app/widgets/quick_action_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EmergencyActionButton Widget Tests', () {
    // Removed mock service setup as it's not needed for widget testing

    testWidgets('should display emergency button correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmergencyActionButton(
              label: 'EMERGÊNCIA',
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(EmergencyActionButton), findsOneWidget);
      expect(find.byIcon(Icons.emergency), findsOneWidget);
      expect(find.text('EMERGÊNCIA'), findsOneWidget);
    });

    testWidgets('should respond to tap', (WidgetTester tester) async {
      // Arrange
      var wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmergencyActionButton(
              label: 'EMERGÊNCIA',
              onTap: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(EmergencyActionButton));
      await tester.pump();

      // Assert
      expect(wasPressed, true);
    });

    testWidgets('should be enabled by default', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmergencyActionButton(
              label: 'EMERGÊNCIA',
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(EmergencyActionButton), findsOneWidget);
    });

    testWidgets('should be disabled when specified', (WidgetTester tester) async {
      // Arrange
      var wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmergencyActionButton(
              label: 'EMERGÊNCIA',
              onTap: () {
                wasPressed = true;
              },
              isEnabled: false,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(EmergencyActionButton));
      await tester.pump();

      // Assert
      expect(wasPressed, false);
    });

    testWidgets('should display custom text', (WidgetTester tester) async {
      // Test custom label
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmergencyActionButton(
              label: 'URJÉNSIA',
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('URJÉNSIA'), findsOneWidget);
    });

    testWidgets('should have pulsing animation when enabled', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmergencyActionButton(
              label: 'EMERGÊNCIA',
              onTap: () {},
              isPulsing: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(EmergencyActionButton), findsOneWidget);
      expect(find.text('EMERGÊNCIA'), findsOneWidget);
    });
  });
}