import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ai4bmi/core/theme/app_theme.dart';
import 'package:ai4bmi/data/models/order_model.dart';
import 'package:ai4bmi/data/services/cart_service.dart';
import 'package:ai4bmi/data/services/order_service.dart';
import 'package:ai4bmi/features/orders/order_detail_controller.dart';
import 'package:ai4bmi/features/orders/payment_webview_page.dart';
import 'package:ai4bmi/features/profile/profile_controller.dart';
import 'package:ai4bmi/routes/app_routes.dart';

class OrdersController extends GetxController {
  final OrderService _orderService = OrderService();
  final CartService _cartService = CartService();

  final loading = true.obs;
  final creating = false.obs;
  final cancellingOrderId = Rxn<int>();
  final orders = <OrderModel>[].obs;

  Timer? _checkoutPollTimer;

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
      String? address;
      String? phone;
      try {
        final profile = Get.find<ProfileController>().user.value;
        address = profile?.address;
        phone = profile?.phone;
      } catch (_) {}
      final res = await _orderService.createOrder(
        shippingAddress: address,
        shippingPhone: phone,
      );
      if (res.success && res.data != null) {
        final orderId = res.data!.id;
        final payRes = await _orderService.initPayment(orderId);
        if (payRes.success &&
            payRes.data != null &&
            payRes.data!.paymentUrl.isNotEmpty) {
          final callbackHit = await Get.to<bool>(
            () => PaymentWebViewPage(
              paymentUrl: payRes.data!.paymentUrl,
              orderId: orderId,
            ),
          );
          await _cartService.getCart();
          Get.offNamed(AppRoutes.orderDetail, arguments: orderId);
          final paidOrder = await _orderService.waitForOrderPaid(orderId);
          if (paidOrder != null) {
            _updateDetailAndNotify(orderId, paidOrder);
          } else if (callbackHit == true) {
            _startCheckoutPolling(orderId);
          } else {
            Get.snackbar(
              'Paiement annulé',
              'Vous pouvez payer plus tard depuis le détail de la commande.',
              backgroundColor: AppTheme.snackbarWarning,
              colorText: Colors.white,
              snackPosition: SnackPosition.TOP,
            );
          }
        } else {
          _snackbarError(
            payRes.message.isNotEmpty
                ? payRes.message
                : 'Impossible d\'ouvrir le paiement.',
          );
        }
      } else {
        _snackbarError(
          res.message.isNotEmpty
              ? res.message
              : 'Impossible de créer la commande.',
        );
      }
    } catch (_) {
      _snackbarError('Impossible de créer la commande.');
    } finally {
      creating.value = false;
    }
  }

  void _snackbarError(String msg) {
    Get.snackbar(
      'Erreur',
      msg,
      backgroundColor: AppTheme.snackbarError,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  void _updateDetailAndNotify(int orderId, OrderModel paidOrder) {
    try {
      final detail = Get.find<OrderDetailController>(
        tag: 'order_detail_$orderId',
      );
      detail.order.value = paidOrder;
    } catch (_) {}
    loadOrders();
    Get.snackbar(
      'Paiement effectué',
      'Votre commande #$orderId a été enregistrée.',
      backgroundColor: AppTheme.snackbarSuccess,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  void _startCheckoutPolling(int orderId) {
    _checkoutPollTimer?.cancel();
    _checkoutPollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final res = await _orderService.getOrder(orderId);
      if (res.success && res.data != null && res.data!.isPaid) {
        _checkoutPollTimer?.cancel();
        _checkoutPollTimer = null;
        _updateDetailAndNotify(orderId, res.data!);
      }
    });
  }

  @override
  void onClose() {
    _checkoutPollTimer?.cancel();
    super.onClose();
  }

  void openOrder(int orderId) {
    Get.toNamed(
      AppRoutes.orderDetail,
      arguments: orderId,
    )?.then((_) => loadOrders());
  }

  Future<void> cancelOrder(int orderId) async {
    cancellingOrderId.value = orderId;
    try {
      final res = await _orderService.cancelOrder(orderId);
      if (res.success) {
        await loadOrders();
        Get.snackbar(
          'Commande annulée',
          'La commande a été annulée.',
          backgroundColor: AppTheme.snackbarSuccess,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        _snackbarError(res.message);
      }
    } catch (_) {
      _snackbarError('Impossible d\'annuler la commande.');
    } finally {
      cancellingOrderId.value = null;
    }
  }

  /// Ouvre la WebView FedaPay pour une commande pending. Retourne true si l'utilisateur a terminé le flux (callback).
  Future<bool?> openPayment(int orderId) async {
    final payRes = await _orderService.initPayment(orderId);
    if (!payRes.success ||
        payRes.data == null ||
        payRes.data!.paymentUrl.isEmpty) {
      _snackbarError(
        payRes.message.isNotEmpty
            ? payRes.message
            : 'Impossible d\'ouvrir le paiement.',
      );
      return null;
    }
    return Get.to<bool>(
      () => PaymentWebViewPage(
        paymentUrl: payRes.data!.paymentUrl,
        orderId: orderId,
      ),
    );
  }
}
