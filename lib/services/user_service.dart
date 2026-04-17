import '../constants/api_constants.dart';
import '../models/user.dart';
import 'api_service.dart';

class UserService {
  final ApiService _apiService = ApiService();

  Future<List<User>> getUsers() async {
    final response = await _apiService.dio.get(ApiConstants.users);

    if (response.statusCode == 200) {
      final List<dynamic> data = response.data;
      return data.map((json) => User.fromJson(json)).toList();
    }

    throw Exception('Failed to load users');
  }

  Future<User> getUser(int id) async {
    final response = await _apiService.dio.get('${ApiConstants.users}/$id');

    if (response.statusCode == 200) {
      return User.fromJson(response.data);
    }

    throw Exception('Failed to load user');
  }

  Future<User> createUser({
    required String username,
    required String password,
    required String role,
  }) async {
    final response = await _apiService.dio.post(
      ApiConstants.users,
      data: {
        'username': username,
        'password': password,
        'role': role,
      },
    );

    if (response.statusCode == 201) {
      return User.fromJson(response.data);
    }

    throw Exception('Failed to create user');
  }

  Future<User> updateUser(
    int id, {
    String? username,
    String? password,
    String? role,
  }) async {
    final data = <String, dynamic>{};
    if (username != null) data['username'] = username;
    if (password != null) data['password'] = password;
    if (role != null) data['role'] = role;

    final response = await _apiService.dio.put(
      '${ApiConstants.users}/$id',
      data: data,
    );

    if (response.statusCode == 200) {
      return User.fromJson(response.data);
    }

    throw Exception('Failed to update user');
  }

  Future<void> deleteUser(int id) async {
    final response = await _apiService.dio.delete('${ApiConstants.users}/$id');

    if (response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }
}
