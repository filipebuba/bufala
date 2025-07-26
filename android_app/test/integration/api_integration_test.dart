import 'package:android_app/services/api_client.dart';
import 'package:android_app/services/endpoints/agriculture_service.dart';
import 'package:android_app/services/endpoints/education_service.dart';
import 'package:android_app/services/endpoints/medical_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('API Integration Tests', () {
    late ApiClient apiClient;
    late MedicalService medicalService;
    late EducationService educationService;
    late AgricultureService agricultureService;

    setUp(() {
      apiClient = ApiClient();
      medicalService = MedicalService(apiClient: apiClient);
      educationService = EducationService(apiClient: apiClient);
      agricultureService = AgricultureService(apiClient: apiClient);
    });

    test('Health check should return true', () async {
      final isConnected = await apiClient.checkConnectivity();
      expect(isConnected, isTrue);
    });

    test('Medical endpoint should return valid response', () async {
      final response = await medicalService.getMedicalGuidance(
        prompt: 'Dor de cabeça',
      );
      expect(response.isSuccess, isTrue);
      expect(response.data, isNotNull);
      expect(response.data?.response, isNotEmpty);
    });

    test('Education endpoint should return valid response', () async {
      final response = await educationService.getEducationGuidance(
        prompt: 'O que é a fotossíntese?',
        subject: 'ciências',
      );
      expect(response.isSuccess, isTrue);
      expect(response.data, isNotNull);
      expect(response.data?.answer, isNotEmpty);
    });

    test('Agriculture endpoint should return valid response', () async {
      final response = await agricultureService.getAgricultureGuidance(
        prompt: 'Como plantar milho?',
        cropType: 'milho',
      );
      expect(response.isSuccess, isTrue);
      expect(response.data, isNotNull);
      expect(response.data?.answer, isNotEmpty);
    });

    test('Education endpoint should return valid response', () async {
      final response = await educationService.getEducationGuidance(
        prompt: 'O que é a fotossíntese?',
        subject: 'ciências',
      );
      expect(response.isSuccess, isTrue);
      expect(response.data, isNotNull);
      expect(response.data?.answer, isNotEmpty);
    });

    test('Agriculture endpoint should return valid response', () async {
      final response = await agricultureService.getAgricultureGuidance(
        prompt: 'Como plantar milho?',
        cropType: 'milho',
      );
      expect(response.isSuccess, isTrue);
      expect(response.data, isNotNull);
      expect(response.data?.answer, isNotEmpty);
    });
  });
}