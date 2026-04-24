import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiClient {
  static const _baseUrl = 'http://10.0.2.2:5000/api/v1'; // use your server IP in production
  static final _storage = FlutterSecureStorage();

  static Dio get dio {
    final d = Dio(BaseOptions(baseUrl: _baseUrl, connectTimeout: Duration(seconds: 10)));
    d.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _storage.read(key: 'token');
        if (token != null) options.headers['Authorization'] = 'Bearer $token';
        handler.next(options);
      },
    ));
    return d;
  }
}
