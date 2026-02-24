import 'package:ai4bmi/routes/app_routes.dart';
import 'package:get/get.dart';

import 'package:ai4bmi/data/models/user_model.dart';
import 'package:ai4bmi/data/services/auth_service.dart';


class ProfileController extends GetxController {
  final AuthService _authService = AuthService();

  final loading = true.obs;
  final user = Rx<UserModel?>(null);
  bool _loaded = false;

  @override
  void onReady() {
    super.onInit();
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
    } catch (e) {
      print('User error: $e');
      user.value = null;
    } finally {
      loading.value = false;
    }
  }

  Future<void> logout() async {
    // final auth = Get.find<AuthController>();
    // await auth.logout();
    await _authService.logout();
    Get.offAllNamed(AppRoutes.login);
  }
}
