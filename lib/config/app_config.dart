import '../utils/token_storage.dart';

class AppConfig {
  static const String defaultBaseUrl = 'http://47.103.151.220:3001';
  static const String _baseUrlKey = 'base_url';
  static const String _languageKey = 'app_language';
  static const String defaultLanguage = 'zh';

  static Future<String> getBaseUrl() async {
    final box = TokenStorage.box;
    return box.get(_baseUrlKey, defaultValue: defaultBaseUrl);
  }

  static Future<void> saveBaseUrl(String url) async {
    final box = TokenStorage.box;
    await box.put(_baseUrlKey, url);
  }

  static Future<String> getLanguage() async {
    final box = TokenStorage.box;
    return box.get(_languageKey, defaultValue: defaultLanguage);
  }

  static Future<void> saveLanguage(String lang) async {
    final box = TokenStorage.box;
    await box.put(_languageKey, lang);
  }

  static Future<void> clearCache() async {
    final box = TokenStorage.box;
    // 保留base_url和language，清除其他缓存
    final baseUrl = box.get(_baseUrlKey, defaultValue: defaultBaseUrl);
    final language = box.get(_languageKey, defaultValue: defaultLanguage);
    await box.clear();
    await box.put(_baseUrlKey, baseUrl);
    await box.put(_languageKey, language);
  }
}
