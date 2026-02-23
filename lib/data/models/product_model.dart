import 'package:ai4bmi/data/models/category_ref_model.dart';

/// Produit
class ProductModel {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int stockQuantity;
  final bool inStock;
  final String? imageUrl;
  final CategoryRefModel? category;
  final int? categoryId;

  ProductModel({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.stockQuantity,
    required this.inStock,
    this.imageUrl,
    this.category,
    this.categoryId,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      price: (json['price'] is num) ? (json['price'] as num).toDouble() : 0,
      stockQuantity: json['stock_quantity'] as int? ?? 0,
      inStock: json['in_stock'] as bool? ?? true,
      imageUrl: json['image_url'] as String?,
      category: json['category'] != null
          ? CategoryRefModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      categoryId: json['category_id'] as int?,
    );
  }
}
