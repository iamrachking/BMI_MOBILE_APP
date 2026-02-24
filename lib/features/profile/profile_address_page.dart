import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:ai4bmi/core/theme/app_theme.dart';
import 'package:ai4bmi/data/services/auth_service.dart';
import 'package:ai4bmi/features/profile/profile_controller.dart';

/// Écran pour gérer l'adresse de livraison (et le téléphone) du profil.
/// Utilise PATCH /user (address, phone) selon la doc API.
class ProfileAddressPage extends StatefulWidget {
  const ProfileAddressPage({super.key});

  @override
  State<ProfileAddressPage> createState() => _ProfileAddressPageState();
}

class _ProfileAddressPageState extends State<ProfileAddressPage> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = Get.find<ProfileController>().user.value;
    if (user != null) {
      _addressController.text = user.address ?? '';
      _phoneController.text = user.phone ?? '';
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _saving) return;
    setState(() => _saving = true);
    try {
      final res = await _authService.updateProfile(
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
      );
      if (res.success) {
        final controller = Get.find<ProfileController>();
        if (res.data != null) {
          controller.user.value = res.data;
        } else {
          await controller.loadUser();
        }
        if (!mounted) return;
        Get.back();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Get.snackbar(
            'Enregistré',
            'Adresse et téléphone mis à jour.',
            backgroundColor: AppTheme.snackbarSuccess,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        });
      } else {
        Get.snackbar(
          'Erreur',
          res.message.isNotEmpty ? res.message : 'Impossible d\'enregistrer.',
          backgroundColor: AppTheme.snackbarError,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      final msg = e is Exception
          ? e.toString().replaceFirst('Exception: ', '')
          : 'Impossible d\'enregistrer.';
      Get.snackbar(
        'Erreur',
        msg.length > 60 ? 'Impossible d\'enregistrer.' : msg,
        backgroundColor: AppTheme.snackbarError,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Get.back(),
          color: const Color(0xFF1F2937),
        ),
        title: const Text(
          'Mon adresse',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Adresse de livraison utilisée pour les commandes (et optionnellement pour le profil).',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Adresse',
                  hintText: 'Ex. Cotonou, quartier ...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                maxLines: 3,
                onSaved: (v) {},
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: 'Téléphone',
                  hintText: 'Ex. 66123456',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Enregistrer',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
