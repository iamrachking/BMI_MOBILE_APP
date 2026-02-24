import 'package:ai4bmi/core/network/api_client.dart';
import 'package:ai4bmi/data/models/api_response.dart';
import 'package:ai4bmi/data/models/category_model.dart';
import 'package:ai4bmi/data/models/product_model.dart';
import 'package:dio/dio.dart';

/// Catalogue
class ProductService {
  Dio get _dio => ApiClient.dio;

  /// Get all categories
  Future<ApiResponse<List<CategoryModel>>> getCategories({
    int perPage = 20,
    bool withProducts = false,
  }) async {
    final res = await _dio.get(
      '/categories',
      queryParameters: {
        'per_page': perPage,
        if (withProducts) 'with_products': 1,
      },
    );
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (d) {
        final List items = d is Map ? (d['data'] as List? ?? []) : (d as List);
        return items 
            .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  /// Get a specific category
  Future<ApiResponse<CategoryModel>> getCategory(int id) async {
    final res = await _dio.get('/categories/$id');
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (d) => CategoryModel.fromJson(d as Map<String, dynamic>),
    );
  }

  /// Get all products
  Future<ApiResponse<List<ProductModel>>> getProducts({
    int? categoryId,
    String? search,
    int perPage = 20,
    int page = 1,
  }) async {
    final q = <String, dynamic>{
      'per_page': perPage,
      'page': page,
    };
    if (categoryId != null) q['category_id'] = categoryId;
    if (search != null && search.isNotEmpty) q['search'] = search;
    final res = await _dio.get('/products', queryParameters: q);
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (d) {
        final List items = d is Map ? (d['data'] as List? ?? []) : (d as List);
        return items
            .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    );
  }

  /// Get a specific product
  Future<ApiResponse<ProductModel>> getProduct(int id) async {
    final res = await _dio.get('/products/$id');
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (d) => ProductModel.fromJson(d as Map<String, dynamic>),
    );
  }
}
