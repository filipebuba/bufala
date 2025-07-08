import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock EmergencyContactCard widget for testing
class EmergencyContactCard extends StatelessWidget {
  
  const EmergencyContactCard({
    required this.name, required this.phone, required this.specialty, required this.distance, super.key,
    this.onCall,
    this.onMessage,
    this.isAvailable = true,
    this.profileImage,
  });
  final String name;
  final String phone;
  final String specialty;
  final String distance;
  final VoidCallback? onCall;
  final VoidCallback? onMessage;
  final bool isAvailable;
  final String? profileImage;
  
  @override
  Widget build(BuildContext context) => Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage: profileImage != null 
                      ? NetworkImage(profileImage!) 
                      : null,
                  child: profileImage == null 
                      ? const Icon(Icons.person, size: 30, color: Colors.blue)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        specialty,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            distance,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isAvailable ? Colors.green : Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              isAvailable ? 'Disponível' : 'Ocupado',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.phone, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  phone,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onCall,
                    icon: const Icon(Icons.phone, size: 18),
                    label: const Text('Ligar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onMessage,
                    icon: const Icon(Icons.message, size: 18),
                    label: const Text('Mensagem'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
}

void main() {
  group('EmergencyContactCard Widget Tests', () {
    testWidgets('should display all contact information correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmergencyContactCard(
              name: 'Dr. João Silva',
              phone: '+245 123 456 789',
              specialty: 'Medicina Geral',
              distance: '2.5 km',
            ),
          ),
        ),
      );
      
      expect(find.text('Dr. João Silva'), findsOneWidget);
      expect(find.text('+245 123 456 789'), findsOneWidget);
      expect(find.text('Medicina Geral'), findsOneWidget);
      expect(find.text('2.5 km'), findsOneWidget);
    });
    
    testWidgets('should show availability status correctly', (tester) async {
      // Test available status
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmergencyContactCard(
              name: 'Dr. Maria Santos',
              phone: '+245 987 654 321',
              specialty: 'Pediatria',
              distance: '1.2 km',
            ),
          ),
        ),
      );
      
      expect(find.text('Disponível'), findsOneWidget);
      
      // Test unavailable status
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmergencyContactCard(
              name: 'Dr. Maria Santos',
              phone: '+245 987 654 321',
              specialty: 'Pediatria',
              distance: '1.2 km',
              isAvailable: false,
            ),
          ),
        ),
      );
      
      expect(find.text('Ocupado'), findsOneWidget);
    });
    
    testWidgets('should handle call button tap', (tester) async {
      var callInitiated = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmergencyContactCard(
              name: 'Dr. João Silva',
              phone: '+245 123 456 789',
              specialty: 'Medicina Geral',
              distance: '2.5 km',
              onCall: () => callInitiated = true,
            ),
          ),
        ),
      );
      
      await tester.tap(find.text('Ligar'));
      await tester.pump();
      
      expect(callInitiated, true);
    });
    
    testWidgets('should handle message button tap', (tester) async {
      var messageInitiated = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmergencyContactCard(
              name: 'Dr. João Silva',
              phone: '+245 123 456 789',
              specialty: 'Medicina Geral',
              distance: '2.5 km',
              onMessage: () => messageInitiated = true,
            ),
          ),
        ),
      );
      
      await tester.tap(find.text('Mensagem'));
      await tester.pump();
      
      expect(messageInitiated, true);
    });
    
    testWidgets('should display default avatar when no profile image', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmergencyContactCard(
              name: 'Dr. João Silva',
              phone: '+245 123 456 789',
              specialty: 'Medicina Geral',
              distance: '2.5 km',
            ),
          ),
        ),
      );
      
      expect(find.byIcon(Icons.person), findsOneWidget);
      expect(find.byType(CircleAvatar), findsOneWidget);
      
      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(avatar.radius, 30);
      expect(avatar.backgroundColor, Colors.blue.shade100);
    });
    
    testWidgets('should display profile image when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmergencyContactCard(
              name: 'Dr. João Silva',
              phone: '+245 123 456 789',
              specialty: 'Medicina Geral',
              distance: '2.5 km',
              profileImage: 'https://example.com/profile.jpg',
            ),
          ),
        ),
      );
      
      final avatar = tester.widget<CircleAvatar>(find.byType(CircleAvatar));
      expect(avatar.backgroundImage, isA<NetworkImage>());
      expect(avatar.child, isNull);
    });
    
    testWidgets('should have proper button styling', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmergencyContactCard(
              name: 'Dr. João Silva',
              phone: '+245 123 456 789',
              specialty: 'Medicina Geral',
              distance: '2.5 km',
            ),
          ),
        ),
      );
      
      // Check call button styling
      final callButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Ligar'),
      );
      final callButtonStyle = callButton.style!;
      expect(
        callButtonStyle.backgroundColor?.resolve({}),
        Colors.green,
      );
      expect(
        callButtonStyle.foregroundColor?.resolve({}),
        Colors.white,
      );
      
      // Check message button styling
      final messageButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Mensagem'),
      );
      final messageButtonStyle = messageButton.style!;
      expect(
        messageButtonStyle.backgroundColor?.resolve({}),
        Colors.blue,
      );
      expect(
        messageButtonStyle.foregroundColor?.resolve({}),
        Colors.white,
      );
    });
    
    testWidgets('should display icons correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmergencyContactCard(
              name: 'Dr. João Silva',
              phone: '+245 123 456 789',
              specialty: 'Medicina Geral',
              distance: '2.5 km',
            ),
          ),
        ),
      );
      
      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.byIcon(Icons.phone), findsNWidgets(2)); // One in info, one in button
      expect(find.byIcon(Icons.message), findsOneWidget);
      expect(find.byIcon(Icons.person), findsOneWidget); // Default avatar
    });
    
    testWidgets('should work without callback functions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmergencyContactCard(
              name: 'Dr. João Silva',
              phone: '+245 123 456 789',
              specialty: 'Medicina Geral',
              distance: '2.5 km',
            ),
          ),
        ),
      );
      
      // Should not throw when buttons are tapped without callbacks
      await tester.tap(find.text('Ligar'));
      await tester.pump();
      
      await tester.tap(find.text('Mensagem'));
      await tester.pump();
      
      // Widget should still be present
      expect(find.byType(EmergencyContactCard), findsOneWidget);
    });
    
    testWidgets('should have proper card styling and layout', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmergencyContactCard(
              name: 'Dr. João Silva',
              phone: '+245 123 456 789',
              specialty: 'Medicina Geral',
              distance: '2.5 km',
            ),
          ),
        ),
      );
      
      final card = tester.widget<Card>(find.byType(Card));
      expect(card.elevation, 4);
      expect(card.margin, const EdgeInsets.symmetric(horizontal: 16, vertical: 8));
      
      // Check layout structure
      expect(find.byType(Column), findsAtLeastNWidgets(1));
      expect(find.byType(Row), findsAtLeastNWidgets(1));
      expect(find.byType(Expanded), findsAtLeastNWidgets(1));
    });
    
    testWidgets('should handle long names and specialties gracefully', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmergencyContactCard(
              name: 'Dr. João Silva Santos Oliveira da Costa',
              phone: '+245 123 456 789',
              specialty: 'Medicina Geral e Cirurgia Cardiovascular Especializada',
              distance: '15.7 km',
            ),
          ),
        ),
      );
      
      expect(find.text('Dr. João Silva Santos Oliveira da Costa'), findsOneWidget);
      expect(find.text('Medicina Geral e Cirurgia Cardiovascular Especializada'), findsOneWidget);
      expect(find.text('15.7 km'), findsOneWidget);
    });
  });
}