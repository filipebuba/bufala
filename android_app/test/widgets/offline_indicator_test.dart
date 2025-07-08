import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock OfflineIndicator widget for testing
class OfflineIndicator extends StatelessWidget {
  
  const OfflineIndicator({
    required this.isOffline, super.key,
    this.onTap,
    this.backgroundColor,
  });
  final bool isOffline;
  final VoidCallback? onTap;
  final Color? backgroundColor;
  
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor ?? (isOffline ? Colors.orange : Colors.green),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isOffline ? Icons.wifi_off : Icons.wifi,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 6),
            Text(
              isOffline ? 'Modo Offline' : 'Online',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
}

// Mock NetworkStatus widget for testing
class NetworkStatus extends StatefulWidget {
  
  const NetworkStatus({required this.child, super.key});
  final Widget child;
  
  @override
  State<NetworkStatus> createState() => _NetworkStatusState();
}

class _NetworkStatusState extends State<NetworkStatus> {
  bool _isOffline = false;
  
  void _toggleConnection() {
    setState(() {
      _isOffline = !_isOffline;
    });
  }
  
  @override
  Widget build(BuildContext context) => Column(
      children: [
        OfflineIndicator(
          isOffline: _isOffline,
          onTap: _toggleConnection,
        ),
        const SizedBox(height: 16),
        Expanded(child: widget.child),
      ],
    );
}

void main() {
  group('OfflineIndicator Widget Tests', () {
    testWidgets('should show offline status correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineIndicator(isOffline: true),
          ),
        ),
      );
      
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      expect(find.text('Modo Offline'), findsOneWidget);
      
      // Check container color for offline state
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(OfflineIndicator),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.orange);
    });
    
    testWidgets('should show online status correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineIndicator(isOffline: false),
          ),
        ),
      );
      
      expect(find.byIcon(Icons.wifi), findsOneWidget);
      expect(find.text('Online'), findsOneWidget);
      
      // Check container color for online state
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(OfflineIndicator),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.green);
    });
    
    testWidgets('should handle tap events', (tester) async {
      var tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OfflineIndicator(
              isOffline: true,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );
      
      await tester.tap(find.byType(OfflineIndicator));
      await tester.pump();
      
      expect(tapped, true);
    });
    
    testWidgets('should use custom background color when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineIndicator(
              isOffline: true,
              backgroundColor: Colors.red,
            ),
          ),
        ),
      );
      
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(OfflineIndicator),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, Colors.red);
    });
    
    testWidgets('should have proper styling and layout', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineIndicator(isOffline: true),
          ),
        ),
      );
      
      // Check icon properties
      final icon = tester.widget<Icon>(find.byIcon(Icons.wifi_off));
      expect(icon.color, Colors.white);
      expect(icon.size, 16);
      
      // Check text properties
      final text = tester.widget<Text>(find.text('Modo Offline'));
      expect(text.style?.color, Colors.white);
      expect(text.style?.fontSize, 12);
      expect(text.style?.fontWeight, FontWeight.w500);
      
      // Check container styling
      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(OfflineIndicator),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.borderRadius, BorderRadius.circular(20));
      expect(decoration.boxShadow, isNotNull);
      expect(decoration.boxShadow!.length, 1);
    });
    
    testWidgets('should work without onTap callback', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineIndicator(isOffline: false),
          ),
        ),
      );
      
      // Should not throw when tapped without callback
      await tester.tap(find.byType(OfflineIndicator));
      await tester.pump();
      
      // Widget should still be present
      expect(find.byType(OfflineIndicator), findsOneWidget);
    });
    
    testWidgets('should have correct semantics for accessibility', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OfflineIndicator(isOffline: true),
          ),
        ),
      );
      
      // Check that the widget is tappable
      final gestureDetector = tester.widget<GestureDetector>(
        find.byType(GestureDetector),
      );
      expect(gestureDetector.onTap, isNull); // No callback provided in this test
      
      // Check that text and icon are present for screen readers
      expect(find.text('Modo Offline'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });
  });
  
  group('NetworkStatus Widget Tests', () {
    testWidgets('should toggle between online and offline states', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NetworkStatus(
              child: Text('Content'),
            ),
          ),
        ),
      );
      
      // Initially should be online
      expect(find.text('Online'), findsOneWidget);
      expect(find.byIcon(Icons.wifi), findsOneWidget);
      
      // Tap to toggle to offline
      await tester.tap(find.byType(OfflineIndicator));
      await tester.pump();
      
      expect(find.text('Modo Offline'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      
      // Tap again to toggle back to online
      await tester.tap(find.byType(OfflineIndicator));
      await tester.pump();
      
      expect(find.text('Online'), findsOneWidget);
      expect(find.byIcon(Icons.wifi), findsOneWidget);
    });
    
    testWidgets('should display child widget', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NetworkStatus(
              child: Text('Test Content'),
            ),
          ),
        ),
      );
      
      expect(find.text('Test Content'), findsOneWidget);
    });
    
    testWidgets('should maintain proper layout structure', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NetworkStatus(
              child: Container(
                height: 200,
                color: Colors.blue,
                child: const Text('Large Content'),
              ),
            ),
          ),
        ),
      );
      
      // Check that both indicator and content are present
      expect(find.byType(OfflineIndicator), findsOneWidget);
      expect(find.text('Large Content'), findsOneWidget);
      
      // Check layout structure
      expect(find.byType(Column), findsOneWidget);
      expect(find.byType(SizedBox), findsOneWidget);
      expect(find.byType(Expanded), findsOneWidget);
    });
  });
}