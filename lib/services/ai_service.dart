import '../constants/api_constants.dart';
import 'api_service.dart';
import 'package:dio/dio.dart';

class AiService {
  final ApiService _apiService = ApiService();

  dynamic _parseResponse(Response response) {
    final data = response.data;
    if (data is Map && data.containsKey('data')) {
      return data['data'];
    }
    return data;
  }

  Future<Map<String, dynamic>> getAiSettings() async {
    final response = await _apiService.dio.get(ApiConstants.aiSettings);
    final parsed = _parseResponse(response);
    return parsed as Map<String, dynamic>;
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
    final parsed = _parseResponse(response);
    return parsed as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> updateAiSettingsRaw({
    required String apiUrl,
    required String apiKey,
    required String model,
    required String titlePrompt,
    required String descriptionPrompt,
    required String safetyRules,
    required String replacementWords,
  }) async {
    final response = await _apiService.dio.put(
      ApiConstants.aiSettings,
      data: {
        'api_url': apiUrl,
        'api_key': apiKey,
        'model': model,
        'title_prompt': titlePrompt,
        'description_prompt': descriptionPrompt,
        'safety_rules': safetyRules,
        'replacement_words': replacementWords,
      },
    );
    final parsed = _parseResponse(response);
    return parsed as Map<String, dynamic>;
  }

  Future<String> generateTitle({
    String? image,
    int? currentUserId,
    String? currentTitle,
  }) async {
    final response = await _apiService.dio.post(
      ApiConstants.generateTitle,
      data: {
        if (image != null) 'image': image,
        if (currentUserId != null) 'current_user_id': currentUserId,
        if (currentTitle != null) 'current_title': currentTitle,
      },
    );
    final parsed = _parseResponse(response);
    if (parsed is Map && parsed.containsKey('title')) {
      return parsed['title'] as String;
    }
    throw Exception('Failed to generate title');
  }

  Future<String> generateDescription({
    String? image,
    int? currentUserId,
    String? currentDescription,
  }) async {
    final response = await _apiService.dio.post(
      ApiConstants.generateDescription,
      data: {
        if (image != null) 'image': image,
        if (currentUserId != null) 'current_user_id': currentUserId,
        if (currentDescription != null) 'current_description': currentDescription,
      },
    );
    final parsed = _parseResponse(response);
    if (parsed is Map && parsed.containsKey('description')) {
      return parsed['description'] as String;
    }
    throw Exception('Failed to generate description');
  }

  Future<String> translate(String text) async {
    try {
      final response = await _apiService.dio.post(
        ApiConstants.translate,
        data: {'text': text},
      );
      print('Translate response: ${response.data}');
      final parsed = _parseResponse(response);
      if (parsed is Map && parsed.containsKey('translated')) {
        return parsed['translated'] as String;
      }
      if (parsed is String) {
        return parsed;
      }
      throw Exception('Failed to translate');
    } catch (e) {
      print('Translate error: $e');
      if (e is DioException) {
        print('Dio error response: ${e.response}');
        print('Dio error message: ${e.message}');
      }
      rethrow;
    }
  }

  Future<String> translateToChinese(String text) async {
    // 直接调用后端API，但这里后端只支持中译英
    // 所以我们复用同一个方法，让用户选择方向
    return translate(text);
  }

  Future<String> translateToEnglish(String text) async {
    return translate(text);
  }
}
