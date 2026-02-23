import 'package:get/get.dart';

import 'package:ai4bmi/data/models/user_model.dart';
import 'package:ai4bmi/data/services/auth_service.dart';
import 'package:ai4bmi/features/auth/auth_controller.dart';

class ProfileController extends GetxController {
  final AuthService _authService = AuthService();

  final loading = true.obs;
  final user = Rx<UserModel?>(null);

  @override
  void onReady() {
    loadUser();
    super.onReady();
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

  Future<void> logout() async {
    final auth = Get.find<AuthController>();
    await auth.logout();
  }
}
