/// Référence légère à une catégorie dans produit
class CategoryRefModel {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;

  CategoryRefModel({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
  });

  factory CategoryRefModel.fromJson(Map<String, dynamic> json) {
    return CategoryRefModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
    );
  }
}
