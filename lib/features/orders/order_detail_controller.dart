import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ai4bmi/core/theme/app_theme.dart';
import 'package:ai4bmi/data/models/order_model.dart';
import 'package:ai4bmi/data/services/order_service.dart';
import 'package:ai4bmi/features/orders/orders_controller.dart';
import 'package:ai4bmi/features/orders/payment_webview_page.dart';

class OrderDetailController extends GetxController {
  final OrderService _orderService = OrderService();

  final loading = true.obs;
  final cancelling = false.obs;
  final openingPayment = false.obs;
  final order = Rx<OrderModel?>(null);

  final loadError = Rx<String?>(null);

  Timer? _paymentPollTimer;

  Future<void> loadOrder(int id) async {
    loading.value = true;
    loadError.value = null;
    try {
      final res = await _orderService.getOrder(id);
      if (res.success && res.data != null) {
        order.value = res.data;
      } else {
        order.value = null;
        loadError.value = res.message.isNotEmpty
            ? res.message
            : 'Impossible de charger la commande.';
      }
    } catch (_) {
      order.value = null;
      loadError.value = 'Impossible de charger la commande.';
    } finally {
      loading.value = false;
    }
  }

  Future<void> openPayment() async {
    final o = order.value;
    if (o == null || !o.isPending) return;
    openingPayment.value = true;
    try {
      final payRes = await _orderService.initPayment(o.id);
      if (payRes.success &&
          payRes.data != null &&
          payRes.data!.paymentUrl.isNotEmpty) {
        final callbackHit = await Get.to<bool>(
          () => PaymentWebViewPage(
            paymentUrl: payRes.data!.paymentUrl,
            orderId: o.id,
          ),
        );
        await loadOrder(o.id);
        final paidOrder = await _orderService.waitForOrderPaid(o.id);
        if (paidOrder != null) {
          _setPaidAndNotify(paidOrder);
        } else if (callbackHit == true) {
          _startPaymentPolling(o.id);
        } else {
          Get.snackbar(
            'Paiement annulé',
            'Vous pouvez réessayer quand vous voulez.',
            backgroundColor: AppTheme.snackbarWarning,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
      } else {
        Get.snackbar(
          'Erreur',
          payRes.message.isNotEmpty
              ? payRes.message
              : 'Impossible d\'ouvrir le paiement.',
          backgroundColor: AppTheme.snackbarError,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (_) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ouvrir le paiement.',
        backgroundColor: AppTheme.snackbarError,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      openingPayment.value = false;
    }
  }

  void _setPaidAndNotify(OrderModel paidOrder) {
    order.value = paidOrder;
    try {
      Get.find<OrdersController>().loadOrders();
    } catch (_) {}
    Get.snackbar(
      'Paiement effectué',
      'Votre commande a été enregistrée.',
      backgroundColor: AppTheme.snackbarSuccess,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
    );
  }

  void _startPaymentPolling(int orderId) {
    _paymentPollTimer?.cancel();
    _paymentPollTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final res = await _orderService.getOrder(orderId);
      if (res.success && res.data != null && res.data!.isPaid) {
        _paymentPollTimer?.cancel();
        _paymentPollTimer = null;
        _setPaidAndNotify(res.data!);
      }
    });
  }

  @override
  void onClose() {
    _paymentPollTimer?.cancel();
    super.onClose();
  }

  Future<void> cancelOrder() async {
    final o = order.value;
    if (o == null || !o.isPending) return;
    cancelling.value = true;
    try {
      final res = await _orderService.cancelOrder(o.id);
      if (res.success && res.data != null) {
        order.value = res.data;
        Get.snackbar(
          'Commande annulée',
          'La commande a été annulée.',
          backgroundColor: AppTheme.snackbarSuccess,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        Get.snackbar(
          'Erreur',
          res.message,
          backgroundColor: AppTheme.snackbarError,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      final msg = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Impossible d\'annuler.';
      Get.snackbar(
        'Erreur',
        msg.length > 80 ? 'Impossible d\'annuler la commande.' : msg,
        backgroundColor: AppTheme.snackbarError,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      cancelling.value = false;
    }
  }
}
