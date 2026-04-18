import '../constants/api_constants.dart';
import 'api_service.dart';
import 'package:dio/dio.dart';

class AdminService {
  final ApiService _apiService = ApiService();

  dynamic _parseResponse(Response response) {
    final data = response.data;
    if (data is Map && data.containsKey('data')) {
      return data['data'];
    }
    return data;
  }

  Future<Map<String, dynamic>> getStats() async {
    final response = await _apiService.dio.get(ApiConstants.adminStats);
    final parsed = _parseResponse(response);
    return parsed as Map<String, dynamic>;
  }

  Future<List<dynamic>> getLogs({int? userId, String? action}) async {
    final params = <String, dynamic>{};
    if (userId != null) params['userId'] = userId;
    if (action != null) params['action'] = action;

    final response = await _apiService.dio.get(
      ApiConstants.adminLogs,
      queryParameters: params,
    );
    final parsed = _parseResponse(response);
    return parsed as List<dynamic>;
  }

  Future<Map<String, dynamic>> createBackup() async {
    final response = await _apiService.dio.post(ApiConstants.adminBackup);
    final parsed = _parseResponse(response);
    return parsed as Map<String, dynamic>;
  }

  Future<List<dynamic>> listBackups() async {
    final response = await _apiService.dio.get(ApiConstants.adminBackups);
    final parsed = _parseResponse(response);
    return parsed as List<dynamic>;
  }

  Future<void> deleteBackup(String backupId) async {
    await _apiService.dio.delete('${ApiConstants.adminBackups}/$backupId');
  }
}
