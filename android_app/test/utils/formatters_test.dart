import 'package:flutter_test/flutter_test.dart';
import 'package:android_app/utils/formatters.dart';


void main() {
  group('Formatters Tests', () {
    group('Severity Formatting', () {
      test('should format emergency severity levels correctly', () {
        expect(Formatters.formatSeverity('critical'), 'Crítico');
        expect(Formatters.formatSeverity('high'), 'Alto');
        expect(Formatters.formatSeverity('medium'), 'Médio');
        expect(Formatters.formatSeverity('low'), 'Baixo');
      });
      
      test('should handle case insensitive input', () {
        expect(Formatters.formatSeverity('CRITICAL'), 'Crítico');
        expect(Formatters.formatSeverity('High'), 'Alto');
        expect(Formatters.formatSeverity('MEDIUM'), 'Médio');
      });
      
      test('should handle unknown severity levels', () {
        expect(Formatters.formatSeverity('unknown'), 'Desconhecido');
        expect(Formatters.formatSeverity(''), 'Desconhecido');
        expect(Formatters.formatSeverity('invalid'), 'Desconhecido');
      });
    });
    
    group('Distance Formatting', () {
      test('should format distances in meters for short distances', () {
        expect(Formatters.formatDistance(0), '0 m');
        expect(Formatters.formatDistance(500), '500 m');
        expect(Formatters.formatDistance(999), '999 m');
      });
      
      test('should format distances in kilometers for long distances', () {
        expect(Formatters.formatDistance(1000), '1.0 km');
        expect(Formatters.formatDistance(1500), '1.5 km');
        expect(Formatters.formatDistance(2500), '2.5 km');
        expect(Formatters.formatDistance(10000), '10.0 km');
      });
      
      test('should handle decimal precision correctly', () {
        expect(Formatters.formatDistance(1234), '1.2 km');
        expect(Formatters.formatDistance(1567), '1.6 km');
      });
    });
    
    group('Time Ago Formatting', () {
      test('should format recent times correctly', () {
        final now = DateTime.now();
        
        // Just now
        expect(Formatters.formatTimeAgo(now), 'agora');
        
        // Minutes ago
        final fiveMinutesAgo = now.subtract(const Duration(minutes: 5));
        expect(Formatters.formatTimeAgo(fiveMinutesAgo), 'há 5 min');
        
        // Hours ago
        final oneHourAgo = now.subtract(const Duration(hours: 1));
        expect(Formatters.formatTimeAgo(oneHourAgo), 'há 1 hora');
        
        final twoHoursAgo = now.subtract(const Duration(hours: 2));
        expect(Formatters.formatTimeAgo(twoHoursAgo), 'há 2 horas');
        
        // Days ago
        final oneDayAgo = now.subtract(const Duration(days: 1));
        expect(Formatters.formatTimeAgo(oneDayAgo), 'há 1 dia');
        
        final threeDaysAgo = now.subtract(const Duration(days: 3));
        expect(Formatters.formatTimeAgo(threeDaysAgo), 'há 3 dias');
      });
    });
    
    group('Emergency Type Formatting', () {
      test('should format emergency types correctly', () {
        expect(Formatters.formatEmergencyType('medical'), 'Emergência Médica');
        expect(Formatters.formatEmergencyType('fire'), 'Incêndio');
        expect(Formatters.formatEmergencyType('accident'), 'Acidente');
        expect(Formatters.formatEmergencyType('natural_disaster'), 'Desastre Natural');
        expect(Formatters.formatEmergencyType('security'), 'Segurança');
      });
      
      test('should handle unknown emergency types', () {
        expect(Formatters.formatEmergencyType('unknown'), 'Emergência Geral');
        expect(Formatters.formatEmergencyType(''), 'Emergência Geral');
      });
    });
    
    group('File Size Formatting', () {
      test('should format file sizes correctly', () {
        expect(Formatters.formatFileSize(512), '512 B');
        expect(Formatters.formatFileSize(1024), '1.0 KB');
        expect(Formatters.formatFileSize(1536), '1.5 KB');
        expect(Formatters.formatFileSize(1048576), '1.0 MB');
        expect(Formatters.formatFileSize(2097152), '2.0 MB');
      });
      
      test('should handle edge cases', () {
        expect(Formatters.formatFileSize(0), '0 B');
        expect(Formatters.formatFileSize(1023), '1023 B');
        expect(Formatters.formatFileSize(1025), '1.0 KB');
      });
    });
  });
}