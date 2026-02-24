import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ai4bmi/data/models/product_model.dart';
import 'package:ai4bmi/data/services/cart_service.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductModel? product = Get.arguments as ProductModel?;
  final CartService _cartService = CartService();

  int quantity = 1;
  bool addingToCart = false;

  void _increment() => setState(() => quantity++);
  void _decrement() {
    if (quantity > 1) setState(() => quantity--);
  }

  Future<void> _addToCart() async {
    setState(() => addingToCart = true);
    try {
      final res = await _cartService.addItem(
        productId: product!.id,
        quantity: quantity,
      );
      if (res.success) {
        Get.snackbar(
          'Panier',
          '${product!.name} ajouté au panier',
          backgroundColor: const Color(0xFFF57C2B),
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        Get.snackbar('Erreur', res.message);
      }
    } catch (e) {
      Get.snackbar('Erreur', 'Impossible d\'ajouter au panier');
    } finally {
      setState(() => addingToCart = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (product == null) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
    }
    return Scaffold(
      backgroundColor: const Color(0xFFF0EBF8),
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
              //AppBar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _CircleBtn(
                      icon: Icons.chevron_left,
                      onTap: () => Get.back(),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: (product!.imageUrl != null &&
                                  product!.imageUrl!.isNotEmpty)
                              ? Image.network(
                                  product!.imageUrl!,
                                  fit: BoxFit.contain,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.image_outlined,
                                    size: 80,
                                    color: Color(0xFFCCCCCC),
                                  ),
                                )
                              : const Icon(
                                  Icons.image_outlined,
                                  size: 80,
                                  color: Color(0xFFCCCCCC),
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      //Fiche produit
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'BMI',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF888899),
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: product!.inStock
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    product!.inStock ? 'En stock' : 'Rupture',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: product!.inStock
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),
                            Text(
                              product!.name,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                fontStyle: FontStyle.italic,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),

                            const SizedBox(height: 10),

                            Text(
                              '\$ ${product!.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFF57C2B),
                              ),
                            ),

                            const SizedBox(height: 16),
                            const Divider(color: Color(0xFFF0F0F0)),
                            const SizedBox(height: 16),

                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1A1A2E),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              product!.description ?? '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B6B8A),
                                height: 1.6,
                              ),
                            ),

                            const SizedBox(height: 16),

                            if (product!.category != null)
                              Row(
                                children: [
                                  const Text(
                                    'Catégorie : ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF1A1A2E),
                                    ),
                                  ),
                                  Text(
                                    product!.category!.name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF7B2FBE),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),

              // ── Ajout au panier
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF4F4F8),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: _decrement,
                            icon: const Icon(Icons.remove, size: 18),
                            color: const Color(0xFF444444),
                          ),
                          Text(
                            '$quantity',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A2E),
                            ),
                          ),
                          IconButton(
                            onPressed: _increment,
                            icon: const Icon(Icons.add, size: 18),
                            color: const Color(0xFF444444),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed:
                              (product!.inStock && !addingToCart) ? _addToCart : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF57C2B),
                            disabledBackgroundColor:
                                const Color(0xFFF57C2B).withOpacity(0.4),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(32),
                            ),
                          ),
                          child: addingToCart
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Ajouter au panier',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
        child: Icon(icon, color: const Color(0xFF444444), size: 22),
      ),
    );
  }
}