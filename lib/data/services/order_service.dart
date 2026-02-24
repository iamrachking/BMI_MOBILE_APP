import 'package:ai4bmi/core/network/api_client.dart';
import 'package:ai4bmi/data/models/api_response.dart';
import 'package:ai4bmi/data/models/order_model.dart';
import 'package:dio/dio.dart';

/// Commandes
class OrderService {
  Dio get _dio => ApiClient.dio;

  /// Get all orders
  Future<ApiResponse<List<OrderModel>>> getOrders({
    String? status,
    int perPage = 15,
  }) async {
    final q = <String, dynamic>{'per_page': perPage};
    if (status != null && status.isNotEmpty) q['status'] = status;
    final res = await _dio.get('/orders', queryParameters: q);
    final body = res.data as Map<String, dynamic>;
    if (body['data'] is Map && body['data']['data'] is List) {
      body['data'] = body['data']['data'];
    }
    return ApiResponse.fromJson(
      body,
      (d) => (d as List)
          .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Get a specific order (GET /orders/{id}). Gère data imbriqué et erreurs.
  Future<ApiResponse<OrderModel>> getOrder(int id) async {
    try {
      final res = await _dio.get('/orders/$id');
      final body = res.data is Map<String, dynamic>
          ? Map<String, dynamic>.from(res.data as Map<String, dynamic>)
          : <String, dynamic>{};
      dynamic data = body['data'];
      if (data is Map && data.containsKey('data')) data = data['data'];
      if (data != null) body['data'] = data;
      return ApiResponse.fromJson(
        body,
        (d) => OrderModel.fromJson(d as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      final msg = (e.response?.data is Map)
          ? ((e.response!.data as Map)['message'] as String? ??
                'Impossible de charger la commande.')
          : 'Impossible de charger la commande.';
      return ApiResponse(success: false, message: msg);
    }
  }

  /// Create an order (POST /orders). 422 = panier vide ou stock insuffisant.
  Future<ApiResponse<OrderModel>> createOrder({
    String? shippingAddress,
    String? shippingPhone,
  }) async {
    final payload = <String, dynamic>{};
    if (shippingAddress != null) payload['shipping_address'] = shippingAddress;
    if (shippingPhone != null) payload['shipping_phone'] = shippingPhone;
    try {
      final res = await _dio.post(
        '/orders',
        data: payload.isEmpty ? null : payload,
      );
      final body = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : <String, dynamic>{};
      dynamic data = body['data'];
      if (data is Map && data.containsKey('data')) data = data['data'];
      if (data != null) body['data'] = data;
      return ApiResponse.fromJson(
        body,
        (d) => OrderModel.fromJson(d as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 422) {
        final msg = (e.response?.data is Map)
            ? ((e.response!.data as Map)['message'] as String? ??
                  'Panier vide ou stock insuffisant.')
            : 'Panier vide ou stock insuffisant.';
        return ApiResponse(success: false, message: msg);
      }
      return ApiResponse(
        success: false,
        message: (e.response?.data is Map)
            ? ((e.response!.data as Map)['message'] as String? ??
                  'Impossible de créer la commande.')
            : 'Impossible de créer la commande.',
      );
    }
  }

  /// Initialize payment (FedaPay sandbox). data peut être imbriqué.
  Future<ApiResponse<PaymentInitResponse>> initPayment(int orderId) async {
    try {
      final res = await _dio.post('/orders/$orderId/payment');
      final body = res.data is Map<String, dynamic>
          ? Map<String, dynamic>.from(res.data as Map<String, dynamic>)
          : <String, dynamic>{};
      dynamic data = body['data'];
      if (data is Map && data.containsKey('data')) data = data['data'];
      if (data != null) body['data'] = data;
      return ApiResponse.fromJson(
        body,
        (d) => PaymentInitResponse.fromJson(d as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      final msg = (e.response?.data is Map)
          ? ((e.response!.data as Map)['message'] as String? ??
                'Impossible d\'initier le paiement.')
          : 'Impossible d\'initier le paiement.';
      return ApiResponse(success: false, message: msg);
    }
  }

  /// Confirmer le paiement côté app (POST /orders/{id}/confirm-payment).
  /// À appeler quand l'app détecte un paiement réussi (ex. WebView avec status=approved).
  /// Le backend met le statut à « paid » sans intervention manuelle.
  Future<ApiResponse<OrderModel>> confirmPayment(int orderId) async {
    try {
      final res = await _dio.post('/orders/$orderId/confirm-payment');
      final body = res.data is Map<String, dynamic>
          ? Map<String, dynamic>.from(res.data as Map<String, dynamic>)
          : <String, dynamic>{};
      dynamic data = body['data'];
      if (data is Map && data.containsKey('data')) data = data['data'];
      if (data != null) body['data'] = data;
      return ApiResponse.fromJson(
        body,
        (d) => OrderModel.fromJson(d as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      final msg = (e.response?.data is Map)
          ? ((e.response!.data as Map)['message'] as String? ??
                'Impossible de confirmer le paiement.')
          : 'Impossible de confirmer le paiement.';
      return ApiResponse(success: false, message: msg);
    }
  }

  /// Attend que la commande passe en "paid" (webhook FedaPay), ou timeout.
  /// Retourne la commande si payée, null sinon.
  Future<OrderModel?> waitForOrderPaid(
    int orderId, {
    int maxAttempts = 20,
    Duration interval = const Duration(seconds: 2),
  }) async {
    for (var i = 0; i < maxAttempts; i++) {
      final res = await getOrder(orderId);
      if (res.success && res.data != null && res.data!.isPaid) {
        return res.data;
      }
      if (i < maxAttempts - 1) await Future<void>.delayed(interval);
    }
    return null;
  }

  /// Cancel an order (POST /orders/{id}/cancel). Gère data imbriqué et 422.
  Future<ApiResponse<OrderModel>> cancelOrder(int orderId) async {
    try {
      final res = await _dio.post('/orders/$orderId/cancel');
      final body = res.data is Map<String, dynamic>
          ? Map<String, dynamic>.from(res.data as Map<String, dynamic>)
          : <String, dynamic>{};
      dynamic data = body['data'];
      if (data is Map && data.containsKey('data')) data = data['data'];
      if (data != null) body['data'] = data;
      return ApiResponse.fromJson(
        body,
        (d) => OrderModel.fromJson(d as Map<String, dynamic>),
      );
    } on DioException catch (e) {
      final msg = (e.response?.data is Map)
          ? ((e.response!.data as Map)['message'] as String? ??
                'Impossible d\'annuler la commande.')
          : 'Impossible d\'annuler la commande.';
      return ApiResponse(success: false, message: msg);
    }
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
