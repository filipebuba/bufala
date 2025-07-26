import 'package:android_app/services/language_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'language_service_test.mocks.dart';

@GenerateMocks([ILanguageService])
void main() {
  group('LanguageService', () {
    late MockILanguageService mockLanguageService;

    setUp(() {
      mockLanguageService = MockILanguageService();
    });

    test('getAvailableLanguages returns a list of languages', () {
      when(mockLanguageService.getAvailableLanguages()).thenReturn(['kriolu', 'portuguese']);

      final languages = mockLanguageService.getAvailableLanguages();

      expect(languages, ['kriolu', 'portuguese']);
    });
  });
}