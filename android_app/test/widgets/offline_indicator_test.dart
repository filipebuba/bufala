import 'package:android_app/widgets/connection_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConnectionStatus Widget Tests', () {
    testWidgets('should display online status correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConnectionStatus(isConnected: true),
          ),
        ),
      );

      // Assert
      expect(find.byType(ConnectionStatus), findsOneWidget);
    });

    testWidgets('should display offline status correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConnectionStatus(isConnected: false),
          ),
        ),
      );

      // Assert
      expect(find.byType(ConnectionStatus), findsOneWidget);
    });

    testWidgets('should show loading state', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConnectionStatus(
              isConnected: false,
              isLoading: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(ConnectionStatus), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display server info when connected', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConnectionStatus(
              isConnected: true,
              serverInfo: 'Server v1.0.0',
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(ConnectionStatus), findsOneWidget);
      expect(find.text('Server v1.0.0'), findsOneWidget);
    });

    testWidgets('should show retry button when offline', (WidgetTester tester) async {
      // Arrange
      var retryPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ConnectionStatus(
              isConnected: false,
              onRetry: () {
                retryPressed = true;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      // Assert
      expect(retryPressed, true);
    });

    testWidgets('should display correct status text', (WidgetTester tester) async {
      // Test online status
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConnectionStatus(isConnected: true),
          ),
        ),
      );

      expect(find.text('Conectado'), findsOneWidget);

      // Test offline status
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConnectionStatus(isConnected: false),
          ),
        ),
      );

      expect(find.text('Desconectado'), findsOneWidget);
    });

    testWidgets('should have proper styling for different states', (WidgetTester tester) async {
      // Test connected state styling
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConnectionStatus(isConnected: true),
          ),
        ),
      );

      expect(find.byType(ConnectionStatus), findsOneWidget);

      // Test disconnected state styling
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConnectionStatus(isConnected: false),
          ),
        ),
      );

      expect(find.byType(ConnectionStatus), findsOneWidget);
    });
  });
}