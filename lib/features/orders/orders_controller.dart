import 'package:get/get.dart';

import 'package:ai4bmi/data/models/order_model.dart';
import 'package:ai4bmi/data/services/cart_service.dart';
import 'package:ai4bmi/data/services/order_service.dart';
import 'package:ai4bmi/routes/app_routes.dart';

class OrdersController extends GetxController {
  final OrderService _orderService = OrderService();
  final CartService _cartService = CartService();

  final loading = true.obs;
  final creating = false.obs;
  final orders = <OrderModel>[].obs;

  bool get isCheckout =>
      Get.arguments is Map && (Get.arguments as Map)['checkout'] == true;

  @override
  void onReady() {
    loadOrders();
    if (isCheckout) _tryCheckout();
    super.onReady();
  }

  Future<void> loadOrders() async {
    loading.value = true;
    try {
      final res = await _orderService.getOrders(perPage: 50);
      if (res.success && res.data != null) orders.value = res.data!;
    } catch (_) {
      orders.clear();
    } finally {
      loading.value = false;
    }
  }

  Future<void> _tryCheckout() async {
    creating.value = true;
    try {
      final res = await _orderService.createOrder();
      if (res.success && res.data != null) {
        await _cartService.getCart();
        final orderId = res.data!.id;
        final payRes = await _orderService.initPayment(orderId);
        if (payRes.success &&
            payRes.data != null &&
            payRes.data!.paymentUrl.isNotEmpty) {
          Get.snackbar('Paiement', 'Order #$orderId — WebView à intégrer');
          Get.offNamed(AppRoutes.orderDetail, arguments: orderId);
        } else {
          Get.snackbar('Erreur', payRes.message);
        }
      } else {
        Get.snackbar('Erreur', res.message);
      }
    } catch (_) {
      Get.snackbar('Erreur', 'Impossible de créer la commande');
    } finally {
      creating.value = false;
    }
  }

  void openOrder(int orderId) {
    Get.toNamed(AppRoutes.orderDetail, arguments: orderId);
  }
}
