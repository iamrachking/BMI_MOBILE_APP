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

    if (body['data'] is Map && body['data']['data'] is Map) {
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

  /// Add item to cart. En cas de 422 (stock insuffisant), retourne success: false avec message clair.
  Future<ApiResponse<CartModel>> addItem({
    required int productId,
    int quantity = 1,
  }) async {
    try {
      final res = await _dio.post(
        '/cart/items',
        data: {'product_id': productId, 'quantity': quantity},
      );
      final body = res.data as Map<String, dynamic>;
      if (body['data'] is Map && body['data']['data'] is Map) {
        body['data'] = body['data']['data'];
      }
      return ApiResponse.fromJson(
        body,
        (d) => CartModel.fromJson(d as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final msg = _extractMessage(e.response?.data);
        final stockMsg =
            msg.toLowerCase().contains('stock') ||
            msg.toLowerCase().contains('épuisé') ||
            msg.toLowerCase().contains('insuffisant') ||
            msg.toLowerCase().contains('disponible');
        return ApiResponse<CartModel>(
          success: false,
          message: stockMsg
              ? 'Stock insuffisant. La quantité demandée n\'est plus disponible.'
              : (msg.isNotEmpty
                    ? msg
                    : 'Stock insuffisant. La quantité demandée n\'est plus disponible.'),
        );
      }
      rethrow;
    }
  }

  /// Update item quantity. En cas de 422 (stock insuffisant), retourne success: false avec message clair.
  Future<ApiResponse<CartModel>> updateItemQuantity(
    int cartItemId,
    int quantity,
  ) async {
    try {
      final res = await _dio.patch(
        '/cart/items/$cartItemId',
        data: {'quantity': quantity},
      );
      final body = res.data as Map<String, dynamic>;
      if (body['data'] is Map && body['data']['data'] is Map) {
        body['data'] = body['data']['data'];
      }
      return ApiResponse.fromJson(
        body,
        (d) => CartModel.fromJson(d as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        return ApiResponse<CartModel>(
          success: false,
          message:
              'Stock insuffisant. La quantité demandée n\'est plus disponible.',
        );
      }
      rethrow;
    }
  }

  static String _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String? ?? '';
    }
    if (data is Map && data['message'] != null) {
      return data['message'].toString();
    }
    return '';
  }

  /// Remove item from cart
  Future<ApiResponse<CartModel>> removeItem(int cartItemId) async {
    final res = await _dio.delete('/cart/items/$cartItemId');
    final body = res.data as Map<String, dynamic>;

    if (body['data'] is Map && body['data']['data'] is Map) {
      body['data'] = body['data']['data'];
    }
    return ApiResponse.fromJson(
      body,
      (d) => CartModel.fromJson(d as Map<String, dynamic>),
    );
  }
}
