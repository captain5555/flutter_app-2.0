import 'dart:io';
import '../constants/api_constants.dart';
import '../models/material.dart';
import 'api_service.dart';
import 'package:dio/dio.dart';

class MaterialService {
  final ApiService _apiService = ApiService();

  Future<List<Material>> getUserMaterials(int userId, String folderType) async {
    final response = await _apiService.dio.get(
      ApiConstants.materialsByUser(userId, folderType),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => Material.fromJson(json)).toList();
    }

    throw Exception('Failed to load materials');
  }

  Future<List<Material>> getTrashMaterials(int userId) async {
    final response = await _apiService.dio.get(
      ApiConstants.trashByUser(userId),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => Material.fromJson(json)).toList();
    }

    throw Exception('Failed to load trash materials');
  }

  Future<Material> getMaterial(int id) async {
    final response = await _apiService.dio.get(
      ApiConstants.materialById(id),
    );

    if (response.statusCode == 200) {
      return Material.fromJson(response.data);
    }

    throw Exception('Failed to load material');
  }

  Future<Material> uploadMaterial({
    required int userId,
    required File file,
    required String folderType,
    String? title,
    String? description,
  }) async {
    String fileName = file.path.split('/').last;
    FormData formData = FormData.fromMap({
      'userId': userId,
      'folderType': folderType,
      'title': title,
      'description': description,
      'file': await MultipartFile.fromFile(file.path, filename: fileName),
    });

    final response = await _apiService.dio.post(
      ApiConstants.uploadMaterial,
      data: formData,
    );

    if (response.statusCode == 201) {
      return Material.fromJson(response.data);
    }

    throw Exception('Failed to upload material');
  }

  Future<Material> updateMaterial(int id, {
    String? title,
    String? description,
    String? usageTag,
    String? viralTag,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (description != null) data['description'] = description;
    if (usageTag != null) data['usageTag'] = usageTag;
    if (viralTag != null) data['viralTag'] = viralTag;

    final response = await _apiService.dio.put(
      ApiConstants.materialById(id),
      data: data,
    );

    if (response.statusCode == 200) {
      return Material.fromJson(response.data);
    }

    throw Exception('Failed to update material');
  }

  Future<void> moveToTrash(int id) async {
    final response = await _apiService.dio.delete(
      ApiConstants.materialById(id),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to move to trash');
    }
  }

  Future<void> batchTrash(List<int> ids) async {
    final response = await _apiService.dio.post(
      ApiConstants.batchTrash,
      data: {'ids': ids},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to batch trash');
    }
  }

  Future<void> batchRestore(List<int> ids) async {
    final response = await _apiService.dio.post(
      ApiConstants.batchRestore,
      data: {'ids': ids},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to batch restore');
    }
  }

  Future<void> batchDelete(List<int> ids) async {
    final response = await _apiService.dio.delete(
      ApiConstants.batchDeletePermanent,
      data: {'ids': ids},
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to batch delete');
    }
  }

  Future<void> batchCopy(List<int> ids, String targetFolder) async {
    final response = await _apiService.dio.post(
      ApiConstants.batchCopy,
      data: {'ids': ids, 'targetFolder': targetFolder},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to batch copy');
    }
  }

  Future<void> batchMove(List<int> ids, String targetFolder) async {
    final response = await _apiService.dio.post(
      ApiConstants.batchMove,
      data: {'ids': ids, 'targetFolder': targetFolder},
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to batch move');
    }
  }
}
