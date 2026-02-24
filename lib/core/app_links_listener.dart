import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:get/get.dart';

import 'package:ai4bmi/features/auth/pending_reset_link.dart';
import 'package:ai4bmi/routes/app_routes.dart';

/// Écoute les liens (ex. clic bouton mail en arrière-plan) et relance le flux via le splash.
class AppLinksListener {
  AppLinksListener._();

  static StreamSubscription? _subscription;

  static void start() {
    _subscription?.cancel();
    _subscription = AppLinks().uriLinkStream.listen((Uri? uri) {
      if (uri == null) return;
      if (!PendingResetLink.isResetPasswordUri(uri)) return;
      PendingResetLink.trySetFromUri(uri);
      if (!PendingResetLink.hasData) return;
      Get.offAllNamed(AppRoutes.splash);
    });
  }

  static void stop() {
    _subscription?.cancel();
    _subscription = null;
  }
}
