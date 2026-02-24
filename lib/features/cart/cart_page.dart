import 'package:ai4bmi/features/cart/cart_controller.dart';
import 'package:ai4bmi/features/navbar/navbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CartController());

    return Scaffold(
      backgroundColor: const Color(0xFFF0EBF8),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      'Mon Panier',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                  ],
                ),
              ),

              // Liste des articles
              Expanded(
                child: Obx(() {
                  if (controller.loading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: Color(0xFFF57C2B)),
                    );
                  }

                  final cart = controller.cart.value;

                  if (cart == null || cart.items.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_bag_outlined,
                              size: 80, color: Color(0xFFCCCCCC)),
                          SizedBox(height: 16),
                          Text(
                            'Votre panier est vide',
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

                  return ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: cart.items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
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
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: 80,
                                height: 80,
                                color: const Color(0xFFF4F4F8),
                                child: (item.product?.imageUrl != null &&
                                        item.product!.imageUrl!.isNotEmpty)
                                    ? Image.network(
                                        item.product!.imageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) =>
                                            const Icon(Icons.image_outlined,
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
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1A1A2E),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$ ${item.product?.price.toStringAsFixed(0) ?? '0'}',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFFF57C2B),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                      controller.removeItem(item.id),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.delete_outline,
                                        color: Colors.red, size: 18),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4F4F8),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () => controller.updateQuantity(
                                            item.id, item.quantity - 1),
                                        child: const Padding(
                                          padding: EdgeInsets.all(6),
                                          child: Icon(Icons.remove,
                                              size: 16,
                                              color: Color(0xFF444444)),
                                        ),
                                      ),
                                      Text(
                                        '${item.quantity}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF1A1A2E),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () => controller.updateQuantity(
                                            item.id, item.quantity + 1),
                                        child: const Padding(
                                          padding: EdgeInsets.all(6),
                                          child: Icon(Icons.add,
                                              size: 16,
                                              color: Color(0xFF444444)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),

              // Passer commande 
              Obx(() {
                final cart = controller.cart.value;
                if (cart == null || cart.items.isEmpty) return const SizedBox();

                final subtotal = cart.items.fold<double>(
                  0,
                  (sum, item) =>
                      sum + (item.product?.price ?? 0) * item.quantity,
                );

                return Container(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sous-total (${cart.items.length} articles)',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF6B6B8A),
                            ),
                          ),
                          Text(
                            '\$ ${subtotal.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFFF0F0F0)),
                      const SizedBox(height: 12),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              fontStyle: FontStyle.italic,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          Text(
                            '\$ ${subtotal.toStringAsFixed(0)}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: controller.checkout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF57C2B),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: const Text(
                            'Passer la commande',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}