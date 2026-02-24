import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ai4bmi/core/theme/app_theme.dart';
import 'package:ai4bmi/features/auth/auth_controller.dart';
import 'package:ai4bmi/features/auth/widgets/auth_accent.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Get.put(AuthController());

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Changer le mot de passe'),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            const AuthAccent(position: AuthAccentPosition.centerRight),
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    'Changer le mot de passe',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Saisissez votre mot de passe actuel et le nouveau mot de passe.',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF1F2937).withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _label('Mot de passe actuel'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _currentController,
                    decoration: _decoration('••••••••').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureCurrent
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () =>
                            setState(() => _obscureCurrent = !_obscureCurrent),
                      ),
                    ),
                    obscureText: _obscureCurrent,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  _label('Nouveau mot de passe'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _newController,
                    decoration: _decoration('••••••••').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureNew
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: Colors.grey.shade600,
                        ),
                        onPressed: () =>
                            setState(() => _obscureNew = !_obscureNew),
                      ),
                    ),
                    obscureText: _obscureNew,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  _label('Confirmer le nouveau mot de passe'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _confirmController,
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
                      onPressed: auth.loading.value
                          ? null
                          : () => _change(auth),
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
                          : const Text('Changer le mot de passe'),
                    ),
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

  Future<void> _change(AuthController auth) async {
    final current = _currentController.text;
    final newPwd = _newController.text;
    final confirm = _confirmController.text;
    if (current.isEmpty) {
      auth.errorMessage.value = 'Veuillez saisir votre mot de passe actuel';
      return;
    }
    if (newPwd.isEmpty) {
      auth.errorMessage.value = 'Veuillez saisir le nouveau mot de passe';
      return;
    }
    if (newPwd != confirm) {
      auth.errorMessage.value = 'Les mots de passe ne correspondent pas';
      return;
    }
    final ok = await auth.changePassword(
      currentPassword: current,
      password: newPwd,
      passwordConfirmation: confirm,
    );
    if (ok && mounted) {
      Get.snackbar(
        'Mot de passe mis à jour',
        'Votre mot de passe a bien été modifié.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppTheme.primary.withValues(alpha: 0.95),
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 12,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      );
      Get.back();
    }
  }
}
