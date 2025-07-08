/// Serviço para o sistema de ensino colaborativo
/// "Ensine o Bu Fala" - Integração com backend e gestão local
library;

import '../models/collaborative_teaching_models.dart';
import 'smart_api_service.dart';

/// Serviço principal para o sistema de ensino colaborativo
class CollaborativeTeachingService {

  factory CollaborativeTeachingService() => _instance;
  CollaborativeTeachingService._internal();
  static final CollaborativeTeachingService _instance =
      CollaborativeTeachingService._internal();

  final SmartApiService _apiService = SmartApiService();

  // Cache local para melhor performance
  List<TeachableLanguage>? _cachedLanguages;
  LanguageProfessor? _currentProfessor;
  TeachingStats? _cachedStats;

  /// Inicializar o serviço com dados do usuário
  Future<void> initialize({String? userId, String? userName}) async {
    try {
      print('[🎓 TEACHING] Inicializando sistema de ensino colaborativo...');

      // Carregar perfil do professor se existir
      if (userId != null) {
        _currentProfessor = await _loadProfessorProfile(userId);
      }

      // Carregar idiomas disponíveis
      await _loadAvailableLanguages();

      print('[✅ TEACHING] Sistema inicializado com sucesso');
    } catch (e) {
      print('[❌ TEACHING] Erro na inicialização: $e');
    }
  }

  /// Carregar idiomas que podem ser ensinados
  Future<List<TeachableLanguage>> getAvailableLanguages() async {
    if (_cachedLanguages != null) {
      return _cachedLanguages!;
    }

    return _loadAvailableLanguages();
  }

  Future<List<TeachableLanguage>> _loadAvailableLanguages() async {
    try {
      final response = await _apiService.get('/teaching/languages');

      if (response.isSuccess && response.data != null) {
        final languagesData = response.data!['languages'] as List? ?? [];
        _cachedLanguages = languagesData
            .map((json) =>
                TeachableLanguage.fromJson(json as Map<String, dynamic>))
            .toList();

        return _cachedLanguages!;
      }

      // Fallback com idiomas padrão da Guiné-Bissau
      _cachedLanguages = _getDefaultLanguages();
      return _cachedLanguages!;
    } catch (e) {
      print('[❌ TEACHING] Erro ao carregar idiomas: $e');
      _cachedLanguages = _getDefaultLanguages();
      return _cachedLanguages!;
    }
  }

  /// Idiomas padrão da Guiné-Bissau
  List<TeachableLanguage> _getDefaultLanguages() => [
      const TeachableLanguage(
        id: 'fula',
        name: 'Fula',
        nativeName: 'Fulfulde',
        region: 'Leste',
        specialties: ['medical', 'agriculture', 'daily'],
      ),
      const TeachableLanguage(
        id: 'mandinka',
        name: 'Mandinka',
        nativeName: 'Mandinka',
        region: 'Norte/Leste',
        specialties: ['agriculture', 'daily', 'greetings'],
      ),
      const TeachableLanguage(
        id: 'balanta',
        name: 'Balanta',
        nativeName: 'Balanta',
        region: 'Centro/Sul',
        specialties: ['agriculture', 'daily'],
      ),
      const TeachableLanguage(
        id: 'papel',
        name: 'Papel',
        nativeName: 'Papel',
        region: 'Bissau/Costa',
        specialties: ['daily', 'greetings'],
      ),
      const TeachableLanguage(
        id: 'wolof',
        name: 'Wolof',
        nativeName: 'Wolof',
        region: 'Norte',
        specialties: ['daily', 'greetings'],
      ),
      const TeachableLanguage(
        id: 'crioulo',
        name: 'Crioulo Guineense',
        nativeName: 'Kriol',
        region: 'Nacional',
        specialties: ['medical', 'agriculture', 'daily', 'greetings'],
      ),
    ];

  /// Carregar perfil do professor
  Future<LanguageProfessor?> _loadProfessorProfile(String userId) async {
    try {
      final response = await _apiService.get('/teaching/professors/$userId');

      if (response.isSuccess && response.data != null) {
        return LanguageProfessor.fromJson(response.data!);
      }

      return null;
    } catch (e) {
      print('[❌ TEACHING] Erro ao carregar perfil: $e');
      return null;
    }
  }

