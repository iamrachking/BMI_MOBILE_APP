import 'package:get/get.dart';

import 'package:ai4bmi/data/models/cart_model.dart';
import 'package:ai4bmi/data/services/cart_service.dart';
import 'package:ai4bmi/routes/app_routes.dart';

class CartController extends GetxController {
  final CartService _cartService = CartService();

  final loading = true.obs;
  final cart = Rx<CartModel?>(null);

  @override
  void onReady() {
    loadCart();
    super.onReady();
  }

  Future<void> loadCart() async {
    loading.value = true;
    try {
      final res = await _cartService.getCart();
      if (res.success && res.data != null) cart.value = res.data;
    } catch (_) {
      cart.value = null;
    } finally {
      loading.value = false;
    }
  }

  Future<void> updateQuantity(int cartItemId, int quantity) async {
    if (quantity < 1) return;
    try {
      final res = await _cartService.updateItemQuantity(cartItemId, quantity);
      if (res.success && res.data != null) cart.value = res.data;
    } catch (_) {}
  }

  Future<void> removeItem(int cartItemId) async {
    try {
      final res = await _cartService.removeItem(cartItemId);
      if (res.success && res.data != null) cart.value = res.data;
    } catch (_) {}
  }

  Future<void> clearCart() async {
    try {
      final res = await _cartService.clearCart();
      if (res.success && res.data != null) cart.value = res.data;
    } catch (_) {}
  }

  void checkout() {
    if (cart.value == null || cart.value!.items.isEmpty) {
      Get.snackbar('Panier vide', 'Ajoutez des articles pour commander');
      return;
    }
    Get.toNamed(AppRoutes.orders, arguments: {'checkout': true});
  }
}
