import 'package:android_app/widgets/quick_action_button.dart';
import 'package:android_app/widgets/connection_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Simple test app without external dependencies
class TestMoranaApp extends StatelessWidget {
  const TestMoranaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Morana Test',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Morana'),
        ),
        body: Column(
           children: [
             const ConnectionStatus(
               isConnected: true,
               serverInfo: 'Test Server',
             ),
             QuickActionButton(
               label: 'Emergência',
               icon: Icons.emergency,
               color: Colors.red,
               onTap: () {},
             ),
             QuickActionButton(
               label: 'Educação',
               icon: Icons.school,
               color: Colors.blue,
               onTap: () {},
             ),
             QuickActionButton(
               label: 'Agricultura',
               icon: Icons.agriculture,
               color: Colors.green,
               onTap: () {},
             ),
           ],
         ),
      ),
    );
  }
}

void main() {
  group('App Widget Integration Tests', () {
    
    // No setup needed for widget integration tests
    
    testWidgets('TestMoranaApp should build without errors', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(const TestMoranaApp());
      await tester.pumpAndSettle();
      
      // Assert - Verify main app components are present
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Morana'), findsOneWidget);
    });
    
    testWidgets('Home screen should display main features', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const TestMoranaApp());
      await tester.pumpAndSettle();
      
      // Assert - Verify main feature buttons are present
      expect(find.byType(QuickActionButton), findsNWidgets(3));
      
      // Check for main feature labels
      expect(find.text('Emergência'), findsOneWidget);
      expect(find.text('Educação'), findsOneWidget);
      expect(find.text('Agricultura'), findsOneWidget);
    });
    
    testWidgets('Connection status should be displayed', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const TestMoranaApp());
      await tester.pumpAndSettle();
      
      // Assert - Verify connection status widget is present
      expect(find.byType(ConnectionStatus), findsOneWidget);
    });
    
    testWidgets('Emergency feature should be present', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const TestMoranaApp());
      await tester.pumpAndSettle();
      
      // Assert - Verify emergency button is present
      final emergencyButton = find.text('Emergência');
      expect(emergencyButton, findsOneWidget);
      
      // Verify the button widget exists
      expect(find.byType(QuickActionButton), findsNWidgets(3));
    });
    
    testWidgets('Education feature should be present', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const TestMoranaApp());
      await tester.pumpAndSettle();
      
      // Assert - Verify education button is present
      final educationButton = find.text('Educação');
      expect(educationButton, findsOneWidget);
    });
    
    testWidgets('Agriculture feature should be present', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const TestMoranaApp());
      await tester.pumpAndSettle();
      
      // Assert - Verify agriculture button is present
      final agricultureButton = find.text('Agricultura');
      expect(agricultureButton, findsOneWidget);
    });
    
    testWidgets('App should display proper UI structure', (WidgetTester tester) async {
       // Arrange
       await tester.pumpWidget(const TestMoranaApp());
       await tester.pumpAndSettle();
       
       // Assert - Check for essential UI elements
       expect(find.byType(Scaffold), findsOneWidget);
       expect(find.byType(AppBar), findsOneWidget);
       expect(find.byType(Column), findsAtLeastNWidgets(1));
     });
    
    testWidgets('App should handle screen size changes', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(const TestMoranaApp());
      await tester.pumpAndSettle();
      
      // Act - Change screen size
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpAndSettle();
      
      // Assert - App should still be functional
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('Morana'), findsOneWidget);
      
      // Reset to original size
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();
      
      expect(find.byType(MaterialApp), findsOneWidget);
    });
    
    testWidgets('App should load quickly', (WidgetTester tester) async {
      // Arrange
      final stopwatch = Stopwatch()..start();
      
      // Act
      await tester.pumpWidget(const TestMoranaApp());
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // Assert - App should load within 2 seconds
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
      expect(find.byType(MaterialApp), findsOneWidget);
    });
    
    testWidgets('All widgets should render correctly', (WidgetTester tester) async {
       // Arrange
       await tester.pumpWidget(const TestMoranaApp());
       await tester.pumpAndSettle();
       
       // Assert - Verify all expected widgets are present
       expect(find.byType(MaterialApp), findsOneWidget);
       expect(find.byType(Scaffold), findsOneWidget);
       expect(find.byType(AppBar), findsOneWidget);
       expect(find.byType(Column), findsAtLeastNWidgets(1));
       expect(find.byType(ConnectionStatus), findsOneWidget);
       expect(find.byType(QuickActionButton), findsNWidgets(3));
       
       // Verify text content
       expect(find.text('Morana'), findsOneWidget);
       expect(find.text('Emergência'), findsOneWidget);
       expect(find.text('Educação'), findsOneWidget);
       expect(find.text('Agricultura'), findsOneWidget);
     });
  });
}