  /// Criar perfil de professor para novo usuário
  Future<LanguageProfessor> createProfessorProfile({
    required String userId,
    required String userName,
    List<String> languagesToTeach = const [],
  }) async {
    try {
      final response = await _apiService.post('/teaching/professors', {
        'user_id': userId,
        'name': userName,
        'languages_to_teach': languagesToTeach,
        'join_date': DateTime.now().toIso8601String(),
      });

      if (response.isSuccess && response.data != null) {
        _currentProfessor = LanguageProfessor.fromJson(response.data!);
        return _currentProfessor!;
      }

      throw Exception('Falha ao criar perfil de professor');
    } catch (e) {
      print('[❌ TEACHING] Erro ao criar perfil: $e');

      // Fallback: criar perfil local temporário
      _currentProfessor = LanguageProfessor(
        id: userId,
        name: userName,
        joinDate: DateTime.now(),
        lastActive: DateTime.now(),
      );

      return _currentProfessor!;
    }
  }

  /// Enviar nova contribuição de ensino
  Future<SmartApiResponse<TeachingContribution>> submitContribution({
    required String sourceLanguage,
    required String targetLanguage,
    required String sourceText,
    required String targetText,
    required String category,
    String? audioBase64,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (_currentProfessor == null) {
        return SmartApiResponse.error('Perfil de professor não encontrado');
      }

      print('[📝 TEACHING] Enviando contribuição: $sourceText → $targetText');

      final response = await _apiService.post('/teaching/contributions', {
        'source_language': sourceLanguage,
        'target_language': targetLanguage,
        'source_text': sourceText,
        'target_text': targetText,
        'category': category,
        'professor_id': _currentProfessor!.id,
        'professor_name': _currentProfessor!.name,
        'audio_base64': audioBase64,
        'metadata': metadata,
        'timestamp': DateTime.now().toIso8601String(),
      });

      if (response.isSuccess && response.data != null) {
        final contribution = TeachingContribution.fromJson(response.data!);

        print(
            '[✅ TEACHING] Contribuição enviada com sucesso: ${contribution.id}');

        return SmartApiResponse.success(
          data: contribution,
          source: 'Sistema de Ensino',
        );
      }

      return SmartApiResponse.error('Falha ao enviar contribuição');
    } catch (e) {
      print('[❌ TEACHING] Erro ao enviar contribuição: $e');
      return SmartApiResponse.error('Erro inesperado: $e');
    }
  }

