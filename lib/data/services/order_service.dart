import 'package:ai4bmi/core/network/api_client.dart';
import 'package:ai4bmi/data/models/api_response.dart';
import 'package:ai4bmi/data/models/order_model.dart';

/// Commandes
class OrderService {
  final _dio = ApiClient.dio;

  /// Get all orders
  Future<ApiResponse<List<OrderModel>>> getOrders({
    String? status,
    int perPage = 15,
  }) async {
    final q = <String, dynamic>{'per_page': perPage};
    if (status != null && status.isNotEmpty) q['status'] = status;
    final res = await _dio.get('/orders', queryParameters: q);
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (d) => (d as List)
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get a specific order
  Future<ApiResponse<OrderModel>> getOrder(int id) async {
    final res = await _dio.get('/orders/$id');
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (d) => OrderModel.fromJson(d as Map<String, dynamic>),
    );
  }

  /// Create an order
  Future<ApiResponse<OrderModel>> createOrder({
    String? shippingAddress,
    String? shippingPhone,
  }) async {
    final data = <String, dynamic>{};
    if (shippingAddress != null) data['shipping_address'] = shippingAddress;
    if (shippingPhone != null) data['shipping_phone'] = shippingPhone;
    final res = await _dio.post('/orders', data: data.isEmpty ? null : data);
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (d) => OrderModel.fromJson(d as Map<String, dynamic>),
    );
  }

  /// Initialize payment
  Future<ApiResponse<PaymentInitResponse>> initPayment(int orderId) async {
    final res = await _dio.post('/orders/$orderId/payment');
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (d) => PaymentInitResponse.fromJson(d as Map<String, dynamic>),
    );
  }

  /// Cancel an order
  Future<ApiResponse<OrderModel>> cancelOrder(int orderId) async {
    final res = await _dio.post('/orders/$orderId/cancel');
    return ApiResponse.fromJson(
      res.data as Map<String, dynamic>,
      (d) => OrderModel.fromJson(d as Map<String, dynamic>),
    );
  }
}

/// Payment initialization response
class PaymentInitResponse {
  final String paymentUrl;
  final String? token;
  final String? transactionId;

  PaymentInitResponse({
    required this.paymentUrl,
    this.token,
    this.transactionId,
  });

  factory PaymentInitResponse.fromJson(Map<String, dynamic> json) {
    return PaymentInitResponse(
      paymentUrl: json['payment_url'] as String,
      token: json['token'] as String?,
      transactionId: json['transaction_id'] as String?,
    );
  }
}
