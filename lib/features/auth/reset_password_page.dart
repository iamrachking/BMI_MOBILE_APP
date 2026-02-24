import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ai4bmi/config/api_config.dart';
import 'package:ai4bmi/core/theme/app_theme.dart';
import 'package:ai4bmi/features/auth/pending_reset_link.dart';
import 'package:ai4bmi/features/auth/auth_controller.dart';
import 'package:ai4bmi/features/auth/widgets/auth_accent.dart';
import 'package:ai4bmi/routes/app_routes.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  bool _fromEmailLink = false;

  @override
  void initState() {
    super.initState();
    _applyTokenAndEmailFromArgs();
    if (!_fromEmailLink) _fetchInitialLinkAndApply();
  }

  void _applyTokenAndEmailFromArgs() {
    if (PendingResetLink.hasData) {
      _emailController.text = PendingResetLink.email!;
      _tokenController.text = PendingResetLink.token!;
      _fromEmailLink = true;
      PendingResetLink.clear();
      return;
    }
    final args = Get.arguments as Map<String, String>?;
    if (args != null) {
      if (args['email'] != null && args['email']!.isNotEmpty) {
        _emailController.text = args['email']!;
      }
      if (args['token'] != null && args['token']!.isNotEmpty) {
        _tokenController.text = args['token']!;
      }
      _fromEmailLink =
          _emailController.text.isNotEmpty && _tokenController.text.isNotEmpty;
    }
  }

  Future<void> _fetchInitialLinkAndApply() async {
    Uri? uri;
    try {
      uri = await AppLinks().getInitialLink();
    } catch (_) {}
    if (uri == null || !mounted) {
      return;
    }
    final token = _extractTokenFromUri(uri);
    final email = uri.queryParameters['email'] ?? '';
    final isResetUri = _isResetPasswordUri(uri);
    if (isResetUri && token.isNotEmpty && email.isNotEmpty && mounted) {
      _emailController.text = email;
      _tokenController.text = token;
      _fromEmailLink = true;
      setState(() {});
    }
  }

  bool _isResetPasswordUri(Uri uri) {
    if (uri.scheme == 'bmi' && uri.host == 'reset-password') return true;
    if (uri.scheme != 'https' || uri.host != ApiConfig.resetPasswordHost) {
      return false;
    }
    return uri.path == ApiConfig.resetPasswordPath ||
        uri.path.startsWith('${ApiConfig.resetPasswordPath}/');
  }

  String _extractTokenFromUri(Uri uri) {
    final fromQuery =
        uri.queryParameters['token'] ??
        uri.queryParameters['reset_token'] ??
        uri.queryParameters['key'] ??
        '';
    if (fromQuery.isNotEmpty) {
      return fromQuery;
    }
    final segments = uri.pathSegments;
    if (segments.length >= 2 && segments[0] == 'reset-password') {
      return segments[1];
    }
    return '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
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
            const AuthAccent(position: AuthAccentPosition.bottomRight),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    'Nouveau mot de passe',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _fromEmailLink
                        ? 'Tout est prêt. Choisissez votre nouveau mot de passe (aucun code ni e-mail à saisir).'
                        : 'Saisissez le code reçu par e-mail et votre nouveau mot de passe.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF1F2937).withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 28),
                  if (!_fromEmailLink) ...[
                    _label('E-mail'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      decoration: _decoration('example@gmail.com'),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                    ),
                    const SizedBox(height: 16),
                    _label('Code de réinitialisation'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _tokenController,
                      decoration: _decoration('Collez le code reçu par e-mail'),
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                    ),
                    const SizedBox(height: 16),
                  ],
                  _label('Nouveau mot de passe'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    decoration: _decoration('••••••••').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                      ),
                    ),
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  _label('Confirmer le mot de passe'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordConfirmController,
                    decoration: _decoration('••••••••').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () =>
                            setState(() => _obscureConfirm = !_obscureConfirm),
                      ),
                    ),
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                  ),
                  Obx(() {
                    final error = auth.errorMessage.value;
                    if (error == null || error.isEmpty) {
                      return const SizedBox.shrink();
                    }
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
                      onPressed: auth.loading.value ? null : () => _reset(auth),
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
                          : const Text('Réinitialiser le mot de passe'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton(
                    onPressed: () => Get.offAllNamed(AppRoutes.login),
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

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w500,
        color: Color(0xFF1F2937),
      ),
    );
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  Future<void> _reset(AuthController auth) async {
    final email = _emailController.text.trim();
    final token = _tokenController.text.trim();
    final password = _passwordController.text;
    final confirm = _passwordConfirmController.text;
    if (email.isEmpty) {
      auth.errorMessage.value = 'Veuillez saisir votre e-mail';
      return;
    }
    if (token.isEmpty) {
      auth.errorMessage.value = 'Veuillez saisir le code de réinitialisation';
      return;
    }
    if (password.isEmpty) {
      auth.errorMessage.value = 'Veuillez saisir le nouveau mot de passe';
      return;
    }
    if (password != confirm) {
      auth.errorMessage.value = 'Les mots de passe ne correspondent pas';
      return;
    }
    final ok = await auth.resetPassword(
      email: email,
      token: token,
      password: password,
      passwordConfirmation: confirm,
    );
    if (ok && mounted) {
      Get.snackbar(
        'Mot de passe réinitialisé',
        'Vous pouvez maintenant vous connecter.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.primary.withValues(alpha: 0.95),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      );
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
