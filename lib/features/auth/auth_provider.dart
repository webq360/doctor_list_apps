import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/api/api_client.dart';
import '../../core/models/models.dart';

class AuthProvider extends ChangeNotifier {
  final _storage = FlutterSecureStorage();
  UserModel? user;
  bool isLoading = false;
  String? error;

  Future<bool> login(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final res = await ApiClient.dio.post('/auth/login', data: {'email': email, 'password': password});
      await _storage.write(key: 'token', value: res.data['token']);
      user = UserModel.fromJson(res.data['user']);
      return true;
    } catch (e) {
      error = 'Invalid credentials';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String name, String email, String phone, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final res = await ApiClient.dio.post('/auth/register', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
      });
      await _storage.write(key: 'token', value: res.data['token']);
      user = UserModel.fromJson(res.data['user']);
      return true;
    } catch (e) {
      error = 'Registration failed';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'token');
    user = null;
    notifyListeners();
  }

  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'token');
    return token != null;
  }
}
