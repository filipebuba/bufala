import 'package:android_app/models/emergency_case.dart';
import 'package:android_app/models/medical_condition.dart';
import 'package:android_app/services/crisis_response_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';



void main() {
  group('CrisisResponseService Tests', () {
    late CrisisResponseService service;
    
    setUp(() {
      service = CrisisResponseService();
    });
    
    group('Emergency Assessment', () {
      test('should assess emergency correctly for bleeding', () async {
        // Arrange
        final symptoms = ['sangramento', 'ferimento', 'dor'];
        
        // Act
        final result = await service.assessEmergency(symptoms);
        
        // Assert
        expect(result.urgencyLevel, UrgencyLevel.high);
        expect(result.condition, isA<MedicalCondition>());
        expect(result.instructions.isNotEmpty, true);
      });
      
      test('should handle multiple symptoms correctly', () async {
        // Arrange
        final symptoms = ['febre', 'tosse', 'dor de cabeça'];
        
        // Act
        final result = await service.assessEmergency(symptoms);
        
        // Assert
        expect(result.urgencyLevel, isIn([UrgencyLevel.medium, UrgencyLevel.low]));
        expect(result.instructions.isNotEmpty, true);
      });
      
      test('should return appropriate instructions in Kriolu', () async {
        // Arrange
        final symptoms = ['sangramento'];
        
        // Act
        final result = await service.assessEmergency(symptoms, language: 'kriolu');
        
        // Assert
        expect(result.instructions.any((instruction) => 
          instruction.contains('para') || instruction.contains('na')), true);
      });
    });
    
    group('Medical Conditions', () {
      test('should identify bleeding condition', () {
        // Arrange
        final symptoms = ['sangramento', 'ferimento'];
        
        // Act
        final condition = service.identifyCondition(symptoms);
        
        // Assert
        expect(condition.name, contains('sangramento'));
        expect(condition.severity, UrgencyLevel.high);
      });
      
      test('should provide first aid instructions', () {
        // Arrange
        final condition = MedicalCondition(
          name: 'Sangramento',
          symptoms: ['sangramento', 'ferimento'],
          severity: UrgencyLevel.high
        );
        
        // Act
        final instructions = service.getFirstAidInstructions(condition);
        
        // Assert
        expect(instructions.isNotEmpty, true);
        expect(instructions.any((instruction) => 
          instruction.toLowerCase().contains('pressão')), true);
      });
    });
    
    group('Language Support', () {
      test('should support Kriolu language', () async {
        // Arrange
        final symptoms = ['sangramento'];
        
        // Act
        final result = await service.assessEmergency(symptoms, language: 'kriolu');
        
        // Assert
        expect(result.instructions.isNotEmpty, true);
      });
      
      test('should support Portuguese language', () async {
        // Arrange
        final symptoms = ['sangramento'];
        
        // Act
        final result = await service.assessEmergency(symptoms, language: 'portuguese');
        
        // Assert
        expect(result.instructions.isNotEmpty, true);
      });
    });
    
    group('Error Handling', () {
      test('should handle empty symptoms list', () async {
        // Arrange
        final symptoms = <String>[];
        
        // Act & Assert
        expect(() => service.assessEmergency(symptoms), 
          throwsA(isA<ArgumentError>()));
      });
      
      test('should handle unknown symptoms', () async {
        // Arrange
        final symptoms = ['sintoma_desconhecido'];
        
        // Act
        final result = await service.assessEmergency(symptoms);
        
        // Assert
        expect(result.urgencyLevel, UrgencyLevel.low);
        expect(result.instructions.isNotEmpty, true);
      });
    });
    
    group('Performance Tests', () {
      test('should respond within acceptable time', () async {
        // Arrange
        final symptoms = ['sangramento', 'ferimento'];
        final stopwatch = Stopwatch()..start();
        
        // Act
        await service.assessEmergency(symptoms);
        stopwatch.stop();
        
        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(2000)); // < 2 seconds
      });
    });
  });
}