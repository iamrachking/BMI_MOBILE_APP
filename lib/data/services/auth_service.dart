import 'dart:io';

import 'package:dio/dio.dart';

import 'package:ai4bmi/core/network/api_client.dart';
import 'package:ai4bmi/core/storage/token_storage.dart';
import 'package:ai4bmi/data/models/api_response.dart';
import 'package:ai4bmi/data/models/auth_data_model.dart';
import 'package:ai4bmi/data/models/user_model.dart';

/// Authentification
class AuthService {
  final _dio = ApiClient.dio;

  /// Register
  Future<ApiResponse<AuthDataModel>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? address,
  }) async {
    final res = await _dio.post(
      '/register',
      data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': passwordConfirmation,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (address != null && address.isNotEmpty) 'address': address,
      },
    );
    final api = ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (d) => AuthDataModel.fromJson(d as Map<String, dynamic>),
    );
    if (api.success && api.data != null) {
      ApiClient.setToken(api.data!.token);
      await TokenStorage.saveToken(api.data!.token);
    }
    return api;
  }

  /// Login
  Future<ApiResponse<AuthDataModel>> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post(
      '/login',
      data: {'email': email, 'password': password},
    );
    final api = ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (d) => AuthDataModel.fromJson(d as Map<String, dynamic>),
    );
    if (api.success && api.data != null) {
      ApiClient.setToken(api.data!.token);
      await TokenStorage.saveToken(api.data!.token);
    }
    return api;
  }

  /// Logout
  Future<ApiResponse<void>> logout() async {
    try {
      await _dio.post('/logout');
    } catch (_) {}
    await ApiClient.clearAuth();
    return ApiResponse(success: true, message: 'Déconnecté');
  }

  /// Get current user
  Future<ApiResponse<UserModel>> getCurrentUser() async {
    final res = await _dio.get('/user');
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (d) => UserModel.fromJson(d as Map<String, dynamic>),
    );
  }

  /// Update profile
  Future<ApiResponse<UserModel>> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? address,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;
    if (phone != null) data['phone'] = phone;
    if (address != null) data['address'] = address;
    final res = await _dio.patch('/user', data: data);
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (d) => UserModel.fromJson(d as Map<String, dynamic>),
    );
  }

  /// Upload profile photo
  Future<ApiResponse<UserModel>> uploadProfilePhoto(File photo) async {
    final formData = FormData.fromMap({
      'photo': await MultipartFile.fromFile(
        photo.path,
        filename: photo.path.split(RegExp(r'[/\\]')).last,
      ),
    });
    final res = await _dio.post(
      '/user/photo',
      data: formData,
      options: Options(
        contentType: 'multipart/form-data',
        headers: {'Accept': 'application/json'},
      ),
    );
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (d) => UserModel.fromJson(d as Map<String, dynamic>),
    );
  }

  static String? getErrorMessage(dynamic e) {
    if (e is DioException && e.response?.data is Map) {
      final d = e.response!.data as Map<String, dynamic>;
      return d['message'] as String? ?? 'Erreur réseau';
    }
    return 'Erreur réseau';
  }
}
