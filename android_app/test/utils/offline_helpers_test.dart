import 'package:flutter_test/flutter_test.dart';
import 'package:android_app/utils/offline_helpers.dart';


void main() {
  group('OfflineHelpers Tests', () {
    group('Offline Data Availability', () {
      test('should check if offline data exists', () async {
        expect(await OfflineHelpers.hasOfflineData('emergency_protocols'), isA<bool>());
        expect(await OfflineHelpers.hasOfflineData('medical_guides'), isA<bool>());
        expect(await OfflineHelpers.hasOfflineData('agricultural_tips'), isA<bool>());
        expect(await OfflineHelpers.hasOfflineData('educational_content'), isA<bool>());
        expect(await OfflineHelpers.hasOfflineData('language_packs'), isA<bool>());
      });
      
      test('should return false for non-existent data', () async {
        expect(await OfflineHelpers.hasOfflineData('non_existent'), false);
        expect(await OfflineHelpers.hasOfflineData(''), false);
        expect(await OfflineHelpers.hasOfflineData('invalid_type'), false);
      });
    });
    
    group('Data Synchronization', () {
      test('should sync offline data successfully', () async {
        final result = await OfflineHelpers.syncOfflineData();
        
        expect(result.success, isA<bool>());
        expect(result.syncedItems, isA<int>());
        expect(result.errors, isA<List<String>>());
        expect(result.timestamp, isA<DateTime>());
      });
      
      test('should handle sync timing correctly', () async {
        final startTime = DateTime.now();
        await OfflineHelpers.syncOfflineData();
        final endTime = DateTime.now();
        
        final duration = endTime.difference(startTime);
        expect(duration.inMilliseconds, greaterThanOrEqualTo(100));
      });
    });
    
    group('Data Compression', () {
      test('should compress and decompress data correctly', () {
        final testData = {
          'emergency_type': 'medical',
          'severity': 'high',
          'location': 'Rural village',
          'actions': ['Call 112', 'Apply first aid'],
          'metadata': {
            'timestamp': '2024-01-01T12:00:00Z',
            'language': 'pt-BR'
          }
        };
        
        final compressed = OfflineHelpers.compressData(testData);
        expect(compressed, isA<String>());
        expect(compressed.isNotEmpty, true);
        
        final decompressed = OfflineHelpers.decompressData(compressed);
        expect(decompressed, equals(testData));
      });
      
      test('should handle empty data compression', () {
        final emptyData = <String, dynamic>{};
        final compressed = OfflineHelpers.compressData(emptyData);
        final decompressed = OfflineHelpers.decompressData(compressed);
        
        expect(decompressed, equals(emptyData));
      });
      
      test('should handle complex nested data', () {
        final complexData = {
          'users': [
            {'name': 'João', 'age': 30, 'skills': ['farming', 'first_aid']},
            {'name': 'Maria', 'age': 25, 'skills': ['teaching', 'cooking']}
          ],
          'settings': {
            'language': 'crioulo',
            'offline_mode': true,
            'notifications': {
              'emergency': true,
              'education': false
            }
          }
        };
        
        final compressed = OfflineHelpers.compressData(complexData);
        final decompressed = OfflineHelpers.decompressData(compressed);
        
        expect(decompressed, equals(complexData));
      });
    });
    
    group('Content Download', () {
      test('should download content with progress tracking', () async {
        final progressValues = <double>[];
        
        final success = await OfflineHelpers.downloadContent(
          'emergency_guide_v1',
          onProgress: progressValues.add,
        );
        
        expect(success, isA<bool>());
        if (progressValues.isNotEmpty) {
          expect(progressValues.first, 0.0);
          expect(progressValues.last, 1.0);
          
          // Check progress is monotonically increasing
          for (var i = 1; i < progressValues.length; i++) {
            expect(progressValues[i], greaterThanOrEqualTo(progressValues[i - 1]));
          }
        }
      });
      
      test('should handle download without progress callback', () async {
        final success = await OfflineHelpers.downloadContent('test_content');
        expect(success, isA<bool>());
      });
    });
    
    group('Storage Management', () {
      test('should calculate storage usage', () async {
        final usage = await OfflineHelpers.calculateStorageUsage();
        expect(usage, isA<int>());
        expect(usage, greaterThan(0));
      });
      
      test('should check storage availability', () async {
        // Test with small requirement (should be available)
        expect(await OfflineHelpers.isStorageAvailable(1024 * 1024 * 10), isA<bool>()); // 10 MB
        
        // Test with large requirement (should not be available)
        expect(await OfflineHelpers.isStorageAvailable(1024 * 1024 * 200), isA<bool>()); // 200 MB
        
        // Test edge case
        expect(await OfflineHelpers.isStorageAvailable(1024 * 1024 * 100), isA<bool>()); // Exactly 100 MB
      });
    });
    
    group('Language Support', () {
      test('should return available languages', () async {
        final languages = await OfflineHelpers.getAvailableLanguages();
        
        expect(languages, isA<List<String>>());
        expect(languages, contains('pt-BR'));
        expect(languages, contains('crioulo'));
        expect(languages, contains('fula'));
        expect(languages, contains('mandinga'));
        expect(languages, contains('balanta'));
        expect(languages.length, equals(5));
      });
    });
  });
}