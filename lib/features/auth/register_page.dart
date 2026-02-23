import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ai4bmi/core/theme/app_theme.dart';
import 'package:ai4bmi/features/auth/auth_controller.dart';
import 'package:ai4bmi/features/auth/widgets/social_buttons.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  bool _obscurePassword = true;
  bool _agreeTerms = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Créer un compte',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Remplissez vos informations ci-dessous ou inscrivez-vous avec votre compte social.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF1F2937).withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 28),
              _LabeledField(
                label: 'Nom et prénom',
                child: TextField(
                  controller: _nameController,
                  decoration: _inputDecoration('Ex. Jean Dupont'),
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(height: 16),
              _LabeledField(
                label: 'E-mail',
                child: TextField(
                  controller: _emailController,
                  decoration: _inputDecoration('exemple@gmail.com'),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autocorrect: false,
                ),
              ),
              const SizedBox(height: 16),
              _LabeledField(
                label: 'Mot de passe',
                child: TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF3F4F6),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                ),
              ),
              const SizedBox(height: 16),
              _LabeledField(
                label: 'Confirmer le mot de passe',
                child: TextField(
                  controller: _passwordConfirmController,
                  decoration: _inputDecoration('••••••••'),
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _agreeTerms,
                      onChanged: (v) =>
                          setState(() => _agreeTerms = v ?? false),
                      activeColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'J\'accepte les ',
                            style: TextStyle(
                              fontSize: 14,
                              color: const Color(
                                0xFF1F2937,
                              ).withValues(alpha: 0.8),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'Conditions générales',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppTheme.primary,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              Obx(() {
                final error = auth.errorMessage.value;
                if (error == null || error.isEmpty)
                  return const SizedBox.shrink();
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
              const SizedBox(height: 24),
              Obx(
                () => FilledButton(
                  onPressed: auth.loading.value ? null : () => _submit(auth),
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
                      : const Text('S\'inscrire'),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey.shade400)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Ou s\'inscrire avec',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey.shade400)),
                ],
              ),
              const SizedBox(height: 24),
              const SocialButtonsRow(),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Vous avez déjà un compte ? ',
                    style: TextStyle(
                      color: const Color(0xFF1F2937).withValues(alpha: 0.8),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Get.back(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Connexion',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  void _submit(AuthController auth) {
    if (!_agreeTerms) {
      auth.errorMessage.value = 'Veuillez accepter les conditions générales';
      return;
    }
    final n = _nameController.text.trim();
    final e = _emailController.text.trim();
    final p = _passwordController.text;
    final pc = _passwordConfirmController.text;
    if (n.isEmpty) {
      auth.errorMessage.value = 'Veuillez saisir votre nom';
      return;
    }
    if (e.isEmpty) {
      auth.errorMessage.value = 'Veuillez saisir votre e-mail';
      return;
    }
    if (p.isEmpty) {
      auth.errorMessage.value = 'Veuillez saisir un mot de passe';
      return;
    }
    if (p != pc) {
      auth.errorMessage.value = 'Les mots de passe ne correspondent pas';
      return;
    }
    auth.register(name: n, email: e, password: p, passwordConfirmation: pc);
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
