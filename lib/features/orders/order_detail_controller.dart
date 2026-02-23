import 'package:get/get.dart';

import 'package:ai4bmi/data/models/order_model.dart';
import 'package:ai4bmi/data/services/order_service.dart';

class OrderDetailController extends GetxController {
  final OrderService _orderService = OrderService();

  final loading = true.obs;
  final cancelling = false.obs;
  final order = Rx<OrderModel?>(null);

  Future<void> loadOrder(int id) async {
    loading.value = true;
    try {
      final res = await _orderService.getOrder(id);
      if (res.success && res.data != null) {
        order.value = res.data;
      }
    } catch (_) {
      order.value = null;
    } finally {
      loading.value = false;
    }
  }

  Future<void> cancelOrder() async {
    final o = order.value;
    if (o == null || !o.isPending) return;
    cancelling.value = true;
    try {
      final res = await _orderService.cancelOrder(o.id);
      if (res.success && res.data != null) {
        order.value = res.data;
        Get.snackbar('OK', 'Commande annulée');
      } else {
        Get.snackbar('Erreur', res.message);
      }
    } catch (_) {
      Get.snackbar('Erreur', 'Impossible d\'annuler');
    } finally {
      cancelling.value = false;
    }
  }
}
