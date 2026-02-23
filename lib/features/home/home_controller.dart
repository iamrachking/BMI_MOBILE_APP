import 'package:get/get.dart';

import 'package:ai4bmi/routes/app_routes.dart';

class HomeController extends GetxController {
  void goToCatalog() => Get.toNamed(AppRoutes.catalog);
  void goToCart() => Get.toNamed(AppRoutes.cart);
  void goToOrders() => Get.toNamed(AppRoutes.orders);
  void goToProfile() => Get.toNamed(AppRoutes.profile);
}
