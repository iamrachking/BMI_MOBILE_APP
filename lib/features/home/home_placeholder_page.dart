import 'package:flutter/material.dart';
import 'package:ai4bmi/core/theme/app_theme.dart';

class HomePlaceholderPage extends StatelessWidget {
  const HomePlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI'),
        backgroundColor: AppTheme.primary,
      ),
      body: const Center(
        child: Text('Accueil (écran à venir)'),
      ),
    );
  }
}
