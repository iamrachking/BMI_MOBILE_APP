import 'dart:io';

import 'package:dio/dio.dart';

import 'package:ai4bmi/core/network/api_client.dart';
import 'package:ai4bmi/core/storage/token_storage.dart';
import 'package:ai4bmi/data/models/api_response.dart';
import 'package:ai4bmi/data/models/auth_data_model.dart';
import 'package:ai4bmi/data/models/user_model.dart';

/// Authentification
class AuthService {
  Dio get _dio => ApiClient.dio;

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
    final body = res.data as Map<String, dynamic>;

    if (body['data'] is Map && (body['data'] as Map).containsKey('data')) {
      body['data'] = body['data']['data'];
    }
    return ApiResponse.fromJson(
      body,
      (d) => UserModel.fromJson(d as Map<String, dynamic>),
    );
  }

  /// Update profile (PATCH /user). Gère réponses imbriquées et erreurs Dio.
  Future<ApiResponse<UserModel>> updateProfile({
    String? name,
    String? email,
    String? phone,
    String? address,
  }) async {
    final payload = <String, dynamic>{};
    if (name != null) payload['name'] = name;
    if (email != null) payload['email'] = email;
    if (phone != null) payload['phone'] = phone;
    if (address != null) payload['address'] = address;
    try {
      final res = await _dio.patch('/user', data: payload);
      final body = res.data is Map<String, dynamic>
          ? Map<String, dynamic>.from(res.data as Map<String, dynamic>)
          : <String, dynamic>{};
      dynamic data = body['data'];
      if (data is Map) {
        if (data.containsKey('data')) data = data['data'];
        if (data.containsKey('user')) data = data['user'];
        body['data'] = data;
      }
      return ApiResponse.fromJson(
        body,
        (d) => UserModel.fromJson(d as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      final data = e.response?.data;
      String message = 'Impossible d\'enregistrer.';
      if (data is Map<String, dynamic>) {
        message =
            data['message'] as String? ??
            (data['errors'] is Map
                ? (data['errors'] as Map).values
                      .expand((v) => v is List ? v : [v])
                      .join(', ')
                : message);
      }
      return ApiResponse(success: false, message: message);
    } catch (e) {
      return ApiResponse(
        success: false,
        message: e.toString().contains('type') || e.toString().length > 80
            ? 'Impossible d\'enregistrer.'
            : e.toString(),
      );
    }
  }

  /// Mot de passe oublié : réponse 200 = succès (même si le body n'a pas success: true)
  Future<ApiResponse<void>> forgotPassword(String email) async {
    final res = await _dio.post('/forgot-password', data: {'email': email});
    final data = res.data is Map<String, dynamic>
        ? res.data as Map<String, dynamic>
        : <String, dynamic>{};
    final success = data['success'] as bool? ?? true;
    final message =
        data['message'] as String? ??
        'Si un compte existe avec cet e-mail, un lien de réinitialisation a été envoyé.';
    return ApiResponse(success: success, message: message);
  }

  /// Réinitialiser le mot de passe
  Future<ApiResponse<void>> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    final res = await _dio.post(
      '/password/reset',
      data: {
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, (_) {});
  }

  /// Changer le mot de passe
  Future<ApiResponse<void>> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    final res = await _dio.patch(
      '/user/password',
      data: {
        'current_password': currentPassword,
        'password': password,
        'password_confirmation': passwordConfirmation,
      },
    );
    return ApiResponse.fromJson(res.data as Map<String, dynamic>, (_) {});
  }

  /// Upload profile photo (POST /user/photo, multipart)
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
    final body = res.data as Map<String, dynamic>;
    if (body['data'] is Map && (body['data'] as Map).containsKey('data')) {
      body['data'] = (body['data'] as Map)['data'];
    }
    return ApiResponse.fromJson(
      body,
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
