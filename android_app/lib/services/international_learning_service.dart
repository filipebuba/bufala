import 'package:dio/dio.dart';
import '../models/international_learning_models.dart';
import 'smart_api_service.dart';
import '../config/app_config.dart';

/// Serviço para o Sistema Internacional "Bu Fala Professor para ONGs"
class InternationalLearningService {

  InternationalLearningService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Bu-Fala-International/1.0',
      },
    ));

    // Interceptor para logging
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('[🌍 INTERNATIONAL] ${options.method} ${options.path}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          print('[✅ INTERNATIONAL] Resposta: ${response.statusCode}');
          handler.next(response);
        },
        onError: (error, handler) {
          print('[❌ INTERNATIONAL] Erro: ${error.message}');
          handler.next(error);
        },
      ),
    );
  }
  static String get baseUrl => AppConfig.backendHost == 'localhost' ? 'http://localhost:5000' : 'http://10.0.2.2:5000';
  late final Dio _dio;

  // ========================================
  // 🏢 ORGANIZAÇÕES INTERNACIONAIS
  // ========================================

  /// Listar organizações disponíveis
  Future<SmartApiResponse<List<InternationalOrganization>>> getOrganizations() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(AppConfig.buildUrl('international/organizations'));

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        if (data['success'] == true) {
          final organizations = (data['data'] as List)
              .map((org) => InternationalOrganization.fromJson(org as Map<String, dynamic>))
              .toList();
          return SmartApiResponse.success(data: organizations);
        }
      }

      return SmartApiResponse.error('Erro ao carregar organizações');
    } catch (e) {
      print('[❌ INTERNATIONAL] Erro ao carregar organizações: $e');
      return SmartApiResponse.error('Falha na comunicação: $e');
    }
  }

  /// Obter detalhes de uma organização
  Future<SmartApiResponse<InternationalOrganization>> getOrganization(String orgId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(AppConfig.buildUrl('international/organizations/$orgId'));

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        if (data['success'] == true) {
          final organization = InternationalOrganization.fromJson(data['data'] as Map<String, dynamic>);
          return SmartApiResponse.success(data: organization);
        }
      }

      return SmartApiResponse.error('Organização não encontrada');
    } catch (e) {
      print('[❌ INTERNATIONAL] Erro ao carregar organização: $e');
      return SmartApiResponse.error('Falha na comunicação: $e');
    }
  }

  // ========================================
  // 👨‍💼 PROFISSIONAIS INTERNACIONAIS
  // ========================================

  /// Registrar novo profissional internacional
  Future<SmartApiResponse<InternationalProfessional>> registerProfessional({
    required String name,
    required String email,
    required String profession,
    required String nativeLanguage,
    required List<String> spokenLanguages,
    required String organizationId,
    required String assignmentLocation,
    required DateTime arrivalDate,
    required List<String> targetLanguages, DateTime? departureDate,
    Map<String, dynamic>? learningPreferences,
  }) async {
    try {
      final requestData = {
        'name': name,
        'email': email,
        'profession': profession,
        'native_language': nativeLanguage,
        'spoken_languages': spokenLanguages,
        'organization_id': organizationId,
        'assignment_location': assignmentLocation,
        'arrival_date': arrivalDate.toIso8601String(),
        'departure_date': departureDate?.toIso8601String(),
        'target_languages': targetLanguages,
        'learning_preferences': learningPreferences ?? {},
      };

      final response = await _dio.post<Map<String, dynamic>>(
        AppConfig.buildUrl('international/professionals/register'),
        data: requestData,
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data!;
        if (responseData['success'] == true) {
          final professional = InternationalProfessional.fromJson(responseData['data'] as Map<String, dynamic>);
          return SmartApiResponse.success(data: professional);
        }
      }

      return SmartApiResponse.error('Erro ao registrar profissional');
    } catch (e) {
      print('[❌ INTERNATIONAL] Erro ao registrar: $e');
      return SmartApiResponse.error('Falha na comunicação: $e');
    }
  }

  /// Obter perfil de profissional
  Future<SmartApiResponse<InternationalProfessional>> getProfessional(String professionalId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(AppConfig.buildUrl('international/professionals/$professionalId'));

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        if (data['success'] == true) {
          final professional = InternationalProfessional.fromJson(data['data'] as Map<String, dynamic>);
          return SmartApiResponse.success(data: professional);
        }
      }

      return SmartApiResponse.error('Profissional não encontrado');
    } catch (e) {
      print('[❌ INTERNATIONAL] Erro ao carregar profissional: $e');
      return SmartApiResponse.error('Falha na comunicação: $e');
    }
  }

  // ========================================
  // 📚 MÓDULOS ESPECIALIZADOS
  // ========================================

  /// Obter módulos disponíveis para uma profissão
  Future<SmartApiResponse<List<SpecializedModule>>> getModules({
    required String profession,
    String? targetLanguage,
    String? difficultyLevel,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'profession': profession,
        if (targetLanguage != null) 'target_language': targetLanguage,
        if (difficultyLevel != null) 'difficulty_level': difficultyLevel,
      };

      final response = await _dio.get<Map<String, dynamic>>(
        AppConfig.buildUrl('international/modules'),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        if (data['success'] == true) {
          final modules = (data['data'] as List)
              .map((module) => SpecializedModule.fromJson(module as Map<String, dynamic>))
              .toList();
          return SmartApiResponse.success(data: modules);
        }
      }

      return SmartApiResponse.error('Erro ao carregar módulos');
    } catch (e) {
      print('[❌ INTERNATIONAL] Erro ao carregar módulos: $e');
      return SmartApiResponse.error('Falha na comunicação: $e');
    }
  }

  /// Obter módulo específico com lições
  Future<SmartApiResponse<SpecializedModule>> getModule(String moduleId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(AppConfig.buildUrl('international/modules/$moduleId'));

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        if (data['success'] == true) {
          final module = SpecializedModule.fromJson(data['data'] as Map<String, dynamic>);
          return SmartApiResponse.success(data: module);
        }
      }

      return SmartApiResponse.error('Módulo não encontrado');
    } catch (e) {
      print('[❌ INTERNATIONAL] Erro ao carregar módulo: $e');
      return SmartApiResponse.error('Falha na comunicação: $e');
    }
  }

  /// Gerar módulo personalizado usando IA
  Future<SmartApiResponse<SpecializedModule>> generateCustomModule({
    required String professionalId,
    required String profession,
    required String targetLanguage,
    required String scenario, // 'emergency', 'daily_work', 'cultural_interaction'
    String? specificNeeds,
    int? urgencyHours, // para módulos de emergência
  }) async {
    try {
      final requestData = {
        'professional_id': professionalId,
        'profession': profession,
        'target_language': targetLanguage,
        'scenario': scenario,
        'specific_needs': specificNeeds,
        'urgency_hours': urgencyHours,
      };

      final response = await _dio.post<Map<String, dynamic>>(
        AppConfig.buildUrl('international/modules/generate'),
        data: requestData,
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data!;
        if (responseData['success'] == true) {
          final module = SpecializedModule.fromJson(responseData['data'] as Map<String, dynamic>);
          return SmartApiResponse.success(data: module);
        }
      }

      return SmartApiResponse.error('Erro ao gerar módulo');
    } catch (e) {
      print('[❌ INTERNATIONAL] Erro ao gerar módulo: $e');
      return SmartApiResponse.error('Falha na comunicação: $e');
    }
  }

  // ========================================
  // 📊 DASHBOARD E RELATÓRIOS
  // ========================================

  /// Obter dashboard da organização
  Future<SmartApiResponse<OrganizationDashboard>> getOrganizationDashboard(String organizationId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(AppConfig.buildUrl('international/dashboard/$organizationId'));

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        if (data['success'] == true) {
          final dashboard = OrganizationDashboard.fromJson(data['data'] as Map<String, dynamic>);
          return SmartApiResponse.success(data: dashboard);
        }
      }

      return SmartApiResponse.error('Erro ao carregar dashboard');
    } catch (e) {
      print('[❌ INTERNATIONAL] Erro ao carregar dashboard: $e');
      return SmartApiResponse.error('Falha na comunicação: $e');
    }
  }

  /// Obter relatório de progresso de profissional
  Future<SmartApiResponse<ProfessionalProgress>> getProfessionalProgress(String professionalId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(AppConfig.buildUrl('international/professionals/$professionalId/progress'));

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        if (data['success'] == true) {
          final progress = ProfessionalProgress.fromJson(data['data'] as Map<String, dynamic>);
          return SmartApiResponse.success(data: progress);
        }
      }

      return SmartApiResponse.error('Erro ao carregar progresso');
    } catch (e) {
      print('[❌ INTERNATIONAL] Erro ao carregar progresso: $e');
      return SmartApiResponse.error('Falha na comunicação: $e');
    }
  }

  // ========================================
  // 🆘 FUNÇÕES DE EMERGÊNCIA
  // ========================================

  /// Gerar módulo de emergência rápido (2 horas ou menos)
  Future<SmartApiResponse<SpecializedModule>> generateEmergencyModule({
    required String professionalId,
    required String profession,
    required String targetLanguage,
    required String emergencyType, // 'medical', 'disaster', 'security'
    required int hoursUntilDeployment,
  }) async {
    try {
      final requestData = {
        'professional_id': professionalId,
        'profession': profession,
        'target_language': targetLanguage,
        'emergency_type': emergencyType,
        'hours_until_deployment': hoursUntilDeployment,
      };

      final response = await _dio.post<Map<String, dynamic>>(
        AppConfig.buildUrl('international/emergency/module'),
        data: requestData,
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data!;
        if (responseData['success'] == true) {
          final module = SpecializedModule.fromJson(responseData['data'] as Map<String, dynamic>);
          return SmartApiResponse.success(data: module);
        }
      }

      return SmartApiResponse.error('Erro ao criar módulo de emergência');
    } catch (e) {
      print('[❌ INTERNATIONAL] Erro módulo emergência: $e');
      return SmartApiResponse.error('Falha na comunicação: $e');
    }
  }

  /// Obter frases essenciais para emergência
  Future<SmartApiResponse<List<LessonItem>>> getEmergencyPhrases({
    required String profession,
    required String targetLanguage,
    required String emergencyType,
  }) async {
    try {
      final queryParams = {
        'profession': profession,
        'target_language': targetLanguage,
        'emergency_type': emergencyType,
      };

      final response = await _dio.get<Map<String, dynamic>>(
        AppConfig.buildUrl('international/emergency/phrases'),
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data!;
        if (data['success'] == true) {
          final phrases = (data['data'] as List)
              .map((phrase) => LessonItem.fromJson(phrase as Map<String, dynamic>))
              .toList();
          return SmartApiResponse.success(data: phrases);
        }
      }

      return SmartApiResponse.error('Erro ao carregar frases de emergência');
    } catch (e) {
      print('[❌ INTERNATIONAL] Erro frases emergência: $e');
      return SmartApiResponse.error('Falha na comunicação: $e');
    }
  }

  // ========================================
  // 🎯 SIMULAÇÕES E CENÁRIOS
  // ========================================

  /// Iniciar simulação de cenário real
  Future<SmartApiResponse<Map<String, dynamic>>> startSimulation({
    required String professionalId,
    required String scenarioType, // 'medical_emergency', 'field_work', 'cultural_meeting'
    required String targetLanguage,
    Map<String, dynamic>? context,
  }) async {
    try {
      final requestData = {
        'professional_id': professionalId,
        'scenario_type': scenarioType,
        'target_language': targetLanguage,
        'context': context ?? {},
      };

      final response = await _dio.post<Map<String, dynamic>>(
        AppConfig.buildUrl('international/simulations/start'),
        data: requestData,
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data!;
        if (responseData['success'] == true) {
          return SmartApiResponse.success(data: responseData['data'] as Map<String, dynamic>);
        }
      }

      return SmartApiResponse.error('Erro ao iniciar simulação');
    } catch (e) {
      print('[❌ INTERNATIONAL] Erro ao iniciar simulação: $e');
      return SmartApiResponse.error('Falha na comunicação: $e');
    }
  }
}
