import 'package:ai4bmi/data/models/product_model.dart';

/// Panier
class CartModel {
  final int id;
  final int itemsCount;
  final double subtotal;
  final List<CartItemModel> items;

  CartModel({
    required this.id,
    required this.itemsCount,
    required this.subtotal,
    required this.items,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    return CartModel(
      id: json['id'] as int? ?? 0,
      itemsCount: json['items_count'] as int? ?? 0,
      subtotal: (json['subtotal'] is num)
          ? (json['subtotal'] as num).toDouble()
          : 0,
      items: json['items'] != null
          ? (json['items'] as List)
                .map((e) => CartItemModel.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
    );
  }
}

class CartItemModel {
  final int id;
  final int productId;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final ProductModel? product;

  CartItemModel({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.product,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as int? ?? 0,
      productId: json['product_id'] as int? ?? 0,
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: (json['unit_price'] is num)
          ? (json['unit_price'] as num).toDouble()
          : 0,
      subtotal: (json['subtotal'] is num)
          ? (json['subtotal'] as num).toDouble()
          : 0,
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'] as Map<String, dynamic>)
          : null,
    );
  }
}
