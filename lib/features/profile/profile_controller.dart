import 'dart:io';

import 'package:get/get.dart';

import 'package:ai4bmi/data/models/user_model.dart';
import 'package:ai4bmi/data/services/auth_service.dart';
import 'package:ai4bmi/routes/app_routes.dart';

class ProfileController extends GetxController {
  final AuthService _authService = AuthService();

  final loading = true.obs;
  final user = Rx<UserModel?>(null);
  final uploadingPhoto = false.obs;
  bool _loaded = false;

  @override
  void onReady() {
    super.onReady();
    if (!_loaded) {
      _loaded = true;
      loadUser();
    }
  }

  Future<void> loadUser() async {
    loading.value = true;
    try {
      final res = await _authService.getCurrentUser();
      if (res.success && res.data != null) {
        user.value = res.data;
      }
    } catch (_) {
      user.value = null;
    } finally {
      loading.value = false;
    }
  }

  Future<bool> uploadProfilePhoto(File file) async {
    uploadingPhoto.value = true;
    try {
      final res = await _authService.uploadProfilePhoto(file);
      if (res.success && res.data != null) {
        user.value = res.data;
        return true;
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      uploadingPhoto.value = false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    Get.offAllNamed(AppRoutes.login);
  }
}
