import 'package:hive/hive.dart';

class UserStorage {
  static const String _boxName = 'user_storage';
  static const String _keySavedUsers = 'saved_users';

  static Future<Box> _getBox() async {
    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox(_boxName);
    }
    return Hive.box(_boxName);
  }

  static Future<List<String>> getSavedUsers() async {
    try {
      final box = await _getBox();
      final dynamic users = box.get(_keySavedUsers);
      if (users is List) {
        return users.cast<String>();
      }
      return [];
    } catch (e) {
      print('Failed to get saved users: $e');
      return [];
    }
  }

  static Future<void> saveUser(String username) async {
    try {
      final box = await _getBox();
      final List<String> users = await getSavedUsers();

      if (!users.contains(username)) {
        users.add(username);
        await box.put(_keySavedUsers, users);
      }
    } catch (e) {
      print('Failed to save user: $e');
    }
  }

  static Future<void> removeUser(String username) async {
    try {
      final box = await _getBox();
      final List<String> users = await getSavedUsers();
      users.remove(username);
      await box.put(_keySavedUsers, users);
    } catch (e) {
      print('Failed to remove user: $e');
    }
  }
}
