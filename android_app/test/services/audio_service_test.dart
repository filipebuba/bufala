import 'dart:convert';
import 'dart:typed_data';

import 'package:android_app/services/api_client.dart';
// Import the service to test
import 'package:android_app/services/audio_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Generate mocks
@GenerateMocks([ApiClient])
import 'audio_service_test.mocks.dart';

void main() {
  group('AudioService Tests', () {
    late AudioService audioService;
    late MockApiClient mockApiClient;
    
    setUp(() {
      mockApiClient = MockApiClient();
      audioService = AudioService(apiClient: mockApiClient);
    });

    group('Initialization', () {
      test('should initialize correctly', () {
        expect(audioService, isNotNull);
      });
      
      test('should initialize with default API client when none provided', () {
        final service = AudioService();
        expect(service, isNotNull);
      });
    });

    group('Audio Recording', () {
      test('should start audio recording', () async {
        // Act
        final result = await audioService.startRecording();
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['recording'], isTrue);
      });
      
      test('should stop audio recording and return audio data', () async {
        // Arrange
        await audioService.startRecording();
        
        // Act
        final result = await audioService.stopRecording();
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['recording'], isFalse);
        expect(result['audio_data'], isNotNull);
        expect(result['duration'], greaterThan(0));
      });
      
      test('should handle recording errors gracefully', () async {
        // Act & Assert
        expect(
          () => audioService.stopRecording(), // Stop without starting
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Audio Playback', () {
      test('should play audio from base64 data', () async {
        // Arrange
        const audioData = 'base64_audio_data';
        
        // Act
        final result = await audioService.playAudio(audioData);
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['playing'], isTrue);
      });
      
      test('should stop audio playback', () async {
        // Arrange
        await audioService.playAudio('base64_audio_data');
        
        // Act
        final result = await audioService.stopPlayback();
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['playing'], isFalse);
      });
      
      test('should handle invalid audio data', () async {
        // Act & Assert
        expect(
          () => audioService.playAudio('invalid_audio_data'),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('Speech Recognition', () {
      test('should recognize speech in Portuguese', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'transcription': 'Preciso de ajuda médica',
            'confidence': 0.95,
            'language': 'pt',
            'words': [
              {'word': 'Preciso', 'confidence': 0.98, 'start_time': 0.0, 'end_time': 0.5},
              {'word': 'de', 'confidence': 0.92, 'start_time': 0.5, 'end_time': 0.7},
              {'word': 'ajuda', 'confidence': 0.96, 'start_time': 0.7, 'end_time': 1.2},
              {'word': 'médica', 'confidence': 0.94, 'start_time': 1.2, 'end_time': 1.8}
            ],
            'intent': {
              'category': 'medical_emergency',
              'urgency': 'high',
              'keywords': ['ajuda', 'médica']
            }
          }
        };
        
        when(mockApiClient.post('/audio/speech-recognition', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await audioService.recognizeSpeech(
          audioData: 'base64_audio_data',
          language: 'pt',
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['transcription'], equals('Preciso de ajuda médica'));
        expect(result['data']['confidence'], greaterThan(0.9));
        expect(result['data']['words'], isA<List>());
        expect(result['data']['intent']['category'], equals('medical_emergency'));
      });
      
      test('should recognize speech in Creole', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'transcription': 'N misti djuda',
            'confidence': 0.88,
            'language': 'creole',
            'translation': {
              'portuguese': 'Preciso de ajuda',
              'english': 'I need help'
            },
            'cultural_context': {
              'region': 'Guinea-Bissau',
              'dialect': 'Bissau Creole',
              'formality': 'informal'
            }
          }
        };
        
        when(mockApiClient.post('/audio/speech-recognition', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await audioService.recognizeSpeech(
          audioData: 'base64_audio_data',
          language: 'creole',
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['transcription'], equals('N misti djuda'));
        expect(result['data']['language'], equals('creole'));
        expect(result['data']['translation'], isA<Map>());
        expect(result['data']['cultural_context'], isA<Map>());
      });
      
      test('should handle poor audio quality', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'transcription': '[áudio inaudível]',
            'confidence': 0.2,
            'quality_issues': [
              'background_noise',
              'low_volume',
              'distortion'
            ],
            'suggestions': [
              'Fale mais próximo do microfone',
              'Reduza ruído de fundo',
              'Fale mais devagar e claramente'
            ]
          }
        };
        
        when(mockApiClient.post('/audio/speech-recognition', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await audioService.recognizeSpeech(
          audioData: 'poor_quality_audio',
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['confidence'], lessThan(0.5));
        expect(result['data']['quality_issues'], isA<List>());
        expect(result['data']['suggestions'], isA<List>());
      });
    });

    group('Text-to-Speech', () {
      test('should convert Portuguese text to speech', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'audio_data': 'base64_generated_audio',
            'duration_seconds': 3.5,
            'voice_settings': {
              'language': 'pt',
              'voice_type': 'female',
              'speed': 'normal',
              'pitch': 'medium'
            },
            'file_format': 'mp3',
            'sample_rate': 22050
          }
        };
        
        when(mockApiClient.post('/audio/text-to-speech', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await audioService.textToSpeech(
          text: 'Bem-vindo ao aplicativo Moransa',
          language: 'pt',
          voiceType: 'female',
          speed: 'normal',
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['audio_data'], isNotEmpty);
        expect(result['data']['duration_seconds'], greaterThan(0));
        expect(result['data']['voice_settings']['language'], equals('pt'));
      });
      
      test('should convert Creole text to speech', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'audio_data': 'base64_creole_audio',
            'duration_seconds': 2.8,
            'voice_settings': {
              'language': 'creole',
              'voice_type': 'male',
              'speed': 'slow',
              'accent': 'bissau'
            },
            'cultural_adaptation': {
              'pronunciation_guide': 'Adaptado para sotaque local',
              'intonation': 'Padrão da Guiné-Bissau'
            }
          }
        };
        
        when(mockApiClient.post('/audio/text-to-speech', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await audioService.textToSpeech(
          text: 'Bon dia, kuma bu sta?',
          language: 'creole',
          voiceType: 'male',
          speed: 'slow',
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['voice_settings']['language'], equals('creole'));
        expect(result['data']['cultural_adaptation'], isA<Map>());
      });
      
      test('should handle long text input', () async {
        // Arrange
        final longText = 'Este é um texto muito longo que precisa ser convertido em áudio. ' * 20;
        final mockResponse = {
          'success': true,
          'data': {
            'audio_data': 'base64_long_audio',
            'duration_seconds': 45.2,
            'chunks': [
              {'start': 0, 'end': 15, 'audio_chunk': 'chunk1'},
              {'start': 15, 'end': 30, 'audio_chunk': 'chunk2'},
              {'start': 30, 'end': 45, 'audio_chunk': 'chunk3'}
            ],
            'total_characters': longText.length
          }
        };
        
        when(mockApiClient.post('/audio/text-to-speech', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await audioService.textToSpeech(text: longText);
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['duration_seconds'], greaterThan(30));
        expect(result['data']['chunks'], isA<List>());
      });
    });

    group('Audio Processing', () {
      test('should enhance audio quality', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'enhanced_audio': 'base64_enhanced_audio',
            'improvements': [
              'noise_reduction',
              'volume_normalization',
              'clarity_enhancement'
            ],
            'quality_metrics': {
              'signal_to_noise_ratio': 15.2,
              'clarity_score': 0.85,
              'volume_level': 'optimal'
            }
          }
        };
        
        when(mockApiClient.post('/audio/enhance', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await audioService.enhanceAudio(
          audioData: 'base64_noisy_audio',
          enhancementType: 'noise_reduction',
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['enhanced_audio'], isNotEmpty);
        expect(result['data']['improvements'], isA<List>());
        expect(result['data']['quality_metrics'], isA<Map>());
      });
      
      test('should compress audio for low bandwidth', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'compressed_audio': 'base64_compressed_audio',
            'compression_ratio': 0.3,
            'original_size_kb': 500,
            'compressed_size_kb': 150,
            'quality_retained': 0.85
          }
        };
        
        when(mockApiClient.post('/audio/compress', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await audioService.compressAudio(
          audioData: 'base64_large_audio',
          compressionLevel: 'high',
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['compressed_audio'], isNotEmpty);
        expect(result['data']['compression_ratio'], lessThan(1.0));
        expect(result['data']['compressed_size_kb'], lessThan(result['data']['original_size_kb']));
      });
    });

    group('Voice Commands', () {
      test('should process emergency voice commands', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'command_recognized': 'emergency_help',
            'confidence': 0.92,
            'action': {
              'type': 'emergency_response',
              'priority': 'high',
              'next_steps': [
                'Ativar modo de emergência',
                'Preparar orientações médicas',
                'Localizar contatos de emergência'
              ]
            },
            'response_audio': 'base64_response_audio',
            'response_text': 'Modo de emergência ativado. Como posso ajudar?'
          }
        };
        
        when(mockApiClient.post('/audio/voice-command', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await audioService.processVoiceCommand(
          audioData: 'base64_voice_command',
          context: 'emergency',
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['command_recognized'], equals('emergency_help'));
        expect(result['data']['action']['priority'], equals('high'));
        expect(result['data']['response_audio'], isNotEmpty);
      });
      
      test('should process navigation voice commands', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'command_recognized': 'navigate_to_health_center',
            'confidence': 0.88,
            'action': {
              'type': 'navigation',
              'destination': 'centro de saúde',
              'directions': [
                'Siga em frente por 200 metros',
                'Vire à direita na próxima esquina',
                'O centro de saúde estará à sua esquerda'
              ]
            },
            'estimated_time': '15 minutos a pé'
          }
        };
        
        when(mockApiClient.post('/audio/voice-command', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await audioService.processVoiceCommand(
          audioData: 'base64_navigation_command',
          context: 'navigation',
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['action']['type'], equals('navigation'));
        expect(result['data']['action']['directions'], isA<List>());
      });
    });

    group('Multilingual Support', () {
      test('should detect language automatically', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'detected_language': 'creole',
            'confidence': 0.85,
            'alternative_languages': [
              {'language': 'portuguese', 'confidence': 0.12},
              {'language': 'french', 'confidence': 0.03}
            ],
            'dialect_info': {
              'region': 'Guinea-Bissau',
              'variant': 'Bissau Creole'
            }
          }
        };
        
        when(mockApiClient.post('/audio/language-detection', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await audioService.detectLanguage(
          audioData: 'base64_multilingual_audio',
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['detected_language'], equals('creole'));
        expect(result['data']['alternative_languages'], isA<List>());
        expect(result['data']['dialect_info'], isA<Map>());
      });
      
      test('should translate audio between languages', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'original_text': 'N misti djuda',
            'translated_text': 'Preciso de ajuda',
            'source_language': 'creole',
            'target_language': 'portuguese',
            'translated_audio': 'base64_translated_audio',
            'cultural_notes': [
              'Expressão comum em situações de emergência',
              'Tom de urgência preservado na tradução'
            ]
          }
        };
        
        when(mockApiClient.post('/audio/translate', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await audioService.translateAudio(
          audioData: 'base64_creole_audio',
          sourceLanguage: 'creole',
          targetLanguage: 'portuguese',
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['original_text'], equals('N misti djuda'));
        expect(result['data']['translated_text'], equals('Preciso de ajuda'));
        expect(result['data']['translated_audio'], isNotEmpty);
        expect(result['data']['cultural_notes'], isA<List>());
      });
    });

    group('Offline Audio Support', () {
      test('should work in offline mode with cached models', () async {
        // Act
        final result = await audioService.processOfflineAudio(
          audioData: 'base64_audio',
          operation: 'speech_recognition',
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['offline_mode'], isTrue);
        expect(result['data']['transcription'], isNotEmpty);
      });
      
      test('should cache frequently used audio responses', () async {
        // Act
        final result = await audioService.getCachedAudioResponse(
          text: 'Bem-vindo',
          language: 'pt',
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['cached'], isTrue);
        expect(result['data']['audio_data'], isNotEmpty);
      });
    });

    group('Audio Accessibility', () {
      test('should provide audio descriptions for visually impaired', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'audio_description': 'base64_description_audio',
            'description_text': 'Tela principal do aplicativo com três botões: Emergência em vermelho no topo, Educação em azul no meio, e Agricultura em verde na parte inferior',
            'navigation_cues': [
              'Toque duplo para ativar',
              'Deslize para a direita para próximo item',
              'Deslize para a esquerda para item anterior'
            ],
            'voice_settings': {
              'speed': 'slow',
              'clarity': 'high',
              'volume': 'loud'
            }
          }
        };
        
        when(mockApiClient.post('/audio/accessibility/describe', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await audioService.getAudioDescription(
          screenContent: 'main_screen',
          detailLevel: 'high',
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['audio_description'], isNotEmpty);
        expect(result['data']['navigation_cues'], isA<List>());
        expect(result['data']['voice_settings'], isA<Map>());
      });
      
      test('should adjust audio for hearing impaired users', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'adjusted_audio': 'base64_adjusted_audio',
            'adjustments': [
              'frequency_enhancement',
              'volume_amplification',
              'clarity_boost'
            ],
            'visual_cues': [
              'Vibração para alertas importantes',
              'Indicadores visuais para sons',
              'Legendas automáticas'
            ]
          }
        };
        
        when(mockApiClient.post('/audio/accessibility/hearing', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await audioService.adjustForHearingImpaired(
          audioData: 'base64_original_audio',
          hearingProfile: 'mild_loss',
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['adjusted_audio'], isNotEmpty);
        expect(result['data']['adjustments'], isA<List>());
        expect(result['data']['visual_cues'], isA<List>());
      });
    });
  });
}