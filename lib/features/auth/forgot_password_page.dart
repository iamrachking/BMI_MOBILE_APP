import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ai4bmi/core/theme/app_theme.dart';
import 'package:ai4bmi/features/auth/auth_controller.dart';
import 'package:ai4bmi/features/auth/widgets/auth_accent.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.put(AuthController());

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF1F2937),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            const AuthAccent(position: AuthAccentPosition.bottomLeft),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Mot de passe oublié',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1F2937),
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Saisissez votre e-mail et nous vous enverrons un lien pour réinitialiser votre mot de passe.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF1F2937).withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'E-mail',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'example@gmail.com',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF3F4F6),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    autocorrect: false,
                  ),
                  Obx(() {
                    final error = auth.errorMessage.value;
                    if (error == null || error.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Text(
                        error,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 13,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 28),
                  Obx(
                    () => FilledButton(
                      onPressed: auth.loading.value ? null : () => _send(auth),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: auth.loading.value
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Envoyer le lien'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                    ),
                    child: const Text('Retour à la connexion'),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _send(AuthController auth) async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      auth.errorMessage.value = 'Veuillez saisir votre e-mail';
      return;
    }
    auth.errorMessage.value = null;
    final ok = await auth.forgotPassword(email);
    if (!mounted) return;
    if (ok) {
      // Afficher le snackbar en haut, bien visible
      _showSuccessSnackbar(email);
      // Laisser le temps de lire le message puis rediriger vers la connexion
      await Future.delayed(const Duration(milliseconds: 2500));
      if (mounted) Get.back();
    }
  }

  void _showSuccessSnackbar(String email) {
    Get.snackbar(
      'E-mail envoyé',
      'Un e-mail a été envoyé à $email. Consultez votre boîte de réception (et les spams) pour le lien de réinitialisation.',
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppTheme.primary.withValues(alpha: 0.95),
      colorText: Colors.white,
      margin: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 16),
      borderRadius: 12,
      duration: const Duration(seconds: 5),
      icon: const Icon(Icons.mark_email_read_outlined, color: Colors.white),
      shouldIconPulse: true,
      mainButton: TextButton(
        onPressed: () => Get.closeCurrentSnackbar(),
        child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
