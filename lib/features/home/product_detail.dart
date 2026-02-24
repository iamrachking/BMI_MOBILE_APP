import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ai4bmi/core/theme/app_theme.dart';
import 'package:ai4bmi/data/models/product_model.dart';
import 'package:ai4bmi/data/services/cart_service.dart';
import 'package:ai4bmi/routes/app_routes.dart';

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
    if (product == null || addingToCart) return;
    if (!product!.inStock) {
      Get.snackbar(
        'Stock épuisé',
        'Ce produit n\'est plus disponible pour le moment.',
        backgroundColor: AppTheme.snackbarWarning,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
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
          backgroundColor: AppTheme.primary,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      } else {
        final isStock =
            res.message.toLowerCase().contains('stock') ||
            res.message.toLowerCase().contains('épuisé') ||
            res.message.toLowerCase().contains('disponible') ||
            res.message.toLowerCase().contains('insuffisant');
        Get.snackbar(
          isStock ? 'Stock épuisé' : 'Erreur',
          isStock
              ? 'La quantité demandée n\'est plus disponible.'
              : res.message,
          backgroundColor: isStock
              ? AppTheme.snackbarWarning
              : AppTheme.snackbarError,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'ajouter au panier.',
        backgroundColor: AppTheme.snackbarError,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      setState(() => addingToCart = false);
    }
  }

  static String _formatPrice(double price) {
    final s = price.toStringAsFixed(0);
    return s.replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+\b)'), (m) => '${m[1]} ');
  }

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    final priceStr = '${_formatPrice(product!.price)} F';
    const darkGrey = Color(0xFF1F2937);
    const midGrey = Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
          color: darkGrey,
        ),
        title: Text(
          product!.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppTheme.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductCard(context, priceStr, darkGrey, midGrey),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    String priceStr,
    Color darkGrey,
    Color midGrey,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: double.infinity,
              height: 280,
              child:
                  (product!.imageUrl != null && product!.imageUrl!.isNotEmpty)
                  ? Image.network(
                      product!.imageUrl!,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) => _placeholder(),
                    )
                  : _placeholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product!.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Catégorie: ${product!.category?.name ?? '—'}',
                    style: TextStyle(fontSize: 14, color: midGrey),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      ...List.generate(
                        5,
                        (i) => Icon(
                          i < 4 ? Icons.star_rounded : Icons.star_half_rounded,
                          color: Colors.amber.shade600,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        '5/5',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF374151),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (product!.inStock)
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 18,
                          color: Colors.green.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'En Stock',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(Icons.schedule_rounded, size: 18, color: midGrey),
                        const SizedBox(width: 6),
                        Text(
                          'Plus que ${product!.stockQuantity} en stock !',
                          style: TextStyle(fontSize: 13, color: midGrey),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 10,
                          color: midGrey,
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 18,
                          color: Colors.red.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Rupture de stock',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.red.shade700,
                          ),
                        ),
                      ],
                    ),
                  if (product!.description != null &&
                      product!.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product!.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: midGrey,
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              priceStr,
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1F2937),
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildQuantitySelector(),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton.icon(
                            onPressed: (product!.inStock && !addingToCart)
                                ? _addToCart
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primary,
                              disabledBackgroundColor: AppTheme.primary
                                  .withValues(alpha: 0.4),
                              foregroundColor: Colors.white,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: addingToCart
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(
                                    Icons.shopping_cart_rounded,
                                    size: 22,
                                  ),
                            label: Text(
                              addingToCart ? 'Ajout...' : 'Ajouter au panier',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 52,
                          child: OutlinedButton.icon(
                            onPressed: product!.inStock
                                ? () => Get.toNamed(AppRoutes.cart)
                                : null,
                            style: OutlinedButton.styleFrom(
                              foregroundColor: darkGrey,
                              side: BorderSide(
                                color: darkGrey.withValues(alpha: 0.5),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.bolt_rounded, size: 20),
                            label: const Text(
                              'Acheter maintenant',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 18,
                        color: midGrey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Payer en 3x ou 4x sans frais',
                        style: TextStyle(fontSize: 12, color: midGrey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _featureIcon(Icons.shield_rounded, 'Garantie 2 ans'),
                      _featureIcon(
                        Icons.local_shipping_rounded,
                        'Livraison Express',
                      ),
                      _featureIcon(Icons.lock_rounded, 'Paiement Sécurisé'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1F2937).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: _decrement,
            icon: const Icon(Icons.remove_rounded, size: 20),
            color: const Color(0xFF1F2937),
          ),
          SizedBox(
            width: 32,
            child: Text(
              '$quantity',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
          ),
          IconButton(
            onPressed: _increment,
            icon: const Icon(Icons.add_rounded, size: 20),
            color: const Color(0xFF1F2937),
          ),
        ],
      ),
    );
  }

  Widget _featureIcon(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 28, color: AppTheme.primary.withValues(alpha: 0.9)),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF6B7280),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _placeholder() {
    return Center(
      child: Icon(Icons.image_outlined, size: 80, color: Colors.grey.shade400),
    );
  }
}
