import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:ai4bmi/core/theme/app_theme.dart';
import 'package:ai4bmi/data/services/order_service.dart';

/// Ouvre l'URL FedaPay (sandbox) dans une WebView.
/// Quand FedaPay redirige vers le callback avec status=approved, on appelle
/// POST /orders/{id}/confirm-payment pour mettre le statut à « payé » puis on ferme avec [true].
class PaymentWebViewPage extends StatefulWidget {
  const PaymentWebViewPage({
    super.key,
    required this.paymentUrl,
    required this.orderId,
  });

  final String paymentUrl;
  final int orderId;

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _successHandled = false;
  final OrderService _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _loading = true),
          onPageFinished: (url) {
            setState(() => _loading = false);
            _checkCallbackUrl(url);
          },
          onWebResourceError: (error) => setState(() => _loading = false),
          onNavigationRequest: (request) {
            _checkCallbackUrl(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  /// Dès que FedaPay redirige avec status=approved : appeler confirm-payment puis fermer.
  /// Ainsi le statut passe à « payé » sans intervention manuelle dans le backoffice.
  Future<void> _checkCallbackUrl(String url) async {
    if (!url.contains('status=approved') || _successHandled) return;
    _successHandled = true;
    await _orderService.confirmPayment(widget.orderId);
    if (!mounted) return;
    Get.back(result: true);
  }

  @override
  Widget build(BuildContext context) {
    // Retour système = annulation (false), pas succès.
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) Get.back(result: false);
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1F2937),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1F2937),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white),
            onPressed: () => Get.back(result: false),
          ),
          title: const Text(
            'Paiement FedaPay',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_loading)
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: AppTheme.primary),
                    SizedBox(height: 16),
                    Text(
                      'Chargement du paiement...',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
