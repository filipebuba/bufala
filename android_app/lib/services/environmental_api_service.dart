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
      Uri.parse('$baseUrl/plant/image-diagnosis'),
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
      Uri.parse('$baseUrl/biodiversity/track'),
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
      Uri.parse('$baseUrl/recycling/scan'),
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
        await http.get(Uri.parse('$baseUrl/environmental/education'));
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['modules'] as List<dynamic>?) ?? [];
  }

  // Alertas ambientais
  Future<List<dynamic>> getEnvironmentalAlerts() async {
    final response = await http.get(Uri.parse('$baseUrl/environmental/alerts'));
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['alerts'] as List<dynamic>?) ?? [];
  }

  // Diagnóstico de doenças de plantas por áudio
  Future<Map<String, dynamic>> analyzePlantAudio({
    required String audioBase64,
    String? plantType,
    String? userId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/plant/audio-diagnosis'),
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
