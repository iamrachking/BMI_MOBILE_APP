import 'package:ai4bmi/data/models/product_model.dart';

/// Commande
class OrderModel {
  final int id;
  final double totalAmount;
  final String status;
  final String? shippingAddress;
  final String? shippingPhone;
  final String createdAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.id,
    required this.totalAmount,
    required this.status,
    this.shippingAddress,
    this.shippingPhone,
    required this.createdAt,
    required this.items,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as int,
      totalAmount: (json['total_amount'] is num)
          ? (json['total_amount'] as num).toDouble()
          : 0,
      status: json['status'] as String? ?? 'pending',
      shippingAddress: json['shipping_address'] as String?,
      shippingPhone: json['shipping_phone'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      items: json['items'] != null
          ? (json['items'] as List)
                .map((e) => OrderItemModel.fromJson(e as Map<String, dynamic>))
                .toList()
          : [],
    );
  }

  bool get isPending => status == 'pending';
  bool get isPaid => status == 'paid';
}

class OrderItemModel {
  final int id;
  final int productId;
  final int quantity;
  final double price;
  final double subtotal;
  final ProductModel? product;

  OrderItemModel({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.price,
    required this.subtotal,
    this.product,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as int,
      productId: json['product_id'] as int,
      quantity: json['quantity'] as int,
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0,
      subtotal: (json['subtotal'] is num)
          ? (json['subtotal'] as num).toDouble()
          : 0,
      product: json['product'] != null
          ? ProductModel.fromJson(json['product'] as Map<String, dynamic>)
          : null,
    );
  }
}
