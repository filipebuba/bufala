import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'dart:convert';

// Import the service to test
import '../../lib/services/emergency_service.dart';
import '../../lib/services/api_client.dart';

// Generate mocks
@GenerateMocks([ApiClient])
import 'emergency_service_test.mocks.dart';

void main() {
  group('EmergencyService Tests', () {
    late EmergencyService emergencyService;
    late MockApiClient mockApiClient;
    
    setUp(() {
      mockApiClient = MockApiClient();
      emergencyService = EmergencyService(apiClient: mockApiClient);
    });

    group('Initialization', () {
      test('should initialize correctly', () {
        expect(emergencyService, isNotNull);
      });
      
      test('should initialize with default API client when none provided', () {
        final service = EmergencyService();
        expect(service, isNotNull);
      });
    });

    group('Medical Emergencies', () {
      test('should provide childbirth emergency guidance', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'emergency_type': 'childbirth',
            'urgency_level': 'high',
            'immediate_actions': [
              'Mantenha a calma',
              'Prepare um local limpo',
              'Lave as mãos com água e sabão',
              'Tenha toalhas limpas prontas'
            ],
            'step_by_step_guide': [
              {
                'step': 1,
                'action': 'Posicione a mãe confortavelmente',
                'details': 'Deite-a de costas com joelhos dobrados',
                'warning': 'Não force nada, deixe o processo natural'
              },
              {
                'step': 2,
                'action': 'Observe os sinais do parto',
                'details': 'Contrações regulares, rompimento da bolsa',
                'warning': 'Se houver sangramento excessivo, procure ajuda imediatamente'
              }
            ],
            'danger_signs': [
              'Sangramento excessivo',
              'Bebê não respira após nascimento',
              'Cordão umbilical enrolado no pescoço',
              'Placenta não sai após 30 minutos'
            ],
            'emergency_contacts': [
              'Hospital mais próximo: (245) 123-4567',
              'Ambulância: 113',
              'Parteira local: (245) 987-6543'
            ],
            'supplies_needed': [
              'Toalhas limpas',
              'Água fervida',
              'Sabão',
              'Tesoura esterilizada',
              'Fio ou barbante limpo'
            ]
          }
        };
        
        when(mockApiClient.post('/medical/emergency', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await emergencyService.getEmergencyGuidance(
          emergencyType: 'childbirth',
          description: 'Mulher em trabalho de parto em casa',
          location: 'área rural sem acesso a hospital',
          urgency: 'high',
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['emergency_type'], equals('childbirth'));
        expect(result['data']['immediate_actions'], isA<List>());
        expect(result['data']['step_by_step_guide'], isA<List>());
        expect(result['data']['danger_signs'], isA<List>());
        expect(result['data']['emergency_contacts'], isA<List>());
        expect(result['data']['immediate_actions'], contains('Mantenha a calma'));
      });
      
      test('should handle severe injury emergency', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'emergency_type': 'severe_injury',
            'urgency_level': 'critical',
            'immediate_actions': [
              'Verifique se a pessoa está consciente',
              'Controle o sangramento',
              'Não mova a pessoa se suspeitar de lesão na coluna',
              'Mantenha a pessoa aquecida'
            ],
            'first_aid_steps': [
              {
                'condition': 'sangramento_severo',
                'action': 'Pressione firmemente sobre o ferimento',
                'materials': 'Pano limpo ou gaze',
                'duration': 'Até parar de sangrar ou ajuda chegar'
              },
              {
                'condition': 'inconsciencia',
                'action': 'Verifique respiração e pulso',
                'materials': 'Nenhum necessário',
                'warning': 'Se não respirar, inicie respiração boca a boca'
              }
            ],
            'when_to_evacuate': [
              'Sangramento que não para',
              'Pessoa inconsciente',
              'Suspeita de fratura na coluna',
              'Dificuldade para respirar'
            ]
          }
        };
        
        when(mockApiClient.post('/medical/emergency', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await emergencyService.getEmergencyGuidance(
          emergencyType: 'severe_injury',
          description: 'Pessoa ferida em acidente',
          urgency: 'critical',
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['urgency_level'], equals('critical'));
        expect(result['data']['first_aid_steps'], isA<List>());
        expect(result['data']['when_to_evacuate'], isA<List>());
      });
    });

    group('First Aid Guidance', () {
      test('should provide first aid for cuts and wounds', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'injury_type': 'cut',
            'severity': 'moderate',
            'treatment_steps': [
              {
                'step': 1,
                'action': 'Lave as mãos',
                'reason': 'Prevenir infecção',
                'materials': 'Água e sabão'
              },
              {
                'step': 2,
                'action': 'Limpe o ferimento',
                'reason': 'Remover sujeira e bactérias',
                'materials': 'Água limpa'
              },
              {
                'step': 3,
                'action': 'Aplique pressão para parar sangramento',
                'reason': 'Controlar perda de sangue',
                'materials': 'Pano limpo ou gaze'
              },
              {
                'step': 4,
                'action': 'Cubra com bandagem',
                'reason': 'Proteger de infecção',
                'materials': 'Bandagem ou pano limpo'
              }
            ],
            'available_supplies': ['bandagem', 'álcool', 'água'],
            'infection_signs': [
              'Vermelhidão aumentando',
              'Inchaço',
              'Calor no local',
              'Pus ou secreção',
              'Febre'
            ],
            'when_to_seek_help': [
              'Corte muito profundo',
              'Sangramento não para',
              'Sinais de infecção',
              'Objeto estranho no ferimento'
            ]
          }
        };
        
        when(mockApiClient.post('/medical/first-aid', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await emergencyService.getFirstAidGuidance(
          situation: 'corte profundo',
          severity: 'moderate',
          availableSupplies: ['bandagem', 'álcool', 'água'],
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['treatment_steps'], isA<List>());
        expect(result['data']['infection_signs'], isA<List>());
        expect(result['data']['when_to_seek_help'], isA<List>());
      });
      
      test('should handle burns treatment', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'injury_type': 'burn',
            'burn_degree': 'second_degree',
            'immediate_care': [
              'Remova a pessoa da fonte de calor',
              'Resfrie com água fria por 10-20 minutos',
              'Remova roupas e joias da área queimada',
              'Não aplique gelo diretamente'
            ],
            'what_not_to_do': [
              'Não aplique manteiga ou óleo',
              'Não estoure bolhas',
              'Não use gelo',
              'Não remova pele morta'
            ],
            'pain_management': [
              'Água fria para alívio',
              'Mantenha a área elevada se possível',
              'Medicação para dor se disponível'
            ],
            'emergency_evacuation': [
              'Queimadura maior que a palma da mão',
              'Queimadura no rosto, mãos ou genitais',
              'Queimadura de terceiro grau',
              'Sinais de choque'
            ]
          }
        };
        
        when(mockApiClient.post('/medical/first-aid', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await emergencyService.getFirstAidGuidance(
          situation: 'queimadura',
          severity: 'moderate',
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['immediate_care'], isA<List>());
        expect(result['data']['what_not_to_do'], isA<List>());
        expect(result['data']['emergency_evacuation'], isA<List>());
      });
    });

    group('Emergency Communication', () {
      test('should provide emergency communication in Creole', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'language': 'creole',
            'emergency_phrases': {
              'help_needed': 'N misti djuda',
              'medical_emergency': 'Emergencia mediku',
              'call_doctor': 'Chama doutór',
              'woman_giving_birth': 'Mindjer ka pari',
              'serious_injury': 'Ferida gravi'
            },
            'key_instructions': {
              'stay_calm': 'Fica kalmu',
              'call_for_help': 'Chama djuda',
              'dont_move_person': 'Ka bulia kel pesoa',
              'apply_pressure': 'Aperta na ferida'
            },
            'emergency_numbers': {
              'ambulance': '113',
              'police': '117',
              'fire': '118'
            }
          }
        };
        
        when(mockApiClient.post('/emergency/communication', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await emergencyService.getEmergencyCommunication(
          language: 'creole',
          emergencyType: 'medical',
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['language'], equals('creole'));
        expect(result['data']['emergency_phrases'], isA<Map>());
        expect(result['data']['key_instructions'], isA<Map>());
        expect(result['data']['emergency_numbers'], isA<Map>());
      });
    });

    group('Location-Based Emergency Services', () {
      test('should find nearest medical facilities', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'nearest_facilities': [
              {
                'name': 'Centro de Saúde de Bissau',
                'type': 'health_center',
                'distance_km': 15.2,
                'estimated_time': '25 minutos de carro',
                'contact': '(245) 123-4567',
                'services': ['emergência', 'maternidade', 'cirurgia básica'],
                'directions': 'Siga pela estrada principal até a rotunda, vire à direita'
              },
              {
                'name': 'Hospital Nacional Simão Mendes',
                'type': 'hospital',
                'distance_km': 45.8,
                'estimated_time': '1 hora de carro',
                'contact': '(245) 987-6543',
                'services': ['emergência 24h', 'UTI', 'cirurgia avançada'],
                'directions': 'Estrada para Bissau, seguir placas do hospital'
              }
            ],
            'transportation_options': [
              {
                'type': 'ambulance',
                'availability': 'limited',
                'contact': '113',
                'notes': 'Pode demorar em áreas rurais'
              },
              {
                'type': 'community_transport',
                'availability': 'available',
                'contact': 'Líder comunitário',
                'notes': 'Veículo da comunidade disponível'
              }
            ]
          }
        };
        
        when(mockApiClient.post('/emergency/location', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await emergencyService.findNearestMedicalFacilities(
          currentLocation: 'Gabú',
          emergencyType: 'childbirth',
          transportAvailable: true,
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['nearest_facilities'], isA<List>());
        expect(result['data']['transportation_options'], isA<List>());
        expect(result['data']['nearest_facilities'].length, greaterThan(0));
      });
    });

    group('Emergency Preparedness', () {
      test('should provide emergency kit recommendations', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'basic_emergency_kit': [
              {
                'item': 'Bandagens',
                'quantity': '10 unidades',
                'purpose': 'Cobrir ferimentos',
                'local_alternative': 'Panos limpos'
              },
              {
                'item': 'Álcool ou desinfetante',
                'quantity': '1 frasco',
                'purpose': 'Limpar ferimentos',
                'local_alternative': 'Água fervida com sal'
              },
              {
                'item': 'Tesoura',
                'quantity': '1 unidade',
                'purpose': 'Cortar bandagens',
                'local_alternative': 'Faca limpa'
              }
            ],
            'childbirth_specific': [
              {
                'item': 'Toalhas limpas',
                'quantity': '5-10 unidades',
                'purpose': 'Receber o bebê e limpar',
                'preparation': 'Ferver e secar ao sol'
              },
              {
                'item': 'Barbante ou fio',
                'quantity': '2 metros',
                'purpose': 'Amarrar cordão umbilical',
                'preparation': 'Ferver antes de usar'
              }
            ],
            'storage_tips': [
              'Manter em local seco',
              'Verificar validade regularmente',
              'Ensinar família a usar',
              'Ter lista de contatos de emergência'
            ]
          }
        };
        
        when(mockApiClient.post('/emergency/preparedness', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await emergencyService.getEmergencyPreparedness(
          communityType: 'rural',
          specificNeeds: ['childbirth', 'injuries'],
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['basic_emergency_kit'], isA<List>());
        expect(result['data']['childbirth_specific'], isA<List>());
        expect(result['data']['storage_tips'], isA<List>());
      });
    });

    group('Offline Emergency Support', () {
      test('should provide offline emergency guidance', () async {
        // Act
        final result = await emergencyService.getOfflineEmergencyGuidance(
          emergencyType: 'childbirth',
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['offline_mode'], isTrue);
        expect(result['data']['basic_guidance'], isA<List>());
      });
      
      test('should work without internet connection', () async {
        // Arrange
        when(mockApiClient.post(any, any))
            .thenThrow(Exception('No internet connection'));
        
        // Act
        final result = await emergencyService.getOfflineEmergencyGuidance(
          emergencyType: 'injury',
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['offline_mode'], isTrue);
      });
    });

    group('Emergency Training', () {
      test('should provide community emergency training content', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'training_modules': [
              {
                'title': 'Primeiros Socorros Básicos',
                'duration': '2 horas',
                'topics': [
                  'Controle de sangramento',
                  'Respiração boca a boca',
                  'Posição de recuperação'
                ],
                'practical_exercises': [
                  'Praticar bandagem',
                  'Simular emergência',
                  'Usar kit de primeiros socorros'
                ]
              },
              {
                'title': 'Assistência ao Parto',
                'duration': '3 horas',
                'topics': [
                  'Sinais do trabalho de parto',
                  'Preparação do ambiente',
                  'Cuidados com o recém-nascido'
                ],
                'practical_exercises': [
                  'Preparar kit de parto',
                  'Posicionamento da mãe',
                  'Corte do cordão umbilical'
                ]
              }
            ],
            'community_roles': {
              'leader': 'Coordenar treinamento e emergências',
              'trained_members': 'Prestar primeiros socorros',
              'communication': 'Contactar serviços de emergência'
            }
          }
        };
        
        when(mockApiClient.post('/emergency/training', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await emergencyService.getEmergencyTraining(
          communitySize: 'medium',
          priorityAreas: ['childbirth', 'first_aid'],
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['training_modules'], isA<List>());
        expect(result['data']['community_roles'], isA<Map>());
      });
    });
  });
}