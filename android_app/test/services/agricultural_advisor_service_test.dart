import 'dart:io';

import 'package:android_app/models/agricultural_recommendation.dart';
import 'package:android_app/models/crop_diagnosis.dart';
import 'package:android_app/models/weather_data.dart';
import 'package:android_app/services/agricultural_advisor_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('AgriculturalAdvisorService Tests', () {
    late AgriculturalAdvisorService service;
    
    setUp(() {
      service = AgriculturalAdvisorService();
    });
    
    group('Crop Diagnosis', () {
      test('should diagnose pest problems from image', () async {
        // Arrange
        final mockImageFile = File('test_assets/pest_image.jpg');
        const cropType = 'arroz';
        
        // Act
        final diagnosis = await service.diagnoseCrop(
          imageFile: mockImageFile,
          cropType: cropType
        );
        
        // Assert
        expect(diagnosis, isA<CropDiagnosis>());
        expect(diagnosis.cropType, cropType);
        expect(diagnosis.issues.isNotEmpty, true);
        expect(diagnosis.confidence, greaterThan(0.7));
      });
      
      test('should identify disease symptoms', () async {
        // Arrange
        final symptoms = ['folhas amarelas', 'manchas marrons', 'murchamento'];
        const cropType = 'milho';
        
        // Act
        final diagnosis = await service.diagnoseBySymptoms(
          symptoms: symptoms,
          cropType: cropType
        );
        
        // Assert
        expect(diagnosis.possibleDiseases.isNotEmpty, true);
        expect(diagnosis.recommendedTreatments.isNotEmpty, true);
      });
      
      test('should provide treatment recommendations', () async {
        // Arrange
        final diagnosis = CropDiagnosis(
          cropType: 'arroz',
          issues: ['praga_insetos'],
          severity: 'moderada',
          confidence: 0.85
        );
        
        // Act
        final recommendations = await service.getTreatmentRecommendations(diagnosis);
        
        // Assert
        expect(recommendations.isNotEmpty, true);
        expect(recommendations.any((rec) => 
          rec.type == 'pesticida_natural'), true);
      });
    });
    
    group('Weather Integration', () {
      test('should provide weather-based recommendations', () async {
        // Arrange
        final weatherData = WeatherData(
          temperature: 28.5,
          humidity: 75.0,
          rainfall: 15.2,
          forecast: 'chuva_moderada'
        );
        const cropType = 'feijão';
        
        // Act
        final recommendations = await service.getWeatherBasedRecommendations(
          weatherData: weatherData,
          cropType: cropType
        );
        
        // Assert
        expect(recommendations.isNotEmpty, true);
        expect(recommendations.any((rec) => 
          rec.content.toLowerCase().contains('chuva')), true);
      });
      
      test('should warn about adverse weather conditions', () async {
        // Arrange
        final extremeWeather = WeatherData(
          temperature: 40.0,
          humidity: 20.0,
          rainfall: 0.0,
          forecast: 'seca_severa'
        );
        
        // Act
        final warnings = await service.getWeatherWarnings(extremeWeather);
        
        // Assert
        expect(warnings.isNotEmpty, true);
        expect(warnings.any((warning) => 
          warning.severity == 'alta'), true);
      });
    });
    
    group('Crop Calendar', () {
      test('should provide planting recommendations by season', () async {
        // Arrange
        const season = 'estação_seca';
        const region = 'guinea_bissau';
        
        // Act
        final recommendations = await service.getSeasonalRecommendations(
          season: season,
          region: region
        );
        
        // Assert
        expect(recommendations.isNotEmpty, true);
        expect(recommendations.any((rec) => 
          rec.cropType == 'amendoim'), true); // Common dry season crop
      });
      
      test('should calculate optimal planting dates', () async {
        // Arrange
        const cropType = 'arroz';
        const region = 'guinea_bissau';
        
        // Act
        final plantingDates = await service.getOptimalPlantingDates(
          cropType: cropType,
          region: region
        );
        
        // Assert
        expect(plantingDates.isNotEmpty, true);
        expect(plantingDates.every((date) => 
          date.isAfter(DateTime.now().subtract(const Duration(days: 365)))), true);
      });
    });
    
    group('Soil Analysis', () {
      test('should analyze soil conditions', () async {
        // Arrange
        final soilData = {
          'ph': 6.5,
          'nitrogen': 'baixo',
          'phosphorus': 'médio',
          'potassium': 'alto',
          'organic_matter': 'médio'
        };
        
        // Act
        final analysis = await service.analyzeSoil(soilData);
        
        // Assert
        expect(analysis.recommendations.isNotEmpty, true);
        expect(analysis.suitableCrops.isNotEmpty, true);
        expect(analysis.fertilizationNeeds.isNotEmpty, true);
      });
      
      test('should recommend soil improvements', () async {
        // Arrange
        final poorSoil = {
          'ph': 4.5, // Very acidic
          'nitrogen': 'muito_baixo',
          'phosphorus': 'baixo',
          'potassium': 'baixo',
          'organic_matter': 'baixo'
        };
        
        // Act
        final improvements = await service.getSoilImprovements(poorSoil);
        
        // Assert
        expect(improvements.isNotEmpty, true);
        expect(improvements.any((imp) => 
          imp.type == 'correção_ph'), true);
        expect(improvements.any((imp) => 
          imp.type == 'adubação_orgânica'), true);
      });
    });
    
    group('Local Knowledge Integration', () {
      test('should incorporate traditional farming practices', () async {
        // Arrange
        const region = 'guinea_bissau';
        const cropType = 'arroz';
        
        // Act
        final practices = await service.getTraditionalPractices(
          region: region,
          cropType: cropType
        );
        
        // Assert
        expect(practices.isNotEmpty, true);
        expect(practices.any((practice) => 
          practice.isValidatedByScience), true);
      });
      
      test('should provide recommendations in local language', () async {
        // Arrange
        const cropType = 'milho';
        const language = 'kriolu';
        
        // Act
        final recommendations = await service.getRecommendations(
          cropType: cropType,
          language: language
        );
        
        // Assert
        expect(recommendations.isNotEmpty, true);
        expect(recommendations.every((rec) => 
          rec.language == language), true);
      });
    });
    
    group('Pest and Disease Management', () {
      test('should identify common pests', () async {
        // Arrange
        final pestSymptoms = ['furos nas folhas', 'insetos visíveis', 'fezes de insetos'];
        const cropType = 'couve';
        
        // Act
        final identification = await service.identifyPests(
          symptoms: pestSymptoms,
          cropType: cropType
        );
        
        // Assert
        expect(identification.possiblePests.isNotEmpty, true);
        expect(identification.organicTreatments.isNotEmpty, true);
      });
      
      test('should recommend integrated pest management', () async {
        // Arrange
        const pestType = 'lagarta';
        const cropType = 'milho';
        
        // Act
        final ipmPlan = await service.getIPMPlan(
          pestType: pestType,
          cropType: cropType
        );
        
        // Assert
        expect(ipmPlan.biologicalControls.isNotEmpty, true);
        expect(ipmPlan.culturalPractices.isNotEmpty, true);
        expect(ipmPlan.preventiveMeasures.isNotEmpty, true);
      });
    });
    
    group('Performance and Offline Functionality', () {
      test('should work offline with cached data', () async {
        // Arrange
        service.setOfflineMode(true);
        const cropType = 'arroz';
        
        // Act
        final recommendations = await service.getRecommendations(
          cropType: cropType
        );
        
        // Assert
        expect(recommendations.isNotEmpty, true);
        expect(service.isUsingCachedData, true);
      });
      
      test('should process image analysis within time limit', () async {
        // Arrange
        final mockImageFile = File('test_assets/crop_image.jpg');
        final stopwatch = Stopwatch()..start();
        
        // Act
        await service.diagnoseCrop(
          imageFile: mockImageFile,
          cropType: 'milho'
        );
        stopwatch.stop();
        
        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // < 5 seconds
      });
    });
    
    group('Error Handling', () {
      test('should handle invalid image files', () async {
        // Arrange
        final invalidFile = File('invalid_path.jpg');
        
        // Act & Assert
        expect(() => service.diagnoseCrop(
          imageFile: invalidFile,
          cropType: 'milho'
        ), throwsA(isA<FileSystemException>()));
      });
      
      test('should handle unknown crop types', () async {
        // Arrange
        const unknownCrop = 'cultura_inexistente';
        
        // Act
        final recommendations = await service.getRecommendations(
          cropType: unknownCrop
        );
        
        // Assert
        expect(recommendations.isNotEmpty, true);
        expect(recommendations.first.content.contains('geral'), true);
      });
    });
  });
}