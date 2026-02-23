import 'package:ai4bmi/core/network/api_client.dart';
import 'package:ai4bmi/data/models/api_response.dart';
import 'package:ai4bmi/data/models/cart_model.dart';

/// Panier
class CartService {
  final _dio = ApiClient.dio;

  /// Get cart
  Future<ApiResponse<CartModel>> getCart() async {
    final res = await _dio.get('/cart');
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
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
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
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
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (d) => CartModel.fromJson(d as Map<String, dynamic>),
    );
  }

  /// Remove item from cart
  Future<ApiResponse<CartModel>> removeItem(int cartItemId) async {
    final res = await _dio.delete('/cart/items/$cartItemId');
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (d) => CartModel.fromJson(d as Map<String, dynamic>),
    );
  }
}
