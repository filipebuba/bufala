import 'package:flutter_test/flutter_test.dart';
import 'package:android_app/utils/validators.dart';

void main() {
  group('Validators Tests', () {
    group('Emergency Number Validation', () {
      test('should validate standard emergency numbers', () {
        expect(Validators.isValidEmergencyNumber('112'), true);
        expect(Validators.isValidEmergencyNumber('911'), true);
        expect(Validators.isValidEmergencyNumber('999'), true);
        expect(Validators.isValidEmergencyNumber('190'), true);
        expect(Validators.isValidEmergencyNumber('193'), true);
      });
      
      test('should reject invalid emergency numbers', () {
        expect(Validators.isValidEmergencyNumber('123'), false);
        expect(Validators.isValidEmergencyNumber(''), false);
        expect(Validators.isValidEmergencyNumber('abc'), false);
        expect(Validators.isValidEmergencyNumber('1122'), false);
      });
    });
    
    group('GPS Coordinate Validation', () {
      test('should validate correct coordinates', () {
        // Guinea-Bissau coordinates
        expect(Validators.isValidCoordinate(12.5, -15), true);
        expect(Validators.isValidCoordinate(11.8, -16.2), true);
        expect(Validators.isValidCoordinate(0, 0), true);
        expect(Validators.isValidCoordinate(-90, -180), true);
        expect(Validators.isValidCoordinate(90, 180), true);
      });
      
      test('should reject invalid coordinates', () {
        expect(Validators.isValidCoordinate(91, 0), false);
        expect(Validators.isValidCoordinate(-91, 0), false);
        expect(Validators.isValidCoordinate(0, 181), false);
        expect(Validators.isValidCoordinate(0, -181), false);
      });
    });
    
    group('Creole Text Validation', () {
      test('should validate Creole text patterns', () {
        expect(Validators.isValidCreoleText('Kuma bu sta?'), true);
        expect(Validators.isValidCreoleText('N sta bon'), true);
        expect(Validators.isValidCreoleText('Bu na kasa'), true);
        expect(Validators.isValidCreoleText('Simple text'), true); // fallback for length
      });
      
      test('should reject empty or whitespace text', () {
        expect(Validators.isValidCreoleText(''), false);
        expect(Validators.isValidCreoleText('   '), false);
        expect(Validators.isValidCreoleText('\n\t'), false);
        expect(Validators.isValidCreoleText('ab'), false); // too short
      });
    });
    
    group('Phone Number Validation', () {
      test('should validate Guinea-Bissau phone numbers', () {
        expect(Validators.isValidPhoneNumber('+245 123 456 789'), true);
        expect(Validators.isValidPhoneNumber('+245123456789'), true);
        expect(Validators.isValidPhoneNumber('+245 987 654 321'), true);
      });
      
      test('should reject invalid phone numbers', () {
        expect(Validators.isValidPhoneNumber('123456789'), false);
        expect(Validators.isValidPhoneNumber('+244 123 456 789'), false); // wrong country
        expect(Validators.isValidPhoneNumber('+245 12 456 789'), false); // wrong format
        expect(Validators.isValidPhoneNumber(''), false);
      });
    });
    
    group('Age Validation', () {
      test('should validate reasonable ages', () {
        expect(Validators.isValidAge(0), true);
        expect(Validators.isValidAge(25), true);
        expect(Validators.isValidAge(65), true);
        expect(Validators.isValidAge(120), true);
      });
      
      test('should reject invalid ages', () {
        expect(Validators.isValidAge(-1), false);
        expect(Validators.isValidAge(121), false);
        expect(Validators.isValidAge(999), false);
      });
    });
  });
}