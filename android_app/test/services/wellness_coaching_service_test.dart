import 'dart:convert';

import 'package:android_app/services/api_client.dart';
// Import the service to test
import 'package:android_app/services/wellness_coaching_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Generate mocks
@GenerateMocks([ApiClient])
import 'wellness_coaching_service_test.mocks.dart';

void main() {
  group('WellnessCoachingService Tests', () {
    late WellnessCoachingService wellnessService;
    late MockApiClient mockApiClient;
    
    setUp(() {
      mockApiClient = MockApiClient();
      wellnessService = WellnessCoachingService(apiClient: mockApiClient);
    });

    group('Initialization', () {
      test('should initialize correctly', () {
        expect(wellnessService, isNotNull);
      });
      
      test('should initialize with default API client when none provided', () {
        final service = WellnessCoachingService();
        expect(service, isNotNull);
      });
    });

    group('Mood Analysis', () {
      test('should analyze mood and provide recommendations', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'mood_analysis': {
              'primary_emotion': 'anxious',
              'intensity': 7,
              'contributing_factors': [
                'Preocupação com a família',
                'Dificuldades financeiras',
                'Isolamento social'
              ],
              'mood_trend': 'declining',
              'risk_level': 'moderate'
            },
            'recommendations': [
              {
                'type': 'breathing_exercise',
                'title': 'Respiração Profunda',
                'description': 'Respire fundo por 4 segundos, segure por 4, expire por 6',
                'duration': '5 minutos',
                'frequency': '3 vezes ao dia'
              },
              {
                'type': 'social_connection',
                'title': 'Conversar com Vizinhos',
                'description': 'Procure conversar com pessoas da comunidade',
                'duration': '15-30 minutos',
                'frequency': 'diariamente'
              }
            ],
            'immediate_actions': [
              'Encontre um local calmo',
              'Pratique respiração profunda',
              'Beba água',
              'Converse com alguém de confiança'
            ],
            'warning_signs': [
              'Pensamentos de autolesão',
              'Isolamento completo',
              'Perda de apetite por dias',
              'Insônia persistente'
            ]
          }
        };
        
        when(mockApiClient.post('/wellness/mood-analysis', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await wellnessService.analyzeMood(
          mood: 'anxious',
          intensity: 7,
          description: 'Sentindo-me muito ansioso hoje',
          language: 'pt',
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['mood_analysis']['primary_emotion'], equals('anxious'));
        expect(result['data']['recommendations'], isA<List>());
        expect(result['data']['immediate_actions'], isA<List>());
        expect(result['data']['warning_signs'], isA<List>());
      });
      
      test('should handle positive mood analysis', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'mood_analysis': {
              'primary_emotion': 'happy',
              'intensity': 8,
              'contributing_factors': [
                'Boa colheita este ano',
                'Família saudável',
                'Comunidade unida'
              ],
              'mood_trend': 'stable',
              'risk_level': 'low'
            },
            'maintenance_tips': [
              'Continue as atividades que trazem alegria',
              'Compartilhe sua felicidade com outros',
              'Mantenha rotina de exercícios',
              'Pratique gratidão diariamente'
            ],
            'community_activities': [
              'Organize encontros comunitários',
              'Ajude vizinhos necessitados',
              'Participe de celebrações locais'
            ]
          }
        };
        
        when(mockApiClient.post('/wellness/mood-analysis', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await wellnessService.analyzeMood(
          mood: 'happy',
          intensity: 8,
          description: 'Sentindo-me muito bem hoje',
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['mood_analysis']['primary_emotion'], equals('happy'));
        expect(result['data']['maintenance_tips'], isA<List>());
        expect(result['data']['community_activities'], isA<List>());
      });
    });

    group('Wellness Coaching', () {
      test('should provide personalized wellness coaching', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'coaching_plan': {
              'duration': '4 semanas',
              'focus_areas': ['reduzir estresse', 'melhorar sono'],
              'weekly_goals': [
                {
                  'week': 1,
                  'goal': 'Estabelecer rotina de respiração',
                  'activities': [
                    'Respiração profunda 3x/dia',
                    'Caminhada de 15 minutos',
                    'Dormir às 22h'
                  ]
                },
                {
                  'week': 2,
                  'goal': 'Melhorar qualidade do sono',
                  'activities': [
                    'Evitar cafeína após 18h',
                    'Criar ambiente calmo para dormir',
                    'Praticar relaxamento antes de dormir'
                  ]
                }
              ]
            },
            'daily_practices': [
              {
                'time': 'manhã',
                'activity': 'Gratidão',
                'description': 'Liste 3 coisas pelas quais é grato',
                'duration': '5 minutos'
              },
              {
                'time': 'tarde',
                'activity': 'Exercício leve',
                'description': 'Caminhada ou alongamento',
                'duration': '20 minutos'
              },
              {
                'time': 'noite',
                'activity': 'Reflexão',
                'description': 'Pense sobre o dia e relaxe',
                'duration': '10 minutos'
              }
            ],
            'progress_tracking': {
              'mood_scale': 'Avalie seu humor de 1-10 diariamente',
              'sleep_quality': 'Registre qualidade do sono',
              'stress_level': 'Monitore níveis de estresse',
              'energy_level': 'Acompanhe energia durante o dia'
            }
          }
        };
        
        when(mockApiClient.post('/wellness/coaching', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await wellnessService.getWellnessCoaching(
          userProfile: 'adulto trabalhador',
          goals: ['reduzir estresse', 'melhorar sono'],
          currentChallenges: ['trabalho excessivo'],
          availableTime: 30,
          preferences: ['exercícios leves'],
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['coaching_plan'], isA<Map>());
        expect(result['data']['daily_practices'], isA<List>());
        expect(result['data']['progress_tracking'], isA<Map>());
      });
    });

    group('Mental Health Support', () {
      test('should provide mental health support for anxiety', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'support_type': 'anxiety_management',
            'severity_assessment': 'moderate',
            'immediate_techniques': [
              {
                'name': 'Técnica 5-4-3-2-1',
                'description': 'Identifique 5 coisas que vê, 4 que ouve, 3 que toca, 2 que cheira, 1 que saboreia',
                'purpose': 'Reduzir ansiedade imediata',
                'duration': '5-10 minutos'
              },
              {
                'name': 'Respiração Quadrada',
                'description': 'Inspire por 4, segure por 4, expire por 4, pause por 4',
                'purpose': 'Acalmar sistema nervoso',
                'duration': '5 minutos'
              }
            ],
            'long_term_strategies': [
              'Estabelecer rotina diária',
              'Praticar exercícios regulares',
              'Manter conexões sociais',
              'Limitar consumo de cafeína',
              'Praticar mindfulness'
            ],
            'community_resources': [
              {
                'type': 'grupo_apoio',
                'name': 'Círculo de Mulheres',
                'description': 'Encontro semanal para compartilhar experiências',
                'contact': 'Líder comunitária Maria'
              },
              {
                'type': 'atividade_fisica',
                'name': 'Caminhada Comunitária',
                'description': 'Caminhada em grupo todas as manhãs',
                'contact': 'Encontro na praça às 6h'
              }
            ],
            'when_to_seek_help': [
              'Ansiedade interfere no trabalho',
              'Dificuldade para dormir por semanas',
              'Evita atividades sociais',
              'Pensamentos negativos constantes'
            ]
          }
        };
        
        when(mockApiClient.post('/wellness/mental-health', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await wellnessService.getMentalHealthSupport(
          concern: 'ansiedade',
          severity: 'moderate',
          supportType: 'immediate',
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['immediate_techniques'], isA<List>());
        expect(result['data']['long_term_strategies'], isA<List>());
        expect(result['data']['community_resources'], isA<List>());
        expect(result['data']['when_to_seek_help'], isA<List>());
      });
      
      test('should handle depression support', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'support_type': 'depression_support',
            'severity_assessment': 'mild',
            'daily_activities': [
              {
                'activity': 'Exposição ao sol',
                'time': 'manhã',
                'duration': '15 minutos',
                'benefit': 'Melhora humor e vitamina D'
              },
              {
                'activity': 'Atividade prazerosa',
                'time': 'tarde',
                'duration': '30 minutos',
                'benefit': 'Aumenta sensação de bem-estar'
              }
            ],
            'social_connection': [
              'Converse com um amigo diariamente',
              'Participe de atividades comunitárias',
              'Ajude alguém necessitado',
              'Compartilhe refeições com família'
            ],
            'warning_signs': [
              'Perda de interesse em tudo',
              'Sentimentos de desesperança',
              'Mudanças no apetite',
              'Pensamentos de autolesão'
            ]
          }
        };
        
        when(mockApiClient.post('/wellness/mental-health', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await wellnessService.getMentalHealthSupport(
          concern: 'depressão',
          severity: 'mild',
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['daily_activities'], isA<List>());
        expect(result['data']['social_connection'], isA<List>());
        expect(result['data']['warning_signs'], isA<List>());
      });
    });

    group('Guided Meditation', () {
      test('should provide guided meditation session', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'session_info': {
              'type': 'relaxation',
              'duration': 10,
              'language': 'pt',
              'experience_level': 'beginner'
            },
            'meditation_script': [
              {
                'time': '0:00',
                'instruction': 'Encontre uma posição confortável, sentado ou deitado',
                'voice_tone': 'calm'
              },
              {
                'time': '0:30',
                'instruction': 'Feche os olhos suavemente e respire naturalmente',
                'voice_tone': 'gentle'
              },
              {
                'time': '1:00',
                'instruction': 'Observe sua respiração, sem tentar mudá-la',
                'voice_tone': 'soothing'
              },
              {
                'time': '2:00',
                'instruction': 'Se sua mente vagar, gentilmente traga atenção de volta à respiração',
                'voice_tone': 'reassuring'
              }
            ],
            'background_sounds': [
              'Sons da natureza',
              'Água corrente',
              'Pássaros cantando'
            ],
            'post_meditation': {
              'reflection_questions': [
                'Como se sente agora?',
                'Notou alguma mudança no seu corpo?',
                'Que pensamentos surgiram?'
              ],
              'integration_tips': [
                'Pratique diariamente no mesmo horário',
                'Comece com sessões curtas',
                'Seja paciente consigo mesmo'
              ]
            }
          }
        };
        
        when(mockApiClient.post('/wellness/guided-meditation', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await wellnessService.getGuidedMeditation(
          sessionType: 'relaxation',
          durationMinutes: 10,
          language: 'pt',
          experienceLevel: 'beginner',
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['session_info'], isA<Map>());
        expect(result['data']['meditation_script'], isA<List>());
        expect(result['data']['background_sounds'], isA<List>());
        expect(result['data']['post_meditation'], isA<Map>());
      });
      
      test('should provide meditation for stress relief', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'session_info': {
              'type': 'stress_relief',
              'duration': 15,
              'focus': 'body_scan'
            },
            'stress_relief_techniques': [
              {
                'technique': 'Relaxamento Muscular Progressivo',
                'steps': [
                  'Tense os músculos dos pés por 5 segundos',
                  'Relaxe completamente',
                  'Suba para as pernas, repita o processo',
                  'Continue até chegar à cabeça'
                ]
              },
              {
                'technique': 'Visualização',
                'steps': [
                  'Imagine um lugar calmo e seguro',
                  'Use todos os sentidos na visualização',
                  'Permaneça neste lugar por alguns minutos'
                ]
              }
            ]
          }
        };
        
        when(mockApiClient.post('/wellness/guided-meditation', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await wellnessService.getGuidedMeditation(
          sessionType: 'stress_relief',
          durationMinutes: 15,
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['stress_relief_techniques'], isA<List>());
      });
    });

    group('Nutrition Guidance', () {
      test('should provide nutrition guidance with local foods', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'local_nutrition': {
              'available_foods': [
                {
                  'name': 'Mandioca',
                  'benefits': 'Rica em carboidratos, fonte de energia',
                  'preparation': 'Cozida, assada ou em farinha',
                  'frequency': 'Diariamente'
                },
                {
                  'name': 'Feijão',
                  'benefits': 'Proteína vegetal, ferro',
                  'preparation': 'Cozido com temperos locais',
                  'frequency': '3-4 vezes por semana'
                },
                {
                  'name': 'Peixe',
                  'benefits': 'Proteína completa, ômega-3',
                  'preparation': 'Grelhado, cozido ou ensopado',
                  'frequency': '2-3 vezes por semana'
                }
              ],
              'meal_planning': {
                'breakfast': 'Mingau de milho com leite de coco',
                'lunch': 'Arroz com feijão e peixe grelhado',
                'dinner': 'Mandioca cozida com verduras',
                'snacks': 'Frutas locais (manga, caju, banana)'
              },
              'hydration': {
                'daily_water': '8-10 copos',
                'natural_drinks': 'Água de coco, chás de ervas',
                'avoid': 'Refrigerantes, bebidas muito açucaradas'
              }
            },
            'budget_friendly_tips': [
              'Cultive horta caseira',
              'Compre em grupo na comunidade',
              'Preserve alimentos sazonais',
              'Use todas as partes dos alimentos'
            ],
            'health_conditions': {
              'diabetes': 'Evite açúcar refinado, prefira frutas',
              'hipertensão': 'Reduza sal, use temperos naturais',
              'anemia': 'Inclua folhas verdes e feijão'
            }
          }
        };
        
        when(mockApiClient.post('/wellness/nutrition', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await wellnessService.getNutritionGuidance(
          query: 'Alimentação saudável com ingredientes locais',
          ageGroup: 'adult',
          healthConditions: [],
          localFoods: true,
          budgetConscious: true,
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['local_nutrition']['available_foods'], isA<List>());
        expect(result['data']['budget_friendly_tips'], isA<List>());
        expect(result['data']['health_conditions'], isA<Map>());
      });
    });

    group('Physical Activity', () {
      test('should provide home-based exercise guidance', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'exercise_plan': {
              'fitness_level': 'beginner',
              'duration': 20,
              'equipment_needed': 'none',
              'exercises': [
                {
                  'name': 'Caminhada no local',
                  'duration': '5 minutos',
                  'description': 'Marche no lugar levantando bem os joelhos',
                  'benefits': 'Aquecimento, melhora circulação'
                },
                {
                  'name': 'Alongamento de braços',
                  'duration': '3 minutos',
                  'description': 'Estenda braços para cima e para os lados',
                  'benefits': 'Flexibilidade, reduz tensão'
                },
                {
                  'name': 'Agachamento simples',
                  'duration': '5 minutos',
                  'description': 'Sente e levante de uma cadeira 10 vezes',
                  'benefits': 'Fortalece pernas e glúteos'
                }
              ]
            },
            'safety_tips': [
              'Pare se sentir dor',
              'Beba água durante o exercício',
              'Comece devagar e aumente gradualmente',
              'Respire normalmente durante os exercícios'
            ],
            'progression': {
              'week_1': 'Faça cada exercício por metade do tempo',
              'week_2': 'Tempo completo, mas com pausas',
              'week_3': 'Tempo completo sem pausas',
              'week_4': 'Adicione mais repetições'
            }
          }
        };
        
        when(mockApiClient.post('/wellness/physical-activity', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await wellnessService.getPhysicalActivityGuidance(
          query: 'Exercícios para fazer em casa',
          fitnessLevel: 'beginner',
          ageGroup: 'adult',
          timeAvailable: 20,
          equipmentAvailable: false,
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['exercise_plan']['exercises'], isA<List>());
        expect(result['data']['safety_tips'], isA<List>());
        expect(result['data']['progression'], isA<Map>());
      });
    });

    group('Stress Management', () {
      test('should provide stress management techniques', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'stress_assessment': {
              'level': 'high',
              'source': 'work',
              'symptoms': ['tensão muscular', 'dificuldade para dormir', 'irritabilidade']
            },
            'immediate_relief': [
              {
                'technique': 'Respiração 4-7-8',
                'steps': [
                  'Inspire pelo nariz por 4 segundos',
                  'Segure a respiração por 7 segundos',
                  'Expire pela boca por 8 segundos',
                  'Repita 4 vezes'
                ],
                'when_to_use': 'Quando sentir ansiedade ou estresse agudo'
              },
              {
                'technique': 'Relaxamento muscular',
                'steps': [
                  'Tense todos os músculos por 5 segundos',
                  'Relaxe completamente',
                  'Observe a diferença entre tensão e relaxamento'
                ],
                'when_to_use': 'Antes de dormir ou durante pausas'
              }
            ],
            'long_term_strategies': [
              'Estabeleça limites no trabalho',
              'Pratique atividade física regular',
              'Mantenha conexões sociais',
              'Reserve tempo para hobbies',
              'Pratique gratidão diariamente'
            ],
            'lifestyle_changes': {
              'sleep': 'Durma 7-8 horas por noite',
              'nutrition': 'Evite cafeína em excesso',
              'exercise': 'Pelo menos 30 minutos de atividade física',
              'social': 'Converse com amigos e família regularmente'
            }
          }
        };
        
        when(mockApiClient.post('/wellness/stress-management', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await wellnessService.getStressManagement(
          stressDescription: 'Estresse do trabalho',
          stressLevel: 'high',
          stressSource: 'work',
          timeAvailable: 15,
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['immediate_relief'], isA<List>());
        expect(result['data']['long_term_strategies'], isA<List>());
        expect(result['data']['lifestyle_changes'], isA<Map>());
      });
    });

    group('Community Wellness', () {
      test('should provide community wellness initiatives', () async {
        // Arrange
        final mockResponse = {
          'success': true,
          'data': {
            'community_programs': [
              {
                'name': 'Círculo de Bem-estar',
                'description': 'Encontro semanal para compartilhar experiências e técnicas de bem-estar',
                'frequency': 'Semanal',
                'participants': '10-15 pessoas',
                'activities': ['meditação em grupo', 'exercícios leves', 'conversa terapêutica']
              },
              {
                'name': 'Horta Comunitária',
                'description': 'Cultivo coletivo de alimentos saudáveis',
                'frequency': 'Diária',
                'participants': 'Toda a comunidade',
                'activities': ['plantio', 'cuidado das plantas', 'colheita compartilhada']
              }
            ],
            'peer_support': {
              'buddy_system': 'Cada pessoa tem um parceiro de bem-estar',
              'check_ins': 'Conversas diárias de 5 minutos',
              'group_activities': 'Caminhadas, exercícios, meditação em grupo'
            },
            'wellness_education': [
              'Workshops sobre nutrição',
              'Treinamento em primeiros socorros psicológicos',
              'Técnicas de relaxamento',
              'Gestão de estresse comunitário'
            ]
          }
        };
        
        when(mockApiClient.post('/wellness/community', any))
            .thenAnswer((_) async => mockResponse);
        
        // Act
        final result = await wellnessService.getCommunityWellness(
          communitySize: 'medium',
          availableResources: ['espaço aberto', 'liderança local'],
        );
        
        // Assert
        expect(result['success'], isTrue);
        expect(result['data']['community_programs'], isA<List>());
        expect(result['data']['peer_support'], isA<Map>());
        expect(result['data']['wellness_education'], isA<List>());
      });
    });
  });
}