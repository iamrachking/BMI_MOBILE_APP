import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ai4bmi/features/auth/pending_reset_link.dart';
import 'package:ai4bmi/core/storage/onboarding_storage.dart';
import 'package:ai4bmi/core/storage/token_storage.dart';
import 'package:ai4bmi/core/theme/app_theme.dart';
import 'package:ai4bmi/routes/app_routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;

    if (PendingResetLink.hasData) {
      Get.offAllNamed(AppRoutes.login);
      Get.toNamed(AppRoutes.resetPassword);
      return;
    }

    final appLinks = AppLinks();
    Uri? initialUri;
    try {
      initialUri = await appLinks.getInitialLink();
    } catch (_) {}
    if (initialUri != null && PendingResetLink.isResetPasswordUri(initialUri)) {
      PendingResetLink.trySetFromUri(initialUri);
      if (PendingResetLink.hasData) {
        Get.offAllNamed(AppRoutes.login);
        Get.toNamed(AppRoutes.resetPassword);
        return;
      }
    }

    // Déjà connecté → accueil (même après fermeture et réouverture de l'app, le token est persisté).
    if (!OnboardingStorage.isDone) {
      Get.offAllNamed(AppRoutes.onboarding);
    } else if (TokenStorage.isLoggedIn) {
      Get.offAllNamed(AppRoutes.home);
    } else {
      Get.offAllNamed(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogo(),
              const SizedBox(height: 24),
              Text(
                'BMI SHOP',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pièces auto & moto',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(
        'assets/images/logo.png',
        width: 120,
        height: 120,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.directions_car,
            size: 56,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
