import 'package:ai4bmi/core/network/api_client.dart';
import 'package:ai4bmi/data/models/api_response.dart';
import 'package:ai4bmi/data/models/cart_model.dart';
import 'package:dio/dio.dart';

/// Panier
class CartService {
  Dio get _dio => ApiClient.dio;

  /// Get cart
  Future<ApiResponse<CartModel>> getCart() async {
    final res = await _dio.get('/cart');
    final body = res.data as Map<String, dynamic>;

    if(body['data'] is Map && body['data']['data'] is Map) {
      body['data'] = body['data']['data'];
    } 
    return ApiResponse.fromJson(
      body,
      (d) => CartModel.fromJson(d as Map<String, dynamic>),
    );
  }

  /// Clear cart
  Future<ApiResponse<CartModel>> clearCart() async {
    final res = await _dio.delete('/cart');
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (d) => CartModel.fromJson(d as Map<String, dynamic>),
    );
  }

  /// Add item to cart
  Future<ApiResponse<CartModel>> addItem({
    required int productId,
    int quantity = 1,
  }) async {
    final res = await _dio.post(
      '/cart/items',
      data: {'product_id': productId, 'quantity': quantity},
    );
    final body = res.data as Map<String, dynamic>;

    if(body['data'] is Map && body['data']['data'] is Map) {
      body['data'] = body['data']['data'];
    } 

    return ApiResponse.fromJson(
      body,
      (d) => CartModel.fromJson(d as Map<String, dynamic>),
    );
  }

  /// Update item quantity
  Future<ApiResponse<CartModel>> updateItemQuantity(
    int cartItemId,
    int quantity,
  ) async {
    final res = await _dio.patch(
      '/cart/items/$cartItemId',
      data: {'quantity': quantity},
    );
    final body = res.data as Map<String, dynamic>;

    if(body['data'] is Map && body['data']['data'] is Map) {
      body['data'] = body['data']['data'];
    } 
    return ApiResponse.fromJson(
      body,
      (d) => CartModel.fromJson(d as Map<String, dynamic>),
    );
  }

  /// Remove item from cart
  Future<ApiResponse<CartModel>> removeItem(int cartItemId) async {
    final res = await _dio.delete('/cart/items/$cartItemId');
    final body = res.data as Map<String, dynamic>;

    if(body['data'] is Map && body['data']['data'] is Map) {
      body['data'] = body['data']['data'];
    } 
    return ApiResponse.fromJson(
      body,
      (d) => CartModel.fromJson(d as Map<String, dynamic>),
    );
  }
}
