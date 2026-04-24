import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../core/api/api_client.dart';
import '../../core/models/models.dart';

class AuthProvider extends ChangeNotifier {
  final _storage = const FlutterSecureStorage();
  UserModel? user;
  bool isLoading = false;
  String? error;

  Future<({bool success, bool isNew})> phoneLogin(String phone, String otp, {String? name}) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final res = await ApiClient.dio.post('/auth/phone-login', data: {
        'phone': phone,
        'otp': otp,
        if (name != null) 'name': name,
      });
      await _storage.write(key: 'token', value: res.data['token']);
      user = UserModel.fromJson(res.data['user']);
      return (success: true, isNew: res.data['isNew'] as bool);
    } catch (e) {
      error = 'Invalid OTP';
      return (success: false, isNew: false);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({String? name, String? phone, String? imageUrl}) async {
    isLoading = true;
    error = null;
    notifyListeners();
    try {
      final res = await ApiClient.dio.put('/users/me', data: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (imageUrl != null) 'imageUrl': imageUrl,
      });
      user = UserModel.fromJson(res.data);
      return true;
    } catch (_) {
      error = 'Update failed';
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

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
    if (token == null) return false;
    try {
      final res = await ApiClient.dio.get('/users/me');
      user = UserModel.fromJson(res.data);
      notifyListeners();
    } catch (_) {}
    return true;
  }
}
