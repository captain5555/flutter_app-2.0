import '../constants/api_constants.dart';
import 'api_service.dart';

class AiService {
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>> getAiSettings() async {
    final response = await _apiService.dio.get(ApiConstants.aiSettings);

    if (response.statusCode == 200) {
      return response.data;
    }

    throw Exception('Failed to load AI settings');
  }

  Future<Map<String, dynamic>> updateAiSettings({
    required String provider,
    required String model,
    required String apiKey,
    required String baseUrl,
  }) async {
    final response = await _apiService.dio.put(
      ApiConstants.aiSettings,
      data: {
        'provider': provider,
        'model': model,
        'apiKey': apiKey,
        'baseUrl': baseUrl,
      },
    );

    if (response.statusCode == 200) {
      return response.data;
    }

    throw Exception('Failed to update AI settings');
  }

  Future<String> generateTitle(String description) async {
    final response = await _apiService.dio.post(
      ApiConstants.generateTitle,
      data: {'description': description},
    );

    if (response.statusCode == 200) {
      return response.data['title'] as String;
    }

    throw Exception('Failed to generate title');
  }

  Future<String> generateDescription(String title) async {
    final response = await _apiService.dio.post(
      ApiConstants.generateDescription,
      data: {'title': title},
    );

    if (response.statusCode == 200) {
      return response.data['description'] as String;
    }

    throw Exception('Failed to generate description');
  }

  Future<String> translate(String text, String targetLang) async {
    final response = await _apiService.dio.post(
      ApiConstants.translate,
      data: {
        'text': text,
        'targetLang': targetLang,
      },
    );

    if (response.statusCode == 200) {
      return response.data['translatedText'] as String;
    }

    throw Exception('Failed to translate');
  }
}