  /// Buscar contribuições para validação
  Future<SmartApiResponse<List<TeachingContribution>>>
      getContributionsForValidation({
    String? languageId,
    String? category,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'status': 'pending',
      };

      if (languageId != null) queryParams['language_id'] = languageId;
      if (category != null) queryParams['category'] = category;

      final response = await _apiService.get(
          '/teaching/contributions/validation?${_buildQueryString(queryParams)}');

      if (response.isSuccess && response.data != null) {
        final contributionsData =
            response.data!['contributions'] as List? ?? [];
        final contributions = contributionsData
            .map((json) =>
                TeachingContribution.fromJson(json as Map<String, dynamic>))
            .toList();

        return SmartApiResponse.success(
          data: contributions,
          source: 'Lista de Validação',
        );
      }

      return SmartApiResponse.error('Falha ao buscar contribuições');
    } catch (e) {
      print('[❌ TEACHING] Erro ao buscar contribuições: $e');
      return SmartApiResponse.error('Erro inesperado: $e');
    }
  }

  /// Votar em uma contribuição (validação)
  Future<SmartApiResponse<String>> voteOnContribution({
    required String contributionId,
    required bool isPositive,
    String? comment,
  }) async {
    try {
      if (_currentProfessor == null) {
        return SmartApiResponse.error('Perfil de professor não encontrado');
      }

      final response = await _apiService
          .post('/teaching/contributions/$contributionId/vote', {
        'validator_id': _currentProfessor!.id,
        'validator_name': _currentProfessor!.name,
        'is_positive': isPositive,
        'comment': comment,
        'timestamp': DateTime.now().toIso8601String(),
      });

      if (response.isSuccess) {
        final message = isPositive
            ? 'Voto positivo registrado'
            : 'Voto negativo registrado';
        print('[✅ TEACHING] $message para contribuição $contributionId');

        return SmartApiResponse.success(
          data: message,
          source: 'Sistema de Validação',
        );
      }

      return SmartApiResponse.error('Falha ao registrar voto');
    } catch (e) {
      print('[❌ TEACHING] Erro ao votar: $e');
      return SmartApiResponse.error('Erro inesperado: $e');
    }
  }

  /// Buscar frases sugeridas para ensinar
  Future<SmartApiResponse<List<String>>> getSuggestedPhrases({
    required String category,
    String? languageId,
    int limit = 10,
  }) async {
    try {
      // Primeiro, tentar buscar do backend
      final response = await _apiService.get(
          '/teaching/suggestions?category=$category&language=$languageId&limit=$limit');

      if (response.isSuccess && response.data != null) {
        final phrases =
            List<String>.from(response.data!['phrases'] as List? ?? []);

        if (phrases.isNotEmpty) {
          return SmartApiResponse.success(
            data: phrases,
            source: 'Sugestões do Backend',
          );
        }
      }
    } catch (e) {
      print('[⚠️ TEACHING] Erro ao buscar sugestões do backend: $e');
    }

    // Fallback: usar sugestões locais
    final localSuggestions = _getLocalSuggestions(category);
    return SmartApiResponse.success(
      data: localSuggestions.take(limit).toList(),
      source: 'Sugestões Locais',
      confidence: 0.8,
    );
  }

  /// Sugestões locais por categoria
  List<String> _getLocalSuggestions(String category) {
    final suggestions = TeachingCategory.defaultCategories
        .firstWhere((cat) => cat.id == category,
            orElse: () => TeachingCategory.defaultCategories.first)
        .suggestedPhrases;

    // Embaralhar para variedade
    final shuffled = List<String>.from(suggestions);
    shuffled.shuffle();
    return shuffled;
  }

  /// Buscar estatísticas do professor atual
  Future<SmartApiResponse<TeachingStats>> getTeachingStats() async {
    try {
      if (_currentProfessor == null) {
        return SmartApiResponse.error('Perfil de professor não encontrado');
      }

      if (_cachedStats != null) {
        return SmartApiResponse.success(
          data: _cachedStats!,
          source: 'Cache Local',
        );
      }

      final response = await _apiService
          .get('/teaching/professors/${_currentProfessor!.id}/stats');

      if (response.isSuccess && response.data != null) {
        _cachedStats = TeachingStats.fromJson(response.data!);

        return SmartApiResponse.success(
          data: _cachedStats!,
          source: 'Estatísticas do Backend',
        );
      }

      // Fallback: estatísticas vazias
      _cachedStats = const TeachingStats();
      return SmartApiResponse.success(
        data: _cachedStats!,
        source: 'Estatísticas Padrão',
        confidence: 0.5,
      );
    } catch (e) {
      print('[❌ TEACHING] Erro ao buscar estatísticas: $e');

      _cachedStats = const TeachingStats();
      return SmartApiResponse.success(
        data: _cachedStats!,
        source: 'Estatísticas de Emergência',
        confidence: 0.3,
      );
    }
  }

  /// Buscar ranking de professores
  Future<SmartApiResponse<List<LanguageProfessor>>> getProfessorRanking({
    String? languageId,
    String period = 'week', // week, month, all
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'period': period,
        'limit': limit,
      };

      if (languageId != null) queryParams['language_id'] = languageId;

      final response = await _apiService
          .get('/teaching/ranking?${_buildQueryString(queryParams)}');

      if (response.isSuccess && response.data != null) {
        final professorsData = response.data!['professors'] as List? ?? [];
        final professors = professorsData
            .map((json) =>
                LanguageProfessor.fromJson(json as Map<String, dynamic>))
            .toList();

        return SmartApiResponse.success(
          data: professors,
          source: 'Ranking do Backend',
        );
      }

      return SmartApiResponse.error('Falha ao buscar ranking');
    } catch (e) {
      print('[❌ TEACHING] Erro ao buscar ranking: $e');
      return SmartApiResponse.error('Erro inesperado: $e');
    }
  }

  /// Verificar e desbloquear badges
  Future<SmartApiResponse<List<TeachingBadge>>> checkUnlockedBadges() async {
    try {
      if (_currentProfessor == null) {
        return SmartApiResponse.error('Perfil de professor não encontrado');
      }

      final response = await _apiService.post(
          '/teaching/professors/${_currentProfessor!.id}/badges/check', {});

      if (response.isSuccess && response.data != null) {
        final badgesData = response.data!['new_badges'] as List? ?? [];
        final newBadges = badgesData
            .map((json) => TeachingBadge.fromJson(json as Map<String, dynamic>))
            .toList();

        if (newBadges.isNotEmpty) {
          print(
              '[🏆 TEACHING] Novas badges desbloqueadas: ${newBadges.length}');
        }

        return SmartApiResponse.success(
          data: newBadges,
          source: 'Sistema de Badges',
        );
      }

      return SmartApiResponse.success(
        data: <TeachingBadge>[],
        source: 'Sem Novas Badges',
      );
    } catch (e) {
      print('[❌ TEACHING] Erro ao verificar badges: $e');
      return SmartApiResponse.error('Erro inesperado: $e');
    }
  }

  /// Buscar histórico de contribuições do usuário
  Future<SmartApiResponse<List<TeachingContribution>>> getMyContributions({
    String? languageId,
    String? category,
    ContributionStatus? status,
    int limit = 20,
  }) async {
    try {
      if (_currentProfessor == null) {
        return SmartApiResponse.error('Perfil de professor não encontrado');
      }

      final queryParams = <String, dynamic>{
        'professor_id': _currentProfessor!.id,
        'limit': limit,
      };

      if (languageId != null) queryParams['language_id'] = languageId;
      if (category != null) queryParams['category'] = category;
      if (status != null) queryParams['status'] = status.name;

      final response = await _apiService
          .get('/teaching/contributions/my?${_buildQueryString(queryParams)}');

      if (response.isSuccess && response.data != null) {
        final contributionsData =
            response.data!['contributions'] as List? ?? [];
        final contributions = contributionsData
            .map((json) =>
                TeachingContribution.fromJson(json as Map<String, dynamic>))
            .toList();

        return SmartApiResponse.success(
          data: contributions,
          source: 'Minhas Contribuições',
        );
      }

      return SmartApiResponse.error('Falha ao buscar contribuições');
    } catch (e) {
      print('[❌ TEACHING] Erro ao buscar contribuições: $e');
      return SmartApiResponse.error('Erro inesperado: $e');
    }
  }

  /// Atualizar cache de dados
  Future<void> refreshCache() async {
    _cachedLanguages = null;
    _cachedStats = null;

    // Recarregar dados
    await _loadAvailableLanguages();
    if (_currentProfessor != null) {
      await getTeachingStats();
    }
  }

  /// Getter para o professor atual
  LanguageProfessor? get currentProfessor => _currentProfessor;

  /// Getter para categorias de ensino
  List<TeachingCategory> get teachingCategories =>
      TeachingCategory.defaultCategories;

  /// Getter para badges disponíveis
  List<TeachingBadge> get availableBadges => TeachingBadge.defaultBadges;

  /// Helper para construir query string
  String _buildQueryString(Map<String, dynamic> params) => params.entries
        .where((e) => e.value != null)
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value.toString())}')
        .join('&');

  /// Calcular pontos por tipo de ação
  static int getPointsForAction(String action) {
    switch (action) {
      case 'contribute_phrase':
        return 10;
      case 'validate_positive':
        return 5;
      case 'validate_negative':
        return 3;
      case 'contribute_audio':
        return 15;
      case 'complete_category':
        return 100;
      case 'daily_streak':
        return 20;
      default:
        return 1;
    }
  }

  /// Verificar se usuário pode ensinar um idioma
  bool canTeachLanguage(String languageId) {
    if (_currentProfessor == null) return false;

    return _currentProfessor!.languagesTeaching
        .any((lang) => lang.languageId == languageId);
  }

  /// Adicionar idioma que o usuário pode ensinar
  Future<SmartApiResponse<String>> addTeachingLanguage(
      String languageId) async {
    try {
      if (_currentProfessor == null) {
        return SmartApiResponse.error('Perfil de professor não encontrado');
      }

      final response = await _apiService.post(
          '/teaching/professors/${_currentProfessor!.id}/languages',
          {'language_id': languageId});

      if (response.isSuccess) {
        // Recarregar perfil do professor
        _currentProfessor = await _loadProfessorProfile(_currentProfessor!.id);

        return SmartApiResponse.success(
          data: 'Idioma adicionado com sucesso',
          source: 'Sistema de Ensino',
        );
      }

      return SmartApiResponse.error('Falha ao adicionar idioma');
    } catch (e) {
      print('[❌ TEACHING] Erro ao adicionar idioma: $e');
      return SmartApiResponse.error('Erro inesperado: $e');
    }
  }
}
