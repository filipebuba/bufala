import 'dart:io';
import 'dart:convert';

const String testBaseUrl = testBaseUrl;

// Import the service to test
import 'package:android_app/services/api_client.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Generate mocks
@GenerateMocks([http.Client])
import 'api_client_test.mocks.dart';

void main() {
  group('ApiClient Tests', () {
    late ApiClient apiClient;
    late MockClient mockHttpClient;
    
    setUp(() {
      mockHttpClient = MockClient();
      apiClient = ApiClient(
        baseUrl: '',
        client: mockHttpClient,
      );
    });
    
    tearDown(() {
      apiClient.dispose();
    });

    group('Initialization', () {
      test('should initialize with default configuration', () {
        final client = ApiClient();
        expect(client, isNotNull);
        client.dispose();
      });
      
      test('should initialize with custom base URL', () {
        final client = ApiClient(baseUrl: 'https://custom.api.com');
        expect(client, isNotNull);
        client.dispose();
      });
    });

    group('GET Requests', () {
      test('should make successful GET request', () async {
        // Arrange
        final responseData = {'success': true, 'data': 'test'};
        when(mockHttpClient.get(
          Uri.parse('/test'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          json.encode(responseData),
          200,
          headers: {'content-type': 'application/json'},
        ));
        
        // Act
        final result = await apiClient.get('/test');
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data'], equals('test'));
      });
      
      test('should handle GET request errors', () async {
        // Arrange
        when(mockHttpClient.get(
          Uri.parse('/error'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          json.encode({'error': 'Not found'}),
          404,
        ));
        
        // Act & Assert
        expect(
          () => apiClient.get('/error'),
          throwsA(isA<Exception>()),
        );
      });
      
      test('should handle network timeout', () async {
        // Arrange
        when(mockHttpClient.get(
          Uri.parse('/timeout'),
          headers: anyNamed('headers'),
        )).thenThrow(Exception('Connection timeout'));
        
        // Act & Assert
        expect(
          () => apiClient.get('/timeout'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('POST Requests', () {
      test('should make successful POST request', () async {
        // Arrange
        final requestData = {'message': 'Hello'};
        final responseData = {'success': true, 'echo': 'Hello'};
        
        when(mockHttpClient.post(
          Uri.parse('/echo'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
          json.encode(responseData),
          200,
          headers: {'content-type': 'application/json'},
        ));
        
        // Act
        final result = await apiClient.post('/echo', requestData);
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['echo'], equals('Hello'));
      });
      
      test('should handle POST request with empty body', () async {
        // Arrange
        final responseData = {'success': true};
        
        when(mockHttpClient.post(
          Uri.parse('/empty'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
          json.encode(responseData),
          200,
          headers: {'content-type': 'application/json'},
        ));
        
        // Act
        final result = await apiClient.post('/empty', {});
        
        // Assert
        expect(result['success'], isTrue);
      });
      
      test('should handle POST request server errors', () async {
        // Arrange
        when(mockHttpClient.post(
          Uri.parse('/server-error'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
          json.encode({'error': 'Internal server error'}),
          500,
        ));
        
        // Act & Assert
        expect(
          () => apiClient.post('/server-error', {}),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('PUT Requests', () {
      test('should make successful PUT request', () async {
        // Arrange
        final requestData = {'id': 1, 'name': 'Updated'};
        final responseData = {'success': true, 'updated': true};
        
        when(mockHttpClient.put(
          Uri.parse('/update/1'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).thenAnswer((_) async => http.Response(
          json.encode(responseData),
          200,
          headers: {'content-type': 'application/json'},
        ));
        
        // Act
        final result = await apiClient.put('/update/1', requestData);
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['updated'], isTrue);
      });
    });

    group('DELETE Requests', () {
      test('should make successful DELETE request', () async {
        // Arrange
        final responseData = {'success': true, 'deleted': true};
        
        when(mockHttpClient.delete(
          Uri.parse('/delete/1'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          json.encode(responseData),
          200,
          headers: {'content-type': 'application/json'},
        ));
        
        // Act
        final result = await apiClient.delete('/delete/1');
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['deleted'], isTrue);
      });
    });

    group('Headers and Authentication', () {
      test('should include default headers', () async {
        // Arrange
        when(mockHttpClient.get(
          Uri.parse('/test'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          json.encode({'success': true}),
          200,
        ));
        
        // Act
        await apiClient.get('/test');
        
        // Assert
        verify(mockHttpClient.get(
          Uri.parse('/test'),
          headers: argThat(
            containsPair('Content-Type', 'application/json'),
            named: 'headers',
          ),
        )).called(1);
      });
      
      test('should include custom headers', () async {
        // Arrange
        final customHeaders = {'Authorization': 'Bearer token123'};
        
        when(mockHttpClient.get(
          Uri.parse('/protected'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          json.encode({'success': true}),
          200,
        ));
        
        // Act
        await apiClient.get('/protected', headers: customHeaders);
        
        // Assert
        verify(mockHttpClient.get(
          Uri.parse('/protected'),
          headers: argThat(
            allOf([
              containsPair('Content-Type', 'application/json'),
              containsPair('Authorization', 'Bearer token123'),
            ]),
            named: 'headers',
          ),
        )).called(1);
      });
    });

    group('Configuration Management', () {
      test('should reset configuration', () {
        // Act
        apiClient.reset();
        
        // Assert - Should not throw any exceptions
        expect(() => apiClient.reset(), returnsNormally);
      });
      
      test('should handle base URL changes', () {
        // Arrange
        final newClient = ApiClient(baseUrl: 'https://new.api.com');
        
        // Assert
        expect(newClient, isNotNull);
        
        // Cleanup
        newClient.dispose();
      });
    });

    group('Error Handling', () {
      test('should handle malformed JSON response', () async {
        // Arrange
        when(mockHttpClient.get(
          Uri.parse('/malformed'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          'Invalid JSON{',
          200,
          headers: {'content-type': 'application/json'},
        ));
        
        // Act & Assert
        expect(
          () => apiClient.get('/malformed'),
          throwsA(isA<FormatException>()),
        );
      });
      
      test('should handle empty response', () async {
        // Arrange
        when(mockHttpClient.get(
          Uri.parse('/empty'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response(
          '',
          200,
        ));
        
        // Act & Assert
        expect(
          () => apiClient.get('/empty'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Performance', () {
      test('should complete requests within reasonable time', () async {
        // Arrange
        when(mockHttpClient.get(
          Uri.parse('/fast'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
          return http.Response(
            json.encode({'success': true}),
            200,
          );
        });
        
        // Act
        final stopwatch = Stopwatch()..start();
        await apiClient.get('/fast');
        stopwatch.stop();
        
        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      });
    });
  });
}