import 'package:ai4bmi/features/navbar/navbar.dart';
import 'package:ai4bmi/features/orders/order_detail_controller.dart';
import 'package:ai4bmi/features/orders/orders_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai4bmi/data/models/order_model.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OrdersController());

    return Scaffold(
      backgroundColor: const Color(0xFFF0EBF8),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFD8CCF0), Color(0xFFE8D8F0), Color(0xFFF0DCE8)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // AppBar
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.chevron_left,
                            color: Color(0xFF444444), size: 26),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Mes Commandes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ),

              // Liste de commandes 
              Expanded(
                child: Obx(() {
                  if (controller.loading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFF57C2B)),
                    );
                  }

                  if (controller.orders.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long_outlined,
                              size: 80, color: Color(0xFFCCCCCC)),
                          SizedBox(height: 16),
                          Text(
                            'Aucune commande pour l\'instant',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF888899),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: const Color(0xFFF57C2B),
                    onRefresh: controller.loadOrders,
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: controller.orders.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        return _OrderCard(
                          order: controller.orders[index],
                          onTap: () => controller
                              .openOrder(controller.orders[index].id),
                          onRefresh: controller.loadOrders,    
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Carte commande 

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback onTap;
  final VoidCallback? onRefresh;

  const _OrderCard({required this.order, required this.onTap, this.onRefresh,});

  Widget _statusBadge(String status) {
    Color color;
    IconData icon;
    String label;

    switch (status.toLowerCase()) {
      case 'delivered':
      case 'livree':
      case 'livrée':
        color = Colors.green;
        icon = Icons.location_on_outlined;
        label = 'Livrée';
        break;
      case 'transit':
      case 'en_transit':
      case 'shipped':
        color = const Color(0xFF7B2FBE);
        icon = Icons.inventory_2_outlined;
        label = 'En transit';
        break;
      case 'pending':
      case 'en_attente':
        color = const Color(0xFFF57C2B);
        icon = Icons.access_time_outlined;
        label = 'En attente';
        break;
      case 'cancelled':
      case 'annulee':
        color = Colors.red;
        icon = Icons.cancel_outlined;
        label = 'Annulée';
        break;
      default:
        color = const Color.fromARGB(255, 209, 209, 107);
        icon = Icons.help_outline;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = order.totalAmount;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ORD-${order.id}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    order.createdAt,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF888899),
                    ),
                  ),
                ],
              ),
              _statusBadge(order.status),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(color: Color.fromARGB(255, 1, 1, 1), height: 1),
          const SizedBox(height: 14),

          ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        width: 56,
                        height: 56,
                        color: const Color(0xFFF4F4F8),
                        child: (item.product?.imageUrl != null &&
                                item.product!.imageUrl!.isNotEmpty)
                            ? Image.network(
                                item.product!.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                    Icons.image_outlined,
                                    color: Color(0xFFCCCCCC)),
                              )
                            : const Icon(Icons.image_outlined,
                                color: Color(0xFFCCCCCC)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product?.name ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Quantité: ${item.quantity}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF888899),
                            ),
                          ),
                          Text(
                            '\$ ${item.price.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFF57C2B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF888899),
                    ),
                  ),
                  Text(
                    '\$ ${total.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 26, 26, 27),
                    ),
                  ),
                ],
              ),
              Row(
                children: [ 
  
                  if (order.isPending) ...[
                    Obx(() {
                      final detailCtrl = Get.put(
                        OrderDetailController(),
                        tag: 'order_${order.id}',
                      );
                      return GestureDetector(
                        onTap: () async {
                          final confirm = await Get.dialog<bool>(
                            AlertDialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              title: const Text('Annuler la commande',
                                  style: TextStyle(fontWeight: FontWeight.w800)),
                              content: const Text(
                                  'Voulez-vous vraiment annuler cette commande ?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Get.back(result: false),
                                  child: const Text('Non',
                                    style: TextStyle(color: Color(0xFF888899))),
                                ),
                                ElevatedButton(
                                  onPressed: () => Get.back(result: true),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12)),
                                  ),
                                  child: const Text('Oui',
                                    style: TextStyle(color: Colors.white)),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            detailCtrl.order.value = order;
                            await detailCtrl.cancelOrder();
                            onRefresh?.call(); 
                          }
                        },
                        child: detailCtrl.cancelling.value
                            ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.red),
                            )
                            : Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Text(
                                'Abandonner',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                      );
                    }),
                    const SizedBox(width: 8),

                    ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF57C2B),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Payer',
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                  ],

                  if (!order.isPending)
                    ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B2FBE),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Suivre ma commande',
                        style: TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
            ],
          ),
        ],
      ),  
    );
  }
}