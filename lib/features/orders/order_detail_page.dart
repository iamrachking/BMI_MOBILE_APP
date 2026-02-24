import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ai4bmi/core/theme/app_theme.dart';
import 'package:ai4bmi/data/models/order_model.dart';
import 'package:ai4bmi/features/orders/order_detail_controller.dart';

class OrderDetailPage extends StatefulWidget {
  const OrderDetailPage({super.key});

  @override
  State<OrderDetailPage> createState() => _OrderDetailPageState();
}

class _OrderDetailPageState extends State<OrderDetailPage> {
  int? _orderId;

  static String _formatDate(String iso) {
    if (iso.isEmpty) return '—';
    try {
      final d = DateTime.tryParse(iso);
      if (d == null) return iso;
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year} à ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    if (args is int) {
      _orderId = args;
      final controller = Get.put(
        OrderDetailController(),
        tag: 'order_detail_$args',
      );
      controller.loadOrder(args);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_orderId == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          backgroundColor: AppTheme.background,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Get.back(),
            color: const Color(0xFF1F2937),
          ),
        ),
        body: const Center(
          child: Text(
            'Commande introuvable',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
          ),
        ),
      );
    }

    final controller = Get.find<OrderDetailController>(
      tag: 'order_detail_$_orderId',
    );

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
          color: const Color(0xFF1F2937),
        ),
        title: Text(
          'Commande #$_orderId',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F2937),
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary),
          );
        }
        final order = controller.order.value;
        if (order == null) {
          final err =
              controller.loadError.value ??
              'Impossible de charger la commande.';
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    err,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade700, fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: () => controller.loadOrder(_orderId!),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Réessayer'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _StatusCard(order: order, formatDate: _formatDate),
              const SizedBox(height: 16),
              _AddressCard(order: order),
              const SizedBox(height: 16),
              _ItemsCard(order: order),
              const SizedBox(height: 16),
              _TotalCard(order: order),
              if (order.isPending) ...[
                const SizedBox(height: 24),
                Obx(() {
                  if (controller.openingPayment.value) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: CircularProgressIndicator(
                          color: AppTheme.primary,
                        ),
                      ),
                    );
                  }
                  return SizedBox(
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: controller.openPayment,
                      icon: const Icon(Icons.payment_rounded, size: 22),
                      label: const Text(
                        'Payer avec FedaPay (Mobile Money)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 12),
                Obx(
                  () => controller.cancelling.value
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: AppTheme.primary,
                          ),
                        )
                      : SizedBox(
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () => _confirmCancel(controller),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Annuler la commande',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Future<void> _confirmCancel(OrderDetailController controller) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Annuler la commande',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'Voulez-vous vraiment annuler cette commande ? Le stock sera recrédité.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text(
              'Non',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Oui, annuler',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
    if (confirm == true) await controller.cancelOrder();
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.order, required this.formatDate});

  final OrderModel order;
  final String Function(String) formatDate;

  static ({Color color, IconData icon, String label}) _style(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return (
          color: const Color(0xFF059669),
          icon: Icons.check_circle_rounded,
          label: 'Payée',
        );
      case 'shipped':
        return (
          color: AppTheme.primary,
          icon: Icons.local_shipping_rounded,
          label: 'Expédiée',
        );
      case 'pending':
        return (
          color: const Color(0xFFD97706),
          icon: Icons.schedule_rounded,
          label: 'En attente de paiement',
        );
      case 'cancelled':
        return (
          color: Colors.red,
          icon: Icons.cancel_rounded,
          label: 'Annulée',
        );
      default:
        return (
          color: const Color(0xFF6B7280),
          icon: Icons.help_outline_rounded,
          label: status,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = _style(order.status);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: s.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(s.icon, size: 28, color: s.color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  s.label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: s.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatDate(order.createdAt),
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on_rounded,
                size: 20,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Livraison',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            order.shippingAddress ?? '—',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF1F2937),
              height: 1.4,
            ),
          ),
          if (order.shippingPhone != null &&
              order.shippingPhone!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.phone_rounded,
                  size: 16,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 6),
                Text(
                  order.shippingPhone!,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ItemsCard extends StatelessWidget {
  const _ItemsCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.shopping_bag_rounded,
                size: 20,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Articles (${order.items.length})',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...order.items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 56,
                      height: 56,
                      color: AppTheme.background,
                      child:
                          (item.product?.imageUrl != null &&
                              item.product!.imageUrl!.isNotEmpty)
                          ? Image.network(
                              item.product!.imageUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.image_outlined,
                                color: Colors.grey.shade400,
                              ),
                            )
                          : Icon(
                              Icons.image_outlined,
                              color: Colors.grey.shade400,
                            ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.product?.name ?? 'Produit #${item.productId}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Qté: ${item.quantity} × ${item.price.toStringAsFixed(0)} F',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${item.subtotal.toStringAsFixed(0)} F',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalCard extends StatelessWidget {
  const _TotalCard({required this.order});

  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total à payer',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F2937),
            ),
          ),
          Text(
            '${order.totalAmount.toStringAsFixed(0)} F',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}
