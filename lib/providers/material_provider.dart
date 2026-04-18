import 'package:flutter/foundation.dart';
import '../models/material.dart';
import '../models/user.dart';
import '../services/material_service.dart';

class MaterialProvider with ChangeNotifier {
  final MaterialService _materialService = MaterialService();

  MaterialService get materialService => _materialService;

  List<Material> _materials = [];
  List<Material> _trashMaterials = [];
  bool _isLoading = false;
  String? _error;
  String _currentFolder = 'images';
  int? _viewingUserId;

  List<Material> get materials => _materials;
  List<Material> get trashMaterials => _trashMaterials;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentFolder => _currentFolder;
  int? get viewingUserId => _viewingUserId;

  void setFolder(String folder) {
    _currentFolder = folder;
    notifyListeners();
  }

  void setViewingUser(int? userId) {
    _viewingUserId = userId;
    notifyListeners();
  }

  Future<void> loadMaterials(User user, {int? viewingUserId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = viewingUserId ?? _viewingUserId ?? user.id;
      _materials = await _materialService.getUserMaterials(userId, _currentFolder);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTrash(User user, {int? viewingUserId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final userId = viewingUserId ?? _viewingUserId ?? user.id;
      _trashMaterials = await _materialService.getTrashMaterials(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh(User user, {int? viewingUserId}) async {
    await Future.wait([
      loadMaterials(user, viewingUserId: viewingUserId),
      loadTrash(user, viewingUserId: viewingUserId),
    ]);
  }

  Future<void> updateMaterial(int id, Map<String, dynamic> data) async {
    try {
      final updated = await _materialService.updateMaterial(
        id,
        title: data['title'],
        description: data['description'],
        usageTag: data['usage_tag'],
        viralTag: data['viral_tag'],
      );

      final index = _materials.indexWhere((m) => m.id == id);
      if (index != -1) {
        _materials[index] = updated;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<bool> updateMaterialObject(Material material) async {
    try {
      final updated = await _materialService.updateMaterial(
        material.id,
        title: material.title,
        description: material.description,
        usageTag: material.usageTag,
        viralTag: material.viralTag,
      );

      final index = _materials.indexWhere((m) => m.id == material.id);
      if (index != -1) {
        _materials[index] = updated;
        notifyListeners();
      }

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> moveToTrash(Material material) async {
    try {
      await _materialService.moveToTrash(material.id);

      _materials.removeWhere((m) => m.id == material.id);
      _trashMaterials.add(material.copyWith(isDeleted: true));
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> batchTrash(List<int> ids) async {
    try {
      await _materialService.batchTrash(ids);

      for (final id in ids) {
        try {
          final material = _materials.firstWhere((m) => m.id == id);
          _materials.removeWhere((m) => m.id == id);
          _trashMaterials.add(material.copyWith(isDeleted: true));
        } catch (e) {
          // Material not found in list, skip
        }
      }
      notifyListeners();

      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> batchRestore(List<int> ids, User user) async {
    try {
      await _materialService.batchRestore(ids);
      await refresh(user);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> batchDelete(List<int> ids, User user) async {
    try {
      await _materialService.batchDelete(ids);
      await refresh(user);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> batchCopy(List<int> ids, int targetUserId, User user) async {
    try {
      await _materialService.batchCopy(ids, targetUserId);
      await refresh(user);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> batchMove(List<int> ids, int targetUserId, String targetFolder, User user) async {
    try {
      await _materialService.batchMove(ids, targetUserId, targetFolder);
      await refresh(user);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<Material> uploadMaterial({
    required int userId,
    required List<int> bytes,
    required String fileName,
    required String folderType,
    String? title,
    String? description,
  }) async {
    try {
      final material = await _materialService.uploadMaterial(
        userId: userId,
        bytes: bytes,
        fileName: fileName,
        folderType: folderType,
        title: title,
        description: description,
      );
      _materials.insert(0, material);
      notifyListeners();
      return material;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
