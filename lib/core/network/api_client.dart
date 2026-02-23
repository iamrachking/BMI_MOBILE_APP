import 'package:dio/dio.dart';

import 'package:ai4bmi/config/api_config.dart';
import 'package:ai4bmi/core/storage/token_storage.dart';

/// Client HTTP Dio : base URL + en-tête Authorization Bearer.
class ApiClient {
  ApiClient._();

  static Dio? _dio;

  static Dio get dio {
    _dio ??= _createDio();
    return _dio!;
  }

  static Dio _createDio() {
    final client = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    client.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = TokenStorage.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (err, handler) {
          if (err.response?.statusCode == 401) {
            TokenStorage.clearToken();
          }
          return handler.next(err);
        },
      ),
    );

    return client;
  }

  /// Appeler après login/register pour mettre à jour le token.
  static void setToken(String token) {
    TokenStorage.saveToken(token);
    _dio = _createDio();
  }

  /// Apres logout pour effacer le token.
  static Future<void> clearAuth() async {
    await TokenStorage.clearToken();
    _dio = _createDio();
  }
}
