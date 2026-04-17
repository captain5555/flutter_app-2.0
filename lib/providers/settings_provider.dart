import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import '../services/api_service.dart';

class SettingsProvider with ChangeNotifier {
  String _baseUrl = 'http://localhost:3000';
  bool _isLoading = false;
  String? _error;

  String get baseUrl => _baseUrl;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSettings() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _baseUrl = await AppConfig.getBaseUrl();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateBaseUrl(String url) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await AppConfig.saveBaseUrl(url);
      await ApiService().updateBaseUrl(url);
      _baseUrl = url;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
