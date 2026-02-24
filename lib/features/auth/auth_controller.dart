import 'package:ai4bmi/core/network/api_client.dart';
import 'package:get/get.dart';

import 'package:ai4bmi/core/storage/token_storage.dart';
import 'package:ai4bmi/data/services/auth_service.dart';
import 'package:ai4bmi/routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _auth = AuthService();

  final loading = false.obs;
  final errorMessage = Rx<String?>(null);

  Future<void> login(String email, String password) async {
    loading.value = true;
    errorMessage.value = null;
    try {
      final res = await _auth.login(email: email, password: password);
      if (res.success && res.data != null) {
        await ApiClient.setToken(res.data!.token);
        Get.offAllNamed(AppRoutes.home);
      } else {
        errorMessage.value = res.message;
      }
    } catch (e) {
      errorMessage.value = AuthService.getErrorMessage(e);
    } finally {
      loading.value = false;
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    String? phone,
    String? address,
  }) async {
    loading.value = true;
    errorMessage.value = null;
    try {
      final res = await _auth.register(
        name: name,
        email: email,
        password: password,
        passwordConfirmation: passwordConfirmation,
        phone: phone,
        address: address,
      );
      if (res.success && res.data != null) {
        Get.offAllNamed(AppRoutes.home);
      } else {
        errorMessage.value = res.message;
      }
    } catch (e) {
      errorMessage.value = AuthService.getErrorMessage(e);
    } finally {
      loading.value = false;
    }
  }

  Future<void> logout() async {
    await _auth.logout();
    Get.offAllNamed(AppRoutes.login);
  }

  /// Mot de passe oublié — envoi du lien par email
  Future<bool> forgotPassword(String email) async {
    loading.value = true;
    errorMessage.value = null;
    try {
      final res = await _auth.forgotPassword(email);
      if (res.success) return true;
      errorMessage.value = res.message;
      return false;
    } catch (e) {
      errorMessage.value = AuthService.getErrorMessage(e);
      return false;
    } finally {
      loading.value = false;
    }
  }

  /// Réinitialisation avec token reçu par email
  Future<bool> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    loading.value = true;
    errorMessage.value = null;
    try {
      final res = await _auth.resetPassword(
        email: email,
        token: token,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      if (res.success) return true;
      errorMessage.value = res.message;
      return false;
    } catch (e) {
      errorMessage.value = AuthService.getErrorMessage(e);
      return false;
    } finally {
      loading.value = false;
    }
  }

  /// Changer le mot de passe (utilisateur connecté)
  Future<bool> changePassword({
    required String currentPassword,
    required String password,
    required String passwordConfirmation,
  }) async {
    loading.value = true;
    errorMessage.value = null;
    try {
      final res = await _auth.changePassword(
        currentPassword: currentPassword,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      if (res.success) return true;
      errorMessage.value = res.message;
      return false;
    } catch (e) {
      errorMessage.value = AuthService.getErrorMessage(e);
      return false;
    } finally {
      loading.value = false;
    }
  }

  static bool get isLoggedIn => TokenStorage.isLoggedIn;
}
