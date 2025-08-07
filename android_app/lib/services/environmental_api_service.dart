import 'dart:convert';
import 'package:http/http.dart' as http;

class EnvironmentalApiService {
  EnvironmentalApiService({required this.baseUrl});
  // Diagnóstico de doenças/pragas em plantas por imagem
  Future<Map<String, dynamic>> analyzePlantImage({
    required String imageBase64,
    String? plantType,
    String? userId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/plant/image-diagnosis'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'image': imageBase64,
        'plant_type': plantType ?? 'desconhecida',
        'user_id': userId,
      }),
    );
    final data = jsonDecode(response.body);
    if (data is Map<String, dynamic>) {
      return data;
    } else {
      throw Exception('Resposta inesperada do backend');
    }
  }

  final String baseUrl;

  // Biodiversidade: upload de imagem + localização
  Future<Map<String, dynamic>> trackBiodiversity({
    required String imageBase64,
    required Map<String, dynamic> location,
    String? userId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/biodiversity/track'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'image': imageBase64,
        'location': location,
        'user_id': userId,
      }),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Reciclagem: upload de imagem
  Future<Map<String, dynamic>> scanRecycling({
    required String imageBase64,
    String? userId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/recycling/scan'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'image': imageBase64,
        'user_id': userId,
      }),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Educação ambiental: módulos
  Future<List<dynamic>> getEducationModules() async {
    final response =
        await http.get(Uri.parse('$baseUrl/api/environmental/education'));
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['modules'] as List<dynamic>?) ?? [];
  }

  // Educação ambiental: conteúdo personalizado
  Future<Map<String, dynamic>> getEducationalContent({
    String? topic,
    String? ageGroup,
    String? educationLevel,
    String? language,
    String? ecosystem,
    String? learningStyle,
    int? duration,
    bool? includeActivities,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/environmental/education'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        if (topic != null) 'topic': topic,
        if (ageGroup != null) 'age_group': ageGroup,
        if (educationLevel != null) 'education_level': educationLevel,
        if (language != null) 'language': language,
        if (ecosystem != null) 'ecosystem': ecosystem,
        if (learningStyle != null) 'learning_style': learningStyle,
        if (duration != null) 'duration': duration,
        if (includeActivities != null) 'include_activities': includeActivities,
      }),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  // Alertas ambientais
  Future<List<dynamic>> getEnvironmentalAlerts() async {
    final response = await http.get(Uri.parse('$baseUrl/api/environmental/alerts'));
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['alerts'] as List<dynamic>?) ?? [];
  }

  // Gerar conteúdo educativo com prompts personalizados (Gemma3n)
  Future<Map<String, dynamic>> generateEducationalContent({
    required String topic,
    required String prompt,
    String? ageGroup,
    String? language,
    String? ecosystem,
    int? duration,
    bool? includeActivities,
    String? difficulty,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/environmental/education/generate-content'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'topic': topic,
          'prompt': prompt,
          if (ageGroup != null) 'age_group': ageGroup,
          if (language != null) 'language': language,
          if (ecosystem != null) 'ecosystem': ecosystem,
          if (duration != null) 'duration': duration,
          if (includeActivities != null) 'include_activities': includeActivities,
          if (difficulty != null) 'difficulty': difficulty,
        }),
      );
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded != null && decoded is Map<String, dynamic>) {
          return decoded;
        }
      }
      
      // Se chegou aqui, houve erro na API
      return {
        'success': false,
        'error': 'Erro na API: ${response.statusCode}',
        'fallback': true
      };
    } catch (e) {
      // Retorna erro estruturado em caso de exceção
      return {
        'success': false,
        'error': 'Erro de conexão: $e',
        'fallback': true
      };
    }
  }

  // Obter lista de tópicos educativos disponíveis
  Future<List<dynamic>> getEducationTopics() async {
    final response = await http.get(Uri.parse('$baseUrl/api/environmental/education/topics'));
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['topics'] as List<dynamic>?) ?? [];
  }

  // Diagnóstico de doenças de plantas por áudio
  Future<Map<String, dynamic>> analyzePlantAudio({
    required String audioBase64,
    String? plantType,
    String? userId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/plant/audio-diagnosis'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'audio': audioBase64,
        'plant_type': plantType ?? 'desconhecida',
        'user_id': userId,
      }),
    );
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
