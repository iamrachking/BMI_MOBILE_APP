import 'package:ai4bmi/data/models/product_model.dart';

/// Catégorie
class CategoryModel {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final int? productsCount;
  final List<ProductModel>? products;

  CategoryModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.productsCount,
    this.products,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      productsCount: json['products_count'] as int?,
      products: json['products'] != null
          ? (json['products'] as List)
                .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
    );
  }
}